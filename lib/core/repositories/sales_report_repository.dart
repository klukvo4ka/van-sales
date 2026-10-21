import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../locale/l10n.dart';
import '../services/supabase_service.dart';
import '../utils/app_logger.dart';

class ProductSalesStat {
  const ProductSalesStat({
    required this.productId,
    required this.name,
    this.nameFa,
    required this.unit,
    required this.qty,
    required this.revenue,
  });

  final String productId;
  final String name;
  final String? nameFa;
  final String unit;
  final double qty;
  final double revenue;
}

class CustomerSalesStat {
  const CustomerSalesStat({
    required this.customerId,
    required this.name,
    required this.amount,
  });

  final String customerId;
  final String name;
  final double amount;
}

class DailySalesStat {
  const DailySalesStat({
    required this.date,
    required this.sold,
    required this.collected,
  });

  final DateTime date;
  final double sold;
  final double collected;
}

class SalesReport {
  const SalesReport({
    this.totalSold = 0,
    this.invoiceCount = 0,
    this.cashCount = 0,
    this.cashAmount = 0,
    this.partialCount = 0,
    this.partialAmount = 0,
    this.creditCount = 0,
    this.creditAmount = 0,
    this.cashCollected = 0,
    this.transferCollected = 0,
    this.topProducts = const [],
    this.topCustomersBySold = const [],
    this.topCustomersByOutstanding = const [],
    this.daily = const [],
    this.fromCache = false,
  });

  final double totalSold;
  final int invoiceCount;
  final int cashCount;
  final double cashAmount;
  final int partialCount;
  final double partialAmount;
  final int creditCount;
  final double creditAmount;
  final double cashCollected;
  final double transferCollected;
  final List<ProductSalesStat> topProducts;
  final List<CustomerSalesStat> topCustomersBySold;
  final List<CustomerSalesStat> topCustomersByOutstanding;
  final List<DailySalesStat> daily;
  final bool fromCache;

  double get avgInvoice => invoiceCount == 0 ? 0 : totalSold / invoiceCount;
  double get totalCollected => cashCollected + transferCollected;
  double get newDebt {
    final d = totalSold - totalCollected;
    return d < 0 ? 0 : d;
  }

  bool get isEmpty => invoiceCount == 0 && totalCollected == 0;
}

class SalesReportRepository {
  SalesReportRepository({AppDatabase? db, SupabaseClient? client})
      : _db = db ?? DatabaseProvider.instance,
        _client = client ?? SupabaseService.client;

  final AppDatabase _db;
  final SupabaseClient _client;

  Future<SalesReport> fetch({
    required String driverId,
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      return await _fetchRemote(driverId: driverId, from: from, to: to);
    } catch (e, st) {
      AppLogger.error('SalesReportRepository.fetch(remote)', e, st);
      return _fetchLocal(driverId: driverId, from: from, to: to);
    }
  }

  Future<SalesReport> _fetchRemote({
    required String driverId,
    required DateTime from,
    required DateTime to,
  }) async {
    final fromStr = _date(from);
    final toStr = _date(to);

    final invoices = await _client
        .from('invoices')
        .select('customer_id,total_amount,paid_amount,invoice_date')
        .eq('driver_id', driverId)
        .gte('invoice_date', fromStr)
        .lte('invoice_date', toStr);
    final payments = await _client
        .from('payments')
        .select('customer_id,amount,payment_method,payment_date')
        .eq('driver_id', driverId)
        .gte('payment_date', fromStr)
        .lte('payment_date', toStr);
    final items = await _client
        .from('invoice_items')
        .select('product_id, quantity, unit_price, '
            'invoices!inner(driver_id, invoice_date)')
        .eq('invoices.driver_id', driverId)
        .gte('invoices.invoice_date', fromStr)
        .lte('invoices.invoice_date', toStr);

    return _aggregate(
      invoiceRows: invoices
          .map((r) => _InvoiceFact(
                customerId: r['customer_id'] as String? ?? '',
                total: _toDouble(r['total_amount']),
                paid: _toDouble(r['paid_amount']),
                date: _parseDay(r['invoice_date']),
              ))
          .toList(),
      paymentRows: payments
          .map((r) => _PaymentFact(
                customerId: r['customer_id'] as String? ?? '',
                amount: _toDouble(r['amount']),
                method: r['payment_method'] as String? ?? 'cash',
                date: _parseDay(r['payment_date']),
              ))
          .toList(),
      itemRows: items
          .map((r) => _ItemFact(
                productId: r['product_id'] as String? ?? '',
                qty: _toDouble(r['quantity']),
                revenue: _toDouble(r['quantity']) * _toDouble(r['unit_price']),
              ))
          .toList(),
      fromCache: false,
    );
  }

