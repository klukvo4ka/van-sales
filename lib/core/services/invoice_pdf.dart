import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../l10n/app_localizations.dart';
import '../database/app_database.dart';
import '../locale/l10n.dart';
import '../repositories/invoice_repository.dart';

class InvoicePdf {
  InvoicePdf._();

  static const _navy = PdfColor.fromInt(0xFF1A2E4A);
  static const _muted = PdfColor.fromInt(0xFF64748B);
  static const _border = PdfColor.fromInt(0xFFE2E8F0);
  static const _due = PdfColor.fromInt(0xFFDC2626);

  static Future<Uint8List> build({
    required Invoice invoice,
    required List<InvoiceItemWithProduct> items,
    Customer? customer,
    String driverName = '',
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

    final number =
        invoice.invoiceNumber ?? '#${invoice.id.substring(0, 8).toUpperCase()}';
    final due = invoice.totalAmount - invoice.paidAmount;

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a5,
        theme: theme,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          _header(number),
          pw.SizedBox(height: 10),
          _metaBlock(invoice, customer, driverName),
          pw.SizedBox(height: 14),
          _itemsTable(items),
          pw.SizedBox(height: 12),
          _totalsBlock(invoice, due),
        ],
      ),
    );
    return doc.save();
  }

  static String _date(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static String _qty(double q) =>
      q == q.roundToDouble() ? '${q.round()}' : '$q';

  static String _bilingualName(InvoiceItemWithProduct row) {
    final p = row.product;
    if (p == null) return row.productName;
    return p.nameFa == null || p.nameFa!.isEmpty
        ? p.name
        : '${p.name} · ${p.nameFa}';
  }

  static pw.Widget _header(String number) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Text(_bi((t) => t.invoice),
            style: pw.TextStyle(
                fontSize: 18, fontWeight: pw.FontWeight.bold, color: _navy)),
        pw.Text(number,
            style: pw.TextStyle(
                fontSize: 12, fontWeight: pw.FontWeight.bold, color: _navy)),
      ],
    );
  }

  static pw.Widget _metaBlock(
      Invoice invoice, Customer? customer, String driverName) {
    pw.Widget line(String label, String value) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 2),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(
                width: 120,
                child: pw.Text(label,
                    style: const pw.TextStyle(fontSize: 9, color: _muted)),
              ),
              pw.Expanded(
                child: pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
              ),
            ],
          ),
        );

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _border),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          line(_bi((t) => t.date), _date(invoice.invoiceDate)),
          line(_bi((t) => t.customer), customer?.name ?? ''),
          if (customer?.phone != null && customer!.phone!.isNotEmpty)
            line(_bi((t) => t.phone), customer.phone!),
          if (customer?.address != null && customer!.address!.isNotEmpty)
            line(_bi((t) => t.address), customer.address!),
          if (driverName.isNotEmpty) line(_bi((t) => t.driver), driverName),
        ],
      ),
    );
  }

  static pw.Widget _itemsTable(List<InvoiceItemWithProduct> items) {
    return pw.TableHelper.fromTextArray(
      headers: [
        '#',
        _bi((t) => t.product),
        _bi((t) => t.qty),
        _bi((t) => t.price),
        _bi((t) => t.total),
      ],
      data: [
        for (var i = 0; i < items.length; i++)
          [
            '${i + 1}',
            _bilingualName(items[i]),
            '${_qty(items[i].item.quantity)} ${items[i].unit}',
            '${items[i].item.unitPrice.round()}',
            '${items[i].item.total.round()}',
          ],
      ],
      headerStyle: pw.TextStyle(
          fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: _navy),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
      },
      columnWidths: {
        0: const pw.FixedColumnWidth(18),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(1.2),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(1.2),
      },
      border: pw.TableBorder.all(color: _border, width: 0.5),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
    );
  }

  static pw.Widget _totalsBlock(Invoice invoice, double due) {
    pw.Widget row(String label, String value,
        {bool bold = false, PdfColor? color}) {
      final style = pw.TextStyle(
        fontSize: bold ? 12 : 10,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        color: color ?? _navy,
      );
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 3),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label, style: style),
            pw.Text(value, style: style)
          ],
        ),
      );
    }

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.SizedBox(
          width: 220,
          child: pw.Column(
            children: [
              row(_bi((t) => t.total), '${invoice.totalAmount.round()} AFN',
                  bold: true),
              row(_bi((t) => t.paid), '${invoice.paidAmount.round()} AFN'),
              row(
                _bi((t) => t.owed),
                '${(due < 0 ? 0 : due).round()} AFN',
                bold: true,
                color: due > 0 ? _due : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _bi(String Function(AppLocalizations t) pick) =>
    '${pick(l10nFor('en'))} · ${pick(l10nFor('fa'))}';
