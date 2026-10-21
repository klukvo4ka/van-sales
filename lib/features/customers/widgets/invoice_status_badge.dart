import 'package:flutter/material.dart';

import '../../../core/locale/l10n.dart';

class InvoiceStatusBadge extends StatelessWidget {
  const InvoiceStatusBadge({super.key, required this.status});

  final String status;

  static const _paidColor = Color(0xFF16A34A);
  static const _partialColor = Color(0xFFD97706);
  static const _unpaidColor = Color(0xFFDC2626);

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'paid' => (l10n.paid, _paidColor),
      'partial' => (l10n.partialLabel, _partialColor),
      _ => (l10n.unpaid, _unpaidColor),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }
}
