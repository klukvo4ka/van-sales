import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../locale/l10n.dart';
import '../services/supabase_service.dart';
import '../utils/app_logger.dart';

enum CompanyPeriod { day, week, month }

class TrendPoint {
  const TrendPoint({
    required this.label,
    required this.sold,
    required this.collected,
  });

  final String label;
  final double sold;
  final double collected;
}

class LeaderStat {
  const LeaderStat(
      {required this.id, required this.name, required this.amount});

  final String id;
  final String name;
  final double amount;
}

class CompanyReport {
  const CompanyReport({
    this.totalSold = 0,
    this.invoiceCount = 0,
    this.cashCollected = 0,
    this.transferCollected = 0,
    this.cashHandedIn = 0,
    this.outstanding = 0,
    this.activeDrivers = 0,
    this.customersServed = 0,
    this.trend = const [],
    this.topDriversBySold = const [],
    this.topDriversByCollected = const [],
    this.topProducts = const [],
    this.prevSold = 0,
    this.prevCollected = 0,
    this.fromCache = false,
  });

  final double totalSold;
  final int invoiceCount;
  final double cashCollected;
  final double transferCollected;
  final double cashHandedIn;
  final double outstanding;
  final int activeDrivers;
  final int customersServed;
  final List<TrendPoint> trend;
  final List<LeaderStat> topDriversBySold;
  final List<LeaderStat> topDriversByCollected;
  final List<LeaderStat> topProducts;
  final double prevSold;
  final double prevCollected;
  final bool fromCache;

  double get avgInvoice => invoiceCount == 0 ? 0 : totalSold / invoiceCount;
  double get totalCollected => cashCollected + transferCollected;
  double get newDebt {
    final d = totalSold - totalCollected;
    return d < 0 ? 0 : d;
  }

  double? get soldChangePct =>
      prevSold <= 0 ? null : (totalSold - prevSold) / prevSold * 100;
  double? get collectedChangePct => prevCollected <= 0
      ? null
      : (totalCollected - prevCollected) / prevCollected * 100;

  bool get isEmpty => invoiceCount == 0 && totalCollected == 0;
}

class _InvoiceFact {
  const _InvoiceFact({
    required this.driverId,
    required this.customerId,
    required this.total,
    required this.day,
    required this.createdAt,
  });

  final String driverId;
  final String customerId;
  final double total;
  final DateTime day;
  final DateTime createdAt;
}

class _PaymentFact {
  const _PaymentFact({
    required this.driverId,
    required this.customerId,
    required this.amount,
    required this.method,
    required this.day,
    required this.createdAt,
  });

  final String driverId;
  final String customerId;
  final double amount;
  final String method;
  final DateTime day;
  final DateTime createdAt;
}

class CompanyReportRepository {
  CompanyReportRepository({AppDatabase? db, SupabaseClient? client})
      : _db = db ?? DatabaseProvider.instance,
        _client = client ?? SupabaseService.client;

  final AppDatabase _db;
  final SupabaseClient _client;

  static (DateTime, DateTime) rangeFor(CompanyPeriod period, DateTime anchor) {
    final day = DateTime(anchor.year, anchor.month, anchor.day);
    return switch (period) {
      CompanyPeriod.day => (day, day),
      CompanyPeriod.week => (
          day.subtract(Duration(days: day.weekday - 1)),
          day
              .subtract(Duration(days: day.weekday - 1))
              .add(const Duration(days: 6)),
        ),
      CompanyPeriod.month => (
          DateTime(day.year, day.month, 1),
          DateTime(day.year, day.month + 1, 0),
        ),
    };
  }

  static DateTime previousAnchor(CompanyPeriod period, DateTime anchor) {
    final (from, _) = rangeFor(period, anchor);
    return switch (period) {
      CompanyPeriod.day => from.subtract(const Duration(days: 1)),
      CompanyPeriod.week => from.subtract(const Duration(days: 7)),
      CompanyPeriod.month => DateTime(from.year, from.month - 1, 15),
    };
  }

  static DateTime nextAnchor(CompanyPeriod period, DateTime anchor) {
    final (_, to) = rangeFor(period, anchor);
    return switch (period) {
      CompanyPeriod.day => to.add(const Duration(days: 1)),
      CompanyPeriod.week => to.add(const Duration(days: 1)),
      CompanyPeriod.month => DateTime(to.year, to.month + 1, 15),
    };
  }

