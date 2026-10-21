import 'package:flutter/material.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/database/app_database.dart';
import '../../../core/locale/l10n.dart';
import '../../../core/repositories/customer_repository.dart'
    show CustomerRepository, SaveResult;
import '../../../core/repositories/invoice_repository.dart';
import '../../../core/repositories/payment_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import 'receipt_pdf_screen.dart';

class PaymentSheet extends StatefulWidget {
  const PaymentSheet({
    super.key,
    required this.customer,
    required this.outstanding,
    this.invoice,
  });

  final Customer customer;
  final double outstanding;
  final Invoice? invoice;

  @override
  State<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<PaymentSheet> {
  final _repo = PaymentRepository();
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _notes = TextEditingController();
  String _method = 'cash';
  bool _saving = false;

  static const _debtColor = Color(0xFFDC2626);
  static const _paidColor = Color(0xFF16A34A);
  static const _warnColor = Color(0xFFD97706);

  @override
  void dispose() {
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  double get _parsedAmount =>
      (int.tryParse(_amount.text.trim()) ?? 0).toDouble();

  bool get _overpay => _parsedAmount > widget.outstanding;

  String? _validateAmount(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return l10n.required;
    final parsed = int.tryParse(value);
    if (parsed == null) return l10n.wholeNumberOnly;
    if (parsed <= 0) return l10n.mustBeMoreThanZero;
    return null;
  }

  void _payFull() {
    _amount.text = widget.outstanding.round().toString();
    setState(() {});
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final amount = _parsedAmount;
    final notes = _notes.text.trim().isEmpty ? null : _notes.text.trim();
    final driverId = AuthService().currentUser?.id ?? '';
    final invoice = widget.invoice;

    final SaveResult result;
    final String message;
    if (invoice == null) {
      result = await _repo.create(
        customerId: widget.customer.id,
        driverId: driverId,
        amount: amount,
        method: _method,
        notes: notes,
      );
      message = l10n.paymentReceivedAfn(amount.round());
    } else {
      result = await InvoiceRepository().addPayment(
        invoice: invoice,
        driverId: driverId,
        amount: amount,
        method: _method,
        notes: notes,
      );
      final fullyPaid = invoice.paidAmount + amount >= invoice.totalAmount;
      message = fullyPaid
          ? l10n.invoicePaidAfn(amount.round())
          : l10n.partialPaymentAfn2(amount.round());
    }

    final fresh = await CustomerRepository().getById(widget.customer.id);
    final newBalance = fresh?.balance ?? widget.customer.balance;
    final date = DateTime.now();
    final receiptNumber =
        'RCPT-${AppUtils.formatDate(date, pattern: 'yyMMdd-HHmmss')}';

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    navigator.pop(true);
    messenger.showSnackBar(
      SnackBar(
        content: Text(result == SaveResult.synced
            ? message
            : l10n.withOfflineNote(message)),
        action: SnackBarAction(
          label: l10n.receipt,
          onPressed: () => navigator.push(
            MaterialPageRoute<void>(
              builder: (_) => ReceiptPdfScreen(
                receiptNumber: receiptNumber,
                date: date,
                customerName: widget.customer.name,
                amount: amount,
                method: _method,
                newBalance: newBalance,
                invoiceNumber: invoice?.invoiceNumber,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _methodChip(String value, String label) {
    final selected = _method == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      labelStyle: TextStyle(
          color: selected ? Colors.white : AppTheme.primaryColor, fontSize: 13),
      onSelected: _saving ? null : (_) => setState(() => _method = value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final owes = widget.outstanding;
    final hasDebt = owes > 0;
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
              Text(
                  widget.invoice == null ? l10n.acceptPayment : l10n.addPayment,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                  widget.invoice == null
                      ? widget.customer.name
                      : '${widget.customer.name} — '
                          '${widget.invoice!.invoiceNumber ?? ''}',
                  style: const TextStyle(
                      color: AppTheme.mutedColor, fontSize: 14)),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: (hasDebt ? _debtColor : _paidColor)
                      .withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                ),
                child: Text(
                  hasDebt
                      ? widget.invoice == null
                          ? l10n.owesAfn(owes.round())
                          : l10n.remainingAfn(owes.round())
                      : l10n.settled,
                  style: TextStyle(
                      color: hasDebt ? _debtColor : _paidColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amount,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: l10n.amountAfn,
                  suffixIcon: hasDebt
                      ? TextButton(
                          onPressed: _saving ? null : _payFull,
                          child: Text(l10n.payFull,
                              style: const TextStyle(fontSize: 12)),
                        )
                      : null,
                ),
                validator: _validateAmount,
              ),
              if (_parsedAmount > 0 && _overpay)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    l10n.moreThanOwed,
                    style: const TextStyle(color: _warnColor, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _methodChip('cash', l10n.cash),
                  const SizedBox(width: 8),
                  _methodChip('transfer', l10n.transfer),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _notes,
                decoration: InputDecoration(labelText: l10n.notes),
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
                      : const Icon(Icons.payments_outlined),
                  label: Text(l10n.receive),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
