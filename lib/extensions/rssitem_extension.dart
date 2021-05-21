import 'package:hnews/models/news.dart';
import 'package:webfeed/webfeed.dart';

extension RssItemUtil on RssItem {
  /// Convert to [News].
  News get toNews => News(
        title: title!,
        link: link!,
        pubDate: pubDate!,
        source: source!.value!,
      );
}
