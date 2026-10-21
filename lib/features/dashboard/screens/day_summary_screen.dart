import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/locale/l10n.dart';
import '../../../core/repositories/day_summary_repository.dart';
import '../../../core/repositories/invoice_repository.dart';
import '../../../core/services/day_summary_pdf.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/widgets/sync_status_bar.dart';
import '../../../main.dart' show syncProvider;
import '../../customers/screens/customer_detail_screen.dart';

class DaySummaryScreen extends StatefulWidget {
  const DaySummaryScreen({super.key});

  @override
  State<DaySummaryScreen> createState() => _DaySummaryScreenState();
}

class _DaySummaryScreenState extends State<DaySummaryScreen> {
  final _repo = DaySummaryRepository();

  String _driverId = '';
  String _driverName = '';
  DaySummary _summary = const DaySummary();
  bool _loading = true;

  static const _okColor = Color(0xFF16A34A);
  static const _debtColor = Color(0xFFDC2626);

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _driverId = AuthService().currentUser?.id ?? '';
    _driverName = await InvoiceRepository().driverNameFor(_driverId);
    await _load();
  }

  Future<void> _load() async {
    final summary = await _repo.getDaySummary(_driverId);
    if (mounted) {
      setState(() {
        _summary = summary;
        _loading = false;
      });
    }
  }

  Future<void> _refresh() async {
    await syncProvider.service.syncNow();
    await _load();
  }

  void _openPdf() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => _DaySummaryPdfScreen(
          summary: _summary,
          driverName: _driverName,
        ),
      ),
    );
  }

  Future<void> _openCustomer(CustomerDayRow row) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => CustomerDetailScreen(customer: row.customer),
      ),
    );
    await _load();
  }

  static String _afn(double v) => '${v.round()} AFN';

  static String _qty(double q) =>
      q == q.roundToDouble() ? '${q.round()}' : '$q';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.daySummary, style: const TextStyle(fontSize: 16)),
        actions: [
          if (!_loading)
            IconButton(
              onPressed: _openPdf,
              tooltip: l10n.pdfReport,
              icon: const Icon(Icons.picture_as_pdf_outlined),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(AppTheme.screenPadding),
                      children: [
                        _salesCard(),
                        const SizedBox(height: 12),
                        _collectedCard(),
                        const SizedBox(height: 12),
                        _dayCard(),
                        if (_summary.customers.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(l10n.customersToday,
                              style: const TextStyle(
                                  color: AppTheme.mutedColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          ..._summary.customers.map(_customerTile),
                        ],
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: SyncStatusBar(
                      service: syncProvider.service, onSync: _refresh),
                ),
              ],
            ),
    );
  }

  Widget _metricRow(String label, String value,
      {Color? color, bool bold = false}) {
    final style = TextStyle(
      color: color ?? Colors.black87,
      fontSize: bold ? 15 : 14,
      fontWeight: bold ? FontWeight.bold : FontWeight.w500,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label,
                style: TextStyle(
                    color: color ?? AppTheme.mutedColor, fontSize: 13)),
          ),
          Text(value, style: style),
        ],
      ),
    );
  }

  Widget _sectionCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: AppTheme.mutedColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _salesCard() {
    final s = _summary;
    return _sectionCard(l10n.sales, [
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(_afn(s.totalSold),
              style: Theme.of(context)
                  .textTheme
                  .displayLarge
                  ?.copyWith(fontSize: 26)),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Text(l10n.invoiceCount(s.invoiceCount),
                style:
                    const TextStyle(color: AppTheme.mutedColor, fontSize: 12)),
          ),
        ],
      ),
      const Divider(height: 16),
      _metricRow(l10n.cashSalesCount(s.cashCount), _afn(s.cashAmount)),
      _metricRow(l10n.partialCount(s.partialCount), _afn(s.partialAmount)),
      _metricRow(l10n.creditSalesCount(s.creditCount), _afn(s.creditAmount)),
    ]);
  }

  Widget _collectedCard() {
    final s = _summary;
    return _sectionCard(l10n.collected, [
      _metricRow(l10n.cash, _afn(s.cashCollected)),
      _metricRow(l10n.transfer, _afn(s.transferCollected)),
      const Divider(height: 16),
      _metricRow(l10n.totalCollected, _afn(s.totalCollected),
          color: _okColor, bold: true),
    ]);
  }

  Widget _dayCard() {
    final s = _summary;
    return _sectionCard(l10n.day, [
      _metricRow(l10n.newDebtToday, _afn(s.newDebt),
          color: s.newDebt > 0 ? _debtColor : null, bold: s.newDebt > 0),
      _metricRow(l10n.visited, '${s.visitedCount} / ${s.routeCount}'),
      _metricRow(l10n.unitsSold, _qty(s.unitsSold)),
      _metricRow(l10n.stockValueLeft, _afn(s.stockValue)),
    ]);
  }

  Widget _customerTile(CustomerDayRow row) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        dense: true,
        title: Text(row.customer.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          l10n.soldCollected(_afn(row.sold), _afn(row.collected)),
          style: const TextStyle(color: AppTheme.mutedColor, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: () => _openCustomer(row),
      ),
    );
  }
}

class _DaySummaryPdfScreen extends StatelessWidget {
  const _DaySummaryPdfScreen({
    required this.summary,
    required this.driverName,
  });

  final DaySummary summary;
  final String driverName;

  @override
  Widget build(BuildContext context) {
    final date = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dayReport(AppUtils.formatDate(date)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16)),
      ),
      body: PdfPreview(
        build: (_) => DaySummaryPdf.build(
          summary: summary,
          date: date,
          driverName: driverName,
        ),
        pdfFileName: 'day-summary-${AppUtils.formatDate(date)}.pdf',
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
      ),
    );
  }
}
