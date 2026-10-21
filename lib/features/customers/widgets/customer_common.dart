import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';

String customerInitials(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '?';
  final parts = trimmed.split(RegExp(r'\s+'));
  return parts.take(2).map((p) => p.characters.first.toUpperCase()).join();
}

Future<void> callPhone(String phone) async {
  final uri = Uri(scheme: 'tel', path: phone);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}

class RouteBadge extends StatelessWidget {
  const RouteBadge({super.key, required this.order});
  final int order;

  @override
  Widget build(BuildContext context) {
    if (order <= 0) return const SizedBox.shrink();
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Text('$order',
          style: const TextStyle(
              color: AppTheme.accentColor,
              fontWeight: FontWeight.bold,
              fontSize: 13)),
    );
  }
}
