import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hnews/models/news.dart';

class HiveDB {
  HiveDB() {
    _init();
  }

  final Completer<void> _initCompleter = Completer<void>();

  late final Box<News> _bookmarksBox;
  late final ValueListenable<Box<News>> _listenableBookmarksBox;

  /// Setup.
  Future<void> _init() async {
    await Hive.initFlutter();

    final NewsAdapter newsAdapter = NewsAdapter();
    if (!Hive.isAdapterRegistered(newsAdapter.typeId)) {
      Hive.registerAdapter<News>(newsAdapter);
    }

    _bookmarksBox = await Hive.openBox<News>('bookmarks');
    _listenableBookmarksBox = _bookmarksBox.listenable();
    _initCompleter.complete();
  }

  /// Check if [HiveDB] initialization is done.
  Future<void> get isInitComplete => _initCompleter.future;

  /// Get bookmarked news.
  List<News> get bookmarks {
    final List<News> bookmarkedNews = _bookmarksBox.values.toList();

    bookmarkedNews.sort((News news1, News news2) => news2.index - news1.index);

    return bookmarkedNews;
  }

  /// Check if [news] is bookmarked.
  bool isBookmarked(News news) => _bookmarksBox.containsKey(news.key);

  /// Bookmark [news].
  Future<void> bookmark(News news) {
    news.index = _bookmarksBox.length;
    return _bookmarksBox.put(news.key, news);
  }

  /// Unbookmark [news].
  Future<void> unbookmark(News news) => _bookmarksBox.delete(news.key);

  /// Listen to bookmarks box changes.
  void listenToBookmarks(VoidCallback callback) =>
      _listenableBookmarksBox.addListener(callback);

  /// Unlisten to bookmarks box changes.
  void unlistenToBookmarks(VoidCallback callback) =>
      _listenableBookmarksBox.removeListener(callback);

  /// Reorder bookmarks.
  Future<void> reorderBookmarks(List<News> newsList) async {
    for (int i = 0; i < newsList.length; i++) {
      final News news = newsList[i];

      news.index = newsList.length - 1 - i;
      await _bookmarksBox.put(news.key, news);
    }
  }
}
