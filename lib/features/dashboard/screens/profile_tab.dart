import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/locale/l10n.dart';
import '../../../core/locale/locale_controller.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/push_service.dart';
import '../../../core/theme/app_theme.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _auth = AuthService();
  final _db = DatabaseProvider.instance;
  final _client = Supabase.instance.client;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _notificationsEnabled = PushService.instance.enabled;
  bool _locationEnabled = LocationService.instance.enabled;
  String _role = AuthService.roleDriver;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String get _email => _auth.currentUser?.email ?? '—';

  Future<void> _load() async {
    final uid = _auth.currentUser?.id;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final row = await _client
          .from('driver_profiles')
          .select()
          .eq('id', uid)
          .maybeSingle();

      if (row != null) {
        _nameController.text = (row['full_name'] as String?) ?? '';
        _phoneController.text = (row['phone'] as String?) ?? '';
        _role = (row['role'] as String?) ?? AuthService.roleDriver;
      } else {
        _nameController.text = _email == '—' ? '' : _email.split('@').first;
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _initials() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      final parts = name.split(RegExp(r'\s+'));
      final letters =
          parts.take(2).map((p) => p.characters.first.toUpperCase()).join();
      if (letters.isNotEmpty) return letters;
    }
    final email = _email;
    return email == '—' ? '?' : email.characters.first.toUpperCase();
  }

  Future<void> _save() async {
    final uid = _auth.currentUser?.id;
    if (uid == null) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    if (name.isEmpty) {
      _snack(l10n.nameCannotBeEmpty);
      return;
    }

    setState(() => _saving = true);
    var serverUpdated = false;
    String? error;

    try {
      final res = await _client
          .from('driver_profiles')
          .update({'full_name': name, 'phone': phone.isEmpty ? null : phone})
          .eq('id', uid)
          .select();
      serverUpdated = res.isNotEmpty;
    } catch (e) {
      error = e.toString();
    }

    try {
      await _db.into(_db.driverProfiles).insertOnConflictUpdate(
            DriverProfilesCompanion(
              id: Value(uid),
              fullName: Value(name),
              phone: Value(phone.isEmpty ? null : phone),
              role: Value(_role),
              synced: const Value(false),
            ),
          );
    } catch (_) {}

    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      _snack(l10n.savedLocallyServerError);
    } else if (serverUpdated) {
      _snack(l10n.profileSaved);
    } else {
      _snack(l10n.savedLocallyServerDenied);
    }
  }

  Future<void> _toggleLocation(bool value) async {
    setState(() => _locationEnabled = value);
    await LocationService.instance.setEnabled(value);
    if (!mounted) return;
    _snack(value ? l10n.locationSharingOn : l10n.locationSharingOff);
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() => _notificationsEnabled = value);
    await PushService.instance.setEnabled(value);
    if (!mounted) return;
    _snack(value ? l10n.notificationsOn : l10n.notificationsOff);
  }

  Future<void> _changePassword() async {
    await showDialog<void>(
      context: context,
      builder: (_) => const _ChangePasswordDialog(),
    );
  }

  Future<void> _logout() async {
    await _auth.signOut();
    if (mounted) context.go('/');
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      children: [
        Center(
          child: CircleAvatar(
            radius: 44,
            backgroundColor: AppTheme.primaryColor,
            child: Text(
              _initials(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            _nameController.text.trim().isEmpty
                ? '—'
                : _nameController.text.trim(),
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(_email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.mutedColor,
                  )),
        ),
        const SizedBox(height: 8),
        Center(child: _RoleBadge(role: _role)),
        if (_phoneController.text.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.phone, size: 16, color: AppTheme.mutedColor),
                const SizedBox(width: 6),
                Text(_phoneController.text.trim(),
                    style: const TextStyle(color: AppTheme.mutedColor)),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        _SectionTitle(l10n.editProfile),
        const SizedBox(height: 12),
        TextField(
          controller: _nameController,
          enabled: !_saving,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: l10n.fullName,
            prefixIcon: const Icon(Icons.person_outline),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phoneController,
          enabled: !_saving,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: l10n.phone,
            prefixIcon: const Icon(Icons.phone_outlined),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(l10n.save),
          ),
        ),
        const SizedBox(height: 24),
        _SectionTitle(l10n.language),
        const SizedBox(height: 12),
        ValueListenableBuilder<Locale>(
          valueListenable: LocaleController.instance.locale,
          builder: (context, locale, _) {
            return SegmentedButton<String>(
              segments: [
                ButtonSegment(
                    value: l10n.languageEnglish,
                    label: Text(l10n.languageEnglish)),
                ButtonSegment(
                    value: l10n.languageDari, label: Text(l10n.languageDari)),
              ],
              selected: {locale.languageCode},
              onSelectionChanged: (selection) =>
                  LocaleController.instance.setLocale(selection.first),
            );
          },
        ),
        const SizedBox(height: 24),
        if (_role == AuthService.roleDriver &&
            LocationService.instance.isAvailable) ...[
          _SectionTitle(l10n.privacy),
          const SizedBox(height: 8),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.location_on_outlined),
              title: Text(l10n.shareMyLocation),
              subtitle: Text(
                l10n.officeSeesYourPositionOn,
                style:
                    const TextStyle(color: AppTheme.mutedColor, fontSize: 12),
              ),
              value: _locationEnabled,
              activeThumbColor: AppTheme.accentColor,
              onChanged: _toggleLocation,
            ),
          ),
          const SizedBox(height: 24),
        ],
        _SectionTitle(l10n.notifications),
        const SizedBox(height: 8),
        Card(
          child: SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: Text(l10n.pushNotifications),
            subtitle: PushService.instance.isAvailable
                ? null
                : Text(
                    l10n.notConfiguredOnThisDevice,
                    style: const TextStyle(
                        color: AppTheme.mutedColor, fontSize: 12),
                  ),
            value: _notificationsEnabled,
            activeThumbColor: AppTheme.accentColor,
            onChanged:
                PushService.instance.isAvailable ? _toggleNotifications : null,
          ),
        ),
        const SizedBox(height: 24),
        _SectionTitle(l10n.account),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: Text(l10n.changePassword),
                trailing: const Icon(Icons.chevron_right),
                onTap: _changePassword,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(l10n.logout,
                    style: const TextStyle(color: Colors.red)),
                onTap: _logout,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleMedium);
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});
  final String role;

  String get _label {
    switch (role) {
      case AuthService.roleOffice:
        return l10n.office;
      case AuthService.roleAdmin:
        return l10n.admin;
      default:
        return l10n.driver;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: Text(
        _label,
        style: const TextStyle(
          color: AppTheme.accentColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  const _ChangePasswordDialog();

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final client = Supabase.instance.client;
    final email = client.auth.currentUser?.email;
    final current = _currentController.text;
    final next = _newController.text;

    if (next.length < 6) {
      setState(() => _error = l10n.newPasswordAtLeast6);
      return;
    }
    if (email == null) {
      setState(() => _error = l10n.noActiveSession);
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      await client.auth.signInWithPassword(email: email, password: current);
      await client.auth.updateUser(UserAttributes(password: next));
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.passwordChanged)),
      );
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = l10n.errorWithDetails(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(l10n.changePassword),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _currentController,
            obscureText: true,
            enabled: !_busy,
            decoration: InputDecoration(
              labelText: l10n.currentPassword,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _newController,
            obscureText: true,
            enabled: !_busy,
            decoration: InputDecoration(
              labelText: l10n.newPassword,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _busy ? null : _submit,
          child: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white),
                )
              : Text(l10n.update),
        ),
      ],
    );
  }
}
