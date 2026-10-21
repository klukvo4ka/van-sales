import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/locale/l10n.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_theme.dart';

typedef PhotoUrlResolver = Future<String?> Function(String objectPath);

void openCustomerPhotoViewer(
    BuildContext context, String title, String? localPath, String? objectPath) {
  final hasLocal =
      localPath != null && localPath.isNotEmpty && File(localPath).existsSync();
  final hasRemote = objectPath != null && objectPath.isNotEmpty;
  if (!hasLocal && !hasRemote) return;
  Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => CustomerPhotoViewer(
        title: title,
        localPath: hasLocal ? localPath : null,
        objectPath: objectPath,
      ),
    ),
  );
}

class CustomerPhotoTile extends StatelessWidget {
  const CustomerPhotoTile({
    super.key,
    required this.label,
    required this.localPath,
    required this.objectPath,
    this.onTap,
  });

  final String label;
  final String? localPath;
  final String? objectPath;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasLocal = localPath != null &&
        localPath!.isNotEmpty &&
        File(localPath!).existsSync();
    final hasRemote = objectPath != null && objectPath!.isNotEmpty;

    Widget content;
    if (hasLocal) {
      content = Image.file(File(localPath!), fit: BoxFit.cover);
    } else if (hasRemote) {
      content = SignedCustomerPhoto(objectPath: objectPath!);
    } else {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_a_photo_outlined, color: AppTheme.mutedColor),
          const SizedBox(height: 6),
          Text(l10n.addPhoto,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.mutedColor, fontSize: 11)),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppTheme.mutedColor, fontSize: 12)),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
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
            child: content,
          ),
        ),
      ],
    );
  }
}

class SignedCustomerPhoto extends StatefulWidget {
  const SignedCustomerPhoto({
    super.key,
    required this.objectPath,
    this.fit = BoxFit.cover,
    this.resolver,
  });

  final String objectPath;
  final BoxFit fit;
  final PhotoUrlResolver? resolver;

  @override
  State<SignedCustomerPhoto> createState() => _SignedCustomerPhotoState();
}

class _SignedCustomerPhotoState extends State<SignedCustomerPhoto> {
  late Future<String?> _urlFuture;

  @override
  void initState() {
    super.initState();
    _urlFuture = _resolve();
  }

  @override
  void didUpdateWidget(SignedCustomerPhoto oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.objectPath != widget.objectPath ||
        oldWidget.resolver != widget.resolver) {
      _urlFuture = _resolve();
    }
  }

  Future<String?> _resolve() {
    final resolve =
        widget.resolver ?? StorageService.createSignedCustomerPhotoUrl;
    return resolve(widget.objectPath);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _urlFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
              child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2)));
        }
        final url = snapshot.data;
        if (url == null || url.isEmpty) return const _PhotoUnavailable();
        return Image.network(
          url,
          fit: widget.fit,
          errorBuilder: (_, __, ___) => const _PhotoUnavailable(),
          loadingBuilder: (context, child, progress) => progress == null
              ? child
              : const Center(
                  child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2))),
        );
      },
    );
  }
}

class _PhotoUnavailable extends StatelessWidget {
  const _PhotoUnavailable();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.broken_image_outlined, color: AppTheme.mutedColor),
          const SizedBox(height: 4),
          Text(l10n.photoUnavailable,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.mutedColor, fontSize: 10)),
        ],
      ),
    );
  }
}

class CustomerPhotoViewer extends StatelessWidget {
  const CustomerPhotoViewer({
    super.key,
    required this.title,
    required this.localPath,
    required this.objectPath,
    this.resolver,
  });

  final String title;
  final String? localPath;
  final String? objectPath;
  final PhotoUrlResolver? resolver;

  @override
  Widget build(BuildContext context) {
    final Widget image;
    if (localPath != null && localPath!.isNotEmpty) {
      image = Image.file(File(localPath!), fit: BoxFit.contain);
    } else if (objectPath != null && objectPath!.isNotEmpty) {
      image = SignedCustomerPhoto(
          objectPath: objectPath!, fit: BoxFit.contain, resolver: resolver);
    } else {
      image = const _PhotoUnavailable();
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(title, style: const TextStyle(fontSize: 16)),
      ),
      body: Center(
        child: InteractiveViewer(
          maxScale: 5,
          child: image,
        ),
      ),
    );
  }
}
