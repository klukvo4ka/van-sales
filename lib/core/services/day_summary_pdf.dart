import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../l10n/app_localizations.dart';
import '../locale/l10n.dart';
import '../repositories/day_summary_repository.dart';

class DaySummaryPdf {
  DaySummaryPdf._();

  static const _navy = PdfColor.fromInt(0xFF1A2E4A);
  static const _muted = PdfColor.fromInt(0xFF64748B);
  static const _border = PdfColor.fromInt(0xFFE2E8F0);
  static const _debt = PdfColor.fromInt(0xFFDC2626);
  static const _ok = PdfColor.fromInt(0xFF16A34A);

  static Future<Uint8List> build({
    required DaySummary summary,
    required DateTime date,
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

    final s = summary;
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(_bi((t) => t.daySummary),
                  style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: _navy)),
              pw.Text(_date(date),
                  style: const pw.TextStyle(fontSize: 11, color: _muted)),
            ],
          ),
          if (driverName.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 2),
              child: pw.Text('${_bi((t) => t.driver)}: $driverName',
                  style: const pw.TextStyle(fontSize: 10, color: _muted)),
            ),
          pw.SizedBox(height: 14),
          _section(_bi((t) => t.sales), [
            (_bi((t) => t.invoices), '${s.invoiceCount}', null),
            (_bi((t) => t.totalSold), _afn(s.totalSold), null),
            (
              '${_bi((t) => t.cashSales)} (${s.cashCount})',
              _afn(s.cashAmount),
              null
            ),
            (
              '${_bi((t) => t.partialLabel)} (${s.partialCount})',
              _afn(s.partialAmount),
              null
            ),
            (
              '${_bi((t) => t.creditSales)} (${s.creditCount})',
              _afn(s.creditAmount),
              null
            ),
          ]),
          pw.SizedBox(height: 10),
          _section(_bi((t) => t.collected), [
            (_bi((t) => t.cash), _afn(s.cashCollected), null),
            (_bi((t) => t.transfer), _afn(s.transferCollected), null),
            (_bi((t) => t.totalCollected), _afn(s.totalCollected), _ok),
          ]),
          pw.SizedBox(height: 10),
          _section(_bi((t) => t.day), [
            (
              _bi((t) => t.newDebtToday),
              _afn(s.newDebt),
              s.newDebt > 0 ? _debt : null
            ),
            (
              _bi((t) => t.visited),
              '${s.visitedCount} / ${s.routeCount}',
              null
            ),
            (_bi((t) => t.unitsSold), _qty(s.unitsSold), null),
            (_bi((t) => t.stockValueLeft), _afn(s.stockValue), null),
          ]),
          if (s.customers.isNotEmpty) ...[
            pw.SizedBox(height: 14),
            pw.TableHelper.fromTextArray(
              headers: [
                _bi((t) => t.customer),
                _bi((t) => t.sold),
                _bi((t) => t.collected2),
              ],
              data: [
                for (final row in s.customers)
                  [
                    row.customer.name,
                    _afn(row.sold),
                    _afn(row.collected),
                  ],
              ],
              headerStyle: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: _navy),
              cellStyle: const pw.TextStyle(fontSize: 9),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerRight,
                2: pw.Alignment.centerRight,
              },
              border: pw.TableBorder.all(color: _border, width: 0.5),
              cellPadding:
                  const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            ),
          ],
        ],
      ),
    );
    return doc.save();
  }

  static String _afn(double v) => '${v.round()} AFN';

  static String _qty(double q) =>
      q == q.roundToDouble() ? '${q.round()}' : '$q';

  static String _date(DateTime d) => '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static pw.Widget _section(
      String title, List<(String, String, PdfColor?)> rows) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _border),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title,
              style: pw.TextStyle(
                  fontSize: 11, fontWeight: pw.FontWeight.bold, color: _navy)),
          pw.SizedBox(height: 6),
          for (final (label, value, color) in rows)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 3),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(label,
                      style: const pw.TextStyle(fontSize: 10, color: _muted)),
                  pw.Text(value,
                      style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: color ?? _navy)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

String _bi(String Function(AppLocalizations t) pick) =>
    '${pick(l10nFor('en'))} · ${pick(l10nFor('fa'))}';
