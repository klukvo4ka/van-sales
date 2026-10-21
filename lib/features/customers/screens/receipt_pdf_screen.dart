import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../../core/locale/l10n.dart';
import '../../../core/services/receipt_pdf.dart';

class ReceiptPdfScreen extends StatelessWidget {
  const ReceiptPdfScreen({
    super.key,
    required this.receiptNumber,
    required this.date,
    required this.customerName,
    required this.amount,
    required this.method,
    required this.newBalance,
    this.invoiceNumber,
  });

  final String receiptNumber;
  final DateTime date;
  final String customerName;
  final double amount;
  final String method;
  final double newBalance;
  final String? invoiceNumber;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.receiptTitleWithNumber(receiptNumber),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16)),
      ),
      body: PdfPreview(
        build: (_) => ReceiptPdf.build(
          receiptNumber: receiptNumber,
          date: date,
          customerName: customerName,
          amount: amount,
          method: method,
          newBalance: newBalance,
          invoiceNumber: invoiceNumber,
        ),
        pdfFileName: '$receiptNumber.pdf',
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
      ),
    );
  }
}
