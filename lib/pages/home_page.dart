import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hnews/pages/bookmarks_page.dart';
import 'package:hnews/pages/news_page.dart';
import 'package:hnews/providers/viewmodels/pages/local_news_view_model.dart';
import 'package:hnews/providers/viewmodels/pages/world_news_view_model.dart';
import 'package:hnews/widgets/sliver_app_bar_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  static const String ROUTE = '/';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final List<_TabContent> _tabContents;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabContents = const <_TabContent>[
      _TabContent(
        tab: Tab(icon: Icon(CupertinoIcons.location)),
        view: NewsPage<LocalNewsViewModel>(
          key: PageStorageKey<String>('localNews'),
        ),
      ),
      _TabContent(
        tab: Tab(icon: Icon(CupertinoIcons.globe)),
        view: NewsPage<WorldNewsViewModel>(
          key: PageStorageKey<String>('worldNews'),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => <Widget>[
          SliverAppBarTab(
            onBookmarkAction: () => Navigator.pushNamed(
              context,
              BookmarksPage.ROUTE,
            ),
            controller: _tabController,
            tabs:
                _tabContents.map((_TabContent content) => content.tab).toList(),
            tabsImageAssetBackground: const <String>[
              'images/local_news.png',
              'images/world_news.jpg',
            ],
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children:
              _tabContents.map((_TabContent content) => content.view).toList(),
        ),
      ),
    );
  }
}

//------------------------------------------------------------------------------
class _TabContent {
  const _TabContent({
    required this.tab,
    required this.view,
  });

  final Tab tab;
  final Widget view;
}
