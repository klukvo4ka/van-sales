import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../services/supabase_service.dart';
import '../utils/app_logger.dart';
import '../utils/app_utils.dart';

class TruckLoadItemView {
  TruckLoadItemView({required this.item, required this.product});
  final TruckLoadItem item;
  final Product? product;
}

class LoadItemRequest {
  LoadItemRequest({required this.productId, required this.requestedQty});
  final String productId;
  final double requestedQty;
}

enum SaveResult { synced, localOnly }

class TruckLoadRepository {
  TruckLoadRepository({AppDatabase? db, SupabaseClient? client})
      : _db = db ?? DatabaseProvider.instance,
        _client = client ?? SupabaseService.client;

  final AppDatabase _db;
  final SupabaseClient _client;

  Future<TruckLoad?> getTodayLoad(String driverId) async {
    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      final end = start.add(const Duration(days: 1));
      final query = _db.select(_db.truckLoads)
        ..where((t) =>
            t.driverId.equals(driverId) &
            t.loadDate.isBiggerOrEqualValue(start) &
            t.loadDate.isSmallerThanValue(end))
        ..limit(1);
      final rows = await query.get();
      return rows.isEmpty ? null : rows.first;
    } catch (e, st) {
      AppLogger.error('TruckLoadRepository.getTodayLoad', e, st);
      return null;
    }
  }

  Future<TruckLoad> createLoad(String driverId, String truckId) async {
    if (truckId.trim().isEmpty) {
      throw ArgumentError('truckId must be a valid UUID');
    }
    final now = DateTime.now();
    final load = TruckLoad(
      id: AppUtils.generateUuid(),
      truckId: truckId,
      driverId: driverId,
      loadDate: DateTime(now.year, now.month, now.day),
      status: 'pending',
      createdAt: now,
      synced: false,
    );

    await _db.into(_db.truckLoads).insertOnConflictUpdate(load);

    try {
      await _client.from('truck_loads').upsert({
        'id': load.id,
        'truck_id': load.truckId,
        'driver_id': load.driverId,
        'load_date': AppUtils.formatDate(load.loadDate),
        'status': load.status,
      });
      await (_db.update(_db.truckLoads)..where((t) => t.id.equals(load.id)))
          .write(const TruckLoadsCompanion(synced: Value(true)));
    } catch (e, st) {
      AppLogger.error('TruckLoadRepository.createLoad(push)', e, st);
    }
    return load;
  }

  Future<SaveResult> saveItems(
      String loadId, List<LoadItemRequest> items) async {
    try {
      await _db.transaction(() async {
        await (_db.delete(_db.truckLoadItems)
              ..where((t) => t.loadId.equals(loadId)))
            .go();
        await _db.batch((b) {
          b.insertAll(
            _db.truckLoadItems,
            items.map(
              (it) => TruckLoadItemsCompanion.insert(
                id: AppUtils.generateUuid(),
                loadId: loadId,
                productId: it.productId,
                requestedQty: Value(it.requestedQty),
                synced: const Value(false),
              ),
            ),
          );
        });
      });
    } catch (e, st) {
      AppLogger.error('TruckLoadRepository.saveItems(local)', e, st);
      return SaveResult.localOnly;
    }

    try {
      final stored = await (_db.select(_db.truckLoadItems)
            ..where((t) => t.loadId.equals(loadId)))
          .get();

      await _client.from('truck_load_items').delete().eq('load_id', loadId);

      if (stored.isNotEmpty) {
        await _client.from('truck_load_items').upsert(stored
            .map((r) => {
                  'id': r.id,
                  'load_id': r.loadId,
                  'product_id': r.productId,
                  'requested_qty': r.requestedQty,
                  'quantity_loaded': r.quantityLoaded,
                  'quantity_returned': r.quantityReturned,
                })
            .toList());
      }

      await (_db.update(_db.truckLoadItems)
            ..where((t) => t.loadId.equals(loadId)))
          .write(const TruckLoadItemsCompanion(synced: Value(true)));
      return SaveResult.synced;
    } catch (e, st) {
      AppLogger.error('TruckLoadRepository.saveItems(remote)', e, st);
      return SaveResult.localOnly;
    }
  }

  Future<void> setLocalPhotoPath(String loadId, String path) async {
    await (_db.update(_db.truckLoads)..where((t) => t.id.equals(loadId))).write(
      TruckLoadsCompanion(
        billPhotoPath: Value(path),
        synced: const Value(false),
      ),
    );
  }

  Future<SaveResult> updateBillPhoto(
    String loadId,
    String url, {
    bool remote = true,
  }) async {
    await (_db.update(_db.truckLoads)..where((t) => t.id.equals(loadId))).write(
      TruckLoadsCompanion(billPhotoUrl: Value(url), synced: const Value(false)),
    );

    if (!remote) return SaveResult.localOnly;

    try {
      await _client
          .from('truck_loads')
          .update({'bill_photo_url': url}).eq('id', loadId);
      await (_db.update(_db.truckLoads)..where((t) => t.id.equals(loadId)))
          .write(const TruckLoadsCompanion(synced: Value(true)));
      return SaveResult.synced;
    } catch (e, st) {
      AppLogger.error('TruckLoadRepository.updateBillPhoto', e, st);
      return SaveResult.localOnly;
    }
  }

  Future<List<TruckLoadItemView>> getItems(String loadId) async {
    try {
      final items = await (_db.select(_db.truckLoadItems)
            ..where((t) => t.loadId.equals(loadId)))
          .get();
      if (items.isEmpty) return [];

      final products = await _db.select(_db.products).get();
      final byId = {for (final p in products) p.id: p};

      final views = items
          .map((it) => TruckLoadItemView(item: it, product: byId[it.productId]))
          .toList();
      views.sort((a, b) => (a.product?.name ?? '')
          .toLowerCase()
          .compareTo((b.product?.name ?? '').toLowerCase()));
      return views;
    } catch (e, st) {
      AppLogger.error('TruckLoadRepository.getItems', e, st);
      return [];
    }
  }

  Future<List<Product>> activeProducts() async {
    try {
      final query = _db.select(_db.products)
        ..where((t) => t.isActive.equals(true))
        ..orderBy([(t) => OrderingTerm(expression: t.name)]);
      return await query.get();
    } catch (e, st) {
      AppLogger.error('TruckLoadRepository.activeProducts', e, st);
      return [];
    }
  }
}
