import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/database/app_database.dart';
import '../../../core/locale/l10n.dart';
import '../../../core/repositories/customer_repository.dart';
import '../../../core/repositories/invoice_repository.dart';
import '../../../core/repositories/payment_repository.dart';
import '../../../core/repositories/truck_initial_stock_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../office/customers_tab.dart' show DriverOption, OfficeCustomerSheet;
import '../widgets/customer_common.dart';
import '../widgets/customer_photo_widgets.dart';
import 'customer_form_sheet.dart';
import 'customer_history_screen.dart';
import 'new_invoice_screen.dart';
import 'payment_sheet.dart';

class CustomerDetailScreen extends StatefulWidget {
  const CustomerDetailScreen({super.key, required this.customer});

  final Customer customer;

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  final _repo = CustomerRepository();
  late Customer _customer;
  DebtSummary? _summary;
  bool _isOffice = false;
  bool _roleReady = false;

  static const _debtColor = Color(0xFFDC2626);
  static const _paidColor = Color(0xFF16A34A);

  @override
  void initState() {
    super.initState();
    _customer = widget.customer;
    _init();
  }

  Future<void> _init() async {
    final role = await AuthService.getUserRole();
    if (mounted) {
      setState(() {
        _isOffice =
            role == AuthService.roleOffice || role == AuthService.roleAdmin;
        _roleReady = true;
      });
    }
    await _reload();
  }

  Future<void> _reload() async {
    if (_isOffice) {
      await InvoiceRepository().hydrateForCustomer(_customer.id);
      await PaymentRepository().hydrateForCustomer(_customer.id);
    } else {
      await InvoiceRepository().reconcileAllocations(_customer.id);
    }
    final fresh = await _repo.getById(_customer.id);
    final summary = await _repo.getDebtSummary(_customer.id);
    if (mounted) {
      setState(() {
        if (fresh != null) _customer = fresh;
        _summary = summary;
      });
    }
  }

