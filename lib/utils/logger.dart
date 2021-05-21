import 'dart:developer';

import 'package:hnews/env.dart';

/// Log message using the [log] function.
///
/// Can be disabled in ".env" file with key "loggerEnabled".
void logger(String name, String message, [StackTrace? stackTrace]) {
  if (!Env.loggerEnabled) {
    return;
  }

  log(message, name: name, stackTrace: stackTrace);
}
