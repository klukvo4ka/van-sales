import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../services/supabase_service.dart';
import '../utils/app_logger.dart';

class DriverLiability {
  const DriverLiability({
    this.goodsIssuedValue = 0,
    this.goodsSoldValue = 0,
    this.remainingStockValue = 0,
    this.cashCollected = 0,
    this.transferCollected = 0,
    this.cashHandedIn = 0,
    this.receivables = 0,
    this.fromCache = false,
  });

  final double goodsIssuedValue;
  final double goodsSoldValue;
  final double remainingStockValue;
  final double cashCollected;
  final double transferCollected;
  final double cashHandedIn;
  final double receivables;
  final bool fromCache;

  double get netOwed => cashCollected - cashHandedIn;

  double get sanityDelta =>
      goodsSoldValue - (cashCollected + transferCollected + receivables);

  bool get sanityOk => sanityDelta.abs() < 1;

  bool get isEmpty =>
      goodsIssuedValue == 0 &&
      goodsSoldValue == 0 &&
      cashCollected == 0 &&
      transferCollected == 0 &&
      cashHandedIn == 0 &&
      receivables == 0;
}

class DriverLiabilityRepository {
  DriverLiabilityRepository({AppDatabase? db, SupabaseClient? client})
      : _db = db ?? DatabaseProvider.instance,
        _client = client ?? SupabaseService.client;

  final AppDatabase _db;
  final SupabaseClient _client;

  Future<DriverLiability> fetch({
    required String driverId,
    required String truckId,
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      return await _fetchRemote(
          driverId: driverId, truckId: truckId, from: from, to: to);
    } catch (e, st) {
      AppLogger.error('DriverLiabilityRepository.fetch(remote)', e, st);
      return _fetchLocal(
          driverId: driverId, truckId: truckId, from: from, to: to);
    }
  }

  Future<DriverLiability> _fetchRemote({
    required String driverId,
    required String truckId,
    required DateTime from,
    required DateTime to,
  }) async {
    final fromStr = _date(from);
    final toStr = _date(to);

    final products = await _client.from('products').select('id,price');
    final priceById = <String, double>{
      for (final p in products) p['id'] as String: _toDouble(p['price']),
    };

    final initialRows = truckId.isEmpty
        ? const <Map<String, dynamic>>[]
        : await _client
            .from('truck_initial_stock')
            .select('product_id,quantity')
            .eq('truck_id', truckId);

    final allItems = await _client
        .from('invoice_items')
        .select('product_id, quantity, unit_price, invoices!inner(driver_id)')
        .eq('invoices.driver_id', driverId);
    final rangeItems = await _client
        .from('invoice_items')
        .select('quantity, unit_price, invoices!inner(driver_id, invoice_date)')
        .eq('invoices.driver_id', driverId)
        .gte('invoices.invoice_date', fromStr)
        .lte('invoices.invoice_date', toStr);

    final payments = await _client
        .from('payments')
        .select('amount,payment_method')
        .eq('driver_id', driverId)
        .gte('payment_date', fromStr)
        .lte('payment_date', toStr);

    final settlements = await _client
        .from('driver_settlements')
        .select('amount')
        .eq('driver_id', driverId)
        .gte('settled_date', fromStr)
        .lte('settled_date', toStr);

    final balances = await _client
        .from('customers')
        .select('balance')
        .eq('driver_id', driverId)
        .eq('is_deleted', false)
        .gt('balance', 0);

    final initialByProduct = <String, double>{};
    for (final row in initialRows) {
      final id = row['product_id'] as String? ?? '';
      initialByProduct[id] =
          (initialByProduct[id] ?? 0) + _toDouble(row['quantity']);
    }
    final soldAllByProduct = <String, double>{};
    for (final row in allItems) {
      final id = row['product_id'] as String? ?? '';
      soldAllByProduct[id] =
          (soldAllByProduct[id] ?? 0) + _toDouble(row['quantity']);
    }
    final goodsSoldValue = rangeItems.fold<double>(
        0,
        (sum, row) =>
            sum + _toDouble(row['quantity']) * _toDouble(row['unit_price']));

    var cashCollected = 0.0, transferCollected = 0.0;
    for (final row in payments) {
      if (row['payment_method'] == 'transfer') {
        transferCollected += _toDouble(row['amount']);
      } else {
        cashCollected += _toDouble(row['amount']);
      }
    }

    final cashHandedIn = settlements.fold<double>(
        0, (sum, row) => sum + _toDouble(row['amount']));
    final receivables =
        balances.fold<double>(0, (sum, row) => sum + _toDouble(row['balance']));

    return _compose(
      priceById: priceById,
      initialByProduct: initialByProduct,
      soldAllByProduct: soldAllByProduct,
      goodsSoldValue: goodsSoldValue,
      cashCollected: cashCollected,
      transferCollected: transferCollected,
      cashHandedIn: cashHandedIn,
      receivables: receivables,
      fromCache: false,
    );
  }

