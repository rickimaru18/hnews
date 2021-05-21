import 'package:intl/intl.dart';

extension DateTimeUtil on DateTime {
  /// Get "ago" string.
  ///
  /// e.g. 23d = 23 days ago.
  String ago([DateTime? from]) {
    late String res;

    from ??= DateTime.now();

    final Duration difference = from.difference(this);

    if (difference.inSeconds < 60) {
      if (difference.inSeconds == 0) {
        res = 'now';
      } else {
        res = '${difference.inSeconds}s ago';
      }
    } else if (difference.inMinutes < 60) {
      res = '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      res = '${difference.inHours}h ago';
    } else if (month != from.month) {
      res = DateFormat.yMMM().format(this);
    } else {
      res = '${difference.inDays}d ago';
    }

    return res;
  }
}
