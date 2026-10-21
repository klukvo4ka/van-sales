import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void error(String tag, Object error, [StackTrace? st]) {
    if (!kDebugMode) return;
    debugPrint('[ERROR][$tag] $error');
    if (st != null) debugPrint(st.toString());
  }

  static void info(String tag, String message) {
    if (!kDebugMode) return;
    debugPrint('[INFO][$tag] $message');
  }
}
