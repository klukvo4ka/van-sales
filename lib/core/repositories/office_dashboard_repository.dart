import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../locale/l10n.dart';
import '../services/supabase_service.dart';
import '../utils/app_logger.dart';

class DriverDayRow {
  const DriverDayRow({
    required this.driverId,
    required this.name,
    required this.sold,
    required this.collected,
    required this.invoiceCount,
    this.lastActivity,
  });

  final String driverId;
  final String name;
  final double sold;
  final double collected;
  final int invoiceCount;
  final DateTime? lastActivity;
}

class TruckDayRow {
  const TruckDayRow({
    required this.truckId,
    required this.name,
    required this.plate,
    required this.initialUnits,
    required this.soldUnits,
  });

  final String truckId;
  final String name;
  final String plate;
  final double initialUnits;
  final double soldUnits;
}

class OfficeDashboardData {
  const OfficeDashboardData({
    this.soldToday = 0,
    this.invoiceCount = 0,
    this.cashCollected = 0,
    this.transferCollected = 0,
    this.outstanding = 0,
    this.activeDrivers = 0,
    this.totalDrivers = 0,
    this.drivers = const [],
    this.trucks = const [],
    this.fromCache = false,
  });

  final double soldToday;
  final int invoiceCount;
  final double cashCollected;
  final double transferCollected;
  final double outstanding;
  final int activeDrivers;
  final int totalDrivers;
  final List<DriverDayRow> drivers;
  final List<TruckDayRow> trucks;
  final bool fromCache;

  double get totalCollected => cashCollected + transferCollected;
}

class OfficeDashboardRepository {
  OfficeDashboardRepository({AppDatabase? db, SupabaseClient? client})
      : _db = db ?? DatabaseProvider.instance,
        _client = client ?? SupabaseService.client;

  final AppDatabase _db;
  final SupabaseClient _client;

  Future<OfficeDashboardData> fetch() async {
    try {
      return await _fetchRemote();
    } catch (e, st) {
      AppLogger.error('OfficeDashboardRepository.fetch(remote)', e, st);
      return _fetchLocal();
    }
  }

