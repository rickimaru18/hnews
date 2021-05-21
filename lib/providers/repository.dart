import 'dart:async';
import 'dart:developer';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:hnews/models/news.dart';
import 'package:hnews/repositories/hive_db.dart';
import 'package:hnews/repositories/rss_service.dart';
import 'package:hnews/utils/logger.dart';
import 'package:uuid/uuid.dart';

class Repository {
  Repository() {
    _init();
  }

  final HiveDB _hiveDB = HiveDB();

  final ReceivePort _receivePort = ReceivePort();

  final Map<String, SendPort> _isolateSendPorts = <String, SendPort>{};
  final Map<String, StreamController<News>> _newsStreams =
      <String, StreamController<News>>{};

  final Completer<void> _initCompleter = Completer<void>();

  /// Setup.
  Future<void> _init() async {
    _receivePort.listen(_messageHandler);
    await _hiveDB.isInitComplete;
    _initCompleter.complete();
  }

  /// Check if [Repository] initialization is done.
  Future<void> get _isInitComplete => _initCompleter.future;

  /// Message handler for messages from isolate.
  Future<void> _messageHandler(dynamic message) async {
    final _IsolateMessage isolateMessage = message as _IsolateMessage;
    logger('Repository', 'MAIN ISOLATE: $message');

    if (isolateMessage.args is SendPort) {
      _isolateSendPorts[isolateMessage.key] = isolateMessage.args! as SendPort;
      _isolateSendPorts[isolateMessage.key]!.send(
        _IsolateActions.SUBSCRIBE_NEWS,
      );
    } else if (isolateMessage.args is News) {
      final News news = isolateMessage.args! as News;
      news.isBookmarked = await isBookmarked(news);
      _newsStreams[isolateMessage.key]?.add(news);
    }
  }

  /// Get news.
  Future<Stream<News>> getNews(String rssUrl) async {
    await _isInitComplete;

    final _IsolateMessage message = _IsolateMessage(
      const Uuid().v1(),
      <String, dynamic>{
        'sendPort': _receivePort.sendPort,
        'rssUrl': rssUrl,
      },
    );
    final Isolate isolate = await Isolate.spawn(_setupIsolate, message);
    final StreamController<News> streamController = StreamController<News>();

    _newsStreams[message.key] = streamController;
    streamController.onCancel = () {
      _isolateSendPorts[message.key]?.send(_IsolateActions.UNSUBSCRIBE_NEWS);
      _isolateSendPorts.remove(message.key);
      _newsStreams.remove(message.key);
      isolate.kill();
    };

    return streamController.stream;
  }

  /// Get bookmarked news.
  Future<List<News>> getBookmarkedNews() async {
    await _isInitComplete;
    return _hiveDB.bookmarks;
  }

  /// Check if [news] is bookmarked.
  Future<bool> isBookmarked(News news) async {
    await _isInitComplete;
    return _hiveDB.isBookmarked(news);
  }

  /// Bookmark [news] and save to database.
  Future<void> bookmarkNews(News news) async {
    await _isInitComplete;
    return _hiveDB.bookmark(news);
  }

  /// Bookmark [news] and remove from database.
  Future<void> unbookmarkNews(News news) async {
    await _isInitComplete;
    return _hiveDB.unbookmark(news);
  }

  /// Listen to bookmarks box changes.
  Future<void> listenToBookmarks(VoidCallback callback) async {
    await _isInitComplete;
    return _hiveDB.listenToBookmarks(callback);
  }

  /// Unlisten to bookmarks box changes.
  Future<void> unlistenToBookmarks(VoidCallback callback) async {
    await _isInitComplete;
    return _hiveDB.unlistenToBookmarks(callback);
  }

  /// Reorder bookmarks.
  Future<void> reorderBookmarks(List<News> newsList) async {
    await _isInitComplete;
    return _hiveDB.reorderBookmarks(newsList);
  }
}

//------------------------------------------------------------------------------
enum _IsolateActions {
  SUBSCRIBE_NEWS,
  UNSUBSCRIBE_NEWS,
}

//------------------------------------------------------------------------------
class _IsolateMessage {
  const _IsolateMessage(this.key, this.args);

  final String key;
  final Object? args;

  @override
  String toString() => '$key: $args';
}

//------------------------------------------------------------------------------
/// Repository isolate.
Future<void> _setupIsolate(dynamic message) async {
  final _IsolateMessage isolateMessage = message as _IsolateMessage;
  final Map<String, dynamic> args =
      isolateMessage.args! as Map<String, dynamic>;
  final ReceivePort isolateReceivePort = ReceivePort();

  final RssService rssService = RssService();
  final Uri rssUri = Uri.parse(args['rssUrl'] as String);

  SendPort? mainIsolateSendPort;
  StreamSubscription<News>? newsSubscription;

  isolateReceivePort.listen((dynamic message) async {
    log(
      'ISOLATE (${isolateMessage.key}): $message',
      name: 'Repository ISOLATE',
    );

    switch (message) {
      case _IsolateActions.SUBSCRIBE_NEWS:
        await newsSubscription?.cancel();
        newsSubscription = rssService.getNews(rssUri).listen((News news) {
          mainIsolateSendPort?.send(_IsolateMessage(isolateMessage.key, news));
        });
        break;

      case _IsolateActions.UNSUBSCRIBE_NEWS:
        await newsSubscription?.cancel();
        newsSubscription = null;
        break;

      default:
        log(
          'ISOLATE (${isolateMessage.key}): Message, $message, not supported.',
          name: 'Repository ISOLATE',
        );
        break;
    }
  });

  if (args['sendPort'] is SendPort) {
    mainIsolateSendPort = args['sendPort'] as SendPort;
    mainIsolateSendPort.send(_IsolateMessage(
      isolateMessage.key,
      isolateReceivePort.sendPort,
    ));
    return;
  }
}
