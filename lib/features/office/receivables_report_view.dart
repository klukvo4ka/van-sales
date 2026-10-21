import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/locale/l10n.dart';
import '../../core/repositories/receivables_report_repository.dart';
import '../../core/repositories/truck_initial_stock_repository.dart';
import '../../core/services/report_export.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../main.dart' show syncProvider;
import '../customers/screens/customer_detail_screen.dart';

enum _SortBy { outstanding, overdue }

class ReceivablesReportView extends StatefulWidget {
  const ReceivablesReportView({super.key});

  @override
  State<ReceivablesReportView> createState() => _ReceivablesReportViewState();
}

class _ReceivablesReportViewState extends State<ReceivablesReportView> {
  final _repo = ReceivablesReportRepository();
  final _stockRepo = TruckInitialStockRepository();
  final _search = TextEditingController();

  ReceivablesReport _report = const ReceivablesReport();
  Map<String, String> _driverNames = {};
  String? _driverFilter;
  _SortBy _sortBy = _SortBy.outstanding;
  String _query = '';
  bool _loading = true;

  static const _unassignedKey = '';

  static const _bucketColors = {
    AgingBucket.current: Color(0xFF16A34A),
    AgingBucket.d8to30: Color(0xFFCA8A04),
    AgingBucket.d31to60: Color(0xFFD97706),
    AgingBucket.d60plus: Color(0xFFDC2626),
  };

