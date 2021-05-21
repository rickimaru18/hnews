import 'package:hive/hive.dart';

part 'news.g.dart';

@HiveType(typeId: 0)
class News {
  News({
    required this.title,
    required this.link,
    required this.pubDate,
    required this.source,
  });

  @HiveField(0)
  final String title;

  @HiveField(1)
  final String link;

  @HiveField(2)
  final DateTime pubDate;

  @HiveField(3)
  final String source;

  @HiveField(4)
  bool isBookmarked = false;

  @HiveField(5)
  int index = 0;

  /// Get key string.
  String get key => link.length > 255 ? link.substring(0, 255) : link;
}
