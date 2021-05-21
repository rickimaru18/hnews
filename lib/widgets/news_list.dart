import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hnews/extensions/datetime_extension.dart';
import 'package:hnews/models/news.dart';
import 'package:hnews/widgets/bookmark_button.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsList extends StatefulWidget {
  const NewsList({
    required this.onAnimatedKeySet,
    required this.news,
    required this.itemBuilder,
    Key? key,
  }) : super(key: key);

  final ValueChanged<GlobalKey<AnimatedListState>> onAnimatedKeySet;
  final List<News> news;
  final AnimatedListItemBuilder itemBuilder;

  @override
  _NewsListState createState() => _NewsListState();
}

class _NewsListState extends State<NewsList>
    with SingleTickerProviderStateMixin {
  late final GlobalKey<AnimatedListState> _key;

  @override
  void initState() {
    super.initState();
    _key = GlobalKey<AnimatedListState>();
    widget.onAnimatedKeySet(_key);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _key,
      initialItemCount: widget.news.length,
      itemBuilder: widget.itemBuilder,
    );
  }
}

//------------------------------------------------------------------------------
abstract class NewsItem extends StatelessWidget {
  const NewsItem({
    required this.news,
    this.animation,
    this.onBookmarkChange,
    Key? key,
  }) : super(key: key);

  final News news;
  final Animation<double>? animation;
  final ValueChanged<bool>? onBookmarkChange;

  /// Wrap [child] inside a [SlideTransition].
  Widget addSlideTransition(Widget child) => SlideTransition(
        position: animation!.drive<Offset>(Tween<Offset>(
          begin: const Offset(1, 0),
          end: const Offset(0, 0),
        )),
        child: child,
      );

  /// Callback when [NewsList] item is tapped.
  Future<void> onTap() async {
    if (!await canLaunch(news.link)) {
      return;
    }
    launch(news.link, forceWebView: false, forceSafariVC: true);
  }
}

//------------------------------------------------------------------------------
class NewsCard extends NewsItem {
  const NewsCard({
    required News news,
    Animation<double>? animation,
    ValueChanged<bool>? onBookmarkChange,
    Key? key,
  }) : super(
          news: news,
          animation: animation,
          onBookmarkChange: onBookmarkChange,
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    Widget child = GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                news.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _Footer(
                onBookmarkChange: (_, bool value) => onBookmarkChange?.call(
                  value,
                ),
                news: news,
              ),
            ],
          ),
        ),
      ),
    );

    if (animation != null) {
      child = addSlideTransition(child);
    }

    return child;
  }
}

//------------------------------------------------------------------------------
class NewsTile extends NewsItem {
  const NewsTile({
    required News news,
    Animation<double>? animation,
    ValueChanged<bool>? onBookmarkChange,
    Key? key,
  }) : super(
          news: news,
          animation: animation,
          onBookmarkChange: onBookmarkChange,
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    Widget child = Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Slidable(
        actionPane: const SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: ListTile(
          onTap: onTap,
          tileColor: Colors.black,
          title: Text(
            news.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: _Footer(
            onBookmarkChange: (BuildContext context, _) => Slidable.of(context)
                ?.open(actionType: SlideActionType.secondary),
            news: news,
          ),
          trailing: const SizedBox(
            height: double.infinity,
            child: Icon(Icons.reorder),
          ),
        ),
        secondaryActions: <Widget>[
          IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () => onBookmarkChange?.call(false),
          ),
        ],
      ),
    );

    if (animation != null) {
      child = addSlideTransition(child);
    }

    return child;
  }
}

//------------------------------------------------------------------------------
typedef OnBookmarkChange = void Function(BuildContext context, bool value);

//------------------------------------------------------------------------------
class _Footer extends StatelessWidget {
  const _Footer({
    required this.news,
    this.onBookmarkChange,
    Key? key,
  }) : super(key: key);

  final News news;
  final OnBookmarkChange? onBookmarkChange;

  @override
  Widget build(BuildContext context) {
    const TextStyle textStyle = TextStyle(fontSize: 12);

    return Row(
      children: <Widget>[
        Expanded(
          child: Row(
            children: <Widget>[
              Flexible(
                child: Text(
                  news.source,
                  overflow: TextOverflow.ellipsis,
                  style: textStyle,
                ),
              ),
              Text(
                ' - ${news.pubDate.ago()}',
                style: textStyle,
              ),
            ],
          ),
        ),
        BookmarkButton(
          onBookmarkChange: (bool value) => onBookmarkChange?.call(
            context,
            value,
          ),
          isBookmarked: news.isBookmarked,
        ),
      ],
    );
  }
}