  Future<SalesReport> _fetchLocal({
    required String driverId,
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final start = DateTime(from.year, from.month, from.day);
      final end =
          DateTime(to.year, to.month, to.day).add(const Duration(days: 1));

      final invoices = await (_db.select(_db.invoices)
            ..where((t) =>
                t.driverId.equals(driverId) &
                t.invoiceDate.isBiggerOrEqualValue(start) &
                t.invoiceDate.isSmallerThanValue(end)))
          .get();
      final payments = await (_db.select(_db.payments)
            ..where((t) =>
                t.driverId.equals(driverId) &
                t.paymentDate.isBiggerOrEqualValue(start) &
                t.paymentDate.isSmallerThanValue(end)))
          .get();
      final invoiceIds = invoices.map((i) => i.id).toList();
      final items = invoiceIds.isEmpty
          ? <InvoiceItem>[]
          : await (_db.select(_db.invoiceItems)
                ..where((t) => t.invoiceId.isIn(invoiceIds)))
              .get();

      return _aggregate(
        invoiceRows: invoices
            .map((i) => _InvoiceFact(
                  customerId: i.customerId,
                  total: i.totalAmount,
                  paid: i.paidAmount,
                  date: DateTime(i.invoiceDate.year, i.invoiceDate.month,
                      i.invoiceDate.day),
                ))
            .toList(),
        paymentRows: payments
            .map((p) => _PaymentFact(
                  customerId: p.customerId,
                  amount: p.amount,
                  method: p.paymentMethod,
                  date: DateTime(p.paymentDate.year, p.paymentDate.month,
                      p.paymentDate.day),
                ))
            .toList(),
        itemRows: items
            .map((it) => _ItemFact(
                  productId: it.productId,
                  qty: it.quantity,
                  revenue: it.quantity * it.unitPrice,
                ))
            .toList(),
        fromCache: true,
      );
    } catch (e, st) {
      AppLogger.error('SalesReportRepository._fetchLocal', e, st);
      return const SalesReport(fromCache: true);
    }
  }

