import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../services/supabase_service.dart';
import '../utils/app_logger.dart';
import '../utils/app_utils.dart';
import 'customer_repository.dart' show SaveResult;

class DriverSettlementRepository {
  DriverSettlementRepository({AppDatabase? db, SupabaseClient? client})
      : _db = db ?? DatabaseProvider.instance,
        _client = client ?? SupabaseService.client;

  final AppDatabase _db;
  final SupabaseClient _client;

  Future<SaveResult> create({
    required String driverId,
    required double amount,
    required DateTime date,
    String? notes,
  }) async {
    if (amount <= 0) {
      throw ArgumentError.value(amount, 'amount', 'must be greater than 0');
    }
    final id = AppUtils.generateUuid();
    await _db.into(_db.driverSettlements).insert(DriverSettlementsCompanion(
          id: Value(id),
          driverId: Value(driverId),
          amount: Value(amount),
          settledDate: Value(DateTime(date.year, date.month, date.day)),
          notes: Value(notes),
          synced: const Value(false),
        ));
    try {
      await _client.from('driver_settlements').upsert({
        'id': id,
        'driver_id': driverId,
        'amount': amount,
        'settled_date': AppUtils.formatDate(date),
        'notes': notes,
      });
      await (_db.update(_db.driverSettlements)..where((t) => t.id.equals(id)))
          .write(const DriverSettlementsCompanion(synced: Value(true)));
      return SaveResult.synced;
    } catch (e, st) {
      AppLogger.error('DriverSettlementRepository.create', e, st);
      return SaveResult.localOnly;
    }
  }

  Future<void> pushUnsynced() async {
    final rows = await (_db.select(_db.driverSettlements)
          ..where((t) => t.synced.equals(false)))
        .get();
    if (rows.isEmpty) return;
    await _client.from('driver_settlements').upsert(rows
        .map((r) => {
              'id': r.id,
              'driver_id': r.driverId,
              'amount': r.amount,
              'settled_date': AppUtils.formatDate(r.settledDate),
              'notes': r.notes,
              'created_at': r.createdAt.toUtc().toIso8601String(),
            })
        .toList());
    final ids = rows.map((r) => r.id).toList();
    await (_db.update(_db.driverSettlements)..where((t) => t.id.isIn(ids)))
        .write(const DriverSettlementsCompanion(synced: Value(true)));
  }

  Future<bool> syncFromSupabase() async {
    try {
      final data = await _client.from('driver_settlements').select();
      if (data.isEmpty) return true;
      final dirtyRows = await (_db.select(_db.driverSettlements)
            ..where((t) => t.synced.equals(false)))
          .get();
      final dirtyIds = dirtyRows.map((r) => r.id).toSet();
      final rows = data.where((row) => !dirtyIds.contains(row['id'])).toList();
      if (rows.isEmpty) return true;
      await _db.batch((b) {
        b.insertAllOnConflictUpdate(
          _db.driverSettlements,
          rows.map((row) => DriverSettlementsCompanion(
                id: Value(row['id'] as String),
                driverId: Value(row['driver_id'] as String),
                amount: Value(_toDouble(row['amount'])),
                settledDate: Value(_toDateTime(row['settled_date'])),
                notes: Value(row['notes'] as String?),
                createdAt: Value(_toDateTime(row['created_at'])),
                synced: const Value(true),
              )),
        );
      });
      return true;
    } catch (e, st) {
      AppLogger.error('DriverSettlementRepository.syncFromSupabase', e, st);
      return false;
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