  Future<OfficeDashboardData> _fetchRemote() async {
    final today = _date(DateTime.now());

    final invoices = await _client
        .from('invoices')
        .select('driver_id,total_amount,created_at')
        .eq('invoice_date', today);
    final payments = await _client
        .from('payments')
        .select('driver_id,amount,payment_method,created_at')
        .eq('payment_date', today);
    final balances = await _client
        .from('customers')
        .select('balance')
        .eq('is_deleted', false)
        .gt('balance', 0);
    final profiles = await _client
        .from('driver_profiles')
        .select('id,full_name,truck_id,role,is_active');
    final trucks = await _client
        .from('trucks')
        .select('id,name,plate_number')
        .eq('is_active', true);
    final initialStock =
        await _client.from('truck_initial_stock').select('truck_id,quantity');
    final itemRows = await _client
        .from('invoice_items')
        .select('quantity, invoices!inner(driver_id, invoice_date)')
        .eq('invoices.invoice_date', today);

    final soldByDriver = <String, double>{};
    final countByDriver = <String, int>{};
    final collectedByDriver = <String, double>{};
    final lastByDriver = <String, DateTime>{};
    var soldToday = 0.0;
    for (final row in invoices) {
      final driverId = row['driver_id'] as String? ?? '';
      final amount = _toDouble(row['total_amount']);
      soldToday += amount;
      soldByDriver[driverId] = (soldByDriver[driverId] ?? 0) + amount;
      countByDriver[driverId] = (countByDriver[driverId] ?? 0) + 1;
      _bumpLast(lastByDriver, driverId, row['created_at']);
    }

    var cashCollected = 0.0, transferCollected = 0.0;
    for (final row in payments) {
      final driverId = row['driver_id'] as String? ?? '';
      final amount = _toDouble(row['amount']);
      if (row['payment_method'] == 'transfer') {
        transferCollected += amount;
      } else {
        cashCollected += amount;
      }
      collectedByDriver[driverId] = (collectedByDriver[driverId] ?? 0) + amount;
      _bumpLast(lastByDriver, driverId, row['created_at']);
    }

    final outstanding =
        balances.fold<double>(0, (sum, row) => sum + _toDouble(row['balance']));

    final driverProfiles = profiles
        .where((p) =>
            (p['role'] as String? ?? 'driver') == 'driver' &&
            (p['is_active'] as bool? ?? true))
        .toList();
    final truckByDriver = <String, String>{
      for (final p in profiles)
        if ((p['truck_id'] as String?) != null)
          p['id'] as String: p['truck_id'] as String,
    };

    final activeIds = <String>{
      ...soldByDriver.keys,
      ...collectedByDriver.keys,
    }..remove('');

    final nameById = {
      for (final p in profiles)
        p['id'] as String: p['full_name'] as String? ?? l10n.driver,
    };
    final listedIds = <String>{
      ...driverProfiles.map((p) => p['id'] as String),
      ...activeIds,
    };
    final driverRows = listedIds
        .map((id) => DriverDayRow(
              driverId: id,
              name: nameById[id] ?? l10n.driver,
              sold: soldByDriver[id] ?? 0,
              collected: collectedByDriver[id] ?? 0,
              invoiceCount: countByDriver[id] ?? 0,
              lastActivity: lastByDriver[id],
            ))
        .toList()
      ..sort((a, b) {
        final bySold = b.sold.compareTo(a.sold);
        return bySold != 0 ? bySold : b.collected.compareTo(a.collected);
      });

    final initialByTruck = <String, double>{};
    for (final row in initialStock) {
      final truckId = row['truck_id'] as String? ?? '';
      initialByTruck[truckId] =
          (initialByTruck[truckId] ?? 0) + _toDouble(row['quantity']);
    }
    final soldUnitsByTruck = <String, double>{};
    for (final row in itemRows) {
      final inv = row['invoices'] as Map<String, dynamic>?;
      final driverId = inv?['driver_id'] as String? ?? '';
      final truckId = truckByDriver[driverId];
      if (truckId == null) continue;
      soldUnitsByTruck[truckId] =
          (soldUnitsByTruck[truckId] ?? 0) + _toDouble(row['quantity']);
    }
    final truckRows = trucks
        .map((t) => TruckDayRow(
              truckId: t['id'] as String,
              name: t['name'] as String? ?? '',
              plate: t['plate_number'] as String? ?? '',
              initialUnits: initialByTruck[t['id']] ?? 0,
              soldUnits: soldUnitsByTruck[t['id']] ?? 0,
            ))
        .toList()
      ..sort((a, b) => b.soldUnits.compareTo(a.soldUnits));

    return OfficeDashboardData(
      soldToday: soldToday,
      invoiceCount: invoices.length,
      cashCollected: cashCollected,
      transferCollected: transferCollected,
      outstanding: outstanding,
      activeDrivers: activeIds.length,
      totalDrivers: driverProfiles.length,
      drivers: driverRows,
      trucks: truckRows,
    );
  }

