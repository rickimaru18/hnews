import 'package:hnews/extensions/rssitem_extension.dart';
import 'package:hnews/models/news.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import 'package:webfeed/webfeed.dart';

class RssService {
  /// Get news.
  Stream<News> getNews(Uri uri) async* {
    final RetryClient client = RetryClient(http.Client());

    try {
      final String body = await client.read(uri);
      final RssFeed rssFeed = RssFeed.parse(body);

      if (rssFeed.items == null) {
        return;
      }

      const Duration yieldDelay = Duration(milliseconds: 100);

      for (final RssItem rssItem in rssFeed.items!) {
        if (rssItem.link == null || rssItem.link!.isEmpty) {
          continue;
        }

        await Future<void>.delayed(yieldDelay);
        yield rssItem.toNews;
      }
    } catch (e) {
      print(e);
    } finally {
      client.close();
    }
  }
}
