import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'sync_service.dart';

class SyncProvider {
  SyncProvider({SyncService? service, Connectivity? connectivity})
      : _service = service ?? SyncService(),
        _connectivity = connectivity ?? Connectivity();

  final SyncService _service;
  final Connectivity _connectivity;

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _periodicTimer;
  bool _wasOffline = false;

  static const Duration _periodicInterval = Duration(minutes: 5);

  SyncService get service => _service;

  Stream<SyncStatus> get statusStream => SyncService.statusStream;

  static bool _isOffline(List<ConnectivityResult> results) =>
      results.isEmpty || results.every((r) => r == ConnectivityResult.none);

  void start() {
    unawaited(_connectivity.checkConnectivity().then((results) {
      _wasOffline = _isOffline(results);
      if (!_wasOffline) unawaited(_service.syncAll());
    }));

    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final offline = _isOffline(results);
      if (_wasOffline && !offline) {
        unawaited(_service.syncAll());
      }
      _wasOffline = offline;
    });

    _periodicTimer = Timer.periodic(
      _periodicInterval,
      (_) => unawaited(_service.syncAll()),
    );
  }

  Future<void> syncNow() => _service.syncAll();

  Future<void> dispose() async {
    _periodicTimer?.cancel();
    _periodicTimer = null;
    await _subscription?.cancel();
    _subscription = null;
  }
}
