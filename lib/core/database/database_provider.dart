import 'package:flutter/foundation.dart';

import 'app_database.dart';

class DatabaseProvider {
  DatabaseProvider._();

  static AppDatabase? _instance;

  static AppDatabase get instance => _instance ??= AppDatabase();

  @visibleForTesting
  static void useForTesting(AppDatabase db) => _instance = db;

  static Future<void> close() async {
    await _instance?.close();
    _instance = null;
  }
}
