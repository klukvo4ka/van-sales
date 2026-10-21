import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/locale/l10n.dart';
import '../../core/repositories/truck_initial_stock_repository.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/sync_status_bar.dart';
import '../../main.dart' show syncProvider;
import 'inventory_tab.dart';
import 'truck_detail_screen.dart';

class TrucksTab extends StatefulWidget {
  const TrucksTab({super.key});

  @override
  State<TrucksTab> createState() => _TrucksTabState();
}

class _TrucksTabState extends State<TrucksTab> {
  final _repo = TruckInitialStockRepository();

  List<Truck> _trucks = [];
  Map<String, DriverProfile> _driverByTruck = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh(syncFirst: true);
  }

  Future<void> _refresh({bool syncFirst = false}) async {
    if (syncFirst) {
      await syncProvider.service.syncNow();
    }
    final trucks = await _repo.getAllTrucks();
    final profiles = await _repo.getDriverProfiles();
    final byTruck = <String, DriverProfile>{
      for (final p in profiles)
        if (p.truckId != null && p.truckId!.isNotEmpty) p.truckId!: p,
    };
    if (!mounted) return;
    setState(() {
      _trucks = trucks;
      _driverByTruck = byTruck;
      _loading = false;
    });
  }

  Future<void> _openTruck(Truck truck) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => TruckDetailScreen(truck: truck),
      ),
    );
    await _refresh();
  }

  void _openProducts() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text(l10n.products, style: const TextStyle(fontSize: 16)),
          ),
          body: const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
            child: InventoryTab(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: SyncStatusBar(
            service: syncProvider.service,
            onSync: () => _refresh(syncFirst: true),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.truckCount(_trucks.length),
                  style: const TextStyle(color: AppTheme.mutedColor),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _openProducts,
                icon: const Icon(Icons.inventory_2_outlined, size: 18),
                label: Text(l10n.manageProducts),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _refresh(syncFirst: true),
            child: _trucks.isEmpty ? _emptyTrucks() : _trucksGrid(),
          ),
        ),
      ],
    );
  }

  Widget _emptyTrucks() {
    return ListView(
      children: [
        const SizedBox(height: 120),
        const Icon(Icons.local_shipping_outlined,
            size: 56, color: Colors.black26),
        const SizedBox(height: 12),
        Text(
          l10n.noTrucks,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black54, fontSize: 16),
        ),
      ],
    );
  }

  Widget _trucksGrid() {
    return GridView(
      padding: const EdgeInsets.only(bottom: 24),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 440,
        mainAxisExtent: 92,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      children: _trucks.map(_truckCard).toList(),
    );
  }

  Widget _truckCard(Truck truck) {
    final driver = _driverByTruck[truck.id];
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        onTap: () => _openTruck(truck),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              const Icon(Icons.local_shipping_outlined,
                  size: 32, color: AppTheme.accentColor),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(truck.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${truck.plateNumber} — '
                            '${driver?.fullName ?? l10n.noDriver}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: AppTheme.mutedColor, fontSize: 12),
                          ),
                        ),
                        if (!truck.isActive) ...[
                          const SizedBox(width: 8),
                          const _InactiveBadge(),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.mutedColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _InactiveBadge extends StatelessWidget {
  const _InactiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Text(
        l10n.inactive,
        style: const TextStyle(color: AppTheme.mutedColor, fontSize: 10),
      ),
    );
  }
}
