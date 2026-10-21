import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../services/supabase_service.dart';
import '../sync/sync_policy.dart';
import '../utils/app_logger.dart';
import '../utils/app_utils.dart';

enum TruckInitialStockSaveResult { synced, localOnly }

class TruckInitialStockInput {
  const TruckInitialStockInput({
    required this.productId,
    required this.quantity,
  });

  final String productId;
  final double quantity;
}

class TruckInitialStockEditorRow {
  const TruckInitialStockEditorRow({
    required this.product,
    required this.quantity,
  });

  final Product product;
  final double quantity;
}

class RemainingStockRow {
  RemainingStockRow({
    required this.productId,
    required this.product,
    required this.initial,
    required this.sold,
  });

  final String productId;
  final Product? product;
  final double initial;
  final double sold;

  double get remaining {
    final r = initial - sold;
    return r < 0 ? 0 : r;
  }

  double get remainingRatio =>
      initial <= 0 ? 0 : (remaining / initial).clamp(0, 1).toDouble();
}

class TruckInitialStockRepository {
  TruckInitialStockRepository({AppDatabase? db, SupabaseClient? client})
      : _db = db ?? DatabaseProvider.instance,
        _client = client ?? SupabaseService.client;

  final AppDatabase _db;
  final SupabaseClient _client;

  Future<List<Truck>> getActiveTrucks() async {
    try {
      final query = _db.select(_db.trucks)
        ..where((t) => t.isActive.equals(true))
        ..orderBy([(t) => OrderingTerm(expression: t.name)]);
      return await query.get();
    } catch (e, st) {
      AppLogger.error('TruckInitialStockRepository.getActiveTrucks', e, st);
      return [];
    }
  }

  Future<List<Truck>> getAllTrucks() async {
    try {
      final query = _db.select(_db.trucks)
        ..orderBy([(t) => OrderingTerm(expression: t.name)]);
      return await query.get();
    } catch (e, st) {
      AppLogger.error('TruckInitialStockRepository.getAllTrucks', e, st);
      return [];
    }
  }

  Future<List<Product>> getActiveProducts() async {
    try {
      final query = _db.select(_db.products)
        ..where((t) => t.isActive.equals(true))
        ..orderBy([(t) => OrderingTerm(expression: t.name)]);
      return await query.get();
    } catch (e, st) {
      AppLogger.error('TruckInitialStockRepository.getActiveProducts', e, st);
      return [];
    }
  }

  Future<String> truckIdForDriver(String driverId) async {
    if (driverId.isEmpty) return '';
    try {
      final local = await (_db.select(_db.driverProfiles)
            ..where((t) => t.id.equals(driverId)))
          .getSingleOrNull();
      final id = local?.truckId;
      if (id != null && id.isNotEmpty) return id;
    } catch (e, st) {
      AppLogger.error(
          'TruckInitialStockRepository.truckIdForDriver(local)', e, st);
    }
    try {
      final row = await _client
          .from('driver_profiles')
          .select('truck_id')
          .eq('id', driverId)
          .maybeSingle();
      final id = row?['truck_id'] as String?;
      if (id != null && id.isNotEmpty) return id;
    } catch (_) {}
    return '';
  }

  Future<List<DriverProfile>> getDriverProfiles() async {
    try {
      final query = _db.select(_db.driverProfiles)
        ..orderBy([(t) => OrderingTerm(expression: t.fullName)]);
      return await query.get();
    } catch (e, st) {
      AppLogger.error('TruckInitialStockRepository.getDriverProfiles', e, st);
      return [];
    }
  }

  Future<TruckInitialStockSaveResult> setTruckActive(
      String truckId, bool active) async {
    await (_db.update(_db.trucks)..where((t) => t.id.equals(truckId))).write(
      TrucksCompanion(isActive: Value(active), synced: const Value(false)),
    );
    try {
      await _client
          .from('trucks')
          .update({'is_active': active}).eq('id', truckId);
      await (_db.update(_db.trucks)..where((t) => t.id.equals(truckId)))
          .write(const TrucksCompanion(synced: Value(true)));
      return TruckInitialStockSaveResult.synced;
    } catch (e, st) {
      AppLogger.error('TruckInitialStockRepository.setTruckActive', e, st);
      return TruckInitialStockSaveResult.localOnly;
    }
  }

