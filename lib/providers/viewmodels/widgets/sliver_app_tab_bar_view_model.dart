import 'package:flutter/material.dart';

class SliverAppBarTabViewModel with ChangeNotifier {
  SliverAppBarTabViewModel(this._controller) {
    _controller.addListener(notifyListeners);
  }

  final TabController _controller;

  /// Get tab index.
  int get index => _controller.index;

  @override
  void dispose() {
    _controller.removeListener(notifyListeners);
    super.dispose();
  }
}