  Future<SalesReport> _aggregate({
    required List<_InvoiceFact> invoiceRows,
    required List<_PaymentFact> paymentRows,
    required List<_ItemFact> itemRows,
    required bool fromCache,
  }) async {
    var totalSold = 0.0;
    var cashCount = 0, partialCount = 0, creditCount = 0;
    var cashAmount = 0.0, partialAmount = 0.0, creditAmount = 0.0;
    final soldByCustomer = <String, double>{};
    final outstandingByCustomer = <String, double>{};
    final soldByDay = <DateTime, double>{};
    for (final inv in invoiceRows) {
      totalSold += inv.total;
      soldByCustomer[inv.customerId] =
          (soldByCustomer[inv.customerId] ?? 0) + inv.total;
      final due = inv.total - inv.paid;
      if (due > 0) {
        outstandingByCustomer[inv.customerId] =
            (outstandingByCustomer[inv.customerId] ?? 0) + due;
      }
      soldByDay[inv.date] = (soldByDay[inv.date] ?? 0) + inv.total;
      if (inv.total > 0 && inv.paid >= inv.total) {
        cashCount++;
        cashAmount += inv.total;
      } else if (inv.paid > 0) {
        partialCount++;
        partialAmount += inv.total;
      } else {
        creditCount++;
        creditAmount += inv.total;
      }
    }

    var cashCollected = 0.0, transferCollected = 0.0;
    final collectedByDay = <DateTime, double>{};
    for (final p in paymentRows) {
      if (p.method == 'transfer') {
        transferCollected += p.amount;
      } else {
        cashCollected += p.amount;
      }
      collectedByDay[p.date] = (collectedByDay[p.date] ?? 0) + p.amount;
    }

    final qtyByProduct = <String, double>{};
    final revenueByProduct = <String, double>{};
    for (final it in itemRows) {
      qtyByProduct[it.productId] = (qtyByProduct[it.productId] ?? 0) + it.qty;
      revenueByProduct[it.productId] =
          (revenueByProduct[it.productId] ?? 0) + it.revenue;
    }

    final products = await _db.select(_db.products).get();
    final productById = {for (final p in products) p.id: p};
    final topProducts = revenueByProduct.keys
        .map((id) => ProductSalesStat(
              productId: id,
              name: productById[id]?.name ?? id,
              nameFa: productById[id]?.nameFa,
              unit: productById[id]?.unit ?? '',
              qty: qtyByProduct[id] ?? 0,
              revenue: revenueByProduct[id] ?? 0,
            ))
        .toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));

    final customerIds = <String>{
      ...soldByCustomer.keys,
      ...outstandingByCustomer.keys,
    }..remove('');
    final customerNames = <String, String>{};
    if (customerIds.isNotEmpty) {
      final rows = await (_db.select(_db.customers)
            ..where((t) => t.id.isIn(customerIds.toList())))
          .get();
      for (final c in rows) {
        customerNames[c.id] = c.name;
      }
    }
    List<CustomerSalesStat> ranked(Map<String, double> byCustomer) =>
        byCustomer.entries
            .where((e) => e.key.isNotEmpty && e.value > 0)
            .map((e) => CustomerSalesStat(
                  customerId: e.key,
                  name: customerNames[e.key] ?? l10n.customer,
                  amount: e.value,
                ))
            .toList()
          ..sort((a, b) => b.amount.compareTo(a.amount));

    final days = <DateTime>{...soldByDay.keys, ...collectedByDay.keys}.toList()
      ..sort();
    final daily = days
        .map((d) => DailySalesStat(
              date: d,
              sold: soldByDay[d] ?? 0,
              collected: collectedByDay[d] ?? 0,
            ))
        .toList();

    return SalesReport(
      totalSold: totalSold,
      invoiceCount: invoiceRows.length,
      cashCount: cashCount,
      cashAmount: cashAmount,
      partialCount: partialCount,
      partialAmount: partialAmount,
      creditCount: creditCount,
      creditAmount: creditAmount,
      cashCollected: cashCollected,
      transferCollected: transferCollected,
      topProducts: topProducts,
      topCustomersBySold: ranked(soldByCustomer),
      topCustomersByOutstanding: ranked(outstandingByCustomer),
      daily: daily,
      fromCache: fromCache,
    );
  }

  static DateTime _parseDay(dynamic v) {
    final parsed = DateTime.tryParse(v?.toString() ?? '') ?? DateTime.now();
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  static String _date(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static double _toDouble(dynamic v) => v == null
      ? 0
      : v is num
          ? v.toDouble()
          : double.tryParse(v.toString()) ?? 0;
}

class _InvoiceFact {
  const _InvoiceFact({
    required this.customerId,
    required this.total,
    required this.paid,
    required this.date,
  });

  final String customerId;
  final double total;
  final double paid;
  final DateTime date;
}

class _PaymentFact {
  const _PaymentFact({
    required this.customerId,
    required this.amount,
    required this.method,
    required this.date,
  });

  final String customerId;
  final double amount;
  final String method;
  final DateTime date;
}

class _ItemFact {
  const _ItemFact({
    required this.productId,
    required this.qty,
    required this.revenue,
  });

  final String productId;
  final double qty;
  final double revenue;
}