  Future<CompanyReport> fetch({
    required CompanyPeriod period,
    required DateTime anchor,
  }) async {
    try {
      return await _fetchRemote(period: period, anchor: anchor);
    } catch (e, st) {
      AppLogger.error('CompanyReportRepository.fetch(remote)', e, st);
      return _fetchLocal(period: period, anchor: anchor);
    }
  }

  Future<CompanyReport> _fetchRemote({
    required CompanyPeriod period,
    required DateTime anchor,
  }) async {
    final (from, to) = rangeFor(period, anchor);
    final (prevFrom, prevTo) = rangeFor(period, previousAnchor(period, anchor));

    final invoices = await _client
        .from('invoices')
        .select('driver_id,customer_id,total_amount,invoice_date,created_at')
        .gte('invoice_date', _date(from))
        .lte('invoice_date', _date(to));
    final payments = await _client
        .from('payments')
        .select('driver_id,customer_id,amount,payment_method,'
            'payment_date,created_at')
        .gte('payment_date', _date(from))
        .lte('payment_date', _date(to));
    final settlements = await _client
        .from('driver_settlements')
        .select('amount')
        .gte('settled_date', _date(from))
        .lte('settled_date', _date(to));
    final items = await _client
        .from('invoice_items')
        .select('product_id, quantity, unit_price, '
            'invoices!inner(invoice_date)')
        .gte('invoices.invoice_date', _date(from))
        .lte('invoices.invoice_date', _date(to));
    final balances = await _client
        .from('customers')
        .select('balance')
        .eq('is_deleted', false)
        .gt('balance', 0);
    final prevInvoices = await _client
        .from('invoices')
        .select('total_amount')
        .gte('invoice_date', _date(prevFrom))
        .lte('invoice_date', _date(prevTo));
    final prevPayments = await _client
        .from('payments')
        .select('amount')
        .gte('payment_date', _date(prevFrom))
        .lte('payment_date', _date(prevTo));

    final revenueByProduct = <String, double>{};
    for (final row in items) {
      final id = row['product_id'] as String? ?? '';
      revenueByProduct[id] = (revenueByProduct[id] ?? 0) +
          _toDouble(row['quantity']) * _toDouble(row['unit_price']);
    }

    return _aggregate(
      period: period,
      from: from,
      to: to,
      invoiceFacts: invoices
          .map((r) => _InvoiceFact(
                driverId: r['driver_id'] as String? ?? '',
                customerId: r['customer_id'] as String? ?? '',
                total: _toDouble(r['total_amount']),
                day: _parseDay(r['invoice_date']),
                createdAt: _parseTs(r['created_at']),
              ))
          .toList(),
      paymentFacts: payments
          .map((r) => _PaymentFact(
                driverId: r['driver_id'] as String? ?? '',
                customerId: r['customer_id'] as String? ?? '',
                amount: _toDouble(r['amount']),
                method: r['payment_method'] as String? ?? 'cash',
                day: _parseDay(r['payment_date']),
                createdAt: _parseTs(r['created_at']),
              ))
          .toList(),
      cashHandedIn:
          settlements.fold<double>(0, (sum, r) => sum + _toDouble(r['amount'])),
      outstanding:
          balances.fold<double>(0, (sum, r) => sum + _toDouble(r['balance'])),
      revenueByProduct: revenueByProduct,
      prevSold: prevInvoices.fold<double>(
          0, (sum, r) => sum + _toDouble(r['total_amount'])),
      prevCollected: prevPayments.fold<double>(
          0, (sum, r) => sum + _toDouble(r['amount'])),
      fromCache: false,
    );
  }

