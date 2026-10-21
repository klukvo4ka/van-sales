import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/locale/l10n.dart';
import '../../core/repositories/customer_repository.dart';
import '../../core/repositories/truck_initial_stock_repository.dart';
import '../../core/theme/app_theme.dart';
import '../customers/screens/customer_detail_screen.dart';
import '../customers/screens/customer_list_screen.dart' show CustomerCard;

class TruckDetailScreen extends StatefulWidget {
  const TruckDetailScreen({super.key, required this.truck});

  final Truck truck;

  @override
  State<TruckDetailScreen> createState() => _TruckDetailScreenState();
}

class _TruckDetailScreenState extends State<TruckDetailScreen> {
  final _repo = TruckInitialStockRepository();
  final _customerRepo = CustomerRepository();
  final Map<String, TextEditingController> _controllers = {};

  late bool _active;
  DriverProfile? _driver;
  List<TruckInitialStockEditorRow> _rows = [];
  Map<String, double> _soldToday = {};
  List<Customer> _customers = [];
  bool _loading = true;
  bool _saving = false;

  static const _warnColor = Color(0xFFD97706);

  @override
  void initState() {
    super.initState();
    _active = widget.truck.isActive;
    _load();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final profiles = await _repo.getDriverProfiles();
    DriverProfile? driver;
    for (final p in profiles) {
      if (p.truckId == widget.truck.id) {
        driver = p;
        break;
      }
    }
    final rows = await _repo.getEditorRows(widget.truck.id);
    final soldToday = driver == null
        ? <String, double>{}
        : await _repo.soldTodayByProduct(driver.id);
    final customers = driver == null
        ? <Customer>[]
        : await _customerRepo.getForDriver(driver.id);

    if (!mounted) return;
    setState(() {
      _driver = driver;
      _setRows(rows);
      _soldToday = soldToday;
      _customers = customers;
      _loading = false;
    });
  }

  void _setRows(List<TruckInitialStockEditorRow> rows) {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _controllers
      ..clear()
      ..addEntries(rows.map(
        (row) => MapEntry(
          row.product.id,
          TextEditingController(text: _formatQty(row.quantity)),
        ),
      ));
    _rows = rows;
  }

  double get _totalQuantity {
    var total = 0.0;
    for (final row in _rows) {
      total += _parseQty(_controllers[row.product.id]?.text ?? '');
    }
    return total;
  }

  static double _parseQty(String value) {
    final cleaned = value.trim().replaceAll(',', '.');
    return double.tryParse(cleaned) ?? 0;
  }

  static String _formatQty(double value) {
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value.toStringAsFixed(3).replaceFirst(RegExp(r'0+$'), '');
  }

  static String _qtyText(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final result = await _repo.saveTruckStock(
      truckId: widget.truck.id,
      items: _rows
          .map((row) => TruckInitialStockInput(
                productId: row.product.id,
                quantity: _parseQty(_controllers[row.product.id]?.text ?? ''),
              ))
          .toList(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    _snack(result == TruckInitialStockSaveResult.synced
        ? l10n.initialStockSaved
        : l10n.savedLocallyOffline);
  }

  Future<void> _toggleActive(bool value) async {
    setState(() => _active = value);
    final result = await _repo.setTruckActive(widget.truck.id, value);
    if (!mounted) return;
    _snack(result == TruckInitialStockSaveResult.synced
        ? (value ? l10n.truckActivated : l10n.truckDeactivated)
        : l10n.savedLocallyOffline);
  }

  Future<void> _openCustomer(Customer customer) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => CustomerDetailScreen(customer: customer),
      ),
    );
    await _load();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.truck;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${t.name} — ${t.plateNumber}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16)),
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: l10n.info),
              Tab(text: l10n.inventory),
              Tab(text: l10n.customers),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _infoTab(),
                  _inventoryTab(),
                  _customersTab(),
                ],
              ),
      ),
    );
  }

  Widget _infoTab() {
    final t = widget.truck;
    return ListView(
      padding: const EdgeInsets.all(AppTheme.screenPadding),
      children: [
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.local_shipping_outlined),
                title: Text(l10n.name,
                    style: const TextStyle(
                        color: AppTheme.mutedColor, fontSize: 12)),
                subtitle: Text(t.name,
                    style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.pin_outlined),
                title: Text(l10n.plate,
                    style: const TextStyle(
                        color: AppTheme.mutedColor, fontSize: 12)),
                subtitle: Text(t.plateNumber,
                    style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(l10n.driver,
                    style: const TextStyle(
                        color: AppTheme.mutedColor, fontSize: 12)),
                subtitle: Text(
                  _driver?.fullName ?? l10n.noDriverAssigned,
                  style: TextStyle(
                    color:
                        _driver == null ? AppTheme.mutedColor : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.power_settings_new_outlined),
                title: Text(l10n.active),
                value: _active,
                activeThumbColor: AppTheme.accentColor,
                onChanged: _toggleActive,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _inventoryTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.productsUnits(
                      _rows.length, _totalQuantity.toStringAsFixed(0)),
                  style: const TextStyle(color: AppTheme.mutedColor),
                ),
              ),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(l10n.save),
              ),
            ],
          ),
        ),
        Expanded(
          child: _rows.isEmpty
              ? Center(
                  child: Text(
                    l10n.noActiveProducts2,
                    style: const TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: _rows.length,
                  itemBuilder: (context, i) => _stockTile(_rows[i]),
                ),
        ),
      ],
    );
  }

  Widget _stockTile(TruckInitialStockEditorRow row) {
    final sold = _soldToday[row.product.id] ?? 0;
    final initial = _parseQty(_controllers[row.product.id]?.text ?? '');
    final remaining = initial - sold;
    final low = remaining <= 0 && initial > 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.inventory_2_outlined),
        title: Text(row.product.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              [
                if (row.product.sku != null && row.product.sku!.isNotEmpty)
                  'SKU: ${row.product.sku}',
                row.product.unit,
              ].join('   •   '),
              style: const TextStyle(color: AppTheme.mutedColor),
            ),
            const SizedBox(height: 2),
            Text(
              l10n.soldTodayRemaining(
                  _qtyText(sold), _qtyText(remaining < 0 ? 0 : remaining)),
              style: TextStyle(
                color: low ? _warnColor : AppTheme.mutedColor,
                fontSize: 12,
                fontWeight: low ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
        trailing: SizedBox(
          width: 112,
          child: TextField(
            controller: _controllers[row.product.id],
            onChanged: (_) => setState(() {}),
            enabled: !_saving,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.end,
            decoration: const InputDecoration(isDense: true, hintText: '0'),
          ),
        ),
      ),
    );
  }

  Widget _customersTab() {
    if (_driver == null) {
      return Center(
        child: Text(
          l10n.noDriverAssigned2,
          style: const TextStyle(color: AppTheme.mutedColor, fontSize: 15),
        ),
      );
    }
    if (_customers.isEmpty) {
      return Center(
        child: Text(
          l10n.noCustomersYet,
          style: const TextStyle(color: AppTheme.mutedColor, fontSize: 15),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.screenPadding),
      itemCount: _customers.length,
      itemBuilder: (context, i) {
        final c = _customers[i];
        return CustomerCard(
          customer: c,
          onTap: () => _openCustomer(c),
        );
      },
    );
  }
}
