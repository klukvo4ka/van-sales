import 'package:flutter/material.dart';

import '../../../core/locale/l10n.dart';

class InvoicesTab extends StatelessWidget {
  const InvoicesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        const Icon(Icons.receipt_long_outlined,
            size: 56, color: Colors.black26),
        const SizedBox(height: 12),
        Text(
          l10n.noInvoicesYet,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black54, fontSize: 16),
        ),
      ],
    );
  }
}
