import 'package:flutter/material.dart';
import 'package:hnews/providers/viewmodels/widgets/sliver_app_tab_bar_view_model.dart';
import 'package:provider/provider.dart';

class SliverAppBarTab extends StatelessWidget {
  const SliverAppBarTab({
    required this.onBookmarkAction,
    required this.controller,
    required this.tabs,
    this.tabsImageAssetBackground,
    Key? key,
  }) : super(key: key);

  final VoidCallback onBookmarkAction;
  final TabController controller;
  final List<Widget> tabs;
  final List<String>? tabsImageAssetBackground;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SliverAppBarTabViewModel>(
      create: (_) => SliverAppBarTabViewModel(controller),
      child: SliverAppBar(
        expandedHeight: 300,
        collapsedHeight: 100,
        elevation: 0,
        pinned: true,
        flexibleSpace: Stack(
          children: <Widget>[
            if (tabsImageAssetBackground != null)
              Positioned.fill(
                child: Consumer<SliverAppBarTabViewModel>(
                  builder: (_, SliverAppBarTabViewModel viewModel, __) {
                    return AnimatedSwitcher(
                      duration: const Duration(seconds: 1),
                      layoutBuilder: (
                        Widget? currentChild,
                        List<Widget> previousChildren,
                      ) {
                        return Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            ...previousChildren,
                            if (currentChild != null) currentChild,
                          ],
                        );
                      },
                      child: Image.asset(
                        tabsImageAssetBackground![viewModel.index >
                                tabsImageAssetBackground!.length - 1
                            ? tabsImageAssetBackground!.length - 1
                            : viewModel.index],
                        key: ValueKey<int>(viewModel.index),
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
            Positioned(
              bottom: 60,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 5, 30, 5),
                color: Colors.black,
                child: const Text(
                  'HNews',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          InkWell(
            onTap: onBookmarkAction,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: Colors.black,
              child: const Icon(
                Icons.bookmark,
                color: Colors.red,
              ),
            ),
          ),
        ],
        bottom: _BottomTabBar(
          controller: controller,
          tabs: tabs,
        ),
      ),
    );
  }
}

//------------------------------------------------------------------------------
class _BottomTabBar extends StatelessWidget implements PreferredSizeWidget {
  const _BottomTabBar({
    required this.controller,
    required this.tabs,
  });

  final TabController controller;
  final List<Widget> tabs;

  @override
  Size get preferredSize {
    for (final Widget item in tabs) {
      if (item is Tab) {
        final Tab tab = item;
        if ((tab.text != null || tab.child != null) && tab.icon != null)
          return const Size.fromHeight(72 + 2);
      }
    }
    return const Size.fromHeight(46 + 2);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: TabBar(
        controller: controller,
        tabs: tabs,
      ),
    );
  }
}
