import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/locale/l10n.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../office/customers_tab.dart';
import '../../office/drivers_tab.dart';
import '../../office/live_map_screen.dart';
import '../../office/office_home_tab.dart';
import '../../office/reports_tab.dart';
import '../../office/trucks_tab.dart';

class OfficeShell extends StatefulWidget {
  const OfficeShell({super.key});

  @override
  State<OfficeShell> createState() => _OfficeShellState();
}

class _OfficeShellState extends State<OfficeShell> {
  final _auth = AuthService();
  final NotificationService _notifications = NotificationService();
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _notifications.subscribe(Supabase.instance.client);
  }

  @override
  void dispose() {
    _notifications.dispose();
    super.dispose();
  }

  static List<_NavItem> get _items => [
        _NavItem(l10n.dashboard, Icons.dashboard_outlined),
        _NavItem(l10n.trucks, Icons.local_shipping_outlined),
        _NavItem(l10n.customers, Icons.storefront_outlined),
        _NavItem(l10n.drivers, Icons.people_outline),
        _NavItem(l10n.reports, Icons.bar_chart_outlined),
        _NavItem(l10n.liveMap, Icons.map_outlined),
      ];

  List<Widget> get _tabs => <Widget>[
        OfficeHomeTab(
          notifications: _notifications,
          onSelectTab: (i) => setState(() => _index = i),
        ),
        const TrucksTab(),
        const CustomersTab(),
        const DriversTab(),
        const ReportsTab(),
        const LiveMapView(),
      ];

  void _select(int i) {
    Navigator.pop(context);
    setState(() => _index = i);
  }

  Future<void> _logout() async {
    Navigator.pop(context);
    await _auth.signOut();
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final email = _auth.currentUser?.email ?? '—';

    return Scaffold(
      appBar: AppBar(
        title: Text(_items[_index].label),
        actions: [_NotificationBell(service: _notifications)],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              _DrawerHeader(email: email),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    for (var i = 0; i < _items.length; i++)
                      ListTile(
                        leading: Icon(_items[i].icon),
                        title: Text(_items[i].label),
                        selected: _index == i,
                        selectedColor: AppTheme.accentColor,
                        selectedTileColor:
                            AppTheme.accentColor.withValues(alpha: 0.10),
                        onTap: () => _select(i),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(l10n.logout),
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.screenPadding,
        ),
        child: IndexedStack(index: _index, children: _tabs),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon);
  final String label;
  final IconData icon;
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.service});
  final NotificationService service;

  void _open(BuildContext context) {
    service.markAllRead();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _NotificationPanel(service: service),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        final count = service.unreadCount;
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              tooltip: l10n.notifications,
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () => _open(context),
            ),
            if (count > 0)
              PositionedDirectional(
                end: 6,
                top: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  constraints:
                      const BoxConstraints(minWidth: 18, minHeight: 18),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _NotificationPanel extends StatelessWidget {
  const _NotificationPanel({required this.service});
  final NotificationService service;

  static String _timeAgo(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return l10n.justNow;
    if (d.inMinutes < 60) return '${d.inMinutes} min ago';
    if (d.inHours < 24) return '${d.inHours} h ago';
    return '${d.inDays} d ago';
  }

  static String _shortId(String id) => id.length >= 8 ? id.substring(0, 8) : id;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListenableBuilder(
          listenable: service,
          builder: (context, _) {
            final items = service.notifications;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.notifications,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(l10n.noNotifications,
                          style: const TextStyle(color: AppTheme.mutedColor)),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final n = items[i];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const CircleAvatar(
                            backgroundColor: AppTheme.accentColor,
                            child: Icon(Icons.receipt_long_outlined,
                                color: Colors.white),
                          ),
                          title: Text(l10n.newInvoiceNotification),
                          subtitle: Text(
                            'AFN ${n.amount.toStringAsFixed(0)} · ${_timeAgo(n.receivedAt)}\n'
                            '${l10n.driverWithId(_shortId(n.driverName))}',
                          ),
                          isThreeLine: true,
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppTheme.primaryColor,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            email,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(AppTheme.borderRadius),
            ),
            child: Text(
              l10n.office,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
