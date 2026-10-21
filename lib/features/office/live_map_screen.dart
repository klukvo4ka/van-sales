import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/database/app_database.dart';
import '../../core/locale/l10n.dart';
import '../../core/repositories/truck_initial_stock_repository.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_logger.dart';
import 'sales_report_view.dart';

class _DriverPin {
  const _DriverPin({
    required this.driverId,
    required this.lat,
    required this.lng,
    required this.updatedAt,
  });

  final String driverId;
  final double lat;
  final double lng;
  final DateTime updatedAt;

  Duration get age => DateTime.now().difference(updatedAt);
  bool get fresh => age.inMinutes < 15;
  bool get visible => age.inMinutes < 60;
}

class LiveMapView extends StatefulWidget {
  const LiveMapView({super.key});

  @override
  State<LiveMapView> createState() => _LiveMapViewState();
}

class _LiveMapViewState extends State<LiveMapView> {
  final _stockRepo = TruckInitialStockRepository();
  final _mapController = MapController();

  final Map<String, _DriverPin> _pins = {};
  Map<String, DriverProfile> _profiles = {};
  Map<String, Truck> _truckById = {};
  RealtimeChannel? _channel;
  Timer? _staleTimer;
  bool _loading = true;
  bool _offline = false;
  bool _showList = false;
  bool _fittedOnce = false;

  static const _kabul = LatLng(34.5553, 69.2075);
  static const _staleColor = Color(0xFF94A3B8);

  @override
  void initState() {
    super.initState();
    _init();
    _staleTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _staleTimer?.cancel();
    _channel?.unsubscribe();
    super.dispose();
  }

  Future<void> _init() async {
    final profiles = await _stockRepo.getDriverProfiles();
    final trucks = await _stockRepo.getAllTrucks();
    if (mounted) {
      setState(() {
        _profiles = {for (final p in profiles) p.id: p};
        _truckById = {for (final t in trucks) t.id: t};
      });
    }
    await _fetchAll();
    _subscribe();
  }

  Future<void> _fetchAll() async {
    try {
      final rows =
          await Supabase.instance.client.from('driver_locations').select();
      if (!mounted) return;
      setState(() {
        _pins.clear();
        for (final row in rows) {
          final pin = _pinFromRow(row);
          if (pin != null) _pins[pin.driverId] = pin;
        }
        _offline = false;
        _loading = false;
      });
      _fitToPins();
    } catch (e, st) {
      AppLogger.error('LiveMapView._fetchAll', e, st);
      if (mounted) {
        setState(() {
          _offline = true;
          _loading = false;
          _showList = true;
        });
      }
    }
  }

