import 'package:flutter/material.dart';
import 'package:hnews/models/news.dart';
import 'package:hnews/providers/viewmodels/pages/news_view_model.dart';
import 'package:hnews/widgets/news_list.dart';
import 'package:provider/provider.dart';

class NewsPage<T extends NewsViewModel> extends StatelessWidget {
  const NewsPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Provider.of<T>(
      context,
      listen: false,
    ).onRemoveListItem = (News news, Animation<double> animation) => NewsCard(
          news: news,
          animation: animation,
        );

    return Consumer<T>(
      child: const Center(child: CircularProgressIndicator()),
      builder: (_, T viewModel, Widget? child) {
        if (viewModel.isLoading) {
          return child!;
        }

        final List<News> news = viewModel.news;

        return RefreshIndicator(
          onRefresh: viewModel.refresh,
          child: NewsList(
            onAnimatedKeySet: (GlobalKey<AnimatedListState> key) =>
                viewModel.animatedListKey = key,
            news: news,
            itemBuilder: (_, int i, Animation<double> animation) {
              return NewsCard(
                news: news[i],
                animation: animation,
                onBookmarkChange: (bool value) =>
                    viewModel.bookmarkChange(value, news[i]),
              );
            },
          ),
        );
      },
    );
  }
}
