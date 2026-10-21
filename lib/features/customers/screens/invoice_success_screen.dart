import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/locale/l10n.dart';
import '../../../core/repositories/invoice_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../widgets/invoice_photo_widgets.dart';
import '../widgets/invoice_status_badge.dart';
import 'invoice_pdf_screen.dart';

class InvoiceSuccessScreen extends StatefulWidget {
  const InvoiceSuccessScreen({
    super.key,
    required this.invoice,
    required this.customer,
    required this.cashSale,
  });

  final Invoice invoice;
  final Customer customer;
  final bool cashSale;

  @override
  State<InvoiceSuccessScreen> createState() => _InvoiceSuccessScreenState();
}

class _InvoiceSuccessScreenState extends State<InvoiceSuccessScreen> {
  final _repo = InvoiceRepository();

  late Invoice _invoice;
  bool _attaching = false;

  static const _okColor = Color(0xFF16A34A);

  @override
  void initState() {
    super.initState();
    _invoice = widget.invoice;
  }

  String get _number =>
      _invoice.invoiceNumber ?? '#${_invoice.id.substring(0, 8).toUpperCase()}';

  bool get _hasPhoto =>
      (_invoice.photoPath != null && _invoice.photoPath!.isNotEmpty) ||
      (_invoice.photoUrl != null && _invoice.photoUrl!.isNotEmpty);

  void _openPdf() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => InvoicePdfScreen(invoice: _invoice),
      ),
    );
  }

  Future<void> _attachPhoto() async {
    if (_attaching) return;
    setState(() => _attaching = true);
    final fresh = await attachInvoicePhotoFlow(context, _repo, _invoice);
    if (mounted) {
      setState(() {
        if (fresh != null) _invoice = fresh;
        _attaching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.invoiceCreated, style: const TextStyle(fontSize: 16)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.screenPadding),
        children: [
          const SizedBox(height: 16),
          const Icon(Icons.check_circle_outline, size: 72, color: _okColor),
          const SizedBox(height: 16),
          Text('${_invoice.totalAmount.round()} AFN',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .displayLarge
                  ?.copyWith(fontSize: 30)),
          const SizedBox(height: 6),
          Text(widget.customer.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('$_number — ${AppUtils.formatDate(_invoice.invoiceDate)}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.mutedColor, fontSize: 13)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InvoiceStatusBadge(status: _invoice.status),
              const SizedBox(width: 8),
              if (_invoice.status == 'partial')
                Text(l10n.paidAfnNow(_invoice.paidAmount.round()),
                    style: const TextStyle(
                        color: Color(0xFFD97706),
                        fontSize: 12,
                        fontWeight: FontWeight.w600))
              else if (widget.cashSale)
                Text(l10n.cash,
                    style: const TextStyle(
                        color: _okColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600))
              else
                Text(l10n.credit,
                    style: const TextStyle(
                        color: AppTheme.mutedColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openPdf,
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: Text(l10n.pdfLabel),
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _attaching ? null : _attachPhoto,
                  icon: _attaching
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : const Icon(Icons.add_a_photo_outlined),
                  label: Text(_hasPhoto ? l10n.replace : l10n.photo),
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48)),
                ),
              ),
            ],
          ),
          if (_hasPhoto) ...[
            const SizedBox(height: 12),
            InvoicePhotoThumb(
              localPath: _invoice.photoPath,
              objectPath: _invoice.photoUrl,
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.done),
              label: Text(l10n.done),
            ),
          ),
        ],
      ),
    );
  }
}
