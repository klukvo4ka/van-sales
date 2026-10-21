import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../utils/app_logger.dart';
import 'truck_initial_stock_repository.dart';

class CustomerDayRow {
  const CustomerDayRow({
    required this.customer,
    required this.sold,
    required this.collected,
  });

  final Customer customer;
  final double sold;
  final double collected;
}

class DaySummary {
  const DaySummary({
    this.invoiceCount = 0,
    this.totalSold = 0,
    this.cashCount = 0,
    this.cashAmount = 0,
    this.partialCount = 0,
    this.partialAmount = 0,
    this.creditCount = 0,
    this.creditAmount = 0,
    this.cashCollected = 0,
    this.transferCollected = 0,
    this.newDebt = 0,
    this.visitedCount = 0,
    this.routeCount = 0,
    this.unitsSold = 0,
    this.stockValue = 0,
    this.customers = const [],
  });

  final int invoiceCount;
  final double totalSold;
  final int cashCount;
  final double cashAmount;
  final int partialCount;
  final double partialAmount;
  final int creditCount;
  final double creditAmount;
  final double cashCollected;
  final double transferCollected;
  final double newDebt;
  final int visitedCount;
  final int routeCount;
  final double unitsSold;
  final double stockValue;
  final List<CustomerDayRow> customers;

  double get totalCollected => cashCollected + transferCollected;
}

class DaySummaryRepository {
  DaySummaryRepository({AppDatabase? db, SupabaseClient? client})
      : _db = db ?? DatabaseProvider.instance,
        _client = client;

  final AppDatabase _db;
  final SupabaseClient? _client;

  Future<DaySummary> getDaySummary(String driverId) async {
    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      final end = start.add(const Duration(days: 1));

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

      var totalSold = 0.0;
      var cashCount = 0, partialCount = 0, creditCount = 0;
      var cashAmount = 0.0, partialAmount = 0.0, creditAmount = 0.0;
      var newDebt = 0.0;
      final soldByCustomer = <String, double>{};
      for (final inv in invoices) {
        totalSold += inv.totalAmount;
        final due = inv.totalAmount - inv.paidAmount;
        newDebt += due > 0 ? due : 0;
        soldByCustomer[inv.customerId] =
            (soldByCustomer[inv.customerId] ?? 0) + inv.totalAmount;
        if (inv.totalAmount > 0 && inv.paidAmount >= inv.totalAmount) {
          cashCount++;
          cashAmount += inv.totalAmount;
        } else if (inv.paidAmount > 0) {
          partialCount++;
          partialAmount += inv.totalAmount;
        } else {
          creditCount++;
          creditAmount += inv.totalAmount;
        }
      }

      var cashCollected = 0.0, transferCollected = 0.0;
      final collectedByCustomer = <String, double>{};
      for (final p in payments) {
        if (p.paymentMethod == 'transfer') {
          transferCollected += p.amount;
        } else {
          cashCollected += p.amount;
        }
        collectedByCustomer[p.customerId] =
            (collectedByCustomer[p.customerId] ?? 0) + p.amount;
      }

      final routeCustomers = await (_db.select(_db.customers)
            ..where(
                (t) => t.driverId.equals(driverId) & t.isDeleted.equals(false)))
          .get();
      final visitedCount = routeCustomers
          .where((c) =>
              c.visitedDate != null &&
              !c.visitedDate!.isBefore(start) &&
              c.visitedDate!.isBefore(end))
          .length;

      final items = _db.invoiceItems;
      final inv = _db.invoices;
      final qtySum = items.quantity.sum();
      final unitsRow = await (_db.selectOnly(items)
            ..addColumns([qtySum])
            ..join([innerJoin(inv, inv.id.equalsExp(items.invoiceId))])
            ..where(inv.driverId.equals(driverId) &
                inv.invoiceDate.isBiggerOrEqualValue(start) &
                inv.invoiceDate.isSmallerThanValue(end)))
          .getSingle();
      final unitsSold = unitsRow.read(qtySum) ?? 0;

      var stockValue = 0.0;
      final stockRepo = TruckInitialStockRepository(db: _db, client: _client);
      final truckId = await stockRepo.truckIdForDriver(driverId);
      if (truckId.isNotEmpty) {
        final rows = await stockRepo.getRemainingStock(driverId, truckId);
        for (final r in rows) {
          stockValue += r.remaining * (r.product?.price ?? 0);
        }
      }

      final customerIds = <String>{
        ...soldByCustomer.keys,
        ...collectedByCustomer.keys,
      };
      final byId = {for (final c in routeCustomers) c.id: c};
      final missing = customerIds.where((id) => !byId.containsKey(id)).toList();
      if (missing.isNotEmpty) {
        final extra = await (_db.select(_db.customers)
              ..where((t) => t.id.isIn(missing)))
            .get();
        for (final c in extra) {
          byId[c.id] = c;
        }
      }
      final customerRows = customerIds
          .where(byId.containsKey)
          .map((id) => CustomerDayRow(
                customer: byId[id]!,
                sold: soldByCustomer[id] ?? 0,
                collected: collectedByCustomer[id] ?? 0,
              ))
          .toList()
        ..sort((a, b) {
          final bySold = b.sold.compareTo(a.sold);
          return bySold != 0 ? bySold : b.collected.compareTo(a.collected);
        });

      return DaySummary(
        invoiceCount: invoices.length,
        totalSold: totalSold,
        cashCount: cashCount,
        cashAmount: cashAmount,
        partialCount: partialCount,
        partialAmount: partialAmount,
        creditCount: creditCount,
        creditAmount: creditAmount,
        cashCollected: cashCollected,
        transferCollected: transferCollected,
        newDebt: newDebt,
        visitedCount: visitedCount,
        routeCount: routeCustomers.length,
        unitsSold: unitsSold,
        stockValue: stockValue,
        customers: customerRows,
      );
    } catch (e, st) {
      AppLogger.error('DaySummaryRepository.getDaySummary', e, st);
      return const DaySummary();
    }
  }
}
