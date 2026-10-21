import 'dart:async';
import 'dart:io' show Platform;

import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/auth_service.dart';
import '../constants/app_constants.dart';
import '../locale/l10n.dart';
import '../utils/app_logger.dart';

class LocationService {
  LocationService._();

  static final LocationService instance = LocationService._();

  static const _enabledPrefKey = 'location_sharing_enabled';
  static const _minInterval = Duration(seconds: 30);
  static const _minDistanceMeters = 100.0;

  bool _available = false;
  bool _enabled = true;
  bool _tracking = false;
  Position? _lastSent;
  DateTime? _lastSentAt;
  StreamSubscription<Position>? _positionSub;
  StreamSubscription<AuthState>? _authSub;

  bool get isAvailable => _available;
  bool get enabled => _enabled;
  bool get isTracking => _tracking;

  Future<void> init() async {
    if (!AppConstants.kGpsEnabled) {
      _available = false;
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_enabledPrefKey) ?? true;
    _available = true;

    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen(
      (state) {
        if (state.event == AuthChangeEvent.signedIn) {
          maybeStart();
        } else if (state.event == AuthChangeEvent.signedOut) {
          stop();
        }
      },
    );
    await maybeStart();
  }

  Future<void> setEnabled(bool value) async {
    if (!_available) return;
    _enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledPrefKey, value);
    if (value) {
      await maybeStart();
    } else {
      await stop();
      await _deleteRow();
    }
  }

  Future<void> maybeStart() async {
    if (!_available || !_enabled || _tracking) return;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final role = await AuthService.getUserRole();
    if (role != AuthService.roleDriver) return;

    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final settings = Platform.isIOS
          ? AppleSettings(
              accuracy: LocationAccuracy.medium,
              distanceFilter: 30,
              pauseLocationUpdatesAutomatically: true,
              showBackgroundLocationIndicator: true,
              allowBackgroundLocationUpdates:
                  permission == LocationPermission.always,
            )
          : Platform.isAndroid
              ? AndroidSettings(
                  accuracy: LocationAccuracy.medium,
                  distanceFilter: 30,
                  intervalDuration: _minInterval,
                  foregroundNotificationConfig: ForegroundNotificationConfig(
                    notificationTitle: l10n.locationNotificationTitle,
                    notificationText: l10n.locationNotificationText,
                    notificationChannelName: l10n.locationChannelName,
                    setOngoing: true,
                  ),
                )
              : const LocationSettings(
                  accuracy: LocationAccuracy.medium,
                  distanceFilter: 30,
                );

      _positionSub = Geolocator.getPositionStream(locationSettings: settings)
          .listen(_onPosition, onError: (Object e, StackTrace st) {
        AppLogger.error('LocationService.stream', e, st);
      });
      _tracking = true;

      final current = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      await _upsert(current);
    } catch (e, st) {
      AppLogger.error('LocationService.maybeStart', e, st);
    }
  }

  Future<void> stop() async {
    await _positionSub?.cancel();
    _positionSub = null;
    _tracking = false;
    _lastSent = null;
    _lastSentAt = null;
  }

  void _onPosition(Position position) {
    final last = _lastSent;
    final lastAt = _lastSentAt;
    final movedEnough = last == null ||
        Geolocator.distanceBetween(last.latitude, last.longitude,
                position.latitude, position.longitude) >=
            _minDistanceMeters;
    final waitedEnough =
        lastAt == null || DateTime.now().difference(lastAt) >= _minInterval;
    if (movedEnough || waitedEnough) {
      _upsert(position);
    }
  }

  Future<void> _upsert(Position position) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || !_enabled) return;
    _lastSent = position;
    _lastSentAt = DateTime.now();
    try {
      await Supabase.instance.client.from('driver_locations').upsert({
        'driver_id': user.id,
        'lat': position.latitude,
        'lng': position.longitude,
        'accuracy': position.accuracy,
        'speed': position.speed,
        'heading': position.heading,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e, st) {
      AppLogger.error('LocationService._upsert', e, st);
    }
  }

  Future<void> _deleteRow() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      await Supabase.instance.client
          .from('driver_locations')
          .delete()
          .eq('driver_id', user.id);
    } catch (e, st) {
      AppLogger.error('LocationService._deleteRow', e, st);
    }
  }

  Future<void> dispose() async {
    await stop();
    await _authSub?.cancel();
  }
}
