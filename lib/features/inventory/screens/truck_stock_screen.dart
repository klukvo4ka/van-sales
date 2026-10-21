import 'package:flutter/material.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/locale/l10n.dart';
import '../../../core/repositories/truck_initial_stock_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/sync_status_bar.dart';
import '../../../main.dart' show syncProvider;

class TruckStockScreen extends StatefulWidget {
  const TruckStockScreen({super.key});

  @override
  State<TruckStockScreen> createState() => _TruckStockScreenState();
}

class _TruckStockScreenState extends State<TruckStockScreen> {
  final _repo = TruckInitialStockRepository();

  String _driverId = '';
  String _truckId = '';
  List<RemainingStockRow> _rows = [];
  bool _loading = true;

  bool get _hasTruck => _truckId.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _driverId = AuthService().currentUser?.id ?? '';
    _truckId = await _repo.truckIdForDriver(_driverId);
    await _reload();
  }

  Future<void> _reload() async {
    final rows = _hasTruck
        ? await _repo.getRemainingStock(_driverId, _truckId)
        : <RemainingStockRow>[];
    if (mounted) {
      setState(() {
        _rows = rows;
        _loading = false;
      });
    }
  }

  Future<void> _refresh() async {
    await syncProvider.service.syncNow();
    _truckId = await _repo.truckIdForDriver(_driverId);
    await _reload();
  }

  Color _color(double ratio, double remaining) {
    if (remaining <= 0 || ratio < 0.10) return Colors.red;
    if (ratio < 0.30) return Colors.orange;
    return Colors.green;
  }

  static String _qty(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _buildContent()),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: SyncStatusBar(service: syncProvider.service, onSync: _refresh),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (!_hasTruck) return _buildNoTruck();

    final totalRemaining = _rows.fold<double>(0, (sum, r) => sum + r.remaining);

    return Column(
      children: [
        if (_rows.isNotEmpty)
          _SummaryBar(skus: _rows.length, unitsRemaining: totalRemaining),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: _rows.isEmpty ? _buildNoStock() : _buildList(),
          ),
        ),
      ],
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: _rows.length,
      itemBuilder: (context, i) {
        final r = _rows[i];
        final color = _color(r.remainingRatio, r.remaining);
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.product?.name ?? r.productId,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        l10n.initialAndSold(_qty(r.initial), _qty(r.sold),
                            r.product?.unit ?? ''),
                        style: const TextStyle(
                            color: AppTheme.mutedColor, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _RemainingBadge(
                  value: _qty(r.remaining),
                  unit: r.product?.unit ?? '',
                  color: color,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoStock() {
    return ListView(
      children: [
        const SizedBox(height: 120),
        const Icon(Icons.local_shipping_outlined,
            size: 64, color: Colors.black26),
        const SizedBox(height: 16),
        Text(
          l10n.stockNotSetYet,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black54, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildNoTruck() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_shipping_outlined,
                size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              l10n.noTruckAssigned2,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.contactOfficeToAssignTruck,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.mutedColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.skus, required this.unitsRemaining});
  final int skus;
  final double unitsRemaining;

  static String _n(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryStat(label: l10n.skus, value: '$skus'),
          Container(width: 1, height: 36, color: Colors.white24),
          _SummaryStat(label: l10n.unitsRemaining, value: _n(unitsRemaining)),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

class _RemainingBadge extends StatelessWidget {
  const _RemainingBadge(
      {required this.value, required this.unit, required this.color});
  final String value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          Text(unit, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}
