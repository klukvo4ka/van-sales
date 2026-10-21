import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/database/app_database.dart';
import '../../../core/locale/l10n.dart';
import '../../../core/repositories/customer_repository.dart' show SaveResult;
import '../../../core/repositories/invoice_repository.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_logger.dart';
import 'customer_photo_widgets.dart';

Future<String?> pickInvoicePhoto(BuildContext context) async {
  final action = await showModalBottomSheet<String>(
    context: context,
    builder: (_) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(l10n.camera),
            onTap: () => Navigator.pop(context, 'camera'),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(l10n.gallery),
            onTap: () => Navigator.pop(context, 'gallery'),
          ),
        ],
      ),
    ),
  );
  if (action == null) return null;
  try {
    final picked = await ImagePicker().pickImage(
      source: action == 'camera' ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1200,
    );
    return picked?.path;
  } catch (e, st) {
    AppLogger.error('pickInvoicePhoto', e, st);
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.cameraGalleryUnavailable)));
    }
    return null;
  }
}

Future<Invoice?> attachInvoicePhotoFlow(
  BuildContext context,
  InvoiceRepository repo,
  Invoice invoice,
) async {
  final path = await pickInvoicePhoto(context);
  if (path == null) return null;
  final result = await repo.attachPhoto(invoice.id, path);
  final fresh = await repo.getById(invoice.id);
  if (context.mounted) {
    final attached = l10n.photoAttached;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(result == SaveResult.synced
          ? attached
          : l10n.withOfflineNote(attached)),
    ));
  }
  return fresh;
}

class InvoicePhotoThumb extends StatelessWidget {
  const InvoicePhotoThumb({
    super.key,
    required this.localPath,
    required this.objectPath,
  });

  final String? localPath;
  final String? objectPath;

  @override
  Widget build(BuildContext context) {
    final hasLocal = localPath != null &&
        localPath!.isNotEmpty &&
        File(localPath!).existsSync();
    final hasRemote = objectPath != null && objectPath!.isNotEmpty;
    if (!hasLocal && !hasRemote) return const SizedBox.shrink();

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => CustomerPhotoViewer(
            title: l10n.invoicePhoto,
            localPath: hasLocal ? localPath : null,
            objectPath: objectPath,
            resolver: StorageService.createSignedInvoicePhotoUrl,
          ),
        ),
      ),
      borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      child: Container(
        height: 96,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppTheme.borderColor),
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
        child: hasLocal
            ? Image.file(File(localPath!), fit: BoxFit.cover)
            : SignedCustomerPhoto(
                objectPath: objectPath!,
                resolver: StorageService.createSignedInvoicePhotoUrl,
              ),
      ),
    );
  }
}
