import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/locale/l10n.dart';
import '../../core/repositories/category_repository.dart';
import '../../core/repositories/product_repository.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';

class InventoryTab extends StatefulWidget {
  const InventoryTab({super.key});

  @override
  State<InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends State<InventoryTab> {
  final _repo = ProductRepository();
  final _categoryRepo = CategoryRepository();
  final _searchController = TextEditingController();

  List<Product> _all = [];
  List<Category> _categories = [];
  Map<String, String> _categoryNames = {};
  String _query = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await _loadCategories();
    await _reload();
    await _categoryRepo.syncFromSupabase();
    final ok = await _repo.syncFromSupabase();
    if (mounted) {
      await _loadCategories();
      if (ok) await _reload();
    }
  }

  Future<void> _loadCategories() async {
    final cats = await _categoryRepo.getAll();
    if (mounted) {
      setState(() {
        _categories = cats;
        _categoryNames = {for (final c in cats) c.id: c.name};
      });
    }
  }

  Future<void> _reload() async {
    final items = await _repo.getAll();
    if (mounted) {
      setState(() {
        _all = items;
        _loading = false;
      });
    }
  }

  Future<void> _refresh() async {
    await _categoryRepo.syncFromSupabase();
    final ok = await _repo.syncFromSupabase();
    await _loadCategories();
    await _reload();
    if (!ok && mounted) {
      _snack(l10n.couldNotReachServer);
    }
  }

  List<Product> get _filtered {
    if (_query.isEmpty) return _all;
    final q = _query.toLowerCase();
    return _all.where((p) {
      return p.name.toLowerCase().contains(q) ||
          (p.nameFa?.toLowerCase().contains(q) ?? false) ||
          (p.sku?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  Future<void> _openSheet({Product? existing}) async {
    final result = await showModalBottomSheet<ProductSaveResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          _ProductSheet(existing: existing, categories: _categories),
    );
    if (result == null) return;
    await _reload();
    if (!mounted) return;
    _snack(result == ProductSaveResult.synced
        ? l10n.productSaved
        : l10n.savedLocallyOffline);
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.accentColor,
        onPressed: () => _openSheet(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v.trim()),
              decoration: InputDecoration(
                hintText: l10n.searchNameOrSku,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: _buildList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final items = _filtered;
    if (items.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          const Icon(Icons.inventory_2_outlined,
              size: 56, color: Colors.black26),
          const SizedBox(height: 12),
          Text(
            l10n.noProductsYet,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, fontSize: 16),
          ),
        ],
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: items.length,
      itemBuilder: (context, i) => _ProductCard(
        product: items[i],
        categoryName: _categoryNames[items[i].categoryId],
        onTap: () => _openSheet(existing: items[i]),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.onTap,
    this.categoryName,
  });
  final Product product;
  final VoidCallback onTap;
  final String? categoryName;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onTap,
        title: Row(
          children: [
            Expanded(
              child: Text(
                product.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            _ActiveBadge(active: product.isActive),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.nameFa != null && product.nameFa!.isNotEmpty)
              Text(product.nameFa!),
            if (categoryName != null && categoryName!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: _CategoryChip(label: categoryName!),
              ),
            const SizedBox(height: 2),
            Text(
              [
                if (product.sku != null && product.sku!.isNotEmpty)
                  'SKU: ${product.sku}',
                '${product.price.toStringAsFixed(0)} AFN / ${product.unit}',
              ].join('   •   '),
              style: const TextStyle(color: AppTheme.mutedColor, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveBadge extends StatelessWidget {
  const _ActiveBadge({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.green : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: Text(
        active ? l10n.active : l10n.inactive,
        style: TextStyle(
            color: color.shade700, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: Text(
        label,
        style: const TextStyle(
            color: Colors.black54, fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _ProductSheet extends StatefulWidget {
  const _ProductSheet({this.existing, required this.categories});
  final Product? existing;
  final List<Category> categories;

  @override
  State<_ProductSheet> createState() => _ProductSheetState();
}

class _ProductSheetState extends State<_ProductSheet> {
  static const _units = ['carton', 'bag', 'pcs', 'kg', 'box'];

  final _repo = ProductRepository();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _nameFaController;
  late final TextEditingController _skuController;
  late final TextEditingController _priceController;
  late String _unit;
  String? _categoryId;
  late bool _active;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _nameController = TextEditingController(text: p?.name ?? '');
    _nameFaController = TextEditingController(text: p?.nameFa ?? '');
    _skuController = TextEditingController(text: p?.sku ?? '');
    _priceController = TextEditingController(
        text: p == null ? '' : p.price.toStringAsFixed(2));
    _unit = p?.unit ?? 'pcs';
    _categoryId = widget.categories.any((c) => c.id == p?.categoryId)
        ? p?.categoryId
        : null;
    _active = p?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFaController.dispose();
    _skuController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  List<String> get _unitOptions =>
      _units.contains(_unit) ? _units : [_unit, ..._units];

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final result = await _repo.save(
      id: widget.existing?.id ?? AppUtils.generateUuid(),
      name: _nameController.text.trim(),
      nameFa: _nameFaController.text.trim().isEmpty
          ? null
          : _nameFaController.text.trim(),
      sku: _skuController.text.trim().isEmpty
          ? null
          : _skuController.text.trim(),
      unit: _unit,
      price: double.tryParse(_priceController.text.trim()) ?? 0,
      categoryId: _categoryId,
      isActive: _active,
    );

    if (mounted) Navigator.of(context).pop(result);
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
                isEdit ? l10n.editProduct : l10n.addProduct,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: l10n.nameEn),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.required : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameFaController,
                decoration: InputDecoration(labelText: l10n.nameDari),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _skuController,
                decoration: const InputDecoration(labelText: 'SKU'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                initialValue: _categoryId,
                decoration: InputDecoration(labelText: l10n.category),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(l10n.noCategory),
                  ),
                  ...widget.categories.map((c) => DropdownMenuItem<String?>(
                        value: c.id,
                        child: Text(c.name),
                      )),
                ],
                onChanged: (v) => setState(() => _categoryId = v),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _unit,
                      decoration: InputDecoration(labelText: l10n.unit),
                      items: _unitOptions
                          .map(
                              (u) => DropdownMenuItem(value: u, child: Text(u)))
                          .toList(),
                      onChanged: (v) => setState(() => _unit = v ?? _unit),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: l10n.price),
                      validator: (v) {
                        final value = double.tryParse((v ?? '').trim());
                        if (value == null) return l10n.numberLabel;
                        if (value < 0) return '≥ 0';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.active),
                value: _active,
                activeThumbColor: AppTheme.accentColor,
                onChanged: (v) => setState(() => _active = v),
              ),
              const SizedBox(height: 8),
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
