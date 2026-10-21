import 'dart:math';

import 'package:flutter_test/flutter_test.dart';

import 'package:van_sales/core/repositories/invoice_repository.dart';

void main() {
  test('composeInvoiceNumber formats {prefix}-{yyMMdd}-{HHmmss}{2 rand}', () {
    final number = InvoiceRepository.composeInvoiceNumber(
      'KBL123',
      DateTime(2026, 7, 5, 14, 3, 9),
      random: Random(1),
    );
    expect(number, matches(RegExp(r'^KBL123-260705-140309\d{2}$')));
  });

  test('composeInvoiceNumber pads single-digit date and time parts', () {
    final number = InvoiceRepository.composeInvoiceNumber(
      'VS',
      DateTime(2026, 1, 2, 3, 4, 5),
      random: Random(1),
    );
    expect(number, startsWith('VS-260102-030405'));
    expect(number.length, 'VS-260102-030405'.length + 2);
  });

  test('sanitizeNumberPrefix strips symbols and caps length', () {
    expect(InvoiceRepository.sanitizeNumberPrefix('kbl 12-34'), 'KBL1234');
    expect(
      InvoiceRepository.sanitizeNumberPrefix('a1b2c3d4e5f6'),
      'A1B2C3D4',
    );
    expect(InvoiceRepository.sanitizeNumberPrefix('؟؟'), '');
  });

  test('statusFor maps totals to invoice status', () {
    expect(InvoiceRepository.statusFor(100, 0), 'unpaid');
    expect(InvoiceRepository.statusFor(100, 40), 'partial');
    expect(InvoiceRepository.statusFor(100, 100), 'paid');
  });
}