  Future<OfficeDashboardData> _fetchLocal() async {
    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      final end = start.add(const Duration(days: 1));

      final invoices = await (_db.select(_db.invoices)
            ..where((t) =>
                t.invoiceDate.isBiggerOrEqualValue(start) &
                t.invoiceDate.isSmallerThanValue(end)))
          .get();
      final payments = await (_db.select(_db.payments)
            ..where((t) =>
                t.paymentDate.isBiggerOrEqualValue(start) &
                t.paymentDate.isSmallerThanValue(end)))
          .get();
      final customers = await (_db.select(_db.customers)
            ..where((t) => t.isDeleted.equals(false)))
          .get();
      final profiles = await _db.select(_db.driverProfiles).get();
      final trucks = await (_db.select(_db.trucks)
            ..where((t) => t.isActive.equals(true)))
          .get();
      final initialStock = await _db.select(_db.truckInitialStocks).get();

      final soldByDriver = <String, double>{};
      final countByDriver = <String, int>{};
      final collectedByDriver = <String, double>{};
      final lastByDriver = <String, DateTime>{};
      var soldToday = 0.0;
      for (final inv in invoices) {
        soldToday += inv.totalAmount;
        soldByDriver[inv.driverId] =
            (soldByDriver[inv.driverId] ?? 0) + inv.totalAmount;
        countByDriver[inv.driverId] = (countByDriver[inv.driverId] ?? 0) + 1;
        final prev = lastByDriver[inv.driverId];
        if (prev == null || inv.createdAt.isAfter(prev)) {
          lastByDriver[inv.driverId] = inv.createdAt;
        }
      }
      var cashCollected = 0.0, transferCollected = 0.0;
      for (final p in payments) {
        if (p.paymentMethod == 'transfer') {
          transferCollected += p.amount;
        } else {
          cashCollected += p.amount;
        }
        collectedByDriver[p.driverId] =
            (collectedByDriver[p.driverId] ?? 0) + p.amount;
        final prev = lastByDriver[p.driverId];
        if (prev == null || p.createdAt.isAfter(prev)) {
          lastByDriver[p.driverId] = p.createdAt;
        }
      }

      final outstanding = customers.fold<double>(
          0, (sum, c) => sum + (c.balance > 0 ? c.balance : 0));

      final driverProfiles =
          profiles.where((p) => p.role == 'driver' && p.isActive).toList();
      final activeIds = <String>{
        ...soldByDriver.keys,
        ...collectedByDriver.keys,
      };
      final nameById = {for (final p in profiles) p.id: p.fullName};
      final listedIds = <String>{
        ...driverProfiles.map((p) => p.id),
        ...activeIds,
      };
      final driverRows = listedIds
          .map((id) => DriverDayRow(
                driverId: id,
                name: nameById[id] ?? l10n.driver,
                sold: soldByDriver[id] ?? 0,
                collected: collectedByDriver[id] ?? 0,
                invoiceCount: countByDriver[id] ?? 0,
                lastActivity: lastByDriver[id],
              ))
          .toList()
        ..sort((a, b) => b.sold.compareTo(a.sold));

      final truckByDriver = <String, String>{
        for (final p in profiles)
          if (p.truckId != null && p.truckId!.isNotEmpty) p.id: p.truckId!,
      };
      final initialByTruck = <String, double>{};
      for (final row in initialStock) {
        initialByTruck[row.truckId] =
            (initialByTruck[row.truckId] ?? 0) + row.quantity;
      }
      final soldUnitsByTruck = <String, double>{};
      final todayInvoiceIds = {
        for (final inv in invoices) inv.id: inv.driverId
      };
      if (todayInvoiceIds.isNotEmpty) {
        final items = await (_db.select(_db.invoiceItems)
              ..where((t) => t.invoiceId.isIn(todayInvoiceIds.keys.toList())))
            .get();
        for (final item in items) {
          final driverId = todayInvoiceIds[item.invoiceId];
          final truckId = driverId == null ? null : truckByDriver[driverId];
          if (truckId == null) continue;
          soldUnitsByTruck[truckId] =
              (soldUnitsByTruck[truckId] ?? 0) + item.quantity;
        }
      }
      final truckRows = trucks
          .map((t) => TruckDayRow(
                truckId: t.id,
                name: t.name,
                plate: t.plateNumber,
                initialUnits: initialByTruck[t.id] ?? 0,
                soldUnits: soldUnitsByTruck[t.id] ?? 0,
              ))
          .toList()
        ..sort((a, b) => b.soldUnits.compareTo(a.soldUnits));

      return OfficeDashboardData(
        soldToday: soldToday,
        invoiceCount: invoices.length,
        cashCollected: cashCollected,
        transferCollected: transferCollected,
        outstanding: outstanding,
        activeDrivers: activeIds.length,
        totalDrivers: driverProfiles.length,
        drivers: driverRows,
        trucks: truckRows,
        fromCache: true,
      );
    } catch (e, st) {
      AppLogger.error('OfficeDashboardRepository._fetchLocal', e, st);
      return const OfficeDashboardData(fromCache: true);
    }
  }

  static void _bumpLast(
      Map<String, DateTime> map, String driverId, dynamic createdAt) {
    if (driverId.isEmpty || createdAt == null) return;
    final parsed = DateTime.tryParse(createdAt.toString())?.toLocal();
    if (parsed == null) return;
    final prev = map[driverId];
    if (prev == null || parsed.isAfter(prev)) map[driverId] = parsed;
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