  Future<CompanyReport> _fetchLocal({
    required CompanyPeriod period,
    required DateTime anchor,
  }) async {
    try {
      final (from, to) = rangeFor(period, anchor);
      final (prevFrom, prevTo) =
          rangeFor(period, previousAnchor(period, anchor));
      final end = to.add(const Duration(days: 1));
      final prevEnd = prevTo.add(const Duration(days: 1));

      final invoices = await (_db.select(_db.invoices)
            ..where((t) =>
                t.invoiceDate.isBiggerOrEqualValue(from) &
                t.invoiceDate.isSmallerThanValue(end)))
          .get();
      final payments = await (_db.select(_db.payments)
            ..where((t) =>
                t.paymentDate.isBiggerOrEqualValue(from) &
                t.paymentDate.isSmallerThanValue(end)))
          .get();
      final settlements = await (_db.select(_db.driverSettlements)
            ..where((t) =>
                t.settledDate.isBiggerOrEqualValue(from) &
                t.settledDate.isSmallerThanValue(end)))
          .get();
      final customers = await (_db.select(_db.customers)
            ..where((t) =>
                t.isDeleted.equals(false) & t.balance.isBiggerThanValue(0)))
          .get();
      final invoiceIds = invoices.map((i) => i.id).toList();
      final items = invoiceIds.isEmpty
          ? <InvoiceItem>[]
          : await (_db.select(_db.invoiceItems)
                ..where((t) => t.invoiceId.isIn(invoiceIds)))
              .get();
      final prevInvoices = await (_db.select(_db.invoices)
            ..where((t) =>
                t.invoiceDate.isBiggerOrEqualValue(prevFrom) &
                t.invoiceDate.isSmallerThanValue(prevEnd)))
          .get();
      final prevPayments = await (_db.select(_db.payments)
            ..where((t) =>
                t.paymentDate.isBiggerOrEqualValue(prevFrom) &
                t.paymentDate.isSmallerThanValue(prevEnd)))
          .get();

      final revenueByProduct = <String, double>{};
      for (final it in items) {
        revenueByProduct[it.productId] =
            (revenueByProduct[it.productId] ?? 0) + it.quantity * it.unitPrice;
      }

      return _aggregate(
        period: period,
        from: from,
        to: to,
        invoiceFacts: invoices
            .map((i) => _InvoiceFact(
                  driverId: i.driverId,
                  customerId: i.customerId,
                  total: i.totalAmount,
                  day: DateTime(i.invoiceDate.year, i.invoiceDate.month,
                      i.invoiceDate.day),
                  createdAt: i.createdAt,
                ))
            .toList(),
        paymentFacts: payments
            .map((p) => _PaymentFact(
                  driverId: p.driverId,
                  customerId: p.customerId,
                  amount: p.amount,
                  method: p.paymentMethod,
                  day: DateTime(p.paymentDate.year, p.paymentDate.month,
                      p.paymentDate.day),
                  createdAt: p.createdAt,
                ))
            .toList(),
        cashHandedIn: settlements.fold<double>(0, (sum, s) => sum + s.amount),
        outstanding: customers.fold<double>(0, (sum, c) => sum + c.balance),
        revenueByProduct: revenueByProduct,
        prevSold: prevInvoices.fold<double>(0, (sum, i) => sum + i.totalAmount),
        prevCollected: prevPayments.fold<double>(0, (sum, p) => sum + p.amount),
        fromCache: true,
      );
    } catch (e, st) {
      AppLogger.error('CompanyReportRepository._fetchLocal', e, st);
      return const CompanyReport(fromCache: true);
    }
  }