  Future<Map<String, double>> soldTodayByProduct(String driverId) async {
    if (driverId.isEmpty) return {};
    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      final end = start.add(const Duration(days: 1));
      final query = _db.select(_db.invoiceItems).join([
        innerJoin(
          _db.invoices,
          _db.invoices.id.equalsExp(_db.invoiceItems.invoiceId),
        ),
      ])
        ..where(_db.invoices.driverId.equals(driverId) &
            _db.invoices.invoiceDate.isBiggerOrEqualValue(start) &
            _db.invoices.invoiceDate.isSmallerThanValue(end));
      final rows = await query.get();
      final map = <String, double>{};
      for (final r in rows) {
        final item = r.readTable(_db.invoiceItems);
        map[item.productId] = (map[item.productId] ?? 0) + item.quantity;
      }
      return map;
    } catch (e, st) {
      AppLogger.error('TruckInitialStockRepository.soldTodayByProduct', e, st);
      return {};
    }
  }

  Future<List<TruckInitialStock>> getForTruck(String truckId) async {
    try {
      final query = _db.select(_db.truckInitialStocks)
        ..where((t) => t.truckId.equals(truckId));
      return await query.get();
    } catch (e, st) {
      AppLogger.error('TruckInitialStockRepository.getForTruck', e, st);
      return [];
    }
  }

  Future<List<TruckInitialStockEditorRow>> getEditorRows(String truckId) async {
    final products = await getActiveProducts();
    final stock = await getForTruck(truckId);
    final byProduct = {for (final row in stock) row.productId: row.quantity};
    return products
        .map(
          (product) => TruckInitialStockEditorRow(
            product: product,
            quantity: byProduct[product.id] ?? 0,
          ),
        )
        .toList();
  }

  Future<List<RemainingStockRow>> getRemainingStock(
    String driverId,
    String truckId,
  ) async {
    try {
      final stock = await getForTruck(truckId);
      if (stock.isEmpty) return [];

      final products = await _db.select(_db.products).get();
      final byId = {for (final p in products) p.id: p};
      final sold = await _soldByProduct(driverId);

      final rows = stock
          .map((s) => RemainingStockRow(
                productId: s.productId,
                product: byId[s.productId],
                initial: s.quantity,
                sold: sold[s.productId] ?? 0,
              ))
          .toList();
      rows.sort((a, b) => (a.product?.name ?? '')
          .toLowerCase()
          .compareTo((b.product?.name ?? '').toLowerCase()));
      return rows;
    } catch (e, st) {
      AppLogger.error('TruckInitialStockRepository.getRemainingStock', e, st);
      return [];
    }
  }

  Future<Map<String, double>> _soldByProduct(String driverId) async {
    try {
      final query = _db.select(_db.invoiceItems).join([
        innerJoin(
          _db.invoices,
          _db.invoices.id.equalsExp(_db.invoiceItems.invoiceId),
        ),
      ])
        ..where(_db.invoices.driverId.equals(driverId));

      final rows = await query.get();
      final map = <String, double>{};
      for (final r in rows) {
        final item = r.readTable(_db.invoiceItems);
        map[item.productId] = (map[item.productId] ?? 0) + item.quantity;
      }
      return map;
    } catch (e, st) {
      AppLogger.error('TruckInitialStockRepository._soldByProduct', e, st);
      return {};
    }
  }

  Future<TruckInitialStockSaveResult> saveTruckStock({
    required String truckId,
    required List<TruckInitialStockInput> items,
  }) async {
    final now = DateTime.now();
    final existing = await getForTruck(truckId);
    final existingByProduct = {
      for (final row in existing) row.productId: row,
    };

    final companions = items.map((item) {
      final old = existingByProduct[item.productId];
      return TruckInitialStocksCompanion(
        id: Value(old?.id ?? AppUtils.generateUuid()),
        truckId: Value(truckId),
        productId: Value(item.productId),
        quantity: Value(item.quantity < 0 ? 0 : item.quantity),
        updatedAt: Value(now),
        createdAt: Value(old?.createdAt ?? now),
        synced: const Value(false),
      );
    }).toList();

    try {
      await _db.batch((b) {
        b.insertAllOnConflictUpdate(_db.truckInitialStocks, companions);
      });
    } catch (e, st) {
      AppLogger.error(
          'TruckInitialStockRepository.saveTruckStock(local)', e, st);
      return TruckInitialStockSaveResult.localOnly;
    }

    if (companions.isEmpty) return TruckInitialStockSaveResult.synced;

    try {
      await _client.from('truck_initial_stock').upsert(
            companions
                .map(
                  (row) => {
                    'id': row.id.value,
                    'truck_id': row.truckId.value,
                    'product_id': row.productId.value,
                    'quantity': row.quantity.value,
                    'updated_at': row.updatedAt.value.toUtc().toIso8601String(),
                    'created_at': row.createdAt.value.toUtc().toIso8601String(),
                  },
                )
                .toList(),
            onConflict: 'truck_id,product_id',
          );
      await _markSynced(companions.map((row) => row.id.value));
      return TruckInitialStockSaveResult.synced;
    } catch (e, st) {
      AppLogger.error(
          'TruckInitialStockRepository.saveTruckStock(remote)', e, st);
      return TruckInitialStockSaveResult.localOnly;
    }
  }

  Future<void> pushUnsynced() async {
    final dirty = await (_db.select(_db.truckInitialStocks)
          ..where((t) => t.synced.equals(false)))
        .get();
    if (dirty.isEmpty) return;

    final ids = dirty.map((row) => row.id).toList();
    final serverRows = await _client
        .from('truck_initial_stock')
        .select('id,updated_at')
        .inFilter('id', ids);
    final serverUpdated = <String, DateTime?>{
      for (final row in serverRows)
        row['id'] as String:
            DateTime.tryParse(row['updated_at']?.toString() ?? ''),
    };
    final toPush = dirty
        .where((row) => SyncPolicy.shouldPushLocalRow(
              localUpdatedAt: row.updatedAt,
              serverUpdatedAt: serverUpdated[row.id],
            ))
        .toList();

    if (toPush.isNotEmpty) {
      await _client.from('truck_initial_stock').upsert(
            toPush
                .map(
                  (row) => {
                    'id': row.id,
                    'truck_id': row.truckId,
                    'product_id': row.productId,
                    'quantity': row.quantity,
                    'updated_at': row.updatedAt.toUtc().toIso8601String(),
                    'created_at': row.createdAt.toUtc().toIso8601String(),
                  },
                )
                .toList(),
            onConflict: 'truck_id,product_id',
          );
    }
    await _markSynced(ids);
  }

  Future<bool> syncFromSupabase() async {
    try {
      final data = await _client.from('truck_initial_stock').select();
      if (data.isEmpty) return true;
      final localRows = await _db.select(_db.truckInitialStocks).get();
      final localById = {for (final row in localRows) row.id: row};
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
          _db.truckInitialStocks,
          rows.map(
            (row) => TruckInitialStocksCompanion(
              id: Value(row['id'] as String),
              truckId: Value(row['truck_id'] as String),
              productId: Value(row['product_id'] as String),
              quantity: Value(_toDouble(row['quantity'])),
              updatedAt: Value(_toDateTime(row['updated_at']).toLocal()),
              createdAt: Value(_toDateTime(row['created_at'])),
              synced: const Value(true),
            ),
          ),
        );
      });
      return true;
    } catch (e, st) {
      AppLogger.error('TruckInitialStockRepository.syncFromSupabase', e, st);
      return false;
    }
  }

  Future<void> _markSynced(Iterable<String> ids) async {
    final idList = ids.toList();
    if (idList.isEmpty) return;
    await (_db.update(_db.truckInitialStocks)..where((t) => t.id.isIn(idList)))
        .write(const TruckInitialStocksCompanion(synced: Value(true)));
  }

  static double _toDouble(dynamic v) => v == null
      ? 0
      : v is num
          ? v.toDouble()
          : double.tryParse(v.toString()) ?? 0;

  static DateTime _toDateTime(dynamic v) =>
      v == null ? DateTime.now() : DateTime.parse(v.toString());
}