  Future<DriverLiability> _fetchLocal({
    required String driverId,
    required String truckId,
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final start = DateTime(from.year, from.month, from.day);
      final end =
          DateTime(to.year, to.month, to.day).add(const Duration(days: 1));

      final products = await _db.select(_db.products).get();
      final priceById = {for (final p in products) p.id: p.price};

      final stock = truckId.isEmpty
          ? <TruckInitialStock>[]
          : await (_db.select(_db.truckInitialStocks)
                ..where((t) => t.truckId.equals(truckId)))
              .get();
      final initialByProduct = <String, double>{};
      for (final row in stock) {
        initialByProduct[row.productId] =
            (initialByProduct[row.productId] ?? 0) + row.quantity;
      }

      final items = _db.invoiceItems;
      final inv = _db.invoices;
      final allRows = await (_db.select(items).join([
        innerJoin(inv, inv.id.equalsExp(items.invoiceId)),
      ])
            ..where(inv.driverId.equals(driverId)))
          .get();
      final soldAllByProduct = <String, double>{};
      var goodsSoldValue = 0.0;
      for (final r in allRows) {
        final item = r.readTable(items);
        final invoice = r.readTable(inv);
        soldAllByProduct[item.productId] =
            (soldAllByProduct[item.productId] ?? 0) + item.quantity;
        if (!invoice.invoiceDate.isBefore(start) &&
            invoice.invoiceDate.isBefore(end)) {
          goodsSoldValue += item.quantity * item.unitPrice;
        }
      }

      final payments = await (_db.select(_db.payments)
            ..where((t) =>
                t.driverId.equals(driverId) &
                t.paymentDate.isBiggerOrEqualValue(start) &
                t.paymentDate.isSmallerThanValue(end)))
          .get();
      var cashCollected = 0.0, transferCollected = 0.0;
      for (final p in payments) {
        if (p.paymentMethod == 'transfer') {
          transferCollected += p.amount;
        } else {
          cashCollected += p.amount;
        }
      }

      final settlements = await (_db.select(_db.driverSettlements)
            ..where((t) =>
                t.driverId.equals(driverId) &
                t.settledDate.isBiggerOrEqualValue(start) &
                t.settledDate.isSmallerThanValue(end)))
          .get();
      final cashHandedIn =
          settlements.fold<double>(0, (sum, s) => sum + s.amount);

      final customers = await (_db.select(_db.customers)
            ..where((t) =>
                t.driverId.equals(driverId) &
                t.isDeleted.equals(false) &
                t.balance.isBiggerThanValue(0)))
          .get();
      final receivables =
          customers.fold<double>(0, (sum, c) => sum + c.balance);

      return _compose(
        priceById: priceById,
        initialByProduct: initialByProduct,
        soldAllByProduct: soldAllByProduct,
        goodsSoldValue: goodsSoldValue,
        cashCollected: cashCollected,
        transferCollected: transferCollected,
        cashHandedIn: cashHandedIn,
        receivables: receivables,
        fromCache: true,
      );
    } catch (e, st) {
      AppLogger.error('DriverLiabilityRepository._fetchLocal', e, st);
      return const DriverLiability(fromCache: true);
    }
  }

  static DriverLiability _compose({
    required Map<String, double> priceById,
    required Map<String, double> initialByProduct,
    required Map<String, double> soldAllByProduct,
    required double goodsSoldValue,
    required double cashCollected,
    required double transferCollected,
    required double cashHandedIn,
    required double receivables,
    required bool fromCache,
  }) {
    var goodsIssuedValue = 0.0;
    var remainingStockValue = 0.0;
    for (final entry in initialByProduct.entries) {
      final price = priceById[entry.key] ?? 0;
      goodsIssuedValue += entry.value * price;
      final remaining = entry.value - (soldAllByProduct[entry.key] ?? 0);
      remainingStockValue += (remaining < 0 ? 0 : remaining) * price;
    }
    return DriverLiability(
      goodsIssuedValue: goodsIssuedValue,
      goodsSoldValue: goodsSoldValue,
      remainingStockValue: remainingStockValue,
      cashCollected: cashCollected,
      transferCollected: transferCollected,
      cashHandedIn: cashHandedIn,
      receivables: receivables,
      fromCache: fromCache,
    );
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
