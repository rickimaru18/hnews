import 'dart:async';
import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:hnews/models/news.dart';
import 'package:hnews/providers/repository.dart';
import 'package:hnews/providers/viewmodels/pages/base_view_model.dart';

class NewsViewModel extends BaseViewModel {
  NewsViewModel(
    Repository repository,
    this._rssUrl,
  ) : super(repository) {
    _init();
  }

  final String _rssUrl;

  /// Get list of [News].
  UnmodifiableListView<News> get news => UnmodifiableListView<News>(_news);
  final List<News> _news = <News>[];

  /// Get [news] count.
  int get newsCount => _news.length;

  /// [News] stream subscription.
  StreamSubscription<News>? _newsSubscription;

  /// Key for [HomePage]'s [AnimatedList].
  GlobalKey<AnimatedListState>? _animatedListKey;
  set animatedListKey(GlobalKey<AnimatedListState> value) {
    _animatedListKey = value;

    if (value.currentState != null) {
      for (int i = 0; i < newsCount; i++) {
        _animatedListKey!.currentState!.insertItem(i);
      }
    }
  }

  /// Callback when news list item is removed.
  OnRemoveListItem? _onRemoveListItem;
  set onRemoveListItem(OnRemoveListItem callback) {
    _onRemoveListItem = callback;
  }

  /// Get initialization state.
  bool get isLoading => _isLoading;
  bool _isLoading = true;

  /// Setup
  Future<void> _init() async {
    refresh();
    repository.listenToBookmarks(_onBookmarksChange);
  }

  /// Refresh news stream.
  ///
  /// This will cancel the existing stream and refetch news.
  Future<void> refresh() async {
    final Completer<void> dataRetrievedComplete = Completer<void>();

    await _newsSubscription?.cancel();

    final Stream<News> newsStream = await repository.getNews(_rssUrl);
    _newsSubscription = newsStream.listen((News news) {
      if (isLoading) {
        _isLoading = false;
        notifyListeners();
      }

      if (!dataRetrievedComplete.isCompleted) {
        // Clear [HomePage]'s [AnimatedList].
        for (int i = 0; i < _news.length; i++) {
          _animatedListKey?.currentState?.removeItem(
            0,
            (_, Animation<double> animation) =>
                _onRemoveListItem?.call(
                  _news[0],
                  animation,
                ) ??
                Container(),
          );
        }

        _news.clear();
        dataRetrievedComplete.complete();
      }

      _news.add(news);
      _animatedListKey?.currentState?.insertItem(newsCount - 1);
    });

    return dataRetrievedComplete.future;
  }

  /// Callback when bookmarks changes.
  Future<void> _onBookmarksChange() async {
    for (final News newsTmp in _news) {
      if (newsTmp.isBookmarked != await repository.isBookmarked(newsTmp)) {
        newsTmp.isBookmarked = !newsTmp.isBookmarked;

        notifyListeners();
        break;
      }
    }
  }

  @override
  void dispose() {
    _animatedListKey = null;
    _newsSubscription?.cancel();
    repository.unlistenToBookmarks(_onBookmarksChange);
    super.dispose();
  }
}

//------------------------------------------------------------------------------
typedef OnRemoveListItem = Widget Function(
  News news,
  Animation<double> animation,
);
