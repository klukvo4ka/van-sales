import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/app_logger.dart';

class InvoiceNotif {
  const InvoiceNotif({
    required this.invoiceId,
    required this.driverName,
    required this.amount,
    required this.receivedAt,
  });

  final String invoiceId;

  final String driverName;
  final double amount;
  final DateTime receivedAt;
}

class NotificationService extends ChangeNotifier {
  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  final List<InvoiceNotif> _notifs = [];
  List<InvoiceNotif> get notifications => List.unmodifiable(_notifs);

  RealtimeChannel? _channel;

  void subscribe(SupabaseClient supabase) {
    try {
      _channel = supabase
          .channel('office_invoices')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'invoices',
            callback: (payload) {
              final row = payload.newRecord;
              _notifs.insert(
                0,
                InvoiceNotif(
                  invoiceId: row['id'] as String? ?? '',
                  driverName: row['driver_id'] as String? ?? '',
                  amount: _toDouble(row['total_amount']),
                  receivedAt: DateTime.now(),
                ),
              );
              _unreadCount++;
              notifyListeners();
            },
          )
          .subscribe();
    } catch (e, st) {
      AppLogger.error('NotificationService.subscribe', e, st);
    }
  }

  static double _toDouble(dynamic value) => value == null
      ? 0
      : value is num
          ? value.toDouble()
          : double.tryParse(value.toString()) ?? 0;

  void markAllRead() {
    if (_unreadCount == 0) return;
    _unreadCount = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    _channel = null;
    super.dispose();
  }
}
