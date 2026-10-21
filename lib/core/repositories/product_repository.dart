import 'package:drift/drift.dart' show Value;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../services/supabase_service.dart';
import '../sync/sync_policy.dart';
import '../utils/app_logger.dart';

enum ProductSaveResult { synced, localOnly }

class ProductRepository {
  ProductRepository({AppDatabase? db, SupabaseClient? client})
      : _db = db ?? DatabaseProvider.instance,
        _client = client ?? SupabaseService.client;

  final AppDatabase _db;
  final SupabaseClient _client;

  Future<List<Product>> getAll() async {
    try {
      final rows = await _db.select(_db.products).get();
      rows.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
      return rows;
    } catch (e, st) {
      AppLogger.error('ProductRepository.getAll', e, st);
      return [];
    }
  }

  Future<bool> syncFromSupabase() async {
    try {
      final data = await _client.from('products').select();
      if (data.isEmpty) return true;
      final localRows = await _db.select(_db.products).get();
      final localById = {for (final p in localRows) p.id: p};
      final rows = data.where((row) {
        final local = localById[row['id']];
        return SyncPolicy.shouldApplyServerRow(
          localExists: local != null,
          localDirty: local != null && !local.synced,
          localUpdatedAt: local?.updatedAt,
          serverUpdatedAt:
              DateTime.tryParse(row['updated_at']?.toString() ?? ''),
        );
      }).toList();
      if (rows.isEmpty) return true;
      await _db.batch((b) {
        b.insertAllOnConflictUpdate(
          _db.products,
          rows.map(
            (row) => ProductsCompanion(
              id: Value(row['id'] as String),
              name: Value(row['name'] as String),
              nameFa: Value(row['name_fa'] as String?),
              sku: Value(row['sku'] as String?),
              unit: Value(row['unit'] as String? ?? 'pcs'),
              price: Value(_toDouble(row['price'])),
              categoryId: Value(row['category_id'] as String?),
              isActive: Value(row['is_active'] as bool? ?? true),
              updatedAt: Value(_toDateTime(row['updated_at']).toLocal()),
              createdAt: Value(_toDateTime(row['created_at'])),
              synced: const Value(true),
            ),
          ),
        );
      });
      return true;
    } catch (e, st) {
      AppLogger.error('ProductRepository.syncFromSupabase', e, st);
      return false;
    }
  }

  Future<void> pushUnsynced() async {
    final dirty = await (_db.select(_db.products)
          ..where((t) => t.synced.equals(false)))
        .get();
    if (dirty.isEmpty) return;

    final ids = dirty.map((p) => p.id).toList();
    final serverRows = await _client
        .from('products')
        .select('id,updated_at')
        .inFilter('id', ids);
    final serverUpdated = <String, DateTime?>{
      for (final row in serverRows)
        row['id'] as String:
            DateTime.tryParse(row['updated_at']?.toString() ?? ''),
    };

    final toPush = dirty
        .where((p) => SyncPolicy.shouldPushLocalRow(
              localUpdatedAt: p.updatedAt,
              serverUpdatedAt: serverUpdated[p.id],
            ))
        .toList();

    if (toPush.isNotEmpty) {
      await _client.from('products').upsert(toPush
          .map((p) => {
                'id': p.id,
                'name': p.name,
                'name_fa': p.nameFa,
                'sku': p.sku,
                'unit': p.unit,
                'price': p.price,
                'category_id': p.categoryId,
                'is_active': p.isActive,
              })
          .toList());
    }
    await (_db.update(_db.products)..where((t) => t.id.isIn(ids)))
        .write(const ProductsCompanion(synced: Value(true)));
  }

  Future<ProductSaveResult> save({
    required String id,
    required String name,
    String? nameFa,
    String? sku,
    required String unit,
    required double price,
    String? categoryId,
    required bool isActive,
  }) async {
    final companion = ProductsCompanion(
      id: Value(id),
      name: Value(name),
      nameFa: Value(nameFa),
      sku: Value(sku),
      unit: Value(unit),
      price: Value(price),
      categoryId: Value(categoryId),
      isActive: Value(isActive),
      updatedAt: Value(DateTime.now()),
      synced: const Value(false),
    );

    await _db.into(_db.products).insertOnConflictUpdate(companion);

    try {
      await _client.from('products').upsert({
        'id': id,
        'name': name,
        'name_fa': nameFa,
        'sku': sku,
        'unit': unit,
        'price': price,
        'category_id': categoryId,
        'is_active': isActive,
      });
      await (_db.update(_db.products)..where((t) => t.id.equals(id)))
          .write(const ProductsCompanion(synced: Value(true)));
      return ProductSaveResult.synced;
    } catch (e, st) {
      AppLogger.error('ProductRepository.save', e, st);
      return ProductSaveResult.localOnly;
    }
  }

  static double _toDouble(dynamic v) => v == null
      ? 0
      : v is num
          ? v.toDouble()
          : double.tryParse(v.toString()) ?? 0;

  static DateTime _toDateTime(dynamic v) =>
      v == null ? DateTime.now() : DateTime.parse(v.toString());
}
