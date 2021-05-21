import 'package:flutter/material.dart';
import 'package:hnews/models/news.dart';
import 'package:hnews/providers/viewmodels/pages/bookmarks_view_model.dart';
import 'package:hnews/widgets/news_list.dart';
import 'package:provider/provider.dart';

class BookmarksPage extends StatelessWidget {
  const BookmarksPage({
    Key? key,
  }) : super(key: key);

  static const String ROUTE = '/bookmarks';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        centerTitle: false,
      ),
      body: Consumer<BookmarksViewModel>(
        builder: (_, BookmarksViewModel viewModel, __) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<News> news = viewModel.news;

          if (news.isEmpty) {
            return const Center(
              child: Text(
                'Empty',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.grey,
                ),
              ),
            );
          }

          return ReorderableListView.builder(
            itemCount: news.length,
            itemBuilder: (_, int i) => NewsTile(
              onBookmarkChange: (bool value) =>
                  viewModel.bookmarkChange(value, news[i]),
              key: ValueKey<int>(i),
              news: news[i],
            ),
            onReorder: viewModel.onReorder,
          );
        },
      ),
    );
  }
}
