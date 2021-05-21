import 'package:flutter/foundation.dart';
import 'package:hnews/models/news.dart';
import 'package:hnews/providers/repository.dart';

class BaseViewModel with ChangeNotifier {
  BaseViewModel(this._repository);

  /// Get [Repository].
  Repository get repository => _repository;
  final Repository _repository;

  /// Change bookmark state of [news].
  Future<void> bookmarkChange(bool value, News news) async {
    if (value) {
      await repository.bookmarkNews(news);
    } else {
      await repository.unbookmarkNews(news);
    }
  }
}
