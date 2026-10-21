import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

import 'package:van_sales/core/database/app_database.dart';
import 'package:van_sales/core/repositories/customer_repository.dart';
import 'package:van_sales/core/repositories/day_summary_repository.dart';
import 'package:van_sales/core/repositories/company_report_repository.dart';
import 'package:van_sales/core/repositories/driver_liability_repository.dart';
import 'package:van_sales/core/repositories/driver_settlement_repository.dart';
import 'package:van_sales/core/repositories/inventory_report_repository.dart';
import 'package:van_sales/core/repositories/invoice_repository.dart';
import 'package:van_sales/core/repositories/payment_repository.dart';
import 'package:van_sales/core/repositories/receivables_report_repository.dart';
import 'package:van_sales/core/repositories/sales_report_repository.dart';
import 'package:van_sales/core/repositories/truck_initial_stock_repository.dart';
import 'package:van_sales/core/utils/app_utils.dart';

const driverId = '00000000-0000-0000-0000-0000000000d1';
const truckId = '00000000-0000-0000-0000-0000000000a1';
const customerId = '00000000-0000-0000-0000-0000000000c1';
const productA = '00000000-0000-0000-0000-0000000000f1';
const productB = '00000000-0000-0000-0000-0000000000f2';

void main() {
  late AppDatabase db;
  late SupabaseClient client;
  late InvoiceRepository invoices;
  late PaymentRepository payments;
  late CustomerRepository customers;
  late TruckInitialStockRepository stock;

  Future<void> seed() async {
    await db.into(db.trucks).insert(TrucksCompanion.insert(
          id: truckId,
          plateNumber: 'KBL-101',
          name: 'Truck 01',
        ));
    await db.into(db.driverProfiles).insert(DriverProfilesCompanion.insert(
          id: driverId,
          fullName: 'Test Driver',
          truckId: const Value(truckId),
        ));
    await db.into(db.products).insert(ProductsCompanion.insert(
          id: productA,
          name: 'Cola',
          price: const Value(100),
          unit: const Value('carton'),
        ));
    await db.into(db.products).insert(ProductsCompanion.insert(
          id: productB,
          name: 'Chips',
          price: const Value(50),
          unit: const Value('carton'),
        ));
    await db.into(db.customers).insert(CustomersCompanion.insert(
          id: customerId,
          name: 'Shop 01',
          driverId: const Value(driverId),
          creditLimit: const Value(500),
        ));
    await db.into(db.truckInitialStocks).insert(
          TruckInitialStocksCompanion.insert(
            id: 'stock-a',
            truckId: truckId,
            productId: productA,
            quantity: const Value(50),
          ),
        );
    await db.into(db.truckInitialStocks).insert(
          TruckInitialStocksCompanion.insert(
            id: 'stock-b',
            truckId: truckId,
            productId: productB,
            quantity: const Value(20),
          ),
        );
  }

  InvoiceItemInput item(String productId, double qty, double price) =>
      InvoiceItemInput(
        id: AppUtils.generateUuid(),
        productId: productId,
        quantity: qty,
        unitPrice: price,
      );

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    client = SupabaseClient('http://127.0.0.1:9', 'test-key');
    invoices = InvoiceRepository(db: db, client: client);
    payments = PaymentRepository(db: db, client: client);
    customers = CustomerRepository(db: db, client: client);
    stock = TruckInitialStockRepository(db: db, client: client);
    await seed();
  });

  tearDown(() async {
    client.dispose();
    await db.close();
  });

  test('cash sale: paid status, linked payment, stock decrement, no debt',
      () async {
    final created = await invoices.create(
      customerId: customerId,
      driverId: driverId,
      invoiceNumber: 'INV-CASH-1',
      items: [item(productA, 3, 100), item(productB, 2, 50)],
      cashSale: true,
    );

    expect(created.result, SaveResult.localOnly);
    expect(created.invoice.totalAmount, 400);
    expect(created.invoice.paidAmount, 400);
    expect(created.invoice.status, 'paid');
    expect(created.invoice.synced, isFalse);

    final paymentRows = await db.select(db.payments).get();
    expect(paymentRows, hasLength(1));
    expect(paymentRows.single.invoiceId, created.invoice.id);
    expect(paymentRows.single.amount, 400);
    expect(paymentRows.single.paymentMethod, 'cash');
    expect(paymentRows.single.synced, isFalse);

    final remaining = await stock.getRemainingStock(driverId, truckId);
    final colaRow = remaining.singleWhere((r) => r.productId == productA);
    expect(colaRow.sold, 3);
    expect(colaRow.remaining, 47);

    final summary = await customers.getDebtSummary(customerId);
    expect(summary.outstanding, 0);
    final customer = await customers.getById(customerId);
    expect(customer!.balance, 0);
  });

  test('credit sale: unpaid status, debt equals total, rows stay dirty',
      () async {
    final created = await invoices.create(
      customerId: customerId,
      driverId: driverId,
      invoiceNumber: 'INV-CREDIT-1',
      items: [item(productA, 2, 100)],
    );

    expect(created.invoice.status, 'unpaid');
    expect(created.invoice.paidAmount, 0);
    expect(await db.select(db.payments).get(), isEmpty);

    final summary = await customers.getDebtSummary(customerId);
    expect(summary.outstanding, 200);
    expect((await customers.getById(customerId))!.balance, 200);

    final itemRows = await db.select(db.invoiceItems).get();
    expect(itemRows.every((r) => !r.synced), isTrue);
    expect(itemRows.single.total, 200);
  });

  test('partial sale: partial status, remainder becomes debt', () async {
    final created = await invoices.create(
      customerId: customerId,
      driverId: driverId,
      invoiceNumber: 'INV-PART-1',
      items: [item(productA, 1, 100)],
      paidNow: 30,
      paymentMethod: 'transfer',
    );

    expect(created.invoice.status, 'partial');
    expect(created.invoice.paidAmount, 30);

    final paymentRows = await db.select(db.payments).get();
    expect(paymentRows.single.amount, 30);
    expect(paymentRows.single.paymentMethod, 'transfer');

    expect((await customers.getDebtSummary(customerId)).outstanding, 70);
  });

  test('addPayment walks unpaid → partial → paid', () async {
    final created = await invoices.create(
      customerId: customerId,
      driverId: driverId,
      invoiceNumber: 'INV-ADD-1',
      items: [item(productA, 1, 100)],
    );

    await invoices.addPayment(
      invoice: created.invoice,
      driverId: driverId,
      amount: 40,
      method: 'cash',
    );
    var fresh = await invoices.getById(created.invoice.id);
    expect(fresh!.status, 'partial');
    expect(fresh.paidAmount, 40);

    await invoices.addPayment(
      invoice: fresh,
      driverId: driverId,
      amount: 60,
      method: 'cash',
    );
    fresh = await invoices.getById(created.invoice.id);
    expect(fresh!.status, 'paid');
    expect(fresh.paidAmount, 100);
    expect((await customers.getDebtSummary(customerId)).outstanding, 0);
  });

  test('general payment allocates FIFO by invoice date and stays account-level',
      () async {
    final older = await invoices.create(
      customerId: customerId,
      driverId: driverId,
      invoiceNumber: 'INV-FIFO-1',
      items: [item(productA, 1, 100)],
      date: DateTime.now().subtract(const Duration(days: 2)),
    );
    final newer = await invoices.create(
      customerId: customerId,
      driverId: driverId,
      invoiceNumber: 'INV-FIFO-2',
      items: [item(productB, 1, 50)],
      date: DateTime.now().subtract(const Duration(days: 1)),
    );

    await payments.create(
      customerId: customerId,
      driverId: driverId,
      amount: 120,
      method: 'cash',
    );

    final olderFresh = await invoices.getById(older.invoice.id);
    final newerFresh = await invoices.getById(newer.invoice.id);
    expect(olderFresh!.status, 'paid');
    expect(olderFresh.paidAmount, 100);
    expect(newerFresh!.status, 'partial');
    expect(newerFresh.paidAmount, 20);

    final paymentRows = await db.select(db.payments).get();
    expect(paymentRows.single.invoiceId, isNull);
    expect((await customers.getDebtSummary(customerId)).outstanding, 30);

    await invoices.reconcileAllocations(customerId);
    expect((await invoices.getById(older.invoice.id))!.paidAmount, 100);
    expect((await invoices.getById(newer.invoice.id))!.paidAmount, 20);
  });

  test('soft-deleted customer stays dirty so a pull cannot resurrect it',
      () async {
    await customers.delete(customerId);
    final row = await customers.getById(customerId);
    expect(row!.isDeleted, isTrue);
    expect(row.synced, isFalse);
    expect(await customers.getAll(), isEmpty);
  });

  test('day summary reconciles with underlying rows', () async {
    await invoices.create(
      customerId: customerId,
      driverId: driverId,
      invoiceNumber: 'INV-DAY-1',
      items: [item(productA, 2, 100)],
      cashSale: true,
    );
    await invoices.create(
      customerId: customerId,
      driverId: driverId,
      invoiceNumber: 'INV-DAY-2',
      items: [item(productB, 4, 50)],
    );
    await customers.setVisited(customerId, true);

    final summary = await DaySummaryRepository(db: db, client: client)
        .getDaySummary(driverId);
    expect(summary.invoiceCount, 2);
    expect(summary.totalSold, 400);
    expect(summary.cashCount, 1);
    expect(summary.cashAmount, 200);
    expect(summary.creditCount, 1);
    expect(summary.creditAmount, 200);
    expect(summary.cashCollected, 200);
    expect(summary.transferCollected, 0);
    expect(summary.newDebt, 200);
    expect(summary.visitedCount, 1);
    expect(summary.routeCount, 1);
    expect(summary.unitsSold, 6);
    expect(summary.customers.single.sold, 400);
    expect(summary.customers.single.collected, 200);
  });

  test('inventory report flags oversold and reconciles totals', () async {
    await invoices.create(
      customerId: customerId,
      driverId: driverId,
      invoiceNumber: 'INV-OVER-1',
      items: [item(productB, 25, 50)],
    );

    final report = await InventoryReportRepository(db: db, client: client)
        .fetch(driverId: driverId, truckId: truckId, date: DateTime.now());

    expect(report.fromCache, isTrue);
    final chips = report.rows.singleWhere((r) => r.productId == productB);
    expect(chips.initial, 20);
    expect(chips.sold, 25);
    expect(chips.oversold, isTrue);
    expect(chips.remaining, 0);

    final cola = report.rows.singleWhere((r) => r.productId == productA);
    expect(cola.oversold, isFalse);
    expect(cola.remainingValue, 50 * 100);

    expect(report.totalInitial, 70);
    expect(report.totalSold, 25);
    expect(report.oversoldCount, 1);
  });

  test('receivables report ages debt from the oldest open invoice', () async {
    await invoices.create(
      customerId: customerId,
      driverId: driverId,
      invoiceNumber: 'INV-AGE-1',
      items: [item(productA, 1, 100)],
      date: DateTime.now().subtract(const Duration(days: 40)),
    );

    final report =
        await ReceivablesReportRepository(db: db, client: client).fetch();
    expect(report.fromCache, isTrue);
    final row = report.rows.single;
    expect(row.outstanding, 100);
    expect(row.daysOverdue, 40);
    expect(row.bucket, AgingBucket.d31to60);
    expect(report.grandTotal, 100);
    expect(report.bucketTotals[AgingBucket.d31to60], 100);
  });

  test('driver liability reconciles goods and money', () async {
    await invoices.create(
      customerId: customerId,
      driverId: driverId,
      invoiceNumber: 'INV-LIA-1',
      items: [item(productA, 4, 100)],
      cashSale: true,
    );
    await invoices.create(
      customerId: customerId,
      driverId: driverId,
      invoiceNumber: 'INV-LIA-2',
      items: [item(productB, 2, 50)],
    );
    await DriverSettlementRepository(db: db, client: client).create(
      driverId: driverId,
      amount: 150,
      date: DateTime.now(),
    );

    final liability =
        await DriverLiabilityRepository(db: db, client: client).fetch(
      driverId: driverId,
      truckId: truckId,
      from: DateTime(2024),
      to: DateTime.now(),
    );

    expect(liability.fromCache, isTrue);
    expect(liability.goodsIssuedValue, 50 * 100 + 20 * 50);
    expect(liability.goodsSoldValue, 500);
    expect(liability.remainingStockValue, 46 * 100 + 18 * 50);
    expect(liability.cashCollected, 400);
    expect(liability.cashHandedIn, 150);
    expect(liability.netOwed, 250);
    expect(liability.receivables, 100);
    expect(liability.sanityOk, isTrue);
  });

  test('sales report reconciles totals, splits, rankings, and daily trend',
      () async {
    await invoices.create(
      customerId: customerId,
      driverId: driverId,
      invoiceNumber: 'INV-SALES-1',
      items: [item(productA, 3, 100)],
      cashSale: true,
    );
    await invoices.create(
      customerId: customerId,
      driverId: driverId,
      invoiceNumber: 'INV-SALES-2',
      items: [item(productB, 2, 50)],
      paidNow: 40,
      paymentMethod: 'transfer',
    );

    final report = await SalesReportRepository(db: db, client: client).fetch(
      driverId: driverId,
      from: DateTime.now(),
      to: DateTime.now(),
    );

    expect(report.fromCache, isTrue);
    expect(report.totalSold, 400);
    expect(report.invoiceCount, 2);
    expect(report.cashCount, 1);
    expect(report.cashAmount, 300);
    expect(report.partialCount, 1);
    expect(report.partialAmount, 100);
    expect(report.cashCollected, 300);
    expect(report.transferCollected, 40);
    expect(report.newDebt, 60);
    expect(report.topProducts.first.productId, productA);
    expect(report.topProducts.first.qty, 3);
    expect(report.topProducts.first.revenue, 300);
    expect(report.topCustomersBySold.single.amount, 400);
    expect(report.topCustomersByOutstanding.single.amount, 60);
    expect(report.daily.single.sold, 400);
    expect(report.daily.single.collected, 340);
  });

  test('company report reconciles period totals and previous-period deltas',
      () async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    await invoices.create(
      customerId: customerId,
      driverId: driverId,
      invoiceNumber: 'INV-COMP-PREV',
      items: [item(productB, 1, 50)],
      cashSale: true,
      date: yesterday,
    );
    await invoices.create(
      customerId: customerId,
      driverId: driverId,
      invoiceNumber: 'INV-COMP-CASH',
      items: [item(productA, 2, 100)],
      cashSale: true,
    );
    await invoices.create(
      customerId: customerId,
      driverId: driverId,
      invoiceNumber: 'INV-COMP-CREDIT',
      items: [item(productB, 2, 50)],
    );
    await DriverSettlementRepository(db: db, client: client).create(
      driverId: driverId,
      amount: 80,
      date: DateTime.now(),
    );

    final report = await CompanyReportRepository(db: db, client: client).fetch(
      period: CompanyPeriod.day,
      anchor: DateTime.now(),
    );

    expect(report.fromCache, isTrue);
    expect(report.totalSold, 300);
    expect(report.invoiceCount, 2);
    expect(report.totalCollected, 200);
    expect(report.cashHandedIn, 80);
    expect(report.newDebt, 100);
    expect(report.outstanding, 100);
    expect(report.activeDrivers, 1);
    expect(report.customersServed, 1);
    expect(report.prevSold, 50);
    expect(report.prevCollected, 50);
    expect(report.topDriversBySold.single.amount, 300);
    expect(report.topDriversByCollected.single.amount, 200);
    expect(report.topProducts.first.id, productA);
    expect(report.trend, hasLength(24));
    expect(report.trend.fold<double>(0, (sum, p) => sum + p.sold), 300);
    expect(
      report.trend.fold<double>(0, (sum, p) => sum + p.collected),
      200,
    );
  });

  test('offline invoice creation leaves every row dirty and duplicate-free',
      () async {
    final created = await invoices.create(
      customerId: customerId,
      driverId: driverId,
      invoiceNumber: 'INV-OFF-1',
      items: [item(productA, 1, 100)],
      paidNow: 40,
    );

    expect(created.result, SaveResult.localOnly);
    final invoiceRows = await db.select(db.invoices).get();
    final itemRows = await db.select(db.invoiceItems).get();
    final paymentRows = await db.select(db.payments).get();
    expect(invoiceRows, hasLength(1));
    expect(itemRows, hasLength(1));
    expect(paymentRows, hasLength(1));
    expect(invoiceRows.every((r) => !r.synced), isTrue);
    expect(itemRows.every((r) => !r.synced), isTrue);
    expect(paymentRows.every((r) => !r.synced), isTrue);

    await invoices.reconcileAllocations(customerId);
    expect(await db.select(db.invoices).get(), hasLength(1));
    expect(await db.select(db.payments).get(), hasLength(1));
  });
}
