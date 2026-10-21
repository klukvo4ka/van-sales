import 'package:flutter/material.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/database/app_database.dart';
import '../../../core/locale/l10n.dart';
import '../../../core/repositories/customer_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/customer_common.dart';
import 'customer_detail_screen.dart';
import 'customer_form_sheet.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

enum _CustomerFilter { all, hasDebt, active }

enum _CustomerSort { routeOrder, name }

class _CustomerListScreenState extends State<CustomerListScreen> {
  final _repo = CustomerRepository();
  final _searchController = TextEditingController();

  String _driverId = '';
  List<Customer> _all = [];
  String _query = '';
  _CustomerFilter _filter = _CustomerFilter.all;
  _CustomerSort _sort = _CustomerSort.routeOrder;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    _driverId = AuthService().currentUser?.id ?? '';
    await _reload();
    final ok = await _repo.syncFromSupabase(_driverId);
    if (ok && mounted) await _reload();
  }

  Future<void> _reload() async {
    await _repo.reconcileBalances(_driverId);
    final items = await _repo.getForDriver(_driverId);
    if (mounted) {
      setState(() {
        _all = items;
        _loading = false;
      });
    }
  }

  double _debtOf(Customer c) => c.balance < 0 ? 0 : c.balance;

  double get _totalOwed => _all.fold<double>(0, (sum, c) => sum + _debtOf(c));

  Future<void> _refresh() async {
    final ok = await _repo.syncFromSupabase(_driverId);
    await _reload();
    if (!ok && mounted) _snack(l10n.couldNotReachServer);
  }

  List<Customer> get _filtered {
    var items = switch (_filter) {
      _CustomerFilter.all => List<Customer>.of(_all),
      _CustomerFilter.hasDebt => _all.where((c) => _debtOf(c) > 0).toList(),
      _CustomerFilter.active => _all.where((c) => c.isActive).toList(),
    };
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      items = items.where((c) {
        return c.name.toLowerCase().contains(q) ||
            (c.address?.toLowerCase().contains(q) ?? false) ||
            (c.phone?.toLowerCase().contains(q) ?? false);
      }).toList();
    }
    if (_sort == _CustomerSort.name) {
      items
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } else {
      items.sort((a, b) {
        final route = a.routeOrder.compareTo(b.routeOrder);
        if (route != 0) return route;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    }
    return items;
  }

  Future<void> _openEditor({Customer? existing}) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => CustomerFormSheet(
        existing: existing,
        driverId: _driverId,
        nextRouteOrder:
            _all.fold<int>(0, (m, c) => c.routeOrder > m ? c.routeOrder : m) +
                1,
      ),
    );
    if (saved == true) await _reload();
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

  void _snack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.accentColor,
        onPressed: () => _openEditor(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: _buildFilterBar(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v.trim()),
              decoration: InputDecoration(
                hintText: l10n.searchNamePhoneOrAddress,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          if (!_loading) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: (_totalOwed > 0
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF16A34A))
                    .withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
              ),
              child: Text(
                l10n.totalOwedToYouAfn(_totalOwed.round()),
                style: TextStyle(
                  color: _totalOwed > 0
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF16A34A),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  l10n.customerCount(_filtered.length),
                  style:
                      const TextStyle(color: AppTheme.mutedColor, fontSize: 13),
                ),
              ),
            ),
          ],
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: _buildList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _filterChip(_CustomerFilter.all, l10n.all),
          const SizedBox(width: 8),
          _filterChip(_CustomerFilter.hasDebt, l10n.hasDebt),
          const SizedBox(width: 8),
          _filterChip(_CustomerFilter.active, l10n.active),
          const SizedBox(width: 16),
          ActionChip(
            avatar: const Icon(Icons.swap_vert,
                size: 18, color: AppTheme.accentColor),
            label: Text(
                _sort == _CustomerSort.routeOrder ? l10n.route : l10n.name),
            onPressed: () => setState(() {
              _sort = _sort == _CustomerSort.routeOrder
                  ? _CustomerSort.name
                  : _CustomerSort.routeOrder;
            }),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(_CustomerFilter value, String label) {
    final selected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      labelStyle: TextStyle(
          color: selected ? Colors.white : AppTheme.primaryColor, fontSize: 13),
      onSelected: (_) => setState(() => _filter = value),
    );
  }

  Widget _buildList() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final items = _filtered;
    if (items.isEmpty) {
      final noData = _all.isEmpty;
      return ListView(
        children: [
          const SizedBox(height: 120),
          Icon(noData ? Icons.people_outline : Icons.search_off,
              size: 56, color: Colors.black26),
          const SizedBox(height: 12),
          Text(
            noData ? l10n.noCustomersYet : l10n.noCustomersMatch,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, fontSize: 16),
          ),
          if (noData)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                l10n.tapToAddYourFirst,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black38, fontSize: 13),
              ),
            ),
        ],
      );
    }
    final groups = <String, List<Customer>>{};
    for (final c in items) {
      groups.putIfAbsent((c.routeName ?? '').trim(), () => []).add(c);
    }
    final keys = groups.keys.toList()
      ..sort((a, b) {
        if (a.isEmpty) return 1;
        if (b.isEmpty) return -1;
        return a.toLowerCase().compareTo(b.toLowerCase());
      });
    final children = <Widget>[];
    for (final key in keys) {
      final members = groups[key]!;
      children.add(_groupHeader(key, members));
      children.addAll(members.map((c) => CustomerCard(
            customer: c,
            debt: _debtOf(c),
            onTap: () => _openDetail(c),
          )));
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: 88),
      children: children,
    );
  }

  Widget _groupHeader(String name, List<Customer> members) {
    final owed = members.fold<double>(0, (sum, c) => sum + _debtOf(c));
    final owedColor =
        owed > 0 ? const Color(0xFFDC2626) : const Color(0xFF16A34A);
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name.isEmpty ? l10n.unassigned : name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppTheme.primaryColor),
            ),
          ),
          Text(
            '${members.length} · ',
            style: const TextStyle(color: AppTheme.mutedColor, fontSize: 12),
          ),
          Text(
            '${owed.round()} AFN',
            style: TextStyle(
                color: owedColor, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class CustomerCard extends StatelessWidget {
  const CustomerCard({
    super.key,
    required this.customer,
    required this.onTap,
    this.subtitleExtra,
    this.debt,
  });

  final Customer customer;
  final VoidCallback onTap;
  final String? subtitleExtra;
  final double? debt;

  @override
  Widget build(BuildContext context) {
    final phone = customer.phone;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  customerInitials(customer.name),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customer.name,
                        style: Theme.of(context).textTheme.titleMedium),
                    if (customer.address != null &&
                        customer.address!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(customer.address!,
                            style: const TextStyle(
                                color: AppTheme.mutedColor, fontSize: 13)),
                      ),
                    if (subtitleExtra != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(subtitleExtra!,
                            style: const TextStyle(
                                color: AppTheme.accentColor, fontSize: 12)),
                      ),
                    if (phone != null && phone.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: InkWell(
                          onTap: () => callPhone(phone),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.phone,
                                  size: 16, color: AppTheme.accentColor),
                              const SizedBox(width: 4),
                              Text(phone,
                                  style: const TextStyle(
                                      color: AppTheme.accentColor)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RouteBadge(order: customer.routeOrder),
                  const SizedBox(height: 6),
                  _BalanceBadge(balance: debt ?? customer.balance),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BalanceBadge extends StatelessWidget {
  const _BalanceBadge({required this.balance});
  final double balance;

  static const _debtColor = Color(0xFFDC2626);
  static const _paidColor = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    if (balance < 0) return const SizedBox.shrink();
    final hasDebt = balance > 0;
    final color = hasDebt ? _debtColor : _paidColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        hasDebt ? '${balance.round()} AFN' : l10n.paidShort,
        style:
            TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
