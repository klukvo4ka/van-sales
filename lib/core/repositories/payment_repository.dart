import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../services/supabase_service.dart';
import '../utils/app_logger.dart';
import '../utils/app_utils.dart';
import 'customer_repository.dart' show CustomerRepository, SaveResult;
import 'invoice_repository.dart' show InvoiceRepository;

class PaymentRepository {
  PaymentRepository({AppDatabase? db, SupabaseClient? client})
      : _db = db ?? DatabaseProvider.instance,
        _client = client ?? SupabaseService.client;

  final AppDatabase _db;
  final SupabaseClient _client;

  Future<void> hydrateForCustomer(String customerId) async {
    try {
      final rows =
          await _client.from('payments').select().eq('customer_id', customerId);
      if (rows.isEmpty) return;

      final localRows = await (_db.select(_db.payments)
            ..where((t) => t.customerId.equals(customerId)))
          .get();
      final dirtyIds =
          localRows.where((r) => !r.synced).map((r) => r.id).toSet();
      final cleanRows =
          rows.where((row) => !dirtyIds.contains(row['id'])).toList();
      if (cleanRows.isEmpty) return;

      await _db.batch((b) {
        b.insertAllOnConflictUpdate(
          _db.payments,
          cleanRows.map((row) => PaymentsCompanion(
                id: Value(row['id'] as String),
                invoiceId: Value(row['invoice_id'] as String?),
                customerId: Value(row['customer_id'] as String),
                driverId: Value(row['driver_id'] as String),
                amount: Value(_toDouble(row['amount'])),
                paymentMethod:
                    Value(row['payment_method'] as String? ?? 'cash'),
                paymentDate: Value(_toDateTime(row['payment_date'])),
                notes: Value(row['notes'] as String?),
                createdAt: Value(_toDateTime(row['created_at'])),
                synced: const Value(true),
              )),
        );
      });
    } catch (e, st) {
      AppLogger.error('PaymentRepository.hydrateForCustomer', e, st);
    }
  }

  static double _toDouble(dynamic v) => v == null
      ? 0
      : v is num
          ? v.toDouble()
          : double.tryParse(v.toString()) ?? 0;

  static DateTime _toDateTime(dynamic v) =>
      v == null ? DateTime.now() : DateTime.parse(v.toString());

  Future<List<Payment>> getForCustomer(String customerId) async {
    try {
      final query = _db.select(_db.payments)
        ..where((t) => t.customerId.equals(customerId))
        ..orderBy([
          (t) =>
              OrderingTerm(expression: t.paymentDate, mode: OrderingMode.desc),
          (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
        ]);
      return await query.get();
    } catch (e, st) {
      AppLogger.error('PaymentRepository.getForCustomer', e, st);
      return [];
    }
  }

  Future<SaveResult> create({
    required String customerId,
    required String driverId,
    required double amount,
    required String method,
    String? notes,
    DateTime? date,
  }) async {
    final id = AppUtils.generateUuid();
    final paymentDate = date ?? DateTime.now();

    await _db.into(_db.payments).insert(PaymentsCompanion(
          id: Value(id),
          invoiceId: const Value(null),
          customerId: Value(customerId),
          driverId: Value(driverId),
          amount: Value(amount),
          paymentMethod: Value(method),
          paymentDate: Value(paymentDate),
          notes: Value(notes),
          synced: const Value(false),
        ));

    SaveResult result;
    try {
      await _client.from('payments').upsert({
        'id': id,
        'invoice_id': null,
        'customer_id': customerId,
        'driver_id': driverId,
        'amount': amount,
        'payment_method': method,
        'payment_date': _date(paymentDate),
        'notes': notes,
      });
      await (_db.update(_db.payments)..where((t) => t.id.equals(id)))
          .write(const PaymentsCompanion(synced: Value(true)));
      result = SaveResult.synced;
    } catch (e, st) {
      AppLogger.error('PaymentRepository.create', e, st);
      result = SaveResult.localOnly;
    }

    await InvoiceRepository(db: _db, client: _client)
        .allocateToOpenInvoices(customerId, amount);
    await CustomerRepository(db: _db, client: _client)
        .recomputeBalance(customerId);
    return result;
  }

  static String _date(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