  void _subscribe() {
    try {
      _channel = Supabase.instance.client
          .channel('office_driver_locations')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'driver_locations',
            callback: (payload) {
              if (!mounted) return;
              setState(() {
                if (payload.eventType == PostgresChangeEvent.delete) {
                  final id = payload.oldRecord['driver_id'] as String?;
                  if (id != null) _pins.remove(id);
                } else {
                  final pin = _pinFromRow(payload.newRecord);
                  if (pin != null) _pins[pin.driverId] = pin;
                }
              });
            },
          )
          .subscribe();
    } catch (e, st) {
      AppLogger.error('LiveMapView._subscribe', e, st);
    }
  }

  _DriverPin? _pinFromRow(Map<String, dynamic> row) {
    final driverId = row['driver_id'] as String?;
    final lat = (row['lat'] as num?)?.toDouble();
    final lng = (row['lng'] as num?)?.toDouble();
    if (driverId == null || lat == null || lng == null) return null;
    return _DriverPin(
      driverId: driverId,
      lat: lat,
      lng: lng,
      updatedAt:
          DateTime.tryParse(row['updated_at']?.toString() ?? '')?.toLocal() ??
              DateTime.now(),
    );
  }

  List<_DriverPin> get _visiblePins =>
      _pins.values.where((p) => p.visible).toList()
        ..sort((a, b) => a.age.compareTo(b.age));

  void _fitToPins() {
    final pins = _visiblePins;
    if (_fittedOnce || pins.isEmpty || _showList) return;
    _fittedOnce = true;
    if (pins.length == 1) {
      _mapController.move(LatLng(pins.first.lat, pins.first.lng), 13);
      return;
    }
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(
            pins.map((p) => LatLng(p.lat, p.lng)).toList()),
        padding: const EdgeInsets.all(56),
      ),
    );
  }

  String _driverName(String driverId) =>
      _profiles[driverId]?.fullName ?? l10n.driver;

  String _plate(String driverId) {
    final truckId = _profiles[driverId]?.truckId;
    return truckId == null ? '' : _truckById[truckId]?.plateNumber ?? '';
  }

  static String _ago(Duration age) {
    if (age.inMinutes < 1) return l10n.justNow2;
    if (age.inMinutes < 60) return l10n.minAgo(age.inMinutes);
    return l10n.hAgo(age.inHours);
  }

  Future<void> _openDriverSheet(_DriverPin pin) async {
    double soldToday = 0;
    try {
      final now = DateTime.now();
      final today = '${now.year.toString().padLeft(4, '0')}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}';
      final rows = await Supabase.instance.client
          .from('invoices')
          .select('total_amount')
          .eq('driver_id', pin.driverId)
          .eq('invoice_date', today);
      soldToday = rows.fold<double>(
          0, (sum, r) => sum + ((r['total_amount'] as num?)?.toDouble() ?? 0));
    } catch (e, st) {
      AppLogger.error('LiveMapView._openDriverSheet', e, st);
    }
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(_driverName(pin.driverId),
                  style: Theme.of(sheetContext).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                [
                  if (_plate(pin.driverId).isNotEmpty) _plate(pin.driverId),
                  l10n.updated(_ago(pin.age)),
                ].join('  •  '),
                style:
                    const TextStyle(color: AppTheme.mutedColor, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.trending_up,
                      size: 20, color: AppTheme.accentColor),
                  const SizedBox(width: 8),
                  Text(
                    l10n.soldTodayAfn(soldToday.round()),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => Scaffold(
                          appBar: AppBar(
                            title: Text(
                                l10n.driverSales(_driverName(pin.driverId)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 16)),
                          ),
                          body: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.screenPadding),
                            child:
                                SalesReportView(initialDriverId: pin.driverId),
                          ),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.bar_chart_outlined, size: 20),
                  label: Text(l10n.salesReport),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.driversOnMap(_visiblePins.length),
                  style: const TextStyle(color: AppTheme.mutedColor),
                ),
              ),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                      value: false,
                      icon: const Icon(Icons.map_outlined, size: 18),
                      label: Text(l10n.map)),
                  ButtonSegment(
                      value: true,
                      icon: const Icon(Icons.list_outlined, size: 18),
                      label: Text(l10n.list)),
                ],
                selected: {_showList},
                onSelectionChanged: (selection) =>
                    setState(() => _showList = selection.first),
              ),
              IconButton(
                tooltip: l10n.refresh,
                onPressed: _fetchAll,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
        ),
        if (_offline)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFD97706).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              border: Border.all(
                  color: const Color(0xFFD97706).withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.cloud_off_outlined,
                    size: 20, color: Color(0xFFD97706)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.offlineLiveMapUnavailable,
                    style:
                        const TextStyle(color: Color(0xFFD97706), fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        Expanded(child: _showList ? _listView() : _mapView()),
      ],
    );
  }

  Widget _mapView() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      child: FlutterMap(
        mapController: _mapController,
        options: const MapOptions(
          initialCenter: _kabul,
          initialZoom: 12,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'dev.maksimenko.vansales',
          ),
          MarkerLayer(
            markers: [
              for (final pin in _visiblePins)
                Marker(
                  point: LatLng(pin.lat, pin.lng),
                  width: 44,
                  height: 44,
                  child: GestureDetector(
                    onTap: () => _openDriverSheet(pin),
                    child: Container(
                      decoration: BoxDecoration(
                        color: pin.fresh ? AppTheme.accentColor : _staleColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: const [
                          BoxShadow(color: Colors.black38, blurRadius: 4),
                        ],
                      ),
                      child: const Icon(Icons.local_shipping,
                          color: Colors.white, size: 22),
                    ),
                  ),
                ),
            ],
          ),
          const SimpleAttributionWidget(
            source: Text('© OpenStreetMap'),
          ),
        ],
      ),
    );
  }

  Widget _listView() {
    final pins = _visiblePins;
    if (pins.isEmpty) {
      return Center(
        child: Text(
          l10n.noLiveDriverLocations,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.mutedColor, fontSize: 15),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: pins.length,
      itemBuilder: (context, i) {
        final pin = pins[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            dense: true,
            leading: Icon(Icons.local_shipping,
                color: pin.fresh ? AppTheme.accentColor : _staleColor),
            title: Text(_driverName(pin.driverId),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
              [
                if (_plate(pin.driverId).isNotEmpty) _plate(pin.driverId),
                _ago(pin.age),
                '${pin.lat.toStringAsFixed(4)}, '
                    '${pin.lng.toStringAsFixed(4)}',
              ].join('  •  '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppTheme.mutedColor, fontSize: 12),
            ),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () => _openDriverSheet(pin),
          ),
        );
      },
    );
  }
}
