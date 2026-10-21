import 'dart:io';

import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../services/storage_service.dart';
import '../services/supabase_service.dart';
import '../sync/sync_policy.dart';
import '../utils/app_logger.dart';

enum SaveResult { synced, localOnly }

class DebtSummary {
  const DebtSummary({
    this.totalInvoiced = 0,
    this.totalPaid = 0,
    this.unpaidCount = 0,
  });

  final double totalInvoiced;
  final double totalPaid;
  final int unpaidCount;

  double get outstanding {
    final diff = totalInvoiced - totalPaid;
    return diff < 0 ? 0 : diff;
  }
}

class CustomerRepository {
  CustomerRepository({AppDatabase? db, SupabaseClient? client})
      : _db = db ?? DatabaseProvider.instance,
        _client = client ?? SupabaseService.client;

  final AppDatabase _db;
  final SupabaseClient _client;

  Future<List<Customer>> getForDriver(String driverId) async {
    try {
      final query = _db.select(_db.customers)
        ..where((t) => t.driverId.equals(driverId) & t.isDeleted.equals(false))
        ..orderBy([
          (t) => OrderingTerm(expression: t.routeOrder),
          (t) => OrderingTerm(expression: t.name),
        ]);
      return await query.get();
    } catch (e, st) {
      AppLogger.error('CustomerRepository.getForDriver', e, st);
      return [];
    }
  }

  Future<Customer?> getById(String id) async {
    try {
      final query = _db.select(_db.customers)..where((t) => t.id.equals(id));
      return await query.getSingleOrNull();
    } catch (e, st) {
      AppLogger.error('CustomerRepository.getById', e, st);
      return null;
    }
  }

