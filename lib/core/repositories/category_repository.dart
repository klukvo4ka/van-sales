import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../services/supabase_service.dart';
import '../sync/sync_policy.dart';
import '../utils/app_logger.dart';

class CategoryRepository {
  CategoryRepository({AppDatabase? db, SupabaseClient? client})
      : _db = db ?? DatabaseProvider.instance,
        _client = client ?? SupabaseService.client;

  final AppDatabase _db;
  final SupabaseClient _client;

  Future<List<Category>> getAll() async {
    try {
      final query = _db.select(_db.categories)
        ..orderBy([
          (t) => OrderingTerm(expression: t.sortOrder),
          (t) => OrderingTerm(expression: t.name),
        ]);
      return await query.get();
    } catch (e, st) {
      AppLogger.error('CategoryRepository.getAll', e, st);
      return [];
    }
  }

  Future<bool> syncFromSupabase() async {
    try {
      final data = await _client.from('categories').select();
      if (data.isEmpty) return true;
      final localRows = await _db.select(_db.categories).get();
      final localById = {for (final c in localRows) c.id: c};
      final rows = data.where((row) {
        final local = localById[row['id']];
        return SyncPolicy.shouldApplyServerRow(
          localExists: local != null,
          localUpdatedAt: local?.updatedAt,
          serverUpdatedAt:
              DateTime.tryParse(row['updated_at']?.toString() ?? ''),
        );
      }).toList();
      if (rows.isEmpty) return true;
      await _db.batch((b) {
        b.insertAllOnConflictUpdate(
          _db.categories,
          rows.map(
            (row) => CategoriesCompanion(
              id: Value(row['id'] as String),
              name: Value(row['name'] as String),
              nameFa: Value(row['name_fa'] as String?),
              sortOrder: Value((row['sort_order'] as num?)?.toInt() ?? 0),
              updatedAt: Value(
                  (DateTime.tryParse(row['updated_at']?.toString() ?? '') ??
                          DateTime.now())
                      .toLocal()),
            ),
          ),
        );
      });
      return true;
    } catch (e, st) {
      AppLogger.error('CategoryRepository.syncFromSupabase', e, st);
      return false;
    }
  }
}
