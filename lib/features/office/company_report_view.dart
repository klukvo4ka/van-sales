import 'package:flutter/material.dart';

import '../../core/locale/l10n.dart';
import '../../core/repositories/company_report_repository.dart';
import '../../core/services/report_export.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../main.dart' show syncProvider;

class CompanyReportView extends StatefulWidget {
  const CompanyReportView({super.key});

  @override
  State<CompanyReportView> createState() => _CompanyReportViewState();
}

class _CompanyReportViewState extends State<CompanyReportView> {
  final _repo = CompanyReportRepository();

  CompanyPeriod _period = CompanyPeriod.day;
  DateTime _anchor = DateTime.now();
  CompanyReport _report = const CompanyReport();
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
    await syncProvider.service.syncNow();
    if (!mounted) return;
    setState(() => _loading = false);
    await _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _fetching = true);
    final report = await _repo.fetch(period: _period, anchor: _anchor);
    if (!mounted) return;
    setState(() {
      _report = report;
      _fetching = false;
    });
  }

  Future<void> _refresh() async {
    await syncProvider.service.syncNow();
    await _load();
  }

  Future<void> _setPeriod(CompanyPeriod period) async {
    setState(() {
      _period = period;
      _anchor = DateTime.now();
    });
    await _load();
  }

  bool get _canGoNext {
    final (_, to) = CompanyReportRepository.rangeFor(_period, _anchor);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return to.isBefore(today);
  }

  Future<void> _shift(bool forward) async {
    setState(() {
      _anchor = forward
          ? CompanyReportRepository.nextAnchor(_period, _anchor)
          : CompanyReportRepository.previousAnchor(_period, _anchor);
    });
    await _load();
  }

  String get _rangeLabel {
    final (from, to) = CompanyReportRepository.rangeFor(_period, _anchor);
    return from == to
        ? AppUtils.formatDate(from)
        : '${AppUtils.formatDate(from)} — ${AppUtils.formatDate(to)}';
  }

  static String _afn(double v) => '${v.round()} AFN';

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
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _periodChip(CompanyPeriod.day, l10n.day),
              const SizedBox(width: 8),
              _periodChip(CompanyPeriod.week, l10n.week),
              const SizedBox(width: 8),
              _periodChip(CompanyPeriod.month, l10n.month),
              const SizedBox(width: 12),
              ExportButtons(
                enabled: !_fetching && !_report.isEmpty,
                onPdf: () => ReportExport.exportPdf(
                  context,
                  reportName: _companyReportName,
                  filters: _companyFilterLine,
                  fileBase: _companyFileBase,
                  tables: _companyTables(),
                ),
                onExcel: () => ReportExport.exportExcel(
                  context,
                  reportName: _companyReportName,
                  filters: _companyFilterLine,
                  fileBase: _companyFileBase,
                  tables: _companyTables(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            IconButton(
              onPressed: _fetching ? null : () => _shift(false),
              tooltip: l10n.previous,
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Text(
                _rangeLabel,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
            IconButton(
              onPressed: _fetching || !_canGoNext ? null : () => _shift(true),
              tooltip: l10n.next,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ],
    );
  }

  static String get _companyReportName => l10n.companyReport;

  String get _periodLabel => switch (_period) {
        CompanyPeriod.day => l10n.day,
        CompanyPeriod.week => l10n.week,
        CompanyPeriod.month => l10n.month,
      };

  String get _companyFilterLine => '$_periodLabel — $_rangeLabel';

  String get _companyFileBase {
    final (from, to) = CompanyReportRepository.rangeFor(_period, _anchor);
    return ReportExport.fileBase(
      'company_${_period.name}',
      'all',
      '${AppUtils.formatDate(from)}_${AppUtils.formatDate(to)}',
    );
  }

  List<ReportTable> _companyTables() {
    final r = _report;
    return [
      ReportTable(
        title: l10n.summary,
        columns: [l10n.metric, l10n.value],
        rows: [
          [l10n.totalSoldAfn, r.totalSold],
          [l10n.invoices, r.invoiceCount],
          [l10n.avgInvoiceAfn, r.avgInvoice],
          [l10n.cashCollectedAfn, r.cashCollected],
          [l10n.transferCollectedAfn, r.transferCollected],
          [l10n.totalCollectedAfn, r.totalCollected],
          [l10n.cashHandedInAfn, r.cashHandedIn],
          [l10n.newDebtAfn, r.newDebt],
          [l10n.outstandingAfn, r.outstanding],
          [l10n.activeDrivers, r.activeDrivers],
          [l10n.customersServed, r.customersServed],
          [l10n.prevSoldAfn, r.prevSold],
          [l10n.prevCollectedAfn, r.prevCollected],
        ],
      ),
      ReportTable(
        title: l10n.trend,
        columns: [
          l10n.bucket,
          l10n.soldAfn,
          l10n.collectedAfn,
        ],
        rows: [
          for (var i = 0; i < r.trend.length; i++)
            [
              r.trend[i].label.isEmpty ? '${i + 1}' : r.trend[i].label,
              r.trend[i].sold,
              r.trend[i].collected,
            ],
        ],
      ),
      ReportTable(
        title: l10n.topDriversSold,
        columns: [l10n.driver, l10n.soldAfn],
        rows: [
          for (final d in r.topDriversBySold) [d.name, d.amount],
        ],
      ),
      ReportTable(
        title: l10n.topDriversCollected,
        columns: [l10n.driver, l10n.collectedAfn],
        rows: [
          for (final d in r.topDriversByCollected) [d.name, d.amount],
        ],
      ),
      ReportTable(
        title: l10n.topProducts,
        columns: [l10n.product, l10n.revenueAfn],
        rows: [
          for (final p in r.topProducts) [p.name, p.amount],
        ],
      ),
    ];
  }

  Widget _periodChip(CompanyPeriod period, String label) {
    final selected = _period == period;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      labelStyle: TextStyle(
          color: selected ? Colors.white : AppTheme.primaryColor, fontSize: 12),
      onSelected: _fetching ? null : (_) => _setPeriod(period),
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
    final r = _report;
    if (r.isEmpty) {
      return ListView(
        children: [
          if (r.fromCache) _offlineBanner(),
          const SizedBox(height: 120),
          const Icon(Icons.business_outlined, size: 56, color: Colors.black26),
          const SizedBox(height: 12),
          Text(
            l10n.noActivityInThisPeriod,
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
        if (r.fromCache) _offlineBanner(),
        _kpiGrid(),
        const SizedBox(height: 12),
        _trendCard(),
        const SizedBox(height: 12),
        _leaderboards(),
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

  Widget _changeTag(double? pct) {
    if (pct == null) return const SizedBox.shrink();
    final up = pct >= 0;
    final color = up ? _okColor : _debtColor;
    return Text(
      '${up ? '▲' : '▼'} ${pct.abs().round()}%',
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
    );
  }

  Widget _kpiGrid() {
    final r = _report;
    final cards = <Widget>[
      _kpiCard(
        icon: Icons.trending_up,
        label: l10n.sold,
        value: _afn(r.totalSold),
        subtitle: l10n.invoicesAvg(r.invoiceCount, _afn(r.avgInvoice)),
        trailing: _changeTag(r.soldChangePct),
      ),
      _kpiCard(
        icon: Icons.payments_outlined,
        label: l10n.collected3,
        value: _afn(r.totalCollected),
        subtitle:
            l10n.cashTransfer(_afn(r.cashCollected), _afn(r.transferCollected)),
        valueColor: _okColor,
        trailing: _changeTag(r.collectedChangePct),
      ),
      _kpiCard(
        icon: Icons.savings_outlined,
        label: l10n.cashHandedIn,
        value: _afn(r.cashHandedIn),
      ),
      _kpiCard(
        icon: Icons.trending_down,
        label: l10n.newDebt,
        value: _afn(r.newDebt),
        valueColor: r.newDebt > 0 ? _debtColor : null,
      ),
      _kpiCard(
        icon: Icons.account_balance_wallet_outlined,
        label: l10n.outstanding,
        value: _afn(r.outstanding),
        valueColor: r.outstanding > 0 ? _debtColor : null,
      ),
      _kpiCard(
        icon: Icons.people_outline,
        label: l10n.activeDrivers,
        value: '${r.activeDrivers}',
        subtitle: l10n.customersServedCount(r.customersServed),
      ),
    ];
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 320,
        mainAxisExtent: 116,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      children: cards,
    );
  }

  Widget _kpiCard({
    required IconData icon,
    required String label,
    required String value,
    String? subtitle,
    Color? valueColor,
    Widget? trailing,
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
                if (trailing != null) trailing,
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

  Widget _trendCard() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(l10n.soldVsCollected,
                      style: const TextStyle(
                          color: AppTheme.mutedColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
                _legendDot(AppTheme.accentColor, l10n.sold),
                const SizedBox(width: 12),
                _legendDot(_okColor, l10n.collected3),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(height: 140, child: _TrendBars(points: _report.trend)),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(color: AppTheme.mutedColor, fontSize: 11)),
      ],
    );
  }

  Widget _leaderboards() {
    final r = _report;
    final sections = <Widget>[
      _leaderCard(l10n.topDriversSold, r.topDriversBySold),
      _leaderCard(l10n.topDriversCollected, r.topDriversByCollected,
          color: _okColor),
      _leaderCard(l10n.topProducts, r.topProducts),
    ];
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 520,
        mainAxisExtent: 220,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      children: sections,
    );
  }

  Widget _leaderCard(String title, List<LeaderStat> stats, {Color? color}) {
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
              child: stats.isEmpty
                  ? Center(
                      child: Text(l10n.nothingHere,
                          style: const TextStyle(
                              color: AppTheme.mutedColor, fontSize: 13)),
                    )
                  : ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        for (var i = 0; i < stats.length && i < 5; i++)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  child: Text('${i + 1}.',
                                      style: const TextStyle(
                                          color: AppTheme.mutedColor,
                                          fontSize: 12)),
                                ),
                                Expanded(
                                  child: Text(stats[i].name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 13, color: Colors.black87)),
                                ),
                                Text(_afn(stats[i].amount),
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: color ?? AppTheme.primaryColor)),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendBars extends StatelessWidget {
  const _TrendBars({required this.points});

  final List<TrendPoint> points;

  static const _okColor = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return Center(
        child: Text(l10n.noData,
            style: const TextStyle(color: AppTheme.mutedColor, fontSize: 13)),
      );
    }
    var maxValue = 0.0;
    for (final p in points) {
      if (p.sold > maxValue) maxValue = p.sold;
      if (p.collected > maxValue) maxValue = p.collected;
    }
    if (maxValue <= 0) maxValue = 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final p in points)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                            child:
                                _bar(p.sold / maxValue, AppTheme.accentColor)),
                        const SizedBox(width: 1),
                        Expanded(child: _bar(p.collected / maxValue, _okColor)),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 14,
                    child: Text(p.label,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: const TextStyle(
                            color: AppTheme.mutedColor, fontSize: 9)),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _bar(double fraction, Color color) {
    final f = fraction.clamp(0.0, 1.0);
    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: f <= 0 ? 0.02 : f,
        widthFactor: 1,
        child: Container(
          decoration: BoxDecoration(
            color: f > 0 ? color : color.withValues(alpha: 0.10),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
          ),
        ),
      ),
    );
  }
}
