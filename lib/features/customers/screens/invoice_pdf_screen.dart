import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../../core/database/app_database.dart';
import '../../../core/repositories/customer_repository.dart';
import '../../../core/repositories/invoice_repository.dart';
import '../../../core/services/invoice_pdf.dart';

class InvoicePdfScreen extends StatefulWidget {
  const InvoicePdfScreen({super.key, required this.invoice});

  final Invoice invoice;

  @override
  State<InvoicePdfScreen> createState() => _InvoicePdfScreenState();
}

class _InvoicePdfScreenState extends State<InvoicePdfScreen> {
  final _repo = InvoiceRepository();

  List<InvoiceItemWithProduct> _items = [];
  Customer? _customer;
  String _driverName = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await _repo.getItems(widget.invoice.id);
    final customer =
        await CustomerRepository().getById(widget.invoice.customerId);
    final driverName = await _repo.driverNameFor(widget.invoice.driverId);
    if (mounted) {
      setState(() {
        _items = items;
        _customer = customer;
        _driverName = driverName;
        _loading = false;
      });
    }
  }

  String get _number =>
      widget.invoice.invoiceNumber ??
      '#${widget.invoice.id.substring(0, 8).toUpperCase()}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF · $_number',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : PdfPreview(
              build: (_) => InvoicePdf.build(
                invoice: widget.invoice,
                items: _items,
                customer: _customer,
                driverName: _driverName,
              ),
              pdfFileName: '$_number.pdf',
              canChangePageFormat: false,
              canChangeOrientation: false,
              canDebug: false,
            ),
    );
  }
}