  Future<void> _edit() async {
    final bool? saved;
    if (_isOffice) {
      final profiles = await TruckInitialStockRepository().getDriverProfiles();
      if (!mounted) return;
      saved = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        builder: (_) => OfficeCustomerSheet(
          existing: _customer,
          drivers: profiles
              .where((p) => p.role == AuthService.roleDriver && p.isActive)
              .map((p) => DriverOption(id: p.id, name: p.fullName))
              .toList(),
        ),
      );
    } else {
      saved = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        builder: (_) => CustomerFormSheet(
          existing: _customer,
          driverId: _customer.driverId ?? '',
          nextRouteOrder: _customer.routeOrder,
        ),
      );
    }
    if (saved == true) await _reload();
  }

  Future<void> _openHistory() async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => CustomerHistoryScreen(customer: _customer),
      ),
    );
    await _reload();
  }

  Future<void> _acceptPayment() async {
    final c = _customer;
    final outstanding =
        _summary?.outstanding ?? (c.balance < 0 ? 0.0 : c.balance);
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => PaymentSheet(customer: c, outstanding: outstanding),
    );
    if (saved == true) await _reload();
  }

  Future<void> _newInvoice() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => NewInvoiceScreen(customer: _customer),
      ),
    );
    if (saved == true) await _reload();
  }

  void _openViewer(String title, String? localPath, String? objectPath) {
    openCustomerPhotoViewer(context, title, localPath, objectPath);
  }

  void _openPhotoOrEdit(String title, String? localPath, String? objectPath) {
    final hasLocal = localPath != null &&
        localPath.isNotEmpty &&
        File(localPath).existsSync();
    final hasRemote = objectPath != null && objectPath.isNotEmpty;
    if (hasLocal || hasRemote) {
      _openViewer(title, localPath, objectPath);
    } else {
      _edit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _customer;
    return Scaffold(
      appBar: AppBar(
        title: Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            onPressed: _edit,
            tooltip: l10n.edit,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: !_roleReady
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _reload,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppTheme.screenPadding),
                children: [
                  _headerCard(context, c),
                  const SizedBox(height: 12),
                  _photosRow(c),
                  const SizedBox(height: 12),
                  _contactCard(c),
                  const SizedBox(height: 12),
                  _balanceCard(c),
                  const SizedBox(height: 16),
                  if (!_isOffice) ...[
                    _actionButton(
                      icon: Icons.receipt_long_outlined,
                      label: l10n.newInvoice,
                      onTap: _newInvoice,
                    ),
                    const SizedBox(height: 10),
                    _actionButton(
                      icon: Icons.payments_outlined,
                      label: l10n.acceptPayment,
                      onTap: _acceptPayment,
                    ),
                    const SizedBox(height: 10),
                  ],
                  _actionButton(
                    icon: Icons.history_outlined,
                    label: l10n.history,
                    onTap: _openHistory,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _headerCard(BuildContext context, Customer c) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _HeaderAvatar(customer: c),
            const SizedBox(width: 12),
            Expanded(
              child:
                  Text(c.name, style: Theme.of(context).textTheme.titleLarge),
            ),
            RouteBadge(order: c.routeOrder),
          ],
        ),
      ),
    );
  }

  Widget _photosRow(Customer c) {
    return Row(
      children: [
        Expanded(
          child: CustomerPhotoTile(
            label: l10n.outside,
            localPath: c.photoOutsidePath,
            objectPath: c.photoOutsideUrl,
            onTap: () => _openPhotoOrEdit(
                l10n.outside, c.photoOutsidePath, c.photoOutsideUrl),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomerPhotoTile(
            label: l10n.inside,
            localPath: c.photoInsidePath,
            objectPath: c.photoInsideUrl,
            onTap: () => _openPhotoOrEdit(
                l10n.inside, c.photoInsidePath, c.photoInsideUrl),
          ),
        ),
      ],
    );
  }

  Widget _contactCard(Customer c) {
    final phone = c.phone;
    final address = c.address;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          children: [
            if (phone != null && phone.isNotEmpty)
              _InfoRow(
                icon: Icons.phone_outlined,
                text: phone,
                onTap: () => callPhone(phone),
              ),
            if (address != null && address.isNotEmpty)
              _InfoRow(icon: Icons.location_on_outlined, text: address),
            if ((phone == null || phone.isEmpty) &&
                (address == null || address.isEmpty))
              _InfoRow(icon: Icons.info_outline, text: l10n.noContactInfo),
          ],
        ),
      ),
    );
  }

  Widget _balanceCard(Customer c) {
    final s = _summary;
    final localLedgerIsEmpty = s != null &&
        s.totalInvoiced == 0 &&
        s.totalPaid == 0 &&
        s.unpaidCount == 0;
    final outstanding = (localLedgerIsEmpty && c.balance > 0)
        ? c.balance
        : (s?.outstanding ?? (c.balance < 0 ? 0.0 : c.balance));
    final hasDebt = outstanding > 0;
    final color = hasDebt ? _debtColor : _paidColor;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.balance,
              style: const TextStyle(color: AppTheme.mutedColor, fontSize: 13)),
          const SizedBox(height: 10),
          _debtRow(l10n.goodsTaken, '${(s?.totalInvoiced ?? 0).round()} AFN'),
          const SizedBox(height: 6),
          _debtRow(l10n.paid, '${(s?.totalPaid ?? 0).round()} AFN'),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(hasDebt ? l10n.owes : l10n.settled,
                  style: TextStyle(
                      color: color, fontSize: 16, fontWeight: FontWeight.bold)),
              if (hasDebt)
                Text('${outstanding.round()} AFN',
                    style: TextStyle(
                        color: color,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
            ],
          ),
          if ((s?.unpaidCount ?? 0) > 0)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                l10n.openInvoiceCount(s!.unpaidCount),
                style:
                    const TextStyle(color: AppTheme.mutedColor, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _debtRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.black87, fontSize: 14)),
        Text(value,
            style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 22),
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

class _HeaderAvatar extends StatelessWidget {
  const _HeaderAvatar({required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    final path = customer.photoOutsidePath;
    final url = customer.photoOutsideUrl;
    final hasLocal = path != null && path.isNotEmpty && File(path).existsSync();
    final hasRemote = url != null && url.isNotEmpty;
    if (!hasLocal && !hasRemote) {
      return CircleAvatar(
        radius: 28,
        backgroundColor: AppTheme.primaryColor,
        child: Text(customerInitials(customer.name),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      );
    }
    return ClipOval(
      child: SizedBox(
        width: 56,
        height: 56,
        child: hasLocal
            ? Image.file(File(path), fit: BoxFit.cover)
            : SignedCustomerPhoto(objectPath: url!),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text, this.onTap});

  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.mutedColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text,
                  style: TextStyle(
                      color: onTap != null
                          ? AppTheme.accentColor
                          : Colors.black87)),
            ),
          ],
        ),
      ),
    );
  }
}
