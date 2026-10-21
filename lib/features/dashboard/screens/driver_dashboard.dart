import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/locale/l10n.dart';
import '../../../core/theme/app_theme.dart';

class DriverDashboard extends StatelessWidget {
  const DriverDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = <_DashboardAction>[
      _DashboardAction(l10n.routeOfTheDay, Icons.map_outlined,
          route: '/route/today'),
      _DashboardAction(l10n.customers, Icons.people_outline),
      _DashboardAction(l10n.newInvoice, Icons.receipt_long_outlined),
      _DashboardAction(l10n.myStock, Icons.warehouse_outlined,
          route: '/inventory/stock'),
      _DashboardAction(l10n.daySummary, Icons.summarize_outlined,
          route: '/day/summary'),
    ];

    return GridView.count(
      padding: const EdgeInsets.symmetric(vertical: 16),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.05,
      children: actions.map((a) => _ActionCard(action: a)).toList(),
    );
  }
}

class _DashboardAction {
  const _DashboardAction(this.label, this.icon, {this.route});
  final String label;
  final IconData icon;
  final String? route;
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.action});
  final _DashboardAction action;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        onTap: () {
          if (action.route != null) {
            context.push(action.route!);
          } else {
            debugPrint('Tapped action: ${action.label}');
          }
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 120),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(action.icon, size: 48, color: AppTheme.accentColor),
                const SizedBox(height: 12),
                Text(
                  action.label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
