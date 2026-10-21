import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_constants.dart';
import '../locale/l10n.dart';
import '../utils/app_logger.dart';

@pragma('vm:entry-point')
Future<void> pushBackgroundHandler(RemoteMessage message) async {}

class PushService {
  PushService._();

  static final PushService instance = PushService._();

  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static const _enabledPrefKey = 'notifications_enabled';

  bool _available = false;
  bool _enabled = true;
  String? _currentToken;
  void Function(String route)? _onNavigate;
  StreamSubscription<AuthState>? _authSub;

  bool get isAvailable => _available;
  bool get enabled => _enabled;

  static const _routes = {
    'invoice': '/dashboard/office',
    'settlement': '/day/summary',
    'stock': '/inventory/stock',
  };

  Future<void> init({void Function(String route)? onNavigate}) async {
    if (!AppConstants.kPushEnabled) {
      _available = false;
      AppLogger.info('Push', 'dormant (kPushEnabled=false)');
      return;
    }
    _onNavigate = onNavigate;
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_enabledPrefKey) ?? true;

    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(pushBackgroundHandler);

      final messaging = FirebaseMessaging.instance;

      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_onOpenedFromMessage);
      final initial = await messaging.getInitialMessage();
      if (initial != null) _onOpenedFromMessage(initial);

      messaging.onTokenRefresh.listen((token) {
        _currentToken = token;
        _registerToken();
      });
      if (_enabled) {
        await messaging.requestPermission();
        _currentToken = await messaging.getToken();
      }

      _available = true;

      _authSub = Supabase.instance.client.auth.onAuthStateChange.listen(
        (state) {
          if (state.event == AuthChangeEvent.signedIn) {
            _registerToken();
          }
        },
      );
      await _registerToken();
      AppLogger.info('Push', 'FCM initialized');
    } catch (e, st) {
      _available = false;
      AppLogger.error('PushService.init (Firebase not configured?)', e, st);
    }
  }

  Future<void> setEnabled(bool value) async {
    if (!AppConstants.kPushEnabled) return;
    _enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledPrefKey, value);
    if (value) {
      await _registerToken();
    } else {
      await _unregisterToken();
    }
  }

  Future<void> unregisterDevice() => _unregisterToken();

  Future<void> _ensureToken() async {
    if (!_available) return;
    try {
      await FirebaseMessaging.instance.requestPermission();
      _currentToken ??= await FirebaseMessaging.instance.getToken();
    } catch (e, st) {
      AppLogger.error('PushService._ensureToken', e, st);
    }
  }

  Future<void> _registerToken() async {
    if (!_available || !_enabled) return;
    await _ensureToken();
    final token = _currentToken;
    final user = Supabase.instance.client.auth.currentUser;
    if (token == null || token.isEmpty || user == null) return;
    try {
      await Supabase.instance.client.from('device_tokens').upsert(
        {
          'user_id': user.id,
          'token': token,
          'platform': _platformName(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        },
        onConflict: 'token',
      );
    } catch (e, st) {
      AppLogger.error('PushService._registerToken', e, st);
    }
  }

  String _platformName() {
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }

  Future<void> _unregisterToken() async {
    final token = _currentToken;
    if (token == null || token.isEmpty) return;
    try {
      await Supabase.instance.client
          .from('device_tokens')
          .delete()
          .eq('token', token);
    } catch (e, st) {
      AppLogger.error('PushService._unregisterToken', e, st);
    }
  }

  void _onForegroundMessage(RemoteMessage message) {
    if (!_enabled) return;
    final title = message.notification?.title ?? '';
    final body = message.notification?.body ?? '';
    if (title.isEmpty && body.isEmpty) return;
    final route = _routes[message.data['route']];
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text([title, body].where((s) => s.isNotEmpty).join(' — ')),
        action: route == null
            ? null
            : SnackBarAction(
                label: l10n.open,
                onPressed: () => _onNavigate?.call(route),
              ),
      ),
    );
  }

  void _onOpenedFromMessage(RemoteMessage message) {
    final route = _routes[message.data['route']];
    if (route != null) _onNavigate?.call(route);
  }

  Future<void> dispose() async {
    await _authSub?.cancel();
  }
}
