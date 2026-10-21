import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class Trucks extends Table {
  TextColumn get id => text()();
  TextColumn get plateNumber => text().unique()();
  TextColumn get name => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get nameFa => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Products extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get nameFa => text().nullable()();
  TextColumn get sku => text().nullable().unique()();
  TextColumn get unit => text().withDefault(const Constant('pcs'))();
  RealColumn get price => real().withDefault(const Constant(0))();
  TextColumn get categoryId => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get driverId => text().nullable()();
  IntColumn get routeOrder => integer().withDefault(const Constant(0))();
  TextColumn get routeName => text().nullable()();
  RealColumn get creditLimit => real().withDefault(const Constant(0))();
  RealColumn get balance => real().withDefault(const Constant(0))();
  TextColumn get photoOutsidePath => text().nullable()();
  TextColumn get photoInsidePath => text().nullable()();
  TextColumn get photoOutsideUrl => text().nullable()();
  TextColumn get photoInsideUrl => text().nullable()();
  DateTimeColumn get visitedDate => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class DriverProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get fullName => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get truckId => text().nullable()();
  TextColumn get role => text().withDefault(const Constant('driver'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class TruckLoads extends Table {
  TextColumn get id => text()();
  TextColumn get truckId => text()();
  TextColumn get driverId => text()();
  DateTimeColumn get loadDate => dateTime()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get billPhotoUrl => text().nullable()();
  TextColumn get billPhotoPath => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {truckId, loadDate},
      ];
}

class TruckLoadItems extends Table {
  TextColumn get id => text()();
  TextColumn get loadId => text()();
  TextColumn get productId => text()();
  RealColumn get requestedQty => real().withDefault(const Constant(0))();
  RealColumn get quantityLoaded => real().withDefault(const Constant(0))();
  RealColumn get quantityReturned => real().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class TruckInitialStocks extends Table {
  TextColumn get id => text()();
  TextColumn get truckId => text()();
  TextColumn get productId => text()();
  RealColumn get quantity => real().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {truckId, productId},
      ];
}

class Invoices extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceNumber => text().nullable().unique()();
  TextColumn get truckLoadId => text().nullable()();
  TextColumn get customerId => text()();
  TextColumn get driverId => text()();
  DateTimeColumn get invoiceDate => dateTime()();
  RealColumn get totalAmount => real().withDefault(const Constant(0))();
  RealColumn get paidAmount => real().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('unpaid'))();
  TextColumn get notes => text().nullable()();
  TextColumn get photoPath => text().nullable()();
  TextColumn get photoUrl => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class InvoiceItems extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceId => text()();
  TextColumn get productId => text()();
  RealColumn get quantity => real()();
  RealColumn get unitPrice => real()();
  RealColumn get total => real().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class DriverSettlements extends Table {
  TextColumn get id => text()();
  TextColumn get driverId => text()();
  RealColumn get amount => real().withDefault(const Constant(0))();
  DateTimeColumn get settledDate => dateTime()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class Payments extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceId => text().nullable()();
  TextColumn get customerId => text()();
  TextColumn get driverId => text()();
  RealColumn get amount => real()();
  TextColumn get paymentMethod => text().withDefault(const Constant('cash'))();
  DateTimeColumn get paymentDate => dateTime()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Trucks,
    Categories,
    Products,
    Customers,
    DriverProfiles,
    TruckLoads,
    TruckLoadItems,
    TruckInitialStocks,
    Invoices,
    InvoiceItems,
    Payments,
    DriverSettlements,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 14;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(truckLoadItems, truckLoadItems.requestedQty);
          }
          if (from < 3) {
            await m.addColumn(truckLoads, truckLoads.billPhotoUrl);
          }
          if (from < 4) {
            await m.addColumn(customers, customers.driverId);
            await m.addColumn(customers, customers.routeOrder);
          }
          if (from < 5) {
            await m.addColumn(truckLoads, truckLoads.billPhotoPath);
          }
          if (from < 6) {
            await m.addColumn(customers, customers.isDeleted);
          }
          if (from < 7) {
            await m.createTable(categories);
            await m.addColumn(products, products.categoryId);
          }
          if (from < 8) {
            await m.createTable(truckInitialStocks);
          }
          if (from < 9) {
            await m.addColumn(customers, customers.photoOutsidePath);
            await m.addColumn(customers, customers.photoInsidePath);
            await m.addColumn(customers, customers.photoOutsideUrl);
            await m.addColumn(customers, customers.photoInsideUrl);
          }
          if (from < 10) {
            await m.addColumn(customers, customers.visitedDate);
          }
          if (from < 11) {
            await m.addColumn(customers, customers.routeName);
          }
          if (from < 12) {
            await m.addColumn(invoices, invoices.photoPath);
            await m.addColumn(invoices, invoices.photoUrl);
          }
          if (from < 13) {
            await m.createTable(driverSettlements);
          }
          if (from < 14) {
            await m.addColumn(customers, customers.updatedAt);
            await m.addColumn(products, products.updatedAt);
            await m.addColumn(categories, categories.updatedAt);
            await m.addColumn(invoices, invoices.updatedAt);
          }
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'van_sales');
  }
}
