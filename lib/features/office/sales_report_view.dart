import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/locale/l10n.dart';
import '../../core/repositories/sales_report_repository.dart';
import '../../core/repositories/truck_initial_stock_repository.dart';
import '../../core/services/report_export.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../main.dart' show syncProvider;

enum SalesRangePreset { today, week, month, custom }

class SalesReportView extends StatefulWidget {
  const SalesReportView({super.key, this.initialDriverId});

  final String? initialDriverId;

  @override
  State<SalesReportView> createState() => _SalesReportViewState();
}

class _SalesReportViewState extends State<SalesReportView> {
  final _repo = SalesReportRepository();
  final _stockRepo = TruckInitialStockRepository();

  List<DriverProfile> _drivers = [];
  Map<String, Truck> _truckById = {};
  DriverProfile? _driver;
  SalesRangePreset _preset = SalesRangePreset.today;
  DateTime _from = DateTime.now();
  DateTime _to = DateTime.now();
  SalesReport _report = const SalesReport();
  bool _loading = true;
  bool _fetching = false;

  static const _okColor = Color(0xFF16A34A);
  static const _warnColor = Color(0xFFD97706);
  static const _debtColor = Color(0xFFDC2626);

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
    final selectedId = _driver?.id ?? widget.initialDriverId;
    DriverProfile? initial;
    if (selectedId != null) {
      initial = drivers.where((p) => p.id == selectedId).firstOrNull;
    }
    if (!mounted) return;
    setState(() {
      _drivers = drivers;
      _truckById = {for (final t in trucks) t.id: t};
      _driver = initial ?? (drivers.isEmpty ? null : drivers.first);
      _loading = false;
    });
  }

  (DateTime, DateTime) _rangeFor(SalesRangePreset preset) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return switch (preset) {
      SalesRangePreset.today => (today, today),
      SalesRangePreset.week => (
          today.subtract(Duration(days: today.weekday - 1)),
          today
        ),
      SalesRangePreset.month => (DateTime(today.year, today.month, 1), today),
      SalesRangePreset.custom => (_from, _to),
    };
  }

  Future<void> _setPreset(SalesRangePreset preset) async {
    if (preset == SalesRangePreset.custom) {
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2024),
        lastDate: DateTime.now(),
        initialDateRange: DateTimeRange(start: _from, end: _to),
      );
      if (picked == null || !mounted) return;
      setState(() {
        _preset = preset;
        _from = picked.start;
        _to = picked.end;
      });
    } else {
      final (from, to) = _rangeFor(preset);
      setState(() {
        _preset = preset;
        _from = from;
        _to = to;
      });
    }
    await _load();
  }

  Future<void> _load() async {
    final driver = _driver;
    if (driver == null) {
      setState(() {
        _report = const SalesReport();
        _fetching = false;
      });
      return;
    }
    setState(() => _fetching = true);
    final report = await _repo.fetch(driverId: driver.id, from: _from, to: _to);
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

  String _driverLabel(DriverProfile p) {
    final truck = p.truckId == null ? null : _truckById[p.truckId!];
    return truck == null ? p.fullName : '${p.fullName} — ${truck.plateNumber}';
  }

  String get _rangeLabel => _from == _to
      ? AppUtils.formatDate(_from)
      : '${AppUtils.formatDate(_from)} — ${AppUtils.formatDate(_to)}';

  static String _afn(double v) => '${v.round()} AFN';

  static String _qty(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
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
                          _driver =
                              _drivers.where((p) => p.id == id).firstOrNull;
                        });
                        _load();
                      },
              ),
            ),
            Text(l10n.rangeWithLabel(_rangeLabel),
                style:
                    const TextStyle(color: AppTheme.mutedColor, fontSize: 12)),
            ExportButtons(
              enabled: !_fetching && _driver != null && !_report.isEmpty,
              onPdf: () => ReportExport.exportPdf(
                context,
                reportName: _salesReportName,
                filters: _salesFilterLine,
                fileBase: _salesFileBase,
                tables: _salesTables(),
              ),
              onExcel: () => ReportExport.exportExcel(
                context,
                reportName: _salesReportName,
                filters: _salesFilterLine,
                fileBase: _salesFileBase,
                tables: _salesTables(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _presetChip(SalesRangePreset.today, l10n.today),
              const SizedBox(width: 8),
              _presetChip(SalesRangePreset.week, l10n.thisWeek),
              const SizedBox(width: 8),
              _presetChip(SalesRangePreset.month, l10n.thisMonth),
              const SizedBox(width: 8),
              _presetChip(SalesRangePreset.custom, l10n.custom),
            ],
          ),
        ),
      ],
    );
  }

  static String get _salesReportName => l10n.salesByDriverTitle;

  String get _salesFilterLine {
    final driver = _driver;
    final name = driver == null ? '' : '${_driverLabel(driver)} — ';
    return '$name$_rangeLabel';
  }

  String get _salesFileBase => ReportExport.fileBase(
        'sales',
        _driver?.fullName ?? 'all',
        '${AppUtils.formatDate(_from)}_${AppUtils.formatDate(_to)}',
      );

  List<ReportTable> _salesTables() {
    final r = _report;
    return [
      ReportTable(
        title: l10n.summary,
        columns: [l10n.metric, l10n.value],
        rows: [
          [l10n.totalSoldAfn, r.totalSold],
          [l10n.invoices, r.invoiceCount],
          [l10n.avgInvoiceAfn, r.avgInvoice],
          [l10n.cashSalesAfn(r.cashCount), r.cashAmount],
          [l10n.partialAfn(r.partialCount), r.partialAmount],
          [l10n.creditSalesAfn(r.creditCount), r.creditAmount],
          [l10n.cashCollectedAfn, r.cashCollected],
          [l10n.transferCollectedAfn, r.transferCollected],
          [l10n.totalCollectedAfn, r.totalCollected],
          [l10n.newDebtAfn, r.newDebt],
        ],
      ),
      ReportTable(
        title: l10n.topProducts,
        columns: [
          l10n.product,
          l10n.qty,
          l10n.revenueAfn,
        ],
        rows: [
          for (final p in r.topProducts)
            [
              p.nameFa == null || p.nameFa!.isEmpty
                  ? p.name
                  : '${p.name} · ${p.nameFa}',
              p.qty,
              p.revenue,
            ],
        ],
      ),
      ReportTable(
        title: l10n.topCustomersSold,
        columns: [l10n.customer, l10n.soldAfn],
        rows: [
          for (final c in r.topCustomersBySold) [c.name, c.amount],
        ],
      ),
      ReportTable(
        title: l10n.topCustomersOwed,
        columns: [l10n.customer, l10n.owedAfn],
        rows: [
          for (final c in r.topCustomersByOutstanding) [c.name, c.amount],
        ],
      ),
      ReportTable(
        title: l10n.daily,
        columns: [
          l10n.date,
          l10n.soldAfn,
          l10n.collectedAfn,
        ],
        rows: [
          for (final d in r.daily) [d.date, d.sold, d.collected],
        ],
      ),
    ];
  }

  Widget _presetChip(SalesRangePreset preset, String label) {
    final selected = _preset == preset;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      labelStyle: TextStyle(
          color: selected ? Colors.white : AppTheme.primaryColor, fontSize: 12),
      onSelected: _fetching ? null : (_) => _setPreset(preset),
    );
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
    if (_report.isEmpty) {
      return ListView(
        children: [
          if (_report.fromCache) _offlineBanner(),
          const SizedBox(height: 120),
          const Icon(Icons.bar_chart_outlined, size: 56, color: Colors.black26),
          const SizedBox(height: 12),
          Text(
            l10n.noSalesInThisRange,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, fontSize: 16),
          ),
        ],
      );
    }

    final r = _report;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (r.fromCache) _offlineBanner(),
        _kpiGrid(),
        const SizedBox(height: 12),
        _methodsCard(),
        const SizedBox(height: 16),
        _breakdownGrid(),
      ],
    );
  }

  Widget _offlineBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _warnColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        border: Border.all(color: _warnColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_outlined, size: 20, color: _warnColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.offlineShowingLocalData,
              style: const TextStyle(color: _warnColor, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _kpiGrid() {
    final r = _report;
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 320,
        mainAxisExtent: 116,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      children: [
        _kpiCard(
          icon: Icons.trending_up,
          label: l10n.totalSold,
          value: _afn(r.totalSold),
          subtitle: l10n.invoicesAvg(r.invoiceCount, _afn(r.avgInvoice)),
        ),
        _kpiCard(
          icon: Icons.payments_outlined,
          label: l10n.collected,
          value: _afn(r.totalCollected),
          subtitle: l10n.cashTransfer(
              _afn(r.cashCollected), _afn(r.transferCollected)),
          valueColor: _okColor,
        ),
        _kpiCard(
          icon: Icons.account_balance_wallet_outlined,
          label: l10n.newDebt,
          value: _afn(r.newDebt),
          valueColor: r.newDebt > 0 ? _debtColor : null,
        ),
      ],
    );
  }

  Widget _kpiCard({
    required IconData icon,
    required String label,
    required String value,
    String? subtitle,
    Color? valueColor,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppTheme.accentColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: AppTheme.mutedColor, fontSize: 12)),
                ),
              ],
            ),
            const Spacer(),
            Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 21,
                      color: valueColor ?? AppTheme.primaryColor,
                    )),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AppTheme.mutedColor, fontSize: 11)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _methodsCard() {
    final r = _report;
    return _sectionCard(l10n.byMethod, [
      _row(l10n.cashSalesCount(r.cashCount), _afn(r.cashAmount)),
      _row(l10n.partialCount(r.partialCount), _afn(r.partialAmount)),
      _row(l10n.creditSalesCount(r.creditCount), _afn(r.creditAmount)),
    ]);
  }

  Widget _breakdownGrid() {
    final r = _report;
    final sections = <Widget>[
      _sectionCard(
        l10n.topProducts,
        r.topProducts.isEmpty
            ? [_emptyRow()]
            : r.topProducts
                .take(5)
                .map((p) => _row(
                      p.nameFa == null || p.nameFa!.isEmpty
                          ? '${p.name} (${_qty(p.qty)} ${p.unit})'
                          : '${p.name} · ${p.nameFa} '
                              '(${_qty(p.qty)} ${p.unit})',
                      _afn(p.revenue),
                    ))
                .toList(),
      ),
      _sectionCard(
        l10n.topCustomersSold,
        r.topCustomersBySold.isEmpty
            ? [_emptyRow()]
            : r.topCustomersBySold
                .take(5)
                .map((c) => _row(c.name, _afn(c.amount)))
                .toList(),
      ),
      _sectionCard(
        l10n.topCustomersOwed,
        r.topCustomersByOutstanding.isEmpty
            ? [_emptyRow()]
            : r.topCustomersByOutstanding
                .take(5)
                .map(
                    (c) => _row(c.name, _afn(c.amount), valueColor: _debtColor))
                .toList(),
      ),
      _sectionCard(
        l10n.daily,
        r.daily.isEmpty
            ? [_emptyRow()]
            : r.daily
                .map((d) => _row(
                      AppUtils.formatDate(d.date),
                      l10n.soldCollShort(_afn(d.sold), _afn(d.collected)),
                    ))
                .toList(),
      ),
    ];

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 520,
        mainAxisExtent: 236,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      children: sections,
    );
  }

  Widget _sectionCard(String title, List<Widget> children) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppTheme.mutedColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(l10n.nothingHere,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.mutedColor, fontSize: 13)),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: Colors.black87)),
          ),
          const SizedBox(width: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppTheme.primaryColor)),
        ],
      ),
    );
  }
}
