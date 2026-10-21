import 'package:flutter/material.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/database/app_database.dart';
import '../../../core/locale/l10n.dart';
import '../../../core/repositories/customer_repository.dart';
import '../../../core/theme/app_theme.dart';
import 'customer_detail_screen.dart';

class RouteScreen extends StatefulWidget {
  const RouteScreen({super.key});

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  final _repo = CustomerRepository();

  String _driverId = '';
  List<Customer> _customers = [];
  String? _routeFilter;
  bool _loading = true;

  static const _visitedColor = Color(0xFF16A34A);

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _driverId = AuthService().currentUser?.id ?? '';
    await _reload();
    final ok = await _repo.syncFromSupabase(_driverId);
    if (ok && mounted) await _reload();
  }

  Future<void> _reload() async {
    final items = await _repo.getForDriver(_driverId);
    if (mounted) {
      setState(() {
        _customers = items;
        final filter = _routeFilter;
        if (filter != null &&
            !items.any((c) => (c.routeName ?? '').trim() == filter)) {
          _routeFilter = null;
        }
        _loading = false;
      });
    }
  }

  List<String> get _routeNames {
    final names = _customers
        .map((c) => (c.routeName ?? '').trim())
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return names;
  }

  bool get _hasUnassigned =>
      _customers.any((c) => (c.routeName ?? '').trim().isEmpty);

  List<Customer> get _visible {
    final filter = _routeFilter;
    if (filter == null) return _customers;
    return _customers
        .where((c) => (c.routeName ?? '').trim() == filter)
        .toList();
  }

  Future<void> _refresh() async {
    final ok = await _repo.syncFromSupabase(_driverId);
    await _reload();
    if (!ok && mounted) {
      _snack(l10n.couldNotReachServer);
    }
  }

  static bool _isToday(DateTime? d) {
    if (d == null) return false;
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  int get _visitedCount =>
      _visible.where((c) => _isToday(c.visitedDate)).length;

  Future<void> _toggleVisited(Customer c, bool visited) async {
    await _repo.setVisited(c.id, visited);
    await _reload();
  }

  Future<void> _openDetail(Customer c) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => CustomerDetailScreen(customer: c),
      ),
    );
    await _reload();
  }

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    final subset = List<Customer>.of(_visible);
    final moved = subset.removeAt(oldIndex);
    subset.insert(newIndex, moved);

    final List<Customer> merged;
    if (_routeFilter == null) {
      merged = subset;
    } else {
      merged = List<Customer>.of(_customers);
      final subsetIds = subset.map((c) => c.id).toSet();
      var next = 0;
      for (var i = 0; i < merged.length; i++) {
        if (subsetIds.contains(merged[i].id)) {
          merged[i] = subset[next++];
        }
      }
    }

    setState(() => _customers = merged);
    final result = await _repo.saveRouteOrder(merged);
    await _reload();
    if (result == SaveResult.localOnly && mounted) {
      _snack(l10n.orderSavedLocallyOffline);
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final total = _visible.length;
    final visited = _visitedCount;
    return Column(
      children: [
        if (_routeNames.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _routeChip(null, l10n.all),
                  for (final name in _routeNames) ...[
                    const SizedBox(width: 8),
                    _routeChip(name, name),
                  ],
                  if (_hasUnassigned) ...[
                    const SizedBox(width: 8),
                    _routeChip('', l10n.unassigned),
                  ],
                ],
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 8),
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.visitedProgress(visited, total),
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0 : visited / total,
                      minHeight: 8,
                      backgroundColor: AppTheme.borderColor,
                      color: _visitedColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: total == 0 ? _emptyState() : _routeList(),
          ),
        ),
      ],
    );
  }

  Widget _routeChip(String? value, String label) {
    final selected = _routeFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      labelStyle: TextStyle(
          color: selected ? Colors.white : AppTheme.primaryColor, fontSize: 13),
      onSelected: (_) => setState(() => _routeFilter = value),
    );
  }

  Widget _emptyState() {
    return ListView(
      children: [
        const SizedBox(height: 120),
        const Icon(Icons.map_outlined, size: 56, color: Colors.black26),
        const SizedBox(height: 12),
        Text(
          l10n.noCustomersOnYourRoute,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black54, fontSize: 16),
        ),
      ],
    );
  }

  Widget _routeList() {
    final items = _visible;
    return ReorderableListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: items.length,
      onReorderItem: _onReorder,
      itemBuilder: (context, i) {
        final c = items[i];
        final visited = _isToday(c.visitedDate);
        return Card(
          key: ValueKey(c.id),
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            onTap: () => _openDetail(c),
            leading: _StopBadge(number: i + 1, visited: visited),
            title: Text(
              c.name,
              style: TextStyle(
                color: visited ? AppTheme.mutedColor : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: c.address != null && c.address!.isNotEmpty
                ? Text(c.address!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppTheme.mutedColor, fontSize: 13))
                : null,
            trailing: Checkbox(
              value: visited,
              activeColor: _visitedColor,
              onChanged: (v) => _toggleVisited(c, v ?? false),
            ),
          ),
        );
      },
    );
  }
}

class _StopBadge extends StatelessWidget {
  const _StopBadge({required this.number, required this.visited});

  final int number;
  final bool visited;

  static const _visitedColor = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    final color = visited ? _visitedColor : AppTheme.accentColor;
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: visited
          ? const Icon(Icons.check, size: 18, color: _visitedColor)
          : Text('$number',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }
}
