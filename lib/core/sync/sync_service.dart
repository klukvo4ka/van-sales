import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/auth_service.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../repositories/category_repository.dart';
import '../repositories/customer_repository.dart';
import '../repositories/driver_settlement_repository.dart';
import '../repositories/product_repository.dart';
import '../repositories/truck_initial_stock_repository.dart';
import '../repositories/truck_load_repository.dart';
import 'sync_policy.dart';
import '../services/storage_service.dart';
import '../services/supabase_service.dart';
import '../utils/app_logger.dart';

enum SyncStatus { idle, syncing, done, error }

class SyncService extends ChangeNotifier {
  SyncService(
      {AppDatabase? db, SupabaseClient? client, Connectivity? connectivity})
      : _db = db ?? DatabaseProvider.instance,
        _client = client ?? SupabaseService.client,
        _connectivity = connectivity ?? Connectivity() {
    _loadRepo = TruckLoadRepository(db: _db, client: _client);
    _initialStockRepo = TruckInitialStockRepository(db: _db, client: _client);
    _settlementRepo = DriverSettlementRepository(db: _db, client: _client);
    _productRepo = ProductRepository(db: _db, client: _client);
    _categoryRepo = CategoryRepository(db: _db, client: _client);
    _customerRepo = CustomerRepository(db: _db, client: _client);
  }

  DateTime? lastSyncedAt;

  bool isSyncing = false;

  final AppDatabase _db;
  final SupabaseClient _client;
  final Connectivity _connectivity;
  late final TruckLoadRepository _loadRepo;
  late final TruckInitialStockRepository _initialStockRepo;
  late final DriverSettlementRepository _settlementRepo;
  late final ProductRepository _productRepo;
  late final CategoryRepository _categoryRepo;
  late final CustomerRepository _customerRepo;

  int dirtyCount = 0;

  static final StreamController<SyncStatus> _statusController =
      StreamController<SyncStatus>.broadcast();

  static Stream<SyncStatus> get statusStream => _statusController.stream;

  final List<String> lastErrors = <String>[];

  final Set<String> _invoiceItemMirrorIds = <String>{};

  final Set<String> _pushedInvoiceIds = <String>{};

  void _emit(SyncStatus status) {
    if (!_statusController.isClosed) _statusController.add(status);
  }

  static bool _isOffline(List<ConnectivityResult> results) =>
      results.isEmpty || results.every((r) => r == ConnectivityResult.none);

  Future<void> syncNow() => syncAll();

  Future<void> syncAll() async {
    final connectivity = await _connectivity.checkConnectivity();
    if (_isOffline(connectivity)) return;
    if (isSyncing) return;

    isSyncing = true;
    notifyListeners();
    try {
      _emit(SyncStatus.syncing);
      lastErrors.clear();
      AppLogger.info('Sync', 'syncAll started');

      await _guard('photos', _uploadPendingPhotos);

      await _guard('truck_loads', _pushTruckLoads);
      await _guard('truck_load_items', _pushTruckLoadItems);
      await _guard('truck_initial_stock', _pushTruckInitialStock);
      await _guard('invoice_item_mirror_capture', _captureInvoiceItemMirrorIds);
      await _guard('invoices', _pushInvoices);
      await _guard('invoice_items', _pushInvoiceItems);
      await _guard('payments', _pushPayments);
      await _guard('driver_settlements', _pushDriverSettlements);
      await _guard('products_push', _productRepo.pushUnsynced);
      await _guard('customers_push', _pushCustomers);

      await _guard('trucks', _pullTrucks);
      await _guard('driver_profiles', _pullDriverProfiles);
      await _guard('categories', _pullCategories);
      await _guard('products', _pullProducts);
      await _guard('truck_initial_stock', _pullTruckInitialStock);
      await _guard('customers', _pullCustomers);
      await _guard('driver_settlements', _pullDriverSettlements);

      final clean = lastErrors.isEmpty;
      AppLogger.info(
        'Sync',
        clean
            ? 'syncAll finished cleanly'
            : 'syncAll finished with ${lastErrors.length} error(s)',
      );
      _emit(clean ? SyncStatus.done : SyncStatus.error);
      if (clean) lastSyncedAt = DateTime.now();
    } catch (e, st) {
      AppLogger.error('SyncService', e, st);
      _emit(SyncStatus.error);
    } finally {
      await refreshDirtyCount();
      isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> _guard(String label, Future<void> Function() op) async {
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        await op();
        return;
      } catch (e, st) {
        if (attempt == 2) {
          AppLogger.error('Sync.$label', e, st);
          lastErrors.add('$label: $e');
        } else {
          await Future.delayed(Duration(milliseconds: 500 * (1 << attempt)));
        }
      }
    }
  }

