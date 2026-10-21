import 'package:flutter_test/flutter_test.dart';

import 'package:van_sales/core/services/storage_service.dart';
import 'package:van_sales/core/sync/sync_policy.dart';

void main() {
  group('SyncPolicy.shouldApplyServerRow', () {
    final older = DateTime.utc(2026, 7, 1, 10);
    final newer = DateTime.utc(2026, 7, 1, 12);

    test('missing local row is always applied', () {
      expect(SyncPolicy.shouldApplyServerRow(localExists: false), isTrue);
    });

    test('dirty local row is never overwritten', () {
      expect(
        SyncPolicy.shouldApplyServerRow(
          localExists: true,
          localDirty: true,
          localUpdatedAt: older,
          serverUpdatedAt: newer,
        ),
        isFalse,
      );
    });

    test('newer server row overwrites clean local', () {
      expect(
        SyncPolicy.shouldApplyServerRow(
          localExists: true,
          localUpdatedAt: older,
          serverUpdatedAt: newer,
        ),
        isTrue,
      );
    });

    test('older server row does not overwrite newer local', () {
      expect(
        SyncPolicy.shouldApplyServerRow(
          localExists: true,
          localUpdatedAt: newer,
          serverUpdatedAt: older,
        ),
        isFalse,
      );
    });

    test('equal timestamps apply the server copy', () {
      expect(
        SyncPolicy.shouldApplyServerRow(
          localExists: true,
          localUpdatedAt: newer,
          serverUpdatedAt: newer,
        ),
        isTrue,
      );
    });

    test('compares across time zones on the UTC axis', () {
      final localWallClock = DateTime(2026, 7, 1, 14);
      final serverSameInstantUtc = localWallClock.toUtc();
      expect(
        SyncPolicy.shouldApplyServerRow(
          localExists: true,
          localUpdatedAt: localWallClock,
          serverUpdatedAt: serverSameInstantUtc,
        ),
        isTrue,
      );
    });
  });

  group('SyncPolicy.shouldPushLocalRow', () {
    final older = DateTime.utc(2026, 7, 1, 10);
    final newer = DateTime.utc(2026, 7, 1, 12);

    test('older local edit does not clobber newer server row', () {
      expect(
        SyncPolicy.shouldPushLocalRow(
          localUpdatedAt: older,
          serverUpdatedAt: newer,
        ),
        isFalse,
      );
    });

    test('newer local edit pushes over older server row', () {
      expect(
        SyncPolicy.shouldPushLocalRow(
          localUpdatedAt: newer,
          serverUpdatedAt: older,
        ),
        isTrue,
      );
    });

    test('row missing on server is pushed', () {
      expect(
        SyncPolicy.shouldPushLocalRow(
          localUpdatedAt: newer,
          serverUpdatedAt: null,
        ),
        isTrue,
      );
    });
  });

  group('StorageService.normalizeObjectPath', () {
    test('plain object path passes through', () {
      expect(
        StorageService.normalizeObjectPath('invoice-photos', 'abc123.jpg'),
        'abc123.jpg',
      );
    });

    test('expired signed URL converts to object path', () {
      const url = 'https://example.supabase.co/storage/v1/object/sign/'
          'invoice-photos/abc123.jpg?token=EXPIRED';
      expect(
        StorageService.normalizeObjectPath('invoice-photos', url),
        'abc123.jpg',
      );
    });

    test('public storage URL converts to object path', () {
      const url = 'https://example.supabase.co/storage/v1/object/public/'
          'customer-photos/cust1_outside.jpg';
      expect(
        StorageService.normalizeObjectPath('customer-photos', url),
        'cust1_outside.jpg',
      );
    });

    test('nested object path keeps subfolders', () {
      const url = 'https://example.supabase.co/storage/v1/object/sign/'
          'load-receipts/2026/07/load1.jpg?token=x';
      expect(
        StorageService.normalizeObjectPath('load-receipts', url),
        '2026/07/load1.jpg',
      );
    });

    test('foreign http URL is left unchanged', () {
      const url = 'https://example.com/some/image.jpg';
      expect(
        StorageService.normalizeObjectPath('invoice-photos', url),
        url,
      );
    });

    test('null and empty pass through', () {
      expect(StorageService.normalizeObjectPath('b', null), isNull);
      expect(StorageService.normalizeObjectPath('b', ''), '');
    });
  });
}
