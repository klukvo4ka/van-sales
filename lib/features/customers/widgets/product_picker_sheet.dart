import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/locale/l10n.dart';
import '../../../core/repositories/truck_initial_stock_repository.dart';
import '../../../core/theme/app_theme.dart';

class ProductPickerSheet extends StatefulWidget {
  const ProductPickerSheet({
    super.key,
    required this.products,
    this.categories = const [],
    this.stock = const {},
  });

  final List<Product> products;
  final List<Category> categories;
  final Map<String, RemainingStockRow> stock;

  static Future<Product?> show(
    BuildContext context, {
    required List<Product> products,
    List<Category> categories = const [],
    Map<String, RemainingStockRow> stock = const {},
  }) {
    return showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ProductPickerSheet(
        products: products,
        categories: categories,
        stock: stock,
      ),
    );
  }

  @override
  State<ProductPickerSheet> createState() => _ProductPickerSheetState();
}

class _ProductPickerSheetState extends State<ProductPickerSheet> {
  final _search = TextEditingController();
  String? _categoryId;

  static const _lowColor = Color(0xFFD97706);
  static const _outColor = Color(0xFFDC2626);

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Category> get _usableCategories {
    final used =
        widget.products.map((p) => p.categoryId).whereType<String>().toSet();
    return widget.categories.where((c) => used.contains(c.id)).toList();
  }

  List<Product> get _filtered {
    final q = _search.text.trim().toLowerCase();
    return widget.products.where((p) {
      if (_categoryId != null && p.categoryId != _categoryId) return false;
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) ||
          (p.nameFa ?? '').toLowerCase().contains(q) ||
          (p.sku ?? '').toLowerCase().contains(q);
    }).toList();
  }

  static String _bilingual(String en, String? fa) =>
      fa == null || fa.isEmpty ? en : '$en · $fa';

  static String _qtyText(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  Widget? _stockBadge(Product p) {
    final row = widget.stock[p.id];
    if (row == null) return null;
    final Color color;
    final String label;
    if (row.remaining <= 0) {
      color = _outColor;
      label = l10n.outOfStock;
    } else if (row.remainingRatio < 0.30) {
      color = _lowColor;
      label = l10n.leftLow(_qtyText(row.remaining));
    } else {
      color = AppTheme.mutedColor;
      label = l10n.leftRemaining(_qtyText(row.remaining));
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _categoryChips() {
    final categories = _usableCategories;
    if (categories.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: ChoiceChip(
              label: Text(l10n.all),
              selected: _categoryId == null,
              labelStyle: TextStyle(
                  fontSize: 12,
                  color: _categoryId == null
                      ? Colors.white
                      : AppTheme.primaryColor),
              onSelected: (_) => setState(() => _categoryId = null),
            ),
          ),
          for (final c in categories)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ChoiceChip(
                label: Text(_bilingual(c.name, c.nameFa)),
                selected: _categoryId == c.id,
                labelStyle: TextStyle(
                    fontSize: 12,
                    color: _categoryId == c.id
                        ? Colors.white
                        : AppTheme.primaryColor),
                onSelected: (_) => setState(() => _categoryId = c.id),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(l10n.chooseProduct,
                  style: Theme.of(context).textTheme.titleLarge),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _search,
                autofocus: false,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: l10n.searchNameOrSku,
                  isDense: true,
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _search.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _search.clear();
                            setState(() {});
                          },
                        ),
                ),
              ),
            ),
            _categoryChips(),
            const SizedBox(height: 4),
            const Divider(height: 1),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(l10n.noProductsFound,
                          style: const TextStyle(color: AppTheme.mutedColor)),
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        final p = filtered[i];
                        return ListTile(
                          title: Text(
                            _bilingual(p.name, p.nameFa),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            p.sku == null || p.sku!.isEmpty
                                ? '${p.price.round()} AFN / ${p.unit}'
                                : '${p.price.round()} AFN / ${p.unit} · '
                                    '${p.sku}',
                            style: const TextStyle(
                                color: AppTheme.mutedColor, fontSize: 12),
                          ),
                          trailing: _stockBadge(p) ??
                              const Icon(Icons.add_circle_outline, size: 22),
                          onTap: () => Navigator.pop(context, p),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
