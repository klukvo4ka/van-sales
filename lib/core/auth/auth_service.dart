import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/push_service.dart';

class AuthService {
  AuthService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const String roleDriver = 'driver';
  static const String roleOffice = 'office';
  static const String roleAdmin = 'admin';

  static Session? get currentSession =>
      Supabase.instance.client.auth.currentSession;

  static String? _cachedRole;

  static void clearRoleCache() => _cachedRole = null;

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  static Future<String> getUserRole() async {
    if (_cachedRole != null) return _cachedRole!;

    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) return roleDriver;

    try {
      final row = await client
          .from('driver_profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      final role = row?['role'] as String?;
      final resolved =
          (role == roleOffice || role == roleAdmin) ? role! : roleDriver;
      _cachedRole = resolved;
      return resolved;
    } catch (_) {
      return roleDriver;
    }
  }

  Future<void> signOut() async {
    await PushService.instance.unregisterDevice();
    clearRoleCache();
    await _client.auth.signOut();
  }
}
