import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/database/app_database.dart';
import '../../../core/locale/l10n.dart';
import '../../../core/repositories/customer_repository.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/app_utils.dart';
import '../widgets/customer_photo_widgets.dart';

class CustomerFormSheet extends StatefulWidget {
  const CustomerFormSheet({
    super.key,
    this.existing,
    required this.driverId,
    required this.nextRouteOrder,
  });

  final Customer? existing;
  final String driverId;
  final int nextRouteOrder;

  @override
  State<CustomerFormSheet> createState() => _CustomerFormSheetState();
}

class _CustomerFormSheetState extends State<CustomerFormSheet> {
  final _repo = CustomerRepository();
  final _formKey = GlobalKey<FormState>();
  late final String _customerId;
  late final TextEditingController _name;
  late final TextEditingController _address;
  late final TextEditingController _phone;
  late final TextEditingController _creditLimit;
  late final TextEditingController _route;
  final _routeFocus = FocusNode();
  List<String> _routeNames = [];
  String? _photoOutsidePath;
  String? _photoInsidePath;
  String? _photoOutsideUrl;
  String? _photoInsideUrl;
  bool _saving = false;

  static final _phonePattern = RegExp(r'^\+?[0-9][0-9\s\-]{5,14}$');

  @override
  void initState() {
    super.initState();
    final c = widget.existing;
    _customerId = c?.id ?? AppUtils.generateUuid();
    _name = TextEditingController(text: c?.name ?? '');
    _address = TextEditingController(text: c?.address ?? '');
    _phone = TextEditingController(text: c?.phone ?? '');
    _creditLimit = TextEditingController(
        text: c == null || c.creditLimit == 0
            ? ''
            : c.creditLimit.round().toString());
    _route = TextEditingController(text: c?.routeName ?? '');
    _photoOutsidePath = c?.photoOutsidePath;
    _photoInsidePath = c?.photoInsidePath;
    _photoOutsideUrl = c?.photoOutsideUrl;
    _photoInsideUrl = c?.photoInsideUrl;
    _loadRouteNames();
  }

  Future<void> _loadRouteNames() async {
    final driverId = widget.existing?.driverId ?? widget.driverId;
    final names = await _repo.getRouteNames(driverId);
    if (mounted) setState(() => _routeNames = names);
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _phone.dispose();
    _creditLimit.dispose();
    _route.dispose();
    _routeFocus.dispose();
    super.dispose();
  }

  String? _validatePhone(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return l10n.required;
    if (!_phonePattern.hasMatch(value)) {
      return l10n.invalidPhoneNumber;
    }
    return null;
  }

  String? _validateCreditLimit(String? v) {
    final value = v?.trim() ?? '';
    if (value.isEmpty) return null;
    final parsed = int.tryParse(value);
    if (parsed == null) return l10n.wholeNumberOnly;
    if (parsed < 0) return l10n.mustBe0OrMore;
    return null;
  }

  Future<void> _editPhoto(String slot) async {
    final isOutside = slot == 'outside';
    final hasPhoto = isOutside
        ? (_photoOutsidePath != null || _photoOutsideUrl != null)
        : (_photoInsidePath != null || _photoInsideUrl != null);
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
            if (hasPhoto)
              ListTile(
                leading:
                    const Icon(Icons.delete_outline, color: Color(0xFFDC2626)),
                title: Text(l10n.removePhoto),
                onTap: () => Navigator.pop(context, 'remove'),
              ),
          ],
        ),
      ),
    );
    if (action == null || !mounted) return;

    if (action == 'remove') {
      setState(() {
        if (isOutside) {
          _photoOutsidePath = null;
          _photoOutsideUrl = null;
        } else {
          _photoInsidePath = null;
          _photoInsideUrl = null;
        }
      });
      return;
    }

    XFile? picked;
    try {
      picked = await ImagePicker().pickImage(
        source: action == 'camera' ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1200,
      );
    } catch (e, st) {
      AppLogger.error('CustomerFormSheet._editPhoto($slot)', e, st);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.cameraGalleryUnavailable)));
      }
      return;
    }
    if (picked == null || !mounted) return;
    setState(() {
      if (isOutside) {
        _photoOutsidePath = picked!.path;
        _photoOutsideUrl = null;
      } else {
        _photoInsidePath = picked!.path;
        _photoInsideUrl = null;
      }
    });
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final existing = widget.existing;
    final result = await _repo.save(
      id: _customerId,
      name: _name.text.trim(),
      address: _address.text.trim().isEmpty ? null : _address.text.trim(),
      phone: _phone.text.trim(),
      driverId: existing?.driverId ?? widget.driverId,
      routeOrder: existing?.routeOrder ?? widget.nextRouteOrder,
      routeName: _route.text.trim().isEmpty ? null : _route.text.trim(),
      creditLimit: (int.tryParse(_creditLimit.text.trim()) ?? 0).toDouble(),
      photoOutsidePath: _photoOutsidePath,
      photoInsidePath: _photoInsidePath,
      photoOutsideUrl: _photoOutsideUrl,
      photoInsideUrl: _photoInsideUrl,
    );
    if (!mounted) return;
    Navigator.pop(context, true);
    final added = existing == null ? l10n.customerAdded : l10n.customerSaved;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            result == SaveResult.synced ? added : l10n.withOfflineNote(added)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEdit ? l10n.editCustomer : l10n.addCustomer,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _name,
                decoration: InputDecoration(labelText: l10n.name),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.required : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _address,
                decoration: InputDecoration(labelText: l10n.address),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: l10n.phone),
                validator: _validatePhone,
              ),
              const SizedBox(height: 12),
              RawAutocomplete<String>(
                textEditingController: _route,
                focusNode: _routeFocus,
                optionsBuilder: (value) {
                  final q = value.text.trim().toLowerCase();
                  if (q.isEmpty) return _routeNames;
                  return _routeNames.where((n) => n.toLowerCase().contains(q));
                },
                onSelected: (v) => _route.text = v,
                fieldViewBuilder:
                    (context, controller, focusNode, onFieldSubmitted) {
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    onFieldSubmitted: (_) => onFieldSubmitted(),
                    decoration: InputDecoration(labelText: l10n.routeZone),
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: AlignmentDirectional.topStart,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(8),
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(maxHeight: 180, maxWidth: 320),
                        child: ListView(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          children: options
                              .map((o) => ListTile(
                                    dense: true,
                                    title: Text(o),
                                    onTap: () => onSelected(o),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _creditLimit,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.creditLimitAfn),
                validator: _validateCreditLimit,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomerPhotoTile(
                      label: l10n.storeOutside,
                      localPath: _photoOutsidePath,
                      objectPath: _photoOutsideUrl,
                      onTap: _saving ? null : () => _editPhoto('outside'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomerPhotoTile(
                      label: l10n.storeInside,
                      localPath: _photoInsidePath,
                      objectPath: _photoInsideUrl,
                      onTap: _saving ? null : () => _editPhoto('inside'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(l10n.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
