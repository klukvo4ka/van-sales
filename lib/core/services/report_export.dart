import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart' hide Border;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../locale/l10n.dart';
import '../theme/app_theme.dart';
import '../utils/app_logger.dart';

class ReportTable {
  const ReportTable({
    required this.title,
    required this.columns,
    required this.rows,
    this.totals,
  });

  final String title;
  final List<String> columns;
  final List<List<Object?>> rows;
  final List<Object?>? totals;
}

class ExportButtons extends StatelessWidget {
  const ExportButtons({
    super.key,
    required this.enabled,
    required this.onPdf,
    required this.onExcel,
  });

  final bool enabled;
  final VoidCallback onPdf;
  final VoidCallback onExcel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton.icon(
          onPressed: enabled ? onPdf : null,
          icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
          label: const Text('PDF'),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: enabled ? onExcel : null,
          icon: const Icon(Icons.grid_on_outlined, size: 18),
          label: Text(l10n.excel),
        ),
      ],
    );
  }
}

class ReportExport {
  ReportExport._();

  static const _navy = PdfColor.fromInt(0xFF1A2E4A);
  static const _muted = PdfColor.fromInt(0xFF64748B);
  static const _border = PdfColor.fromInt(0xFFE2E8F0);

  static String fileBase(String report, String scope, String range) {
    String clean(String s) => s
        .replaceAll(RegExp(r'[^A-Za-z0-9؀-ۿ]+'), '_')
        .replaceAll(RegExp('_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
    return [clean(report), clean(scope), clean(range)]
        .where((s) => s.isNotEmpty)
        .join('_');
  }

  static Future<void> exportPdf(
    BuildContext context, {
    required String reportName,
    required String filters,
    required String fileBase,
    required List<ReportTable> tables,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => _ExportPdfScreen(
          reportName: reportName,
          filters: filters,
          fileBase: fileBase,
          tables: tables,
        ),
      ),
    );
  }

  static Future<void> exportExcel(
    BuildContext context, {
    required String reportName,
    required String filters,
    required String fileBase,
    required List<ReportTable> tables,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final excel = Excel.createExcel();
      final sheetName = _sheetName(reportName);
      excel.rename('Sheet1', sheetName);
      final sheet = excel[sheetName];

      sheet.appendRow([TextCellValue(reportName)]);
      sheet.appendRow([TextCellValue(filters)]);
      sheet.appendRow([
        TextCellValue(l10n.generatedAt(_timestamp(DateTime.now()))),
      ]);
      for (final table in tables) {
        sheet.appendRow([TextCellValue('')]);
        sheet.appendRow([TextCellValue(table.title)]);
        sheet.appendRow(table.columns.map(TextCellValue.new).toList());
        for (final row in table.rows) {
          sheet.appendRow(row.map(_cell).toList());
        }
        final totals = table.totals;
        if (totals != null) {
          sheet.appendRow(totals.map(_cell).toList());
        }
      }

      final bytes = excel.save();
      if (bytes == null) {
        throw StateError('excel.save() returned null');
      }
      final data = Uint8List.fromList(bytes);

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileBase.xlsx');
      await file.writeAsBytes(data, flush: true);

      messenger.showSnackBar(SnackBar(
        content: Text(l10n.excelSaved(file.path)),
      ));
      await Printing.sharePdf(bytes: data, filename: '$fileBase.xlsx');
    } catch (e, st) {
      AppLogger.error('ReportExport.exportExcel', e, st);
      messenger.showSnackBar(SnackBar(
        content: Text(l10n.exportFailed),
      ));
    }
  }

  static CellValue _cell(Object? v) => switch (v) {
        null => TextCellValue(''),
        final int i => IntCellValue(i),
        final double d =>
          d == d.roundToDouble() ? IntCellValue(d.round()) : DoubleCellValue(d),
        final DateTime dt =>
          DateCellValue(year: dt.year, month: dt.month, day: dt.day),
        _ => TextCellValue(v.toString()),
      };

  static String _sheetName(String reportName) {
    final en = reportName.split('·').first.trim();
    final cleaned = en.replaceAll(RegExp(r'[\\/*?\[\]:]'), '');
    return cleaned.isEmpty
        ? 'Report'
        : cleaned.length > 31
            ? cleaned.substring(0, 31)
            : cleaned;
  }

  static String _timestamp(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')} '
      '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}';

  static String _pdfCell(Object? v) => switch (v) {
        null => '',
        final double d => _formatNumber(d),
        final DateTime dt => '${dt.year.toString().padLeft(4, '0')}-'
            '${dt.month.toString().padLeft(2, '0')}-'
            '${dt.day.toString().padLeft(2, '0')}',
        _ => v.toString(),
      };

  static String _formatNumber(double value) {
    if (value == value.roundToDouble()) return value.round().toString();
    return value
        .toStringAsFixed(3)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  static Future<Uint8List> buildPdf({
    required String reportName,
    required String filters,
    required List<ReportTable> tables,
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

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: theme,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => [
          pw.Text(reportName,
              style: pw.TextStyle(
                  fontSize: 16, fontWeight: pw.FontWeight.bold, color: _navy)),
          pw.SizedBox(height: 3),
          pw.Text(filters,
              style: const pw.TextStyle(fontSize: 10, color: _muted)),
          pw.Text(l10n.generatedAt(_timestamp(DateTime.now())),
              style: const pw.TextStyle(fontSize: 9, color: _muted)),
          for (final table in tables) ...[
            pw.SizedBox(height: 14),
            pw.Text(table.title,
                style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: _navy)),
            pw.SizedBox(height: 4),
            pw.TableHelper.fromTextArray(
              headers: table.columns,
              data: [
                for (final row in table.rows) row.map(_pdfCell).toList(),
                if (table.totals != null) table.totals!.map(_pdfCell).toList(),
              ],
              headerStyle: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: _navy),
              cellStyle: const pw.TextStyle(fontSize: 9),
              border: pw.TableBorder.all(color: _border, width: 0.5),
              cellPadding:
                  const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
              cellAlignments: {
                for (var i = 1; i < table.columns.length; i++)
                  i: pw.Alignment.centerRight,
                0: pw.Alignment.centerLeft,
              },
            ),
          ],
        ],
      ),
    );
    return doc.save();
  }
}

class _ExportPdfScreen extends StatelessWidget {
  const _ExportPdfScreen({
    required this.reportName,
    required this.filters,
    required this.fileBase,
    required this.tables,
  });

  final String reportName;
  final String filters;
  final String fileBase;
  final List<ReportTable> tables;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(reportName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16)),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: PdfPreview(
        build: (_) => ReportExport.buildPdf(
          reportName: reportName,
          filters: filters,
          tables: tables,
        ),
        pdfFileName: '$fileBase.pdf',
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
      ),
    );
  }
}