  Future<CompanyReport> _aggregate({
    required CompanyPeriod period,
    required DateTime from,
    required DateTime to,
    required List<_InvoiceFact> invoiceFacts,
    required List<_PaymentFact> paymentFacts,
    required double cashHandedIn,
    required double outstanding,
    required Map<String, double> revenueByProduct,
    required double prevSold,
    required double prevCollected,
    required bool fromCache,
  }) async {
    var totalSold = 0.0;
    final soldByDriver = <String, double>{};
    final driverIds = <String>{};
    final customerIds = <String>{};
    for (final inv in invoiceFacts) {
      totalSold += inv.total;
      if (inv.driverId.isNotEmpty) {
        driverIds.add(inv.driverId);
        soldByDriver[inv.driverId] =
            (soldByDriver[inv.driverId] ?? 0) + inv.total;
      }
      if (inv.customerId.isNotEmpty) customerIds.add(inv.customerId);
    }

    var cashCollected = 0.0, transferCollected = 0.0;
    final collectedByDriver = <String, double>{};
    for (final p in paymentFacts) {
      if (p.method == 'transfer') {
        transferCollected += p.amount;
      } else {
        cashCollected += p.amount;
      }
      if (p.driverId.isNotEmpty) {
        driverIds.add(p.driverId);
        collectedByDriver[p.driverId] =
            (collectedByDriver[p.driverId] ?? 0) + p.amount;
      }
      if (p.customerId.isNotEmpty) customerIds.add(p.customerId);
    }

    final profiles = await _db.select(_db.driverProfiles).get();
    final driverNames = {for (final p in profiles) p.id: p.fullName};
    List<LeaderStat> rankDrivers(Map<String, double> byDriver) =>
        byDriver.entries
            .where((e) => e.value > 0)
            .map((e) => LeaderStat(
                  id: e.key,
                  name: driverNames[e.key] ?? l10n.driver,
                  amount: e.value,
                ))
            .toList()
          ..sort((a, b) => b.amount.compareTo(a.amount));

    final products = await _db.select(_db.products).get();
    final productById = {for (final p in products) p.id: p};
    final topProducts =
        revenueByProduct.entries.where((e) => e.value > 0).map((e) {
      final p = productById[e.key];
      final name = p == null
          ? e.key
          : (p.nameFa == null || p.nameFa!.isEmpty
              ? p.name
              : '${p.name} · ${p.nameFa}');
      return LeaderStat(id: e.key, name: name, amount: e.value);
    }).toList()
          ..sort((a, b) => b.amount.compareTo(a.amount));

    return CompanyReport(
      totalSold: totalSold,
      invoiceCount: invoiceFacts.length,
      cashCollected: cashCollected,
      transferCollected: transferCollected,
      cashHandedIn: cashHandedIn,
      outstanding: outstanding,
      activeDrivers: driverIds.length,
      customersServed: customerIds.length,
      trend: _buildTrend(period, from, to, invoiceFacts, paymentFacts),
      topDriversBySold: rankDrivers(soldByDriver),
      topDriversByCollected: rankDrivers(collectedByDriver),
      topProducts: topProducts,
      prevSold: prevSold,
      prevCollected: prevCollected,
      fromCache: fromCache,
    );
  }

  static List<TrendPoint> _buildTrend(
    CompanyPeriod period,
    DateTime from,
    DateTime to,
    List<_InvoiceFact> invoiceFacts,
    List<_PaymentFact> paymentFacts,
  ) {
    switch (period) {
      case CompanyPeriod.day:
        final sold = List.filled(24, 0.0);
        final collected = List.filled(24, 0.0);
        for (final inv in invoiceFacts) {
          sold[inv.createdAt.toLocal().hour] += inv.total;
        }
        for (final p in paymentFacts) {
          collected[p.createdAt.toLocal().hour] += p.amount;
        }
        return [
          for (var h = 0; h < 24; h++)
            TrendPoint(
              label: h % 6 == 0 ? '$h' : '',
              sold: sold[h],
              collected: collected[h],
            ),
        ];
      case CompanyPeriod.week:
        final sold = List.filled(7, 0.0);
        final collected = List.filled(7, 0.0);
        int index(DateTime d) => d.difference(from).inDays.clamp(0, 6);
        for (final inv in invoiceFacts) {
          sold[index(inv.day)] += inv.total;
        }
        for (final p in paymentFacts) {
          collected[index(p.day)] += p.amount;
        }
        return [
          for (var i = 0; i < 7; i++)
            TrendPoint(
              label: '${from.add(Duration(days: i)).day}',
              sold: sold[i],
              collected: collected[i],
            ),
        ];
      case CompanyPeriod.month:
        final weeks = ((to.day - 1) ~/ 7) + 1;
        final sold = List.filled(weeks, 0.0);
        final collected = List.filled(weeks, 0.0);
        int index(DateTime d) => ((d.day - 1) ~/ 7).clamp(0, weeks - 1);
        for (final inv in invoiceFacts) {
          sold[index(inv.day)] += inv.total;
        }
        for (final p in paymentFacts) {
          collected[index(p.day)] += p.amount;
        }
        return [
          for (var w = 0; w < weeks; w++)
            TrendPoint(
              label: 'W${w + 1}',
              sold: sold[w],
              collected: collected[w],
            ),
        ];
    }
  }

  static DateTime _parseDay(dynamic v) {
    final parsed = DateTime.tryParse(v?.toString() ?? '') ?? DateTime.now();
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  static DateTime _parseTs(dynamic v) =>
      DateTime.tryParse(v?.toString() ?? '')?.toLocal() ?? DateTime.now();

  static String _date(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static double _toDouble(dynamic v) => v == null
      ? 0
      : v is num
          ? v.toDouble()
          : double.tryParse(v.toString()) ?? 0;
}
