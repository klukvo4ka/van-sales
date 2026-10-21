import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/locale/l10n.dart';
import '../../core/repositories/inventory_report_repository.dart';
import '../../core/repositories/truck_initial_stock_repository.dart';
import '../../core/services/report_export.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../main.dart' show syncProvider;
import 'company_report_view.dart';
import 'driver_liability_view.dart';
import 'receivables_report_view.dart';
import 'sales_report_view.dart';

class ReportsTab extends StatefulWidget {
  const ReportsTab({super.key});

  @override
  State<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab> {
  final _reportRepo = InventoryReportRepository();
  final _stockRepo = TruckInitialStockRepository();

  List<DriverProfile> _drivers = [];
  Map<String, Truck> _truckById = {};
  DriverProfile? _driver;
  DateTime _date = DateTime.now();
  InventoryReport _report = const InventoryReport();
  int _section = 0;
  bool _loading = true;
  bool _fetching = false;

  static const _okColor = Color(0xFF16A34A);
  static const _lowColor = Color(0xFFD97706);
  static const _outColor = Color(0xFFDC2626);

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _loadLookups(syncFirst: true);
    await _load();
  }

  Future<void> _loadLookups({bool syncFirst = false}) async {
    if (syncFirst) {
      await syncProvider.service.syncNow();
    }
    final profiles = await _stockRepo.getDriverProfiles();
    final trucks = await _stockRepo.getAllTrucks();
    final drivers =
        profiles.where((p) => p.role == 'driver' && p.isActive).toList();
    if (!mounted) return;
    final selectedId = _driver?.id;
    final selected = selectedId == null
        ? null
        : drivers.where((p) => p.id == selectedId).firstOrNull;
    setState(() {
      _drivers = drivers;
      _truckById = {for (final t in trucks) t.id: t};
      _driver = selected ?? (drivers.isEmpty ? null : drivers.first);
      _loading = false;
    });
  }

  Future<void> _load() async {
    final driver = _driver;
    if (driver == null) {
      setState(() {
        _report = const InventoryReport();
        _fetching = false;
      });
      return;
    }
    setState(() => _fetching = true);
    final report = await _reportRepo.fetch(
      driverId: driver.id,
      truckId: driver.truckId ?? '',
      date: _date,
    );
    if (!mounted) return;
    setState(() {
      _report = report;
      _fetching = false;
    });
  }

