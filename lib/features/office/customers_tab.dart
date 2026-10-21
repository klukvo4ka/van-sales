import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/database/app_database.dart';
import '../../core/locale/l10n.dart';
import '../../core/repositories/customer_repository.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../customers/screens/customer_detail_screen.dart';
import '../customers/screens/customer_list_screen.dart' show CustomerCard;

class CustomersTab extends StatefulWidget {
  const CustomersTab({super.key});

  @override
  State<CustomersTab> createState() => _CustomersTabState();
}

class _CustomersTabState extends State<CustomersTab> {
  final _repo = CustomerRepository();

  List<Customer> _all = [];
  List<DriverOption> _drivers = [];
  Map<String, String> _driverNames = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _loadDrivers();
    await _reload();
    final ok = await _repo.syncFromSupabase();
    if (ok && mounted) await _reload();
  }

  Future<void> _loadDrivers() async {
    try {
      final rows = await Supabase.instance.client
          .from('driver_profiles')
          .select('id, full_name');
      _drivers = rows
          .map((r) => DriverOption(
                id: r['id'] as String,
                name: (r['full_name'] as String?) ?? l10n.driver,
              ))
          .toList();
    } catch (_) {
      _drivers = [];
    }
    _driverNames = {for (final d in _drivers) d.id: d.name};
  }

  Future<void> _reload() async {
    final items = await _repo.getAll();
    if (mounted) {
      setState(() {
        _all = items;
        _loading = false;
      });
    }
  }

  Future<void> _refresh() async {
    await _loadDrivers();
    final ok = await _repo.syncFromSupabase();
    await _reload();
    if (!ok && mounted) _snack(l10n.couldNotReachServer);
  }

  String _driverLabel(String? driverId) {
    if (driverId == null || driverId.isEmpty) {
      return l10n.unassigned2;
    }
    return _driverNames[driverId] ?? driverId;
  }

  Future<void> _openEditor({Customer? existing}) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => OfficeCustomerSheet(
        existing: existing,
        drivers: _drivers,
      ),
    );
    if (changed == true) await _reload();
  }

  Future<void> _openDetail(Customer customer) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => CustomerDetailScreen(customer: customer),
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
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_all.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          const Icon(Icons.people_outline, size: 56, color: Colors.black26),
          const SizedBox(height: 12),
          Text(l10n.noCustomersYet,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 16)),
        ],
      );
    }

    final groups = <String?, List<Customer>>{};
    for (final c in _all) {
      groups.putIfAbsent(c.driverId, () => []).add(c);
    }
    final driverIds = groups.keys.toList()
      ..sort((a, b) => _driverLabel(a).compareTo(_driverLabel(b)));

    final children = <Widget>[];
    for (final id in driverIds) {
      children.add(Padding(
        padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
        child: Text(
          '${_driverLabel(id)}  (${groups[id]!.length})',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ));
      for (final c in groups[id]!) {
        children.add(CustomerCard(
          customer: c,
          onTap: () => _openDetail(c),
        ));
      }
    }

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 88),
      children: children,
    );
  }
}

class DriverOption {
  DriverOption({required this.id, required this.name});
  final String id;
  final String name;
}

class OfficeCustomerSheet extends StatefulWidget {
  const OfficeCustomerSheet({super.key, this.existing, required this.drivers});
  final Customer? existing;
  final List<DriverOption> drivers;

  @override
  State<OfficeCustomerSheet> createState() => OfficeCustomerSheetState();
}

class OfficeCustomerSheetState extends State<OfficeCustomerSheet> {
  final _repo = CustomerRepository();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _address;
  late final TextEditingController _phone;
  String? _driverId;
  bool _saving = false;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    final c = widget.existing;
    _name = TextEditingController(text: c?.name ?? '');
    _address = TextEditingController(text: c?.address ?? '');
    _phone = TextEditingController(text: c?.phone ?? '');
    _driverId = c?.driverId;
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final existing = widget.existing;
    final result = await _repo.save(
      id: existing?.id ?? AppUtils.generateUuid(),
      name: _name.text.trim(),
      address: _address.text.trim().isEmpty ? null : _address.text.trim(),
      phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      driverId: _driverId,
      routeOrder: existing?.routeOrder ?? 0,
    );
    if (!mounted) return;
    Navigator.pop(context, true);
    _snack(result == SaveResult.synced
        ? l10n.customerSaved
        : l10n.savedLocallyOffline);
  }

  Future<void> _delete() async {
    final existing = widget.existing;
    if (existing == null) return;
    setState(() => _deleting = true);
    await _repo.delete(existing.id);
    if (!mounted) return;
    Navigator.pop(context, true);
    _snack(l10n.customerDeleted);
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final busy = _saving || _deleting;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      isEdit ? l10n.editCustomer : l10n.addCustomer,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (isEdit)
                    IconButton(
                      tooltip: l10n.delete,
                      icon: _deleting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2.5),
                            )
                          : const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: busy ? null : _delete,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _name,
                decoration: InputDecoration(labelText: l10n.name),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.required : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _address,
                decoration: InputDecoration(labelText: l10n.address),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: l10n.phone),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: _driverId,
                decoration: InputDecoration(labelText: l10n.driver),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(l10n.unassigned2),
                  ),
                  ...widget.drivers.map((d) => DropdownMenuItem<String?>(
                        value: d.id,
                        child: Text(d.name),
                      )),
                ],
                onChanged: busy ? null : (v) => setState(() => _driverId = v),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: busy ? null : _save,
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
            ],
          ),
        ),
      ),
    );
  }
}
