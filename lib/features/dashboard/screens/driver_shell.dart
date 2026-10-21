import 'package:flutter/material.dart';

import '../../../core/locale/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../customers/screens/customer_list_screen.dart';
import '../../inventory/screens/truck_stock_screen.dart';
import 'driver_dashboard.dart';
import 'profile_tab.dart';

class DriverShell extends StatefulWidget {
  const DriverShell({super.key});

  @override
  State<DriverShell> createState() => _DriverShellState();
}

class _DriverShellState extends State<DriverShell> {
  int _index = 0;

  static List<String> get _titles => [
        l10n.appTitle,
        l10n.customers,
        l10n.myStock,
        l10n.profile,
      ];

  static const _tabs = <Widget>[
    DriverDashboard(),
    CustomerListScreen(),
    TruckStockScreen(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.screenPadding,
        ),
        child: IndexedStack(index: _index, children: _tabs),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people_outline),
            activeIcon: const Icon(Icons.people),
            label: l10n.customers,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.inventory_2_outlined),
            activeIcon: const Icon(Icons.inventory_2),
            label: l10n.myStock2,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}
