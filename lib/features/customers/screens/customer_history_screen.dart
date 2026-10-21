import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/locale/l10n.dart';
import '../../../core/repositories/invoice_repository.dart';
import '../../../core/repositories/payment_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../widgets/invoice_status_badge.dart';
import 'invoice_detail_screen.dart';

class CustomerHistoryScreen extends StatefulWidget {
  const CustomerHistoryScreen({super.key, required this.customer});

  final Customer customer;

  @override
  State<CustomerHistoryScreen> createState() => _CustomerHistoryScreenState();
}

class _CustomerHistoryScreenState extends State<CustomerHistoryScreen> {
  final _invoiceRepo = InvoiceRepository();
  final _paymentRepo = PaymentRepository();

  List<_TimelineEntry> _entries = [];
  bool _loading = true;

  static const _paidColor = Color(0xFF16A34A);

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final invoices = await _invoiceRepo.getForCustomer(widget.customer.id);
    final payments = await _paymentRepo.getForCustomer(widget.customer.id);
    final entries = <_TimelineEntry>[
      ...invoices.map((i) => _TimelineEntry(
          date: i.invoiceDate, createdAt: i.createdAt, invoice: i)),
      ...payments.map((p) => _TimelineEntry(
          date: p.paymentDate, createdAt: p.createdAt, payment: p)),
    ]..sort((a, b) {
        final byDate = b.date.compareTo(a.date);
        if (byDate != 0) return byDate;
        return b.createdAt.compareTo(a.createdAt);
      });
    if (mounted) {
      setState(() {
        _entries = entries;
        _loading = false;
      });
    }
  }

  Future<void> _openInvoice(Invoice invoice) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => InvoiceDetailScreen(invoice: invoice),
      ),
    );
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.historyFor(widget.customer.name),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16)),
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _entries.isEmpty
                ? _emptyState()
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppTheme.screenPadding),
                    itemCount: _entries.length,
                    itemBuilder: (context, i) => _entryCard(_entries[i]),
                  ),
      ),
    );
  }

  Widget _emptyState() {
    return ListView(
      children: [
        const SizedBox(height: 120),
        const Icon(Icons.history, size: 56, color: Colors.black26),
        const SizedBox(height: 12),
        Text(
          l10n.noHistoryYet,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black54, fontSize: 16),
        ),
      ],
    );
  }

  Widget _entryCard(_TimelineEntry entry) {
    final invoice = entry.invoice;
    if (invoice != null) {
      final number = invoice.invoiceNumber ??
          '#${invoice.id.substring(0, 8).toUpperCase()}';
      return Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          onTap: () => _openInvoice(invoice),
          leading: const CircleAvatar(
            backgroundColor: Color(0x1F2563EB),
            child: Icon(Icons.receipt_long_outlined,
                color: AppTheme.accentColor, size: 22),
          ),
          title: Text(l10n.invoiceTitleWithNumber(number),
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(AppUtils.formatDate(invoice.invoiceDate),
              style: const TextStyle(color: AppTheme.mutedColor, fontSize: 13)),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${invoice.totalAmount.round()} AFN',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              InvoiceStatusBadge(status: invoice.status),
            ],
          ),
        ),
      );
    }

    final payment = entry.payment!;
    final method =
        payment.paymentMethod == 'transfer' ? l10n.transfer : l10n.cash;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0x1F16A34A),
          child: Icon(Icons.payments_outlined, color: _paidColor, size: 22),
        ),
        title: Text(l10n.payment,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('$method — ${AppUtils.formatDate(payment.paymentDate)}',
            style: const TextStyle(color: AppTheme.mutedColor, fontSize: 13)),
        trailing: Text('+${payment.amount.round()} AFN',
            style: const TextStyle(
                color: _paidColor, fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }
}

class _TimelineEntry {
  const _TimelineEntry({
    required this.date,
    required this.createdAt,
    this.invoice,
    this.payment,
  });

  final DateTime date;
  final DateTime createdAt;
  final Invoice? invoice;
  final Payment? payment;
}
