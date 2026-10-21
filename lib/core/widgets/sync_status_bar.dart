import 'package:flutter/material.dart';

import '../locale/l10n.dart';
import '../sync/sync_service.dart';
import '../theme/app_theme.dart';

class SyncStatusBar extends StatelessWidget {
  const SyncStatusBar({super.key, required this.service, this.onSync});

  final SyncService service;

  final VoidCallback? onSync;

  static const _textStyle = TextStyle(color: AppTheme.mutedColor, fontSize: 12);

  static String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        final syncing = service.isSyncing;
        final last = service.lastSyncedAt;

        final Widget status;
        if (syncing) {
          status = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 1.5),
              ),
              const SizedBox(width: 8),
              Text(l10n.syncing, style: _textStyle),
            ],
          );
        } else if (last != null) {
          status = Text(
            l10n.lastSyncAt(_two(last.hour), _two(last.minute)),
            style: _textStyle,
          );
        } else {
          status = Text(l10n.notSyncedYet, style: _textStyle);
        }

        final dirty = service.dirtyCount;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Expanded(child: status),
              if (dirty > 0 && !syncing)
                Container(
                  margin: const EdgeInsetsDirectional.only(end: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD97706).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    l10n.unsyncedCount(dirty),
                    style: const TextStyle(
                        color: Color(0xFFD97706),
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              if (onSync != null)
                IconButton(
                  iconSize: 18,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 24),
                  tooltip: l10n.syncNow,
                  icon: const Icon(Icons.sync),
                  onPressed: syncing ? null : onSync,
                ),
            ],
          ),
        );
      },
    );
  }
}