  Future<void> refreshDirtyCount() async {
    try {
      var total = 0;
      Future<int> count<T extends Table, D>(
        TableInfo<T, D> table,
        Expression<bool> Function(T tbl) where,
      ) async {
        final countExp = countAll();
        final row = await (_db.selectOnly(table)
              ..addColumns([countExp])
              ..where(where(table.asDslTable)))
            .getSingle();
        return row.read(countExp) ?? 0;
      }

      total += await count(_db.customers, (t) => t.synced.equals(false));
      total += await count(_db.products, (t) => t.synced.equals(false));
      total += await count(_db.trucks, (t) => t.synced.equals(false));
      total += await count(_db.truckLoads, (t) => t.synced.equals(false));
      total += await count(_db.truckLoadItems, (t) => t.synced.equals(false));
      total +=
          await count(_db.truckInitialStocks, (t) => t.synced.equals(false));
      total += await count(_db.invoices, (t) => t.synced.equals(false));
      total += await count(_db.invoiceItems, (t) => t.synced.equals(false));
      total += await count(_db.payments, (t) => t.synced.equals(false));
      total +=
          await count(_db.driverSettlements, (t) => t.synced.equals(false));
      dirtyCount = total;
      notifyListeners();
    } catch (e, st) {
      AppLogger.error('SyncService.refreshDirtyCount', e, st);
    }
  }

