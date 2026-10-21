import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../services/supabase_service.dart';
import '../utils/app_logger.dart';

enum AgingBucket { current, d8to30, d31to60, d60plus }

class ReceivableRow {
  ReceivableRow({required this.customer, required this.oldestUnpaid});

  final Customer customer;
  final DateTime? oldestUnpaid;

  double get outstanding => customer.balance;

  int get daysOverdue {
    final oldest = oldestUnpaid;
    if (oldest == null) return 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(oldest.year, oldest.month, oldest.day);
    final diff = today.difference(day).inDays;
    return diff < 0 ? 0 : diff;
  }

  AgingBucket get bucket {
    final days = daysOverdue;
    if (days <= 7) return AgingBucket.current;
    if (days <= 30) return AgingBucket.d8to30;
    if (days <= 60) return AgingBucket.d31to60;
    return AgingBucket.d60plus;
  }
}

class ReceivablesReport {
  const ReceivablesReport({this.rows = const [], this.fromCache = false});

  final List<ReceivableRow> rows;
  final bool fromCache;

  double get grandTotal => rows.fold(0, (sum, r) => sum + r.outstanding);

  Map<AgingBucket, double> get bucketTotals {
    final map = {for (final b in AgingBucket.values) b: 0.0};
    for (final r in rows) {
      map[r.bucket] = map[r.bucket]! + r.outstanding;
    }
    return map;
  }
}

class ReceivablesReportRepository {
  ReceivablesReportRepository({AppDatabase? db, SupabaseClient? client})
      : _db = db ?? DatabaseProvider.instance,
        _client = client ?? SupabaseService.client;

  final AppDatabase _db;
  final SupabaseClient _client;

  Future<ReceivablesReport> fetch() async {
    try {
      return await _fetchRemote();
    } catch (e, st) {
      AppLogger.error('ReceivablesReportRepository.fetch(remote)', e, st);
      return _fetchLocal();
    }
  }

  Future<ReceivablesReport> _fetchRemote() async {
    final customerRows = await _client
        .from('customers')
        .select()
        .eq('is_deleted', false)
        .gt('balance', 0);
    final invoiceRows = await _client
        .from('invoices')
        .select('customer_id,invoice_date,status')
        .inFilter('status', ['unpaid', 'partial']);

    final oldestByCustomer = <String, DateTime>{};
    for (final row in invoiceRows) {
      final customerId = row['customer_id'] as String? ?? '';
      final date = DateTime.tryParse(row['invoice_date']?.toString() ?? '');
      if (customerId.isEmpty || date == null) continue;
      final prev = oldestByCustomer[customerId];
      if (prev == null || date.isBefore(prev)) {
        oldestByCustomer[customerId] = date;
      }
    }

    final rows = customerRows
        .map((row) => ReceivableRow(
              customer: _customerFromRow(row),
              oldestUnpaid: oldestByCustomer[row['id'] as String? ?? ''],
            ))
        .toList();
    return ReceivablesReport(rows: rows);
  }

  Future<ReceivablesReport> _fetchLocal() async {
    try {
      final customers = await (_db.select(_db.customers)
            ..where((t) =>
                t.isDeleted.equals(false) & t.balance.isBiggerThanValue(0)))
          .get();
      final openInvoices = await (_db.select(_db.invoices)
            ..where((t) => t.status.isIn(const ['unpaid', 'partial'])))
          .get();

      final oldestByCustomer = <String, DateTime>{};
      for (final inv in openInvoices) {
        final prev = oldestByCustomer[inv.customerId];
        if (prev == null || inv.invoiceDate.isBefore(prev)) {
          oldestByCustomer[inv.customerId] = inv.invoiceDate;
        }
      }

      final rows = customers
          .map((c) => ReceivableRow(
                customer: c,
                oldestUnpaid: oldestByCustomer[c.id],
              ))
          .toList();
      return ReceivablesReport(rows: rows, fromCache: true);
    } catch (e, st) {
      AppLogger.error('ReceivablesReportRepository._fetchLocal', e, st);
      return const ReceivablesReport(fromCache: true);
    }
  }

  static Customer _customerFromRow(Map<String, dynamic> row) => Customer(
        id: row['id'] as String,
        name: row['name'] as String? ?? '',
        phone: row['phone'] as String?,
        address: row['address'] as String?,
        driverId: row['driver_id'] as String?,
        routeOrder: (row['route_order'] as num?)?.toInt() ?? 0,
        routeName: row['route_name'] as String?,
        creditLimit: _toDouble(row['credit_limit']),
        balance: _toDouble(row['balance']),
        photoOutsidePath: null,
        photoInsidePath: null,
        photoOutsideUrl: row['photo_outside_url'] as String?,
        photoInsideUrl: row['photo_inside_url'] as String?,
        visitedDate: null,
        isActive: row['is_active'] as bool? ?? true,
        isDeleted: row['is_deleted'] as bool? ?? false,
        updatedAt:
            DateTime.tryParse(row['updated_at']?.toString() ?? '')?.toLocal() ??
                DateTime.now(),
        createdAt: DateTime.tryParse(row['created_at']?.toString() ?? '') ??
            DateTime.now(),
        synced: true,
      );

  static double _toDouble(dynamic v) => v == null
      ? 0
      : v is num
          ? v.toDouble()
          : double.tryParse(v.toString()) ?? 0;
}
