import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../services/supabase_service.dart';
import '../utils/app_logger.dart';

class InventoryReportRow {
  const InventoryReportRow({
    required this.productId,
    required this.name,
    this.nameFa,
    required this.unit,
    required this.price,
    required this.initial,
    required this.sold,
  });

  final String productId;
  final String name;
  final String? nameFa;
  final String unit;
  final double price;
  final double initial;
  final double sold;

  double get remaining {
    final r = initial - sold;
    return r < 0 ? 0 : r;
  }

  double get remainingRatio =>
      initial <= 0 ? 0 : (remaining / initial).clamp(0, 1).toDouble();

  double get remainingValue => remaining * price;

  bool get oversold => sold > initial;
}

class InventoryReport {
  const InventoryReport({this.rows = const [], this.fromCache = false});

  final List<InventoryReportRow> rows;
  final bool fromCache;

  int get skuCount => rows.length;
  double get totalInitial => rows.fold(0, (sum, r) => sum + r.initial);
  double get totalSold => rows.fold(0, (sum, r) => sum + r.sold);
  double get totalRemaining => rows.fold(0, (sum, r) => sum + r.remaining);
  double get totalRemainingValue =>
      rows.fold(0, (sum, r) => sum + r.remainingValue);
  int get oversoldCount => rows.where((r) => r.oversold).length;
}

class InventoryReportRepository {
  InventoryReportRepository({AppDatabase? db, SupabaseClient? client})
      : _db = db ?? DatabaseProvider.instance,
        _client = client ?? SupabaseService.client;

  final AppDatabase _db;
  final SupabaseClient _client;

  Future<InventoryReport> fetch({
    required String driverId,
    required String truckId,
    required DateTime date,
  }) async {
    try {
      return await _fetchRemote(
          driverId: driverId, truckId: truckId, date: date);
    } catch (e, st) {
      AppLogger.error('InventoryReportRepository.fetch(remote)', e, st);
      return _fetchLocal(driverId: driverId, truckId: truckId, date: date);
    }
  }

  Future<InventoryReport> _fetchRemote({
    required String driverId,
    required String truckId,
    required DateTime date,
  }) async {
    final dateStr = _date(date);

    final products =
        await _client.from('products').select('id,name,name_fa,unit,price');
    final initialRows = truckId.isEmpty
        ? const <Map<String, dynamic>>[]
        : await _client
            .from('truck_initial_stock')
            .select('product_id,quantity')
            .eq('truck_id', truckId);
    final soldRows = await _client
        .from('invoice_items')
        .select('product_id, quantity, invoices!inner(driver_id, invoice_date)')
        .eq('invoices.driver_id', driverId)
        .eq('invoices.invoice_date', dateStr);

    final initialByProduct = <String, double>{};
    for (final row in initialRows) {
      final id = row['product_id'] as String? ?? '';
      initialByProduct[id] =
          (initialByProduct[id] ?? 0) + _toDouble(row['quantity']);
    }
    final soldByProduct = <String, double>{};
    for (final row in soldRows) {
      final id = row['product_id'] as String? ?? '';
      soldByProduct[id] = (soldByProduct[id] ?? 0) + _toDouble(row['quantity']);
    }

    final infoById = <String, Map<String, dynamic>>{
      for (final p in products) p['id'] as String: p,
    };
    return InventoryReport(
      rows: _buildRows(
        initialByProduct: initialByProduct,
        soldByProduct: soldByProduct,
        name: (id) => infoById[id]?['name'] as String? ?? id,
        nameFa: (id) => infoById[id]?['name_fa'] as String?,
        unit: (id) => infoById[id]?['unit'] as String? ?? '',
        price: (id) => _toDouble(infoById[id]?['price']),
      ),
    );
  }

  Future<InventoryReport> _fetchLocal({
    required String driverId,
    required String truckId,
    required DateTime date,
  }) async {
    try {
      final start = DateTime(date.year, date.month, date.day);
      final end = start.add(const Duration(days: 1));

      final products = await _db.select(_db.products).get();
      final stock = truckId.isEmpty
          ? <TruckInitialStock>[]
          : await (_db.select(_db.truckInitialStocks)
                ..where((t) => t.truckId.equals(truckId)))
              .get();

      final query = _db.select(_db.invoiceItems).join([
        innerJoin(
          _db.invoices,
          _db.invoices.id.equalsExp(_db.invoiceItems.invoiceId),
        ),
      ])
        ..where(_db.invoices.driverId.equals(driverId) &
            _db.invoices.invoiceDate.isBiggerOrEqualValue(start) &
            _db.invoices.invoiceDate.isSmallerThanValue(end));
      final soldItemRows = await query.get();

      final initialByProduct = <String, double>{};
      for (final row in stock) {
        initialByProduct[row.productId] =
            (initialByProduct[row.productId] ?? 0) + row.quantity;
      }
      final soldByProduct = <String, double>{};
      for (final r in soldItemRows) {
        final item = r.readTable(_db.invoiceItems);
        soldByProduct[item.productId] =
            (soldByProduct[item.productId] ?? 0) + item.quantity;
      }

      final infoById = {for (final p in products) p.id: p};
      return InventoryReport(
        fromCache: true,
        rows: _buildRows(
          initialByProduct: initialByProduct,
          soldByProduct: soldByProduct,
          name: (id) => infoById[id]?.name ?? id,
          nameFa: (id) => infoById[id]?.nameFa,
          unit: (id) => infoById[id]?.unit ?? '',
          price: (id) => infoById[id]?.price ?? 0,
        ),
      );
    } catch (e, st) {
      AppLogger.error('InventoryReportRepository._fetchLocal', e, st);
      return const InventoryReport(fromCache: true);
    }
  }

  static List<InventoryReportRow> _buildRows({
    required Map<String, double> initialByProduct,
    required Map<String, double> soldByProduct,
    required String Function(String id) name,
    required String? Function(String id) nameFa,
    required String Function(String id) unit,
    required double Function(String id) price,
  }) {
    final ids = <String>{...initialByProduct.keys, ...soldByProduct.keys}
      ..remove('');
    final rows = ids
        .map((id) => InventoryReportRow(
              productId: id,
              name: name(id),
              nameFa: nameFa(id),
              unit: unit(id),
              price: price(id),
              initial: initialByProduct[id] ?? 0,
              sold: soldByProduct[id] ?? 0,
            ))
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return rows;
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
