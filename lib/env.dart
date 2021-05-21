import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hnews/utils/logger.dart';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';

class Env {
  Env._();

  static late Map<String, dynamic> _env;

  /// Setup .env file.
  static Future<void> init() async {
    final RetryClient client = RetryClient(http.Client());

    _env = json.decode(await rootBundle.loadString(
      kReleaseMode ? '.env' : '.env_dev',
    )) as Map<String, dynamic>;

    try {
      final String body =
          await client.read(Uri.parse(_env['locationApi']! as String));
      final String location = jsonDecode(body)['country'] as String;

      _env['localNews'] = _env['localNews']?.replaceFirst(
        '{location}',
        location,
      );
    } catch (e) {
      logger('Env', 'Failed to get country. $e', StackTrace.current);
    } finally {
      client.close();
    }
  }

  /// Get enabled state of [logger].
  static bool get loggerEnabled => _env['loggerEnabled'] as bool;

  /// Get local news RSS URL.
  static String get localNews =>
      _env['localNews']!.toString().contains('{location}')
          ? _env['topNews']! as String
          : _env['localNews']! as String;

  /// Get world news RSS URL.
  static String get worldNews => _env['worldNews']! as String;
}
