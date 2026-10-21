import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../l10n/app_localizations.dart';
import '../locale/l10n.dart';

class ReceiptPdf {
  ReceiptPdf._();

  static const _navy = PdfColor.fromInt(0xFF1A2E4A);
  static const _muted = PdfColor.fromInt(0xFF64748B);
  static const _border = PdfColor.fromInt(0xFFE2E8F0);
  static const _ok = PdfColor.fromInt(0xFF16A34A);

  static Future<Uint8List> build({
    required String receiptNumber,
    required DateTime date,
    required String customerName,
    required double amount,
    required String method,
    required double newBalance,
    String? invoiceNumber,
  }) async {
    final inter =
        pw.Font.ttf(await rootBundle.load('assets/fonts/Inter-Regular.ttf'));
    final interBold =
        pw.Font.ttf(await rootBundle.load('assets/fonts/Inter-Bold.ttf'));
    final vazir = pw.Font.ttf(
        await rootBundle.load('assets/fonts/Vazirmatn-Regular.ttf'));
    final vazirBold =
        pw.Font.ttf(await rootBundle.load('assets/fonts/Vazirmatn-Bold.ttf'));

    final theme = pw.ThemeData.withFont(
      base: inter,
      bold: interBold,
      fontFallback: [vazir, vazirBold],
    );

    final methodLabel =
        method == 'transfer' ? _bi((t) => t.transfer) : _bi((t) => t.cash);

    pw.Widget line(String label, String value, {bool bold = false}) =>
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 4),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(label,
                  style: const pw.TextStyle(fontSize: 9, color: _muted)),
              pw.Text(value,
                  style: pw.TextStyle(
                    fontSize: bold ? 12 : 10,
                    fontWeight:
                        bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                    color: _navy,
                  )),
            ],
          ),
        );

    final doc = pw.Document();
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a6,
        theme: theme,
        margin: const pw.EdgeInsets.all(18),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Text(_bi((t) => t.receipt),
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: _navy)),
            pw.SizedBox(height: 4),
            pw.Text(receiptNumber,
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 9, color: _muted)),
            pw.SizedBox(height: 12),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: _border),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                children: [
                  line(_bi((t) => t.date), _date(date)),
                  line(_bi((t) => t.customer), customerName),
                  if (invoiceNumber != null && invoiceNumber.isNotEmpty)
                    line(_bi((t) => t.invoice), invoiceNumber),
                  line(_bi((t) => t.method), methodLabel),
                  pw.Divider(color: _border, height: 12),
                  line(_bi((t) => t.amount), '${amount.round()} AFN',
                      bold: true),
                  line(_bi((t) => t.newBalance), '${newBalance.round()} AFN'),
                ],
              ),
            ),
            pw.SizedBox(height: 14),
            pw.Text(_bi((t) => t.thankYou),
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 10, color: _ok)),
          ],
        ),
      ),
    );
    return doc.save();
  }

  static String _date(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}

String _bi(String Function(AppLocalizations t) pick) =>
    '${pick(l10nFor('en'))} · ${pick(l10nFor('fa'))}';