  Future<List<Customer>> getAll() async {
    try {
      final query = _db.select(_db.customers)
        ..where((t) => t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm(expression: t.name)]);
      return await query.get();
    } catch (e, st) {
      AppLogger.error('CustomerRepository.getAll', e, st);
      return [];
    }
  }

  Future<bool> syncFromSupabase([String? driverId]) async {
    try {
      var query = _client.from('customers').select();
      final data = driverId == null
          ? await query
          : await query.eq('driver_id', driverId);
      if (data.isEmpty) return true;
      final localRows = await _db.select(_db.customers).get();
      final localById = {for (final c in localRows) c.id: c};
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
          _db.customers,
          rows.map(
            (row) => CustomersCompanion(
              id: Value(row['id'] as String),
              name: Value(row['name'] as String),
              phone: Value(row['phone'] as String?),
              address: Value(row['address'] as String?),
              driverId: Value(row['driver_id'] as String?),
              routeOrder: Value((row['route_order'] as num?)?.toInt() ?? 0),
              routeName: Value(row['route_name'] as String?),
              creditLimit: Value(_toDouble(row['credit_limit'])),
              balance: Value(_toDouble(row['balance'])),
              photoOutsideUrl: Value(StorageService.normalizeObjectPath(
                  StorageService.customerPhotosBucket,
                  row['photo_outside_url'] as String?)),
              photoInsideUrl: Value(StorageService.normalizeObjectPath(
                  StorageService.customerPhotosBucket,
                  row['photo_inside_url'] as String?)),
              isActive: Value(row['is_active'] as bool? ?? true),
              isDeleted: Value(row['is_deleted'] as bool? ?? false),
              updatedAt: Value(_toDateTime(row['updated_at']).toLocal()),
              createdAt: Value(_toDateTime(row['created_at'])),
              synced: const Value(true),
            ),
          ),
        );
      });
      return true;
    } catch (e, st) {
      AppLogger.error('CustomerRepository.syncFromSupabase', e, st);
      return false;
    }
  }

  Future<SaveResult> save({
    required String id,
    required String name,
    String? phone,
    String? address,
    String? driverId,
    int routeOrder = 0,
    String? routeName,
    double creditLimit = 0,
    String? photoOutsidePath,
    String? photoInsidePath,
    String? photoOutsideUrl,
    String? photoInsideUrl,
  }) async {
    await _db.into(_db.customers).insertOnConflictUpdate(
          CustomersCompanion(
            id: Value(id),
            name: Value(name),
            phone: Value(phone),
            address: Value(address),
            driverId: Value(driverId),
            routeOrder: Value(routeOrder),
            routeName: Value(routeName),
            creditLimit: Value(creditLimit),
            photoOutsidePath: Value(photoOutsidePath),
            photoInsidePath: Value(photoInsidePath),
            photoOutsideUrl: Value(photoOutsideUrl),
            photoInsideUrl: Value(photoInsideUrl),
            updatedAt: Value(DateTime.now()),
            synced: const Value(false),
          ),
        );

    final outsideUrl = await _uploadPhotoIfPending(
        id, 'outside', photoOutsidePath, photoOutsideUrl);
    final insideUrl = await _uploadPhotoIfPending(
        id, 'inside', photoInsidePath, photoInsideUrl);
    if (outsideUrl != photoOutsideUrl || insideUrl != photoInsideUrl) {
      await (_db.update(_db.customers)..where((t) => t.id.equals(id))).write(
        CustomersCompanion(
          photoOutsideUrl: Value(outsideUrl),
          photoInsideUrl: Value(insideUrl),
        ),
      );
    }

    try {
      await _client.from('customers').upsert({
        'id': id,
        'name': name,
        'phone': phone,
        'address': address,
        'driver_id': driverId,
        'route_order': routeOrder,
        'route_name': routeName,
        'credit_limit': creditLimit,
        'photo_outside_url': outsideUrl,
        'photo_inside_url': insideUrl,
      });
      await (_db.update(_db.customers)..where((t) => t.id.equals(id)))
          .write(const CustomersCompanion(synced: Value(true)));
      return SaveResult.synced;
    } catch (e, st) {
      AppLogger.error('CustomerRepository.save', e, st);
      return SaveResult.localOnly;
    }
  }

  Future<String?> _uploadPhotoIfPending(
      String customerId, String slot, String? localPath, String? url) async {
    if (url != null && url.isNotEmpty) return url;
    if (localPath == null || localPath.isEmpty) return null;
    try {
      final file = File(localPath);
      if (!await file.exists()) return null;
      return await StorageService.uploadCustomerPhoto(customerId, slot, file);
    } catch (e, st) {
      AppLogger.error(
          'CustomerRepository._uploadPhotoIfPending($customerId,$slot)', e, st);
      return null;
    }
  }

  Future<DebtSummary> getDebtSummary(String customerId) async {
    try {
      final inv = _db.invoices;
      final invoicedSum = inv.totalAmount.sum();
      final openCount =
          countAll(filter: inv.status.isIn(const ['unpaid', 'partial']));
      final invRow = await (_db.selectOnly(inv)
            ..addColumns([invoicedSum, openCount])
            ..where(inv.customerId.equals(customerId)))
          .getSingle();

      final pay = _db.payments;
      final paidSum = pay.amount.sum();
      final payRow = await (_db.selectOnly(pay)
            ..addColumns([paidSum])
            ..where(pay.customerId.equals(customerId)))
          .getSingle();

      return DebtSummary(
        totalInvoiced: invRow.read(invoicedSum) ?? 0,
        totalPaid: payRow.read(paidSum) ?? 0,
        unpaidCount: invRow.read(openCount) ?? 0,
      );
    } catch (e, st) {
      AppLogger.error('CustomerRepository.getDebtSummary', e, st);
      return const DebtSummary();
    }
  }

  Future<double> recomputeBalance(String customerId) async {
    try {
      final summary = await getDebtSummary(customerId);
      final balance = summary.outstanding;

      final customer = await getById(customerId);
      if (customer == null || customer.balance == balance) return balance;

      final wasSynced = customer.synced;
      await (_db.update(_db.customers)..where((t) => t.id.equals(customerId)))
          .write(CustomersCompanion(
        balance: Value(balance),
        updatedAt: Value(DateTime.now()),
        synced: const Value(false),
      ));
      try {
        await _client
            .from('customers')
            .update({'balance': balance}).eq('id', customerId);
        if (wasSynced) {
          await (_db.update(_db.customers)
                ..where((t) => t.id.equals(customerId)))
              .write(const CustomersCompanion(synced: Value(true)));
        }
      } catch (e, st) {
        AppLogger.error('CustomerRepository.recomputeBalance(push)', e, st);
      }
      return balance;
    } catch (e, st) {
      AppLogger.error('CustomerRepository.recomputeBalance', e, st);
      return 0;
    }
  }

  Future<void> reconcileBalances(String driverId) async {
    try {
      final invoicedBy = <String, double>{};
      final paidBy = <String, double>{};

      final inv = _db.invoices;
      final invoicedSum = inv.totalAmount.sum();
      final invRows = await (_db.selectOnly(inv)
            ..addColumns([inv.customerId, invoicedSum])
            ..groupBy([inv.customerId]))
          .get();
      for (final row in invRows) {
        invoicedBy[row.read(inv.customerId)!] = row.read(invoicedSum) ?? 0;
      }

      final pay = _db.payments;
      final paidSum = pay.amount.sum();
      final payRows = await (_db.selectOnly(pay)
            ..addColumns([pay.customerId, paidSum])
            ..groupBy([pay.customerId]))
          .get();
      for (final row in payRows) {
        paidBy[row.read(pay.customerId)!] = row.read(paidSum) ?? 0;
      }

      final customers = await getForDriver(driverId);
      for (final c in customers) {
        final diff = (invoicedBy[c.id] ?? 0) - (paidBy[c.id] ?? 0);
        final expected = diff < 0 ? 0.0 : diff;
        if (c.balance == expected) continue;
        await (_db.update(_db.customers)..where((t) => t.id.equals(c.id)))
            .write(CustomersCompanion(
          balance: Value(expected),
          updatedAt: Value(DateTime.now()),
          synced: const Value(false),
        ));
      }
    } catch (e, st) {
      AppLogger.error('CustomerRepository.reconcileBalances', e, st);
    }
  }

  Future<List<String>> getRouteNames(String driverId) async {
    try {
      final c = _db.customers;
      final query = _db.selectOnly(c, distinct: true)
        ..addColumns([c.routeName])
        ..where(c.driverId.equals(driverId) &
            c.isDeleted.equals(false) &
            c.routeName.isNotNull());
      final rows = await query.get();
      final names = rows
          .map((r) => r.read(c.routeName))
          .whereType<String>()
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      return names;
    } catch (e, st) {
      AppLogger.error('CustomerRepository.getRouteNames', e, st);
      return [];
    }
  }

  Future<void> setVisited(String id, bool visited) async {
    try {
      await (_db.update(_db.customers)..where((t) => t.id.equals(id))).write(
        CustomersCompanion(
          visitedDate: Value(visited ? DateTime.now() : null),
        ),
      );
    } catch (e, st) {
      AppLogger.error('CustomerRepository.setVisited', e, st);
    }
  }

  Future<SaveResult> saveRouteOrder(List<Customer> ordered) async {
    final previouslySynced =
        ordered.where((c) => c.synced).map((c) => c.id).toList();
    final now = DateTime.now();
    try {
      await _db.transaction(() async {
        for (var i = 0; i < ordered.length; i++) {
          await (_db.update(_db.customers)
                ..where((t) => t.id.equals(ordered[i].id)))
              .write(CustomersCompanion(
            routeOrder: Value(i + 1),
            updatedAt: Value(now),
            synced: const Value(false),
          ));
        }
      });
    } catch (e, st) {
      AppLogger.error('CustomerRepository.saveRouteOrder(local)', e, st);
      return SaveResult.localOnly;
    }
    try {
      for (var i = 0; i < ordered.length; i++) {
        await _client
            .from('customers')
            .update({'route_order': i + 1}).eq('id', ordered[i].id);
      }
      if (previouslySynced.isNotEmpty) {
        await (_db.update(_db.customers)
              ..where((t) => t.id.isIn(previouslySynced)))
            .write(const CustomersCompanion(synced: Value(true)));
      }
      return SaveResult.synced;
    } catch (e, st) {
      AppLogger.error('CustomerRepository.saveRouteOrder(remote)', e, st);
      return SaveResult.localOnly;
    }
  }

  Future<SaveResult> delete(String id) async {
    try {
      await (_db.update(_db.customers)..where((t) => t.id.equals(id))).write(
        CustomersCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(DateTime.now()),
          synced: const Value(false),
        ),
      );
    } catch (e, st) {
      AppLogger.error('CustomerRepository.delete(local)', e, st);
      return SaveResult.localOnly;
    }
    try {
      await _client.from('customers').update({'is_deleted': true}).eq('id', id);
      await (_db.update(_db.customers)..where((t) => t.id.equals(id)))
          .write(const CustomersCompanion(synced: Value(true)));
      return SaveResult.synced;
    } catch (e, st) {
      AppLogger.error('CustomerRepository.delete(remote)', e, st);
      return SaveResult.localOnly;
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