  static Map<AgingBucket, String> get _bucketLabels => {
        AgingBucket.current: l10n.aging0to7,
        AgingBucket.d8to30: l10n.aging8to30,
        AgingBucket.d31to60: l10n.aging31to60,
        AgingBucket.d60plus: l10n.aging60plus,
      };

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
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
    if (mounted) {
      setState(() {
        _driverNames = {for (final p in profiles) p.id: p.fullName};
      });
    }
  }

  Future<void> _load() async {
    final report = await _repo.fetch();
    if (!mounted) return;
    setState(() {
      _report = report;
      _loading = false;
    });
  }

  Future<void> _refresh() async {
    await _loadLookups(syncFirst: true);
    await _load();
  }

  String _driverLabel(String key) => key == _unassignedKey
      ? l10n.unassigned2
      : _driverNames[key] ?? l10n.driver;

  static String _afn(double v) => '${v.round()} AFN';

  List<ReceivableRow> get _filteredRows {
    final q = _query.toLowerCase();
    return _report.rows.where((r) {
      final driverKey = r.customer.driverId ?? _unassignedKey;
      if (_driverFilter != null && driverKey != _driverFilter) return false;
      if (q.isEmpty) return true;
      return r.customer.name.toLowerCase().contains(q) ||
          (r.customer.phone ?? '').toLowerCase().contains(q);
    }).toList();
  }

  List<MapEntry<String, List<ReceivableRow>>> get _groups {
    final byDriver = <String, List<ReceivableRow>>{};
    for (final row in _filteredRows) {
      byDriver
          .putIfAbsent(row.customer.driverId ?? _unassignedKey, () => [])
          .add(row);
    }
    int compareRows(ReceivableRow a, ReceivableRow b) =>
        _sortBy == _SortBy.outstanding
            ? b.outstanding.compareTo(a.outstanding)
            : b.daysOverdue.compareTo(a.daysOverdue);
    for (final rows in byDriver.values) {
      rows.sort(compareRows);
    }
    double subtotal(List<ReceivableRow> rows) =>
        rows.fold(0, (sum, r) => sum + r.outstanding);
    final entries = byDriver.entries.toList()
      ..sort((a, b) {
        if (a.key == _unassignedKey) return 1;
        if (b.key == _unassignedKey) return -1;
        return subtotal(b.value).compareTo(subtotal(a.value));
      });
    return entries;
  }

  Future<void> _openCustomer(Customer customer) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => CustomerDetailScreen(customer: customer),
      ),
    );
    await _load();
  }

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
    final driverKeys = <String>{
      for (final r in _report.rows) r.customer.driverId ?? _unassignedKey,
    }.toList()
      ..sort((a, b) {
        if (a == _unassignedKey) return 1;
        if (b == _unassignedKey) return -1;
        return _driverLabel(a).compareTo(_driverLabel(b));
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 220, maxWidth: 320),
              child: TextField(
                controller: _search,
                onChanged: (v) => setState(() => _query = v.trim()),
                decoration: InputDecoration(
                  hintText: l10n.searchCustomer,
                  isDense: true,
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _search.clear();
                            setState(() => _query = '');
                          },
                        ),
                ),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 200, maxWidth: 300),
              child: DropdownButtonFormField<String?>(
                initialValue: _driverFilter,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.driver,
                  isDense: true,
                ),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(l10n.allDrivers),
                  ),
                  ...driverKeys.map((key) => DropdownMenuItem<String?>(
                        value: key,
                        child: Text(_driverLabel(key),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      )),
                ],
                onChanged: (v) => setState(() => _driverFilter = v),
              ),
            ),
            ExportButtons(
              enabled: _filteredRows.isNotEmpty,
              onPdf: () => ReportExport.exportPdf(
                context,
                reportName: _receivablesReportName,
                filters: _receivablesFilterLine,
                fileBase: _receivablesFileBase,
                tables: _receivablesTables(),
              ),
              onExcel: () => ReportExport.exportExcel(
                context,
                reportName: _receivablesReportName,
                filters: _receivablesFilterLine,
                fileBase: _receivablesFileBase,
                tables: _receivablesTables(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _sortChip(_SortBy.outstanding, l10n.byAmount),
              const SizedBox(width: 8),
              _sortChip(_SortBy.overdue, l10n.byOverdue),
            ],
          ),
        ),
      ],
    );
  }

  static String get _receivablesReportName => l10n.receivablesShort;

  String get _receivablesFilterLine {
    final scope =
        _driverFilter == null ? l10n.allDrivers : _driverLabel(_driverFilter!);
    return '$scope — ${AppUtils.formatDate(DateTime.now())}';
  }

  String get _receivablesFileBase => ReportExport.fileBase(
        'receivables',
        _driverFilter == null ? 'all' : _driverLabel(_driverFilter!),
        AppUtils.formatDate(DateTime.now()),
      );

  List<ReportTable> _receivablesTables() {
    final buckets = _report.bucketTotals;
    final rows = _filteredRows;
    final total = rows.fold<double>(0, (sum, r) => sum + r.outstanding);
    return [
      ReportTable(
        title: l10n.aging,
        columns: [l10n.bucket2, l10n.amountAfn],
        rows: [
          for (final bucket in AgingBucket.values)
            [_bucketLabels[bucket], buckets[bucket] ?? 0],
        ],
      ),
      ReportTable(
        title: l10n.customers,
        columns: [
          l10n.driver,
          l10n.customer,
          l10n.phone,
          l10n.outstandingAfn2,
          l10n.oldest,
          l10n.days,
        ],
        rows: [
          for (final group in _groups)
            for (final r in group.value)
              [
                _driverLabel(group.key),
                r.customer.name,
                r.customer.phone ?? '',
                r.outstanding,
                r.oldestUnpaid,
                r.daysOverdue,
              ],
        ],
        totals: [l10n.total, '', '', total, '', ''],
      ),
    ];
  }

  Widget _sortChip(_SortBy value, String label) {
    final selected = _sortBy == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      labelStyle: TextStyle(
          color: selected ? Colors.white : AppTheme.primaryColor, fontSize: 12),
      onSelected: (_) => setState(() => _sortBy = value),
    );
  }

  Widget _body() {
    if (_report.rows.isEmpty) {
      return ListView(
        children: [
          if (_report.fromCache) _offlineBanner(),
          const SizedBox(height: 120),
          const Icon(Icons.account_balance_wallet_outlined,
              size: 56, color: Colors.black26),
          const SizedBox(height: 12),
          Text(
            l10n.noReceivablesAllSettled,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, fontSize: 16),
          ),
        ],
      );
    }

    final groups = _groups;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (_report.fromCache) _offlineBanner(),
        _summaryHeader(),
        const SizedBox(height: 12),
        if (groups.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Text(
              l10n.noMatches,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.mutedColor, fontSize: 15),
            ),
          )
        else
          for (final group in groups) ..._driverGroup(group.key, group.value),
      ],
    );
  }

  Widget _offlineBanner() {
    const color = Color(0xFFD97706);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_outlined, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.offlineShowingLocalData,
              style: const TextStyle(color: color, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryHeader() {
    final buckets = _report.bucketTotals;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.totalOutstanding,
                    style: const TextStyle(
                        color: AppTheme.mutedColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                Text(_afn(_report.grandTotal),
                    style: const TextStyle(
                        color: Color(0xFFDC2626),
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                for (final bucket in AgingBucket.values)
                  _bucketStat(bucket, buckets[bucket] ?? 0),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _bucketStat(AgingBucket bucket, double amount) {
    final color = _bucketColors[bucket]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_bucketLabels[bucket]!,
              style: TextStyle(color: color, fontSize: 11)),
          const SizedBox(height: 2),
          Text(_afn(amount),
              style: TextStyle(
                  color: color, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  List<Widget> _driverGroup(String driverKey, List<ReceivableRow> rows) {
    final subtotal = rows.fold<double>(0, (sum, r) => sum + r.outstanding);
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${_driverLabel(driverKey)}  (${rows.length})',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text(_afn(subtotal),
                style: const TextStyle(
                    color: Color(0xFFDC2626),
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      ...rows.map(_customerTile),
    ];
  }

  Widget _customerTile(ReceivableRow row) {
    final c = row.customer;
    final color = _bucketColors[row.bucket]!;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        dense: true,
        onTap: () => _openCustomer(c),
        title: Text(c.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          [
            if (c.phone != null && c.phone!.isNotEmpty) c.phone!,
            row.oldestUnpaid == null
                ? l10n.noOpenInvoice
                : l10n.oldestUnpaidDays(
                    AppUtils.formatDate(row.oldestUnpaid!), row.daysOverdue),
          ].join('  •  '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: AppTheme.mutedColor, fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(_afn(row.outstanding),
                style: const TextStyle(
                    color: Color(0xFFDC2626),
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(_bucketLabels[row.bucket]!,
                  style: TextStyle(
                      color: color, fontSize: 10, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
