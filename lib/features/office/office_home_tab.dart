import 'package:flutter/material.dart';

import '../../core/locale/l10n.dart';
import '../../core/repositories/office_dashboard_repository.dart';
import '../../core/services/notification_service.dart';
import '../../core/theme/app_theme.dart';
import 'sales_report_view.dart';

class OfficeHomeTab extends StatefulWidget {
  const OfficeHomeTab({super.key, this.notifications, this.onSelectTab});

  final NotificationService? notifications;
  final ValueChanged<int>? onSelectTab;

  @override
  State<OfficeHomeTab> createState() => _OfficeHomeTabState();
}

class _OfficeHomeTabState extends State<OfficeHomeTab> {
  final _repo = OfficeDashboardRepository();

  OfficeDashboardData _data = const OfficeDashboardData();
  bool _loading = true;
  bool _loadInFlight = false;
  bool _refreshQueued = false;

  static const _okColor = Color(0xFF16A34A);
  static const _debtColor = Color(0xFFDC2626);
  static const _warnColor = Color(0xFFD97706);

  @override
  void initState() {
    super.initState();
    widget.notifications?.addListener(_onRealtimeInvoice);
    _load();
  }

  @override
  void dispose() {
    widget.notifications?.removeListener(_onRealtimeInvoice);
    super.dispose();
  }

  void _onRealtimeInvoice() {
    _load();
  }

  Future<void> _load() async {
    if (_loadInFlight) {
      _refreshQueued = true;
      return;
    }

    _loadInFlight = true;
    try {
      final data = await _repo.fetch();
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } finally {
      _loadInFlight = false;
    }

    if (mounted && _refreshQueued) {
      _refreshQueued = false;
      await _load();
    }
  }

  static String _afn(double v) => '${v.round()} AFN';

  static String _units(double q) =>
      q == q.roundToDouble() ? '${q.round()}' : '$q';

  static String _time(DateTime? d) => d == null
      ? '—'
      : '${d.hour.toString().padLeft(2, '0')}:'
          '${d.minute.toString().padLeft(2, '0')}';

  void _openDriverReport(DriverDayRow row) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text(l10n.driverSalesToday(row.name),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16)),
          ),
          body: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
            child: SalesReportView(initialDriverId: row.driverId),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          if (_data.fromCache) _offlineBanner(),
          _kpiGrid(),
          const SizedBox(height: 16),
          _sectionTitle(l10n.trucks),
          const SizedBox(height: 8),
          _trucksStrip(),
          const SizedBox(height: 16),
          _sectionTitle(l10n.todayByDriver),
          const SizedBox(height: 8),
          if (_data.drivers.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                l10n.noActivityToday,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.mutedColor),
              ),
            )
          else
            ..._data.drivers.map(_driverTile),
        ],
      ),
    );
  }

  Widget _offlineBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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

  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            color: AppTheme.mutedColor,
            fontSize: 13,
            fontWeight: FontWeight.w600));
  }

  Widget _kpiGrid() {
    final d = _data;
    final cards = <Widget>[
      _KpiCard(
        icon: Icons.trending_up,
        label: l10n.soldToday,
        value: _afn(d.soldToday),
        subtitle: l10n.invoiceCount(d.invoiceCount),
      ),
      _KpiCard(
        icon: Icons.payments_outlined,
        label: l10n.collectedToday,
        value: _afn(d.totalCollected),
        subtitle:
            l10n.cashTransfer(_afn(d.cashCollected), _afn(d.transferCollected)),
        valueColor: _okColor,
      ),
      _KpiCard(
        icon: Icons.account_balance_wallet_outlined,
        label: l10n.outstanding,
        value: _afn(d.outstanding),
        valueColor: d.outstanding > 0 ? _debtColor : null,
      ),
      _KpiCard(
        icon: Icons.people_outline,
        label: l10n.activeDrivers,
        value: '${d.activeDrivers} / ${d.totalDrivers}',
      ),
    ];
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 320,
        mainAxisExtent: 128,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      children: cards,
    );
  }

  Widget _trucksStrip() {
    if (_data.trucks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          l10n.noActiveTrucks,
          style: const TextStyle(color: AppTheme.mutedColor),
        ),
      );
    }
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _data.trucks.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final t = _data.trucks[i];
          return InkWell(
            onTap: () => widget.onSelectTab?.call(1),
            borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            child: Container(
              width: 190,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppTheme.borderColor),
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_shipping_outlined,
                          size: 18, color: AppTheme.accentColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          t.name.isEmpty ? t.plate : t.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(t.plate,
                      style: const TextStyle(
                          color: AppTheme.mutedColor, fontSize: 11)),
                  const Spacer(),
                  Text(
                    l10n.soldUnitsOfInitial(
                        _units(t.soldUnits), _units(t.initialUnits)),
                    style: const TextStyle(
                        color: AppTheme.mutedColor, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _driverTile(DriverDayRow row) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: AppTheme.primaryColor,
          child: Text(
            row.name.isEmpty ? '?' : row.name[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
        title: Text(row.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          l10n.soldCollectedInv(
              _afn(row.sold), _afn(row.collected), row.invoiceCount),
          style: const TextStyle(color: AppTheme.mutedColor, fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(_time(row.lastActivity),
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Text(l10n.last,
                style:
                    const TextStyle(color: AppTheme.mutedColor, fontSize: 10)),
          ],
        ),
        onTap: () => _openDriverReport(row),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Card(
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
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppTheme.mutedColor, fontSize: 12),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 22,
                    color: valueColor ?? AppTheme.primaryColor,
                  ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(color: AppTheme.mutedColor, fontSize: 11),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
