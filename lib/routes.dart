import 'package:flutter/material.dart';
import 'package:hnews/pages/bookmarks_page.dart';
import 'package:hnews/pages/home_page.dart';
import 'package:hnews/providers/repository.dart';
import 'package:hnews/providers/viewmodels/pages/bookmarks_view_model.dart';
import 'package:hnews/providers/viewmodels/pages/local_news_view_model.dart';
import 'package:hnews/providers/viewmodels/pages/news_view_model.dart';
import 'package:hnews/providers/viewmodels/pages/world_news_view_model.dart';
import 'package:provider/provider.dart';

Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
  // Route to HomePage.
  HomePage.ROUTE: (BuildContext context) {
    final Repository repository = Provider.of<Repository>(
      context,
      listen: false,
    );

    return MultiProvider(
      providers: <ChangeNotifierProvider<NewsViewModel>>[
        ChangeNotifierProvider<LocalNewsViewModel>(
          create: (_) => LocalNewsViewModel(repository),
          lazy: false,
        ),
        ChangeNotifierProvider<WorldNewsViewModel>(
          create: (_) => WorldNewsViewModel(repository),
          lazy: false,
        ),
      ],
      child: const HomePage(),
    );
  },

  // Route to BookmarksPage.
  BookmarksPage.ROUTE: (BuildContext context) {
    return ChangeNotifierProvider<BookmarksViewModel>(
      create: (_) => BookmarksViewModel(Provider.of<Repository>(
        context,
        listen: false,
      )),
      child: const BookmarksPage(),
    );
  },
};