  static String _date(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static String _ts(DateTime d) => d.toUtc().toIso8601String();

  static DateTime _toDateTime(dynamic v) =>
      v == null ? DateTime.now() : DateTime.parse(v.toString());

  Future<void> _uploadPendingPhotos() async {
    final loads = await _db.select(_db.truckLoads).get();
    for (final load in loads) {
      final path = load.billPhotoPath;
      final hasLocal = path != null && path.isNotEmpty;
      final hasRemote =
          load.billPhotoUrl != null && load.billPhotoUrl!.isNotEmpty;
      if (!hasLocal || hasRemote) continue;

      try {
        final file = File(path);
        if (!await file.exists()) continue;
        final url = await StorageService.uploadLoadReceipt(load.id, file);
        if (url != null && url.isNotEmpty) {
          await _loadRepo.updateBillPhoto(load.id, url, remote: false);
        }
      } catch (e, st) {
        AppLogger.error('Sync._uploadPendingPhotos(${load.id})', e, st);
      }
    }

    final customers = await _db.select(_db.customers).get();
    for (final c in customers) {
      await _uploadCustomerPhotoSlot(
          c.id, 'outside', c.photoOutsidePath, c.photoOutsideUrl);
      await _uploadCustomerPhotoSlot(
          c.id, 'inside', c.photoInsidePath, c.photoInsideUrl);
    }

    final invoices = await _db.select(_db.invoices).get();
    for (final inv in invoices) {
      final path = inv.photoPath;
      final hasLocal = path != null && path.isNotEmpty;
      final hasRemote = inv.photoUrl != null && inv.photoUrl!.isNotEmpty;
      if (!hasLocal || hasRemote) continue;

      try {
        final file = File(path);
        if (!await file.exists()) continue;
        final url = await StorageService.uploadInvoicePhoto(inv.id, file);
        if (url != null && url.isNotEmpty) {
          await (_db.update(_db.invoices)..where((t) => t.id.equals(inv.id)))
              .write(InvoicesCompanion(
            photoUrl: Value(url),
            synced: const Value(false),
          ));
        }
      } catch (e, st) {
        AppLogger.error('Sync._uploadPendingPhotos(invoice ${inv.id})', e, st);
      }
    }
  }

  Future<void> _uploadCustomerPhotoSlot(
      String customerId, String slot, String? path, String? url) async {
    final hasLocal = path != null && path.isNotEmpty;
    final hasRemote = url != null && url.isNotEmpty;
    if (!hasLocal || hasRemote) return;
    try {
      final file = File(path);
      if (!await file.exists()) return;
      final remote =
          await StorageService.uploadCustomerPhoto(customerId, slot, file);
      if (remote == null || remote.isEmpty) return;
      await (_db.update(_db.customers)..where((t) => t.id.equals(customerId)))
          .write(CustomersCompanion(
        photoOutsideUrl:
            slot == 'outside' ? Value(remote) : const Value.absent(),
        photoInsideUrl: slot == 'inside' ? Value(remote) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
        synced: const Value(false),
      ));
    } catch (e, st) {
      AppLogger.error(
          'Sync._uploadCustomerPhotoSlot($customerId,$slot)', e, st);
    }
  }

  Future<void> _pushTruckLoads() async {
    final rows = await (_db.select(_db.truckLoads)
          ..where((t) => t.synced.equals(false)))
        .get();
    if (rows.isEmpty) return;
    await _client.from('truck_loads').upsert(rows.map((r) {
          final map = <String, dynamic>{
            'id': r.id,
            'truck_id': r.truckId,
            'driver_id': r.driverId,
            'load_date': _date(r.loadDate),
            'status': r.status,
            'created_at': _ts(r.createdAt),
          };
          if (r.billPhotoUrl != null && r.billPhotoUrl!.isNotEmpty) {
            map['bill_photo_url'] = r.billPhotoUrl;
          }
          return map;
        }).toList());
    await _markSynced(_db.truckLoads, rows.map((r) => r.id));
  }

  Future<void> _pushTruckLoadItems() async {
    final unsynced = await (_db.select(_db.truckLoadItems)
          ..where((t) => t.synced.equals(false)))
        .get();
    if (unsynced.isEmpty) return;

    final loadIds = unsynced.map((r) => r.loadId).toSet();
    for (final loadId in loadIds) {
      try {
        final current = await (_db.select(_db.truckLoadItems)
              ..where((t) => t.loadId.equals(loadId)))
            .get();

        await _client.from('truck_load_items').delete().eq('load_id', loadId);
        if (current.isNotEmpty) {
          await _client.from('truck_load_items').upsert(current
              .map((r) => {
                    'id': r.id,
                    'load_id': r.loadId,
                    'product_id': r.productId,
                    'requested_qty': r.requestedQty,
                    'quantity_loaded': r.quantityLoaded,
                    'quantity_returned': r.quantityReturned,
                    'created_at': _ts(r.createdAt),
                  })
              .toList());
        }

        await _markSynced(_db.truckLoadItems, current.map((r) => r.id));
      } catch (e, st) {
        AppLogger.error('Sync._pushTruckLoadItems($loadId)', e, st);
      }
    }
  }

  Future<void> _pushTruckInitialStock() async {
    final role = await AuthService.getUserRole();
    if (role != AuthService.roleOffice && role != AuthService.roleAdmin) return;
    await _initialStockRepo.pushUnsynced();
  }

  Future<void> _pushInvoices() async {
    final rows = await (_db.select(_db.invoices)
          ..where((t) => t.synced.equals(false)))
        .get();
    if (rows.isEmpty) return;
    await _client.from('invoices').upsert(rows.map((r) {
          final map = <String, dynamic>{
            'id': r.id,
            'invoice_number': r.invoiceNumber,
            'truck_load_id': r.truckLoadId,
            'customer_id': r.customerId,
            'driver_id': r.driverId,
            'invoice_date': _date(r.invoiceDate),
            'total_amount': r.totalAmount,
            'paid_amount': r.paidAmount,
            'status': r.status,
            'notes': r.notes,
            'created_at': _ts(r.createdAt),
          };
          if (r.photoUrl != null && r.photoUrl!.isNotEmpty) {
            map['photo_url'] = r.photoUrl;
          }
          return map;
        }).toList());
    _pushedInvoiceIds.addAll(rows.map((r) => r.id));
    await _markSynced(
      _db.invoices,
      rows.where((r) => !_invoiceItemMirrorIds.contains(r.id)).map((r) => r.id),
    );
  }

  Future<void> _captureInvoiceItemMirrorIds() async {
    _invoiceItemMirrorIds.clear();
    _pushedInvoiceIds.clear();
    final dirtyItems = await (_db.select(_db.invoiceItems)
          ..where((t) => t.synced.equals(false)))
        .get();
    _invoiceItemMirrorIds.addAll(dirtyItems.map((r) => r.invoiceId));

    final dirtyInvoices = await (_db.select(_db.invoices)
          ..where((t) => t.synced.equals(false)))
        .get();
    _invoiceItemMirrorIds.addAll(dirtyInvoices.map((r) => r.id));
  }

  Future<void> _pushInvoiceItems() async {
    final unsynced = await (_db.select(_db.invoiceItems)
          ..where((t) => t.synced.equals(false)))
        .get();
    final invoiceIds = <String>{
      ..._invoiceItemMirrorIds,
      ...unsynced.map((r) => r.invoiceId),
    };
    if (invoiceIds.isEmpty) return;

    for (final invoiceId in invoiceIds) {
      try {
        final current = await (_db.select(_db.invoiceItems)
              ..where((t) => t.invoiceId.equals(invoiceId)))
            .get();

        await _client
            .from('invoice_items')
            .delete()
            .eq('invoice_id', invoiceId);
        if (current.isNotEmpty) {
          await _client.from('invoice_items').upsert(current
              .map((r) => {
                    'id': r.id,
                    'invoice_id': r.invoiceId,
                    'product_id': r.productId,
                    'quantity': r.quantity,
                    'unit_price': r.unitPrice,
                    'created_at': _ts(r.createdAt),
                  })
              .toList());
        }

        await _markSynced(_db.invoiceItems, current.map((r) => r.id));
        if (_invoiceItemMirrorIds.contains(invoiceId)) {
          if (_pushedInvoiceIds.contains(invoiceId)) {
            await (_db.update(_db.invoices)
                  ..where((t) => t.id.equals(invoiceId)))
                .write(const InvoicesCompanion(synced: Value(true)));
          }
          _invoiceItemMirrorIds.remove(invoiceId);
        }
      } catch (e, st) {
        AppLogger.error('Sync._pushInvoiceItems($invoiceId)', e, st);
        lastErrors.add('invoice_items($invoiceId): $e');
      }
    }
  }

  Future<void> _pushPayments() async {
    final rows = await (_db.select(_db.payments)
          ..where((t) => t.synced.equals(false)))
        .get();
    if (rows.isEmpty) return;
    await _client.from('payments').upsert(rows
        .map((r) => {
              'id': r.id,
              'invoice_id': r.invoiceId,
              'customer_id': r.customerId,
              'driver_id': r.driverId,
              'amount': r.amount,
              'payment_method': r.paymentMethod,
              'payment_date': _date(r.paymentDate),
              'notes': r.notes,
              'created_at': _ts(r.createdAt),
            })
        .toList());
    await _markSynced(_db.payments, rows.map((r) => r.id));
  }

  Future<void> _pushCustomers() async {
    final rows = await (_db.select(_db.customers)
          ..where((t) => t.synced.equals(false)))
        .get();
    if (rows.isEmpty) return;
    final dirtyLedgerCustomerIds = await _customerIdsWithDirtyLedger();
    final candidates =
        rows.where((r) => !dirtyLedgerCustomerIds.contains(r.id)).toList();
    if (candidates.isEmpty) return;

    final ids = candidates.map((r) => r.id).toList();
    final serverRows = await _client
        .from('customers')
        .select('id,updated_at')
        .inFilter('id', ids);
    final serverUpdated = <String, DateTime?>{
      for (final row in serverRows)
        row['id'] as String:
            DateTime.tryParse(row['updated_at']?.toString() ?? ''),
    };
    final rowsToPush = candidates
        .where((r) => SyncPolicy.shouldPushLocalRow(
              localUpdatedAt: r.updatedAt,
              serverUpdatedAt: serverUpdated[r.id],
            ))
        .toList();

    if (rowsToPush.isNotEmpty) {
      await _client.from('customers').upsert(rowsToPush
          .map((r) => {
                'id': r.id,
                'name': r.name,
                'phone': r.phone,
                'address': r.address,
                'driver_id': r.driverId,
                'route_order': r.routeOrder,
                'route_name': r.routeName,
                'credit_limit': r.creditLimit,
                'balance': r.balance,
                'photo_outside_url': r.photoOutsideUrl,
                'photo_inside_url': r.photoInsideUrl,
                'is_active': r.isActive,
                'is_deleted': r.isDeleted,
                'created_at': _ts(r.createdAt),
              })
          .toList());
    }
    await _markSynced(_db.customers, ids);
  }

  Future<Set<String>> _customerIdsWithDirtyLedger() async {
    final ids = <String>{};

    final dirtyInvoices = await (_db.select(_db.invoices)
          ..where((t) => t.synced.equals(false)))
        .get();
    ids.addAll(dirtyInvoices.map((r) => r.customerId));

    final dirtyPayments = await (_db.select(_db.payments)
          ..where((t) => t.synced.equals(false)))
        .get();
    ids.addAll(dirtyPayments.map((r) => r.customerId));

    final invoiceItems = _db.invoiceItems;
    final invoices = _db.invoices;
    final dirtyItemRows = await (_db.select(invoiceItems).join([
      innerJoin(invoices, invoices.id.equalsExp(invoiceItems.invoiceId)),
    ])
          ..where(invoiceItems.synced.equals(false)))
        .get();
    ids.addAll(dirtyItemRows.map((r) => r.readTable(invoices).customerId));

    return ids;
  }

  Future<void> _markSynced<T extends Table, D>(
    TableInfo<T, D> table,
    Iterable<String> ids,
  ) async {
    final idList = ids.toList();
    if (idList.isEmpty) return;
    final placeholders = List.filled(idList.length, '?').join(', ');
    await _db.customUpdate(
      'UPDATE ${table.actualTableName} SET synced = 1 WHERE id IN ($placeholders)',
      variables: idList.map((id) => Variable<String>(id)).toList(),
      updates: {table},
    );
  }

  Future<void> _pullTrucks() async {
    final data = await _client.from('trucks').select();
    if (data.isEmpty) return;
    await _db.batch((b) {
      b.insertAllOnConflictUpdate(
        _db.trucks,
        data.map((row) => TrucksCompanion(
              id: Value(row['id'] as String),
              plateNumber: Value(row['plate_number'] as String),
              name: Value(row['name'] as String),
              isActive: Value(row['is_active'] as bool? ?? true),
              createdAt: Value(_toDateTime(row['created_at'])),
              synced: const Value(true),
            )),
      );
    });
  }

  Future<void> _pullDriverProfiles() async {
    final data = await _client.from('driver_profiles').select();
    if (data.isEmpty) return;
    await _db.batch((b) {
      b.insertAllOnConflictUpdate(
        _db.driverProfiles,
        data.map((row) => DriverProfilesCompanion(
              id: Value(row['id'] as String),
              fullName: Value(row['full_name'] as String? ?? 'Driver'),
              phone: Value(row['phone'] as String?),
              truckId: Value(row['truck_id'] as String?),
              role: Value(row['role'] as String? ?? 'driver'),
              isActive: Value(row['is_active'] as bool? ?? true),
              createdAt: Value(_toDateTime(row['created_at'])),
              synced: const Value(true),
            )),
      );
    });
  }

  Future<void> _pullCategories() async {
    await _categoryRepo.syncFromSupabase();
  }

  Future<void> _pullProducts() async {
    await _productRepo.syncFromSupabase();
  }

  Future<void> _pushDriverSettlements() async {
    await _settlementRepo.pushUnsynced();
  }

  Future<void> _pullDriverSettlements() async {
    await _settlementRepo.syncFromSupabase();
  }

  Future<void> _pullTruckInitialStock() async {
    await _initialStockRepo.syncFromSupabase();
  }

  Future<void> _pullCustomers() async {
    await _customerRepo.syncFromSupabase();
  }
}