  Future<void> _refresh() async {
    await _loadLookups(syncFirst: true);
    await _load();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked == null || !mounted) return;
    setState(() => _date = picked);
    await _load();
  }

  String _driverLabel(DriverProfile p) {
    final truck = p.truckId == null ? null : _truckById[p.truckId!];
    return truck == null ? p.fullName : '${p.fullName} — ${truck.plateNumber}';
  }

  static String _qty(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  static String _afn(double v) => '${v.round()} AFN';

  Color? _rowTint(InventoryReportRow row) {
    if (row.oversold) return _outColor.withValues(alpha: 0.08);
    if (row.initial <= 0) return null;
    if (row.remaining <= 0 || row.remainingRatio < 0.10) {
      return _outColor.withValues(alpha: 0.06);
    }
    if (row.remainingRatio < 0.30) return _lowColor.withValues(alpha: 0.08);
    return null;
  }

  Color _remainingColor(InventoryReportRow row) {
    if (row.oversold || row.remaining <= 0 || row.remainingRatio < 0.10) {
      return _outColor;
    }
    if (row.remainingRatio < 0.30) return _lowColor;
    return _okColor;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _sectionChip(0, l10n.inventoryByDriver),
                  const SizedBox(width: 8),
                  _sectionChip(1, l10n.salesByDriver),
                  const SizedBox(width: 8),
                  _sectionChip(2, l10n.receivablesShort),
                  const SizedBox(width: 8),
                  _sectionChip(3, l10n.driverLiability),
                  const SizedBox(width: 8),
                  _sectionChip(4, l10n.company),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _section,
            children: [
              _inventorySection(),
              const SalesReportView(),
              const ReceivablesReportView(),
              const DriverLiabilityView(),
              const CompanyReportView(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionChip(int index, String label) {
    final selected = _section == index;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      labelStyle: TextStyle(
          color: selected ? Colors.white : AppTheme.primaryColor, fontSize: 12),
      onSelected: (_) => setState(() => _section = index),
    );
  }

  Widget _inventorySection() {
    return Column(
      children: [
        const SizedBox(height: 8),
        _filters(),
        const SizedBox(height: 8),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: _body(),
          ),
        ),
      ],
    );
  }

  Widget _filters() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 240, maxWidth: 380),
          child: DropdownButtonFormField<String>(
            initialValue: _driver?.id,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n.driver,
              isDense: true,
            ),
            items: _drivers
                .map((p) => DropdownMenuItem(
                      value: p.id,
                      child: Text(_driverLabel(p),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ))
                .toList(),
            onChanged: _fetching
                ? null
                : (id) {
                    setState(() {
                      _driver = _drivers.where((p) => p.id == id).firstOrNull;
                    });
                    _load();
                  },
          ),
        ),
        OutlinedButton.icon(
          onPressed: _fetching ? null : _pickDate,
          icon: const Icon(Icons.calendar_today_outlined, size: 18),
          label: Text(l10n.dateWithLabel(AppUtils.formatDate(_date))),
        ),
        ExportButtons(
          enabled: !_fetching && _report.rows.isNotEmpty,
          onPdf: () => ReportExport.exportPdf(
            context,
            reportName: _inventoryReportName,
            filters: _inventoryFilterLine,
            fileBase: _inventoryFileBase,
            tables: _inventoryTables(),
          ),
          onExcel: () => ReportExport.exportExcel(
            context,
            reportName: _inventoryReportName,
            filters: _inventoryFilterLine,
            fileBase: _inventoryFileBase,
            tables: _inventoryTables(),
          ),
        ),
      ],
    );
  }

  static String get _inventoryReportName => l10n.inventoryByDriverTitle;

  String get _inventoryFilterLine {
    final driver = _driver;
    final name = driver == null ? '' : '${_driverLabel(driver)} — ';
    return '$name${AppUtils.formatDate(_date)}';
  }

  String get _inventoryFileBase => ReportExport.fileBase(
        'inventory',
        _driver?.fullName ?? 'all',
        AppUtils.formatDate(_date),
      );

  List<ReportTable> _inventoryTables() {
    final r = _report;
    return [
      ReportTable(
        title: l10n.stock,
        columns: [
          l10n.product,
          l10n.initial,
          l10n.sold,
          l10n.remaining,
          l10n.valueAfn2,
        ],
        rows: [
          for (final row in r.rows)
            [
              row.nameFa == null || row.nameFa!.isEmpty
                  ? row.name
                  : '${row.name} · ${row.nameFa}',
              row.initial,
              row.sold,
              row.remaining,
              row.remainingValue,
            ],
        ],
        totals: [
          l10n.totalSkus(r.skuCount),
          r.totalInitial,
          r.totalSold,
          r.totalRemaining,
          r.totalRemainingValue,
        ],
      ),
    ];
  }

  Widget _body() {
    if (_fetching) {
      return ListView(
        children: const [
          SizedBox(height: 160),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }
    if (_driver == null) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          const Icon(Icons.people_outline, size: 56, color: Colors.black26),
          const SizedBox(height: 12),
          Text(
            l10n.noDriversYet,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, fontSize: 16),
          ),
        ],
      );
    }
    if (_report.rows.isEmpty) {
      return ListView(
        children: [
          if (_report.fromCache) _offlineBanner(),
          const SizedBox(height: 120),
          const Icon(Icons.inventory_2_outlined,
              size: 56, color: Colors.black26),
          const SizedBox(height: 12),
          Text(
            l10n.noStockOrSalesFor,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, fontSize: 16),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (_report.fromCache) _offlineBanner(),
        _table(),
        const SizedBox(height: 12),
        _totalsFooter(),
      ],
    );
  }

  Widget _offlineBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _lowColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        border: Border.all(color: _lowColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_outlined, size: 20, color: _lowColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.offlineShowingLocalData,
              style: const TextStyle(color: _lowColor, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _table() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Card(
              margin: EdgeInsets.zero,
              child: DataTable(
                headingRowHeight: 44,
                dataRowMinHeight: 44,
                dataRowMaxHeight: 60,
                horizontalMargin: 14,
                columnSpacing: 20,
                headingTextStyle: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12),
                columns: [
                  DataColumn(label: Text(l10n.product)),
                  DataColumn(label: Text(l10n.initial), numeric: true),
                  DataColumn(label: Text(l10n.sold), numeric: true),
                  DataColumn(label: Text(l10n.remaining), numeric: true),
                  DataColumn(label: Text(l10n.value2), numeric: true),
                ],
                rows: _report.rows.map(_dataRow).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  DataRow _dataRow(InventoryReportRow row) {
    final tint = _rowTint(row);
    return DataRow(
      color: tint == null ? null : WidgetStateProperty.all(tint),
      cells: [
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                row.nameFa == null || row.nameFa!.isEmpty
                    ? row.name
                    : '${row.name} · ${row.nameFa}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (row.oversold)
                Text(
                  l10n.oversold,
                  style: const TextStyle(
                      color: _outColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
        DataCell(Text('${_qty(row.initial)} ${row.unit}')),
        DataCell(Text(_qty(row.sold))),
        DataCell(Text(
          _qty(row.remaining),
          style: TextStyle(
            color: _remainingColor(row),
            fontWeight: FontWeight.w700,
          ),
        )),
        DataCell(Text(_afn(row.remainingValue))),
      ],
    );
  }

  Widget _totalsFooter() {
    final r = _report;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 20,
          runSpacing: 10,
          children: [
            _totalStat(l10n.skus, '${r.skuCount}'),
            _totalStat(l10n.initial, _qty(r.totalInitial)),
            _totalStat(l10n.sold, _qty(r.totalSold)),
            _totalStat(l10n.remaining, _qty(r.totalRemaining)),
            _totalStat(l10n.remainingValue, _afn(r.totalRemainingValue)),
            if (r.oversoldCount > 0)
              _totalStat(l10n.oversold2, '${r.oversoldCount}',
                  color: _outColor),
          ],
        ),
      ),
    );
  }

  Widget _totalStat(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: const TextStyle(color: AppTheme.mutedColor, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                color: color ?? AppTheme.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}
