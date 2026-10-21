import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/app_logger.dart';
import 'supabase_service.dart';

class StorageService {
  StorageService._();

  static const String bucket = 'load-receipts';

  static String receiptPath(String loadId) => '$loadId.jpg';

  static Future<String?> uploadLoadReceipt(
      String loadId, File imageFile) async {
    try {
      final path = receiptPath(loadId);
      final storage = SupabaseService.client.storage.from(bucket);
      await storage.upload(
        path,
        imageFile,
        fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
      );
      return path;
    } catch (e, st) {
      AppLogger.error('StorageService.uploadLoadReceipt($loadId)', e, st);
      return null;
    }
  }

  static Future<String?> createSignedReceiptUrl(String path) =>
      _createSignedUrl(bucket, path);

  static const String customerPhotosBucket = 'customer-photos';

  static String customerPhotoPath(String customerId, String slot) =>
      '${customerId}_$slot.jpg';

  static Future<String?> uploadCustomerPhoto(
      String customerId, String slot, File imageFile) async {
    try {
      final path = customerPhotoPath(customerId, slot);
      final storage = SupabaseService.client.storage.from(customerPhotosBucket);
      await storage.upload(
        path,
        imageFile,
        fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
      );
      return path;
    } catch (e, st) {
      AppLogger.error(
          'StorageService.uploadCustomerPhoto($customerId,$slot)', e, st);
      return null;
    }
  }

  static Future<String?> createSignedCustomerPhotoUrl(String path) =>
      _createSignedUrl(customerPhotosBucket, path);

  static const String invoicePhotosBucket = 'invoice-photos';

  static String invoicePhotoPath(String invoiceId) => '$invoiceId.jpg';

  static Future<String?> uploadInvoicePhoto(
      String invoiceId, File imageFile) async {
    try {
      final path = invoicePhotoPath(invoiceId);
      final storage = SupabaseService.client.storage.from(invoicePhotosBucket);
      await storage.upload(
        path,
        imageFile,
        fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
      );
      return path;
    } catch (e, st) {
      AppLogger.error('StorageService.uploadInvoicePhoto($invoiceId)', e, st);
      return null;
    }
  }

  static Future<String?> createSignedInvoicePhotoUrl(String path) =>
      _createSignedUrl(invoicePhotosBucket, path);

  static String? normalizeObjectPath(String bucketName, String? value) {
    if (value == null || value.isEmpty) return value;
    if (!value.startsWith('http')) return value;
    final marker = '/$bucketName/';
    final idx = value.indexOf(marker);
    if (idx == -1) return value;
    var path = value.substring(idx + marker.length);
    final query = path.indexOf('?');
    if (query != -1) path = path.substring(0, query);
    return path.isEmpty ? value : path;
  }

  static final Map<String, ({String url, DateTime expiresAt})> _signedCache =
      {};

  static Future<String?> _createSignedUrl(
      String bucketName, String path) async {
    final normalized = normalizeObjectPath(bucketName, path) ?? path;
    if (normalized.startsWith('http')) return normalized;

    final key = '$bucketName/$normalized';
    final cached = _signedCache[key];
    if (cached != null && cached.expiresAt.isAfter(DateTime.now())) {
      return cached.url;
    }
    try {
      final url = await SupabaseService.client.storage
          .from(bucketName)
          .createSignedUrl(normalized, 60 * 60);
      _signedCache[key] = (
        url: url,
        expiresAt: DateTime.now().add(const Duration(minutes: 45)),
      );
      return url;
    } catch (e, st) {
      AppLogger.error(
          'StorageService._createSignedUrl($bucketName/$normalized)', e, st);
      return null;
    }
  }
}
