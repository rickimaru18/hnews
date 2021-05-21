import 'dart:async';
import 'dart:collection';

import 'package:hnews/models/news.dart';
import 'package:hnews/providers/repository.dart';
import 'package:hnews/providers/viewmodels/pages/base_view_model.dart';

class BookmarksViewModel extends BaseViewModel {
  BookmarksViewModel(Repository repository) : super(repository) {
    _init();
  }

  /// Get list of [News].
  UnmodifiableListView<News> get news => UnmodifiableListView<News>(_news);
  late List<News> _news;

  /// Get initialization state.
  bool get isLoading => _isLoading;
  bool _isLoading = true;

  /// Setup.
  Future<void> _init() async {
    _news = await repository.getBookmarkedNews();
    _isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> bookmarkChange(bool value, News news) async {
    super.bookmarkChange(value, news);
    _news = await repository.getBookmarkedNews();
    notifyListeners();
  }

  /// Callback when list items are reordered.
  void onReorder(int oldIndex, int newIndex) {
    _news.insert(
      newIndex - (newIndex < oldIndex ? 0 : 1),
      _news.removeAt(oldIndex),
    );
    repository.reorderBookmarks(_news);
  }
}
