import 'package:flutter/material.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/database/app_database.dart';
import '../../../core/locale/l10n.dart';
import '../../../core/repositories/category_repository.dart';
import '../../../core/repositories/customer_repository.dart'
    show CustomerRepository, SaveResult;
import '../../../core/repositories/invoice_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../widgets/invoice_photo_widgets.dart';
import '../widgets/invoice_status_badge.dart';
import '../widgets/product_picker_sheet.dart';
import 'invoice_pdf_screen.dart';
import 'payment_sheet.dart';

class InvoiceDetailScreen extends StatefulWidget {
  const InvoiceDetailScreen({super.key, required this.invoice});

  final Invoice invoice;

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  final _repo = InvoiceRepository();

  late Invoice _invoice;
  Customer? _customer;
  List<InvoiceItemWithProduct> _items = [];
  List<_DraftLine> _draft = [];
  bool _loading = true;
  bool _editing = false;
  bool _saving = false;
  bool _attaching = false;
  bool _isOffice = false;
  bool _roleReady = false;

  static const _dueColor = Color(0xFFDC2626);

  @override
  void initState() {
    super.initState();
    _invoice = widget.invoice;
    AuthService.getUserRole().then((role) {
      if (mounted) {
        setState(() {
          _isOffice =
              role == AuthService.roleOffice || role == AuthService.roleAdmin;
          _roleReady = true;
        });
      }
    });
    _reload();
  }

  @override
  void dispose() {
    _disposeDraft();
    super.dispose();
  }

  void _disposeDraft() {
    for (final line in _draft) {
      line.dispose();
    }
    _draft = [];
  }

  Future<void> _reload() async {
    final fresh = await _repo.getById(_invoice.id);
    final items = await _repo.getItems(_invoice.id);
    final customer = await CustomerRepository().getById(_invoice.customerId);
    if (mounted) {
      setState(() {
        if (fresh != null) _invoice = fresh;
        _customer = customer;
        _items = items;
        _loading = false;
      });
    }
  }

  Future<void> _addPayment() async {
    final customer = _customer;
    if (customer == null) return;
    final due = _invoice.totalAmount - _invoice.paidAmount;
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => PaymentSheet(
        customer: customer,
        outstanding: due < 0 ? 0 : due,
        invoice: _invoice,
      ),
    );
    if (saved == true) await _reload();
  }

  String get _number =>
      _invoice.invoiceNumber ?? '#${_invoice.id.substring(0, 8).toUpperCase()}';

  void _startEdit() {
    _disposeDraft();
    setState(() {
      _draft = _items.map(_DraftLine.fromItem).toList();
      _editing = true;
    });
  }

  void _cancelEdit() {
    _disposeDraft();
    setState(() => _editing = false);
  }

  double get _draftTotal =>
      _draft.fold<double>(0, (sum, l) => sum + l.lineTotal);

  Future<void> _addLine() async {
    final products = await _repo.getActiveProducts();
    final categories = await CategoryRepository().getAll();
    if (!mounted) return;
    if (products.isEmpty) {
      _snack(l10n.noProductsAvailable);
      return;
    }
    final picked = await ProductPickerSheet.show(
      context,
      products: products,
      categories: categories,
    );
    if (picked == null || !mounted) return;
    final existing = _draft.where((l) => l.productId == picked.id).toList();
    setState(() {
      if (existing.isEmpty) {
        _draft.add(_DraftLine.fromProduct(picked));
      } else {
        final line = existing.first;
        line.qtyController.text = '${line.quantity.round() + 1}';
      }
    });
  }

  void _removeLine(int index) {
    final line = _draft[index];
    setState(() => _draft.removeAt(index));
    line.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    for (final line in _draft) {
      if (line.quantity <= 0) {
        _snack(l10n.quantityMustBeMoreThan);
        return;
      }
      if (line.unitPrice < 0) {
        _snack(l10n.invalidPrice);
        return;
      }
    }
    setState(() => _saving = true);
    final inputs = _draft
        .map((l) => InvoiceItemInput(
              id: l.id,
              productId: l.productId,
              quantity: l.quantity,
              unitPrice: l.unitPrice,
            ))
        .toList();
    final result = await _repo.saveItems(invoice: _invoice, items: inputs);
    if (!mounted) return;
    _disposeDraft();
    setState(() {
      _editing = false;
      _saving = false;
    });
    await _reload();
    if (!mounted) return;
    final updated = l10n.stockUpdated;
    _snack(
        result == SaveResult.synced ? updated : l10n.withOfflineNote(updated));
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  bool get _hasPhoto =>
      (_invoice.photoPath != null && _invoice.photoPath!.isNotEmpty) ||
      (_invoice.photoUrl != null && _invoice.photoUrl!.isNotEmpty);

  void _openPdf() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => InvoicePdfScreen(invoice: _invoice),
      ),
    );
  }

  Future<void> _attachPhoto() async {
    if (_attaching) return;
    setState(() => _attaching = true);
    final fresh = await attachInvoicePhotoFlow(context, _repo, _invoice);
    if (mounted) {
      setState(() {
        if (fresh != null) _invoice = fresh;
        _attaching = false;
      });
    }
  }

  Widget _documentsRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _openPdf,
                icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
                label: Text(l10n.pdfLabel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _attaching ? null : _attachPhoto,
                icon: _attaching
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : const Icon(Icons.add_a_photo_outlined, size: 20),
                label: Text(_hasPhoto ? l10n.replace : l10n.photo),
              ),
            ),
          ],
        ),
        if (_hasPhoto) ...[
          const SizedBox(height: 10),
          InvoicePhotoThumb(
            localPath: _invoice.photoPath,
            objectPath: _invoice.photoUrl,
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.invoiceTitleWithNumber(_number),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16)),
        actions: [
          if (!_editing && !_loading && _roleReady && !_isOffice)
            IconButton(
              onPressed: _startEdit,
              tooltip: l10n.edit,
              icon: const Icon(Icons.edit_outlined),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _editing
              ? _editView()
              : _readView(),
    );
  }

  Widget _readView() {
    final due = _invoice.totalAmount - _invoice.paidAmount;
    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppTheme.screenPadding),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_number,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      InvoiceStatusBadge(status: _invoice.status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.dateLabel(AppUtils.formatDate(_invoice.invoiceDate)),
                    style: const TextStyle(
                        color: AppTheme.mutedColor, fontSize: 13),
                  ),
                  const Divider(height: 20),
                  _totalRow(l10n.total, '${_invoice.totalAmount.round()} AFN'),
                  const SizedBox(height: 4),
                  _totalRow(l10n.paid, '${_invoice.paidAmount.round()} AFN'),
                  const SizedBox(height: 4),
                  _totalRow(
                    l10n.due,
                    '${(due < 0 ? 0 : due).round()} AFN',
                    color: due > 0 ? _dueColor : null,
                    bold: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _documentsRow(),
          if (due > 0 && _roleReady && !_isOffice) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _customer == null ? null : _addPayment,
                icon: const Icon(Icons.payments_outlined, size: 20),
                label: Text(l10n.addPayment),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(l10n.items,
              style: const TextStyle(
                  color: AppTheme.mutedColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (_items.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Text(
                l10n.noItems,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
            ),
          ..._items.map(_itemCard),
        ],
      ),
    );
  }

  Widget _totalRow(String label, String value,
      {Color? color, bool bold = false}) {
    final style = TextStyle(
      color: color ?? Colors.black87,
      fontSize: bold ? 15 : 14,
      fontWeight: bold ? FontWeight.bold : FontWeight.w500,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text(label, style: style), Text(value, style: style)],
    );
  }

  Widget _itemCard(InvoiceItemWithProduct row) {
    final item = row.item;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        dense: true,
        title: Text(row.productName,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${_qty(item.quantity)} ${row.unit} × ${item.unitPrice.round()} AFN',
          style: const TextStyle(color: AppTheme.mutedColor, fontSize: 13),
        ),
        trailing: Text('${item.total.round()} AFN',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }

  static String _qty(double q) =>
      q == q.roundToDouble() ? '${q.round()}' : '$q';

  Widget _editView() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppTheme.screenPadding),
            children: [
              for (var i = 0; i < _draft.length; i++) _draftCard(i),
              const SizedBox(height: 4),
              OutlinedButton.icon(
                onPressed: _saving ? null : _addLine,
                icon: const Icon(Icons.add),
                label: Text(l10n.addItem),
              ),
            ],
          ),
        ),
        SafeArea(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppTheme.borderColor)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.totalAfn(_draftTotal.round()),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                TextButton(
                  onPressed: _saving ? null : _cancelEdit,
                  child: Text(l10n.cancel),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Icon(Icons.save_outlined, size: 18),
                  label: Text(l10n.save),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _draftCard(int index) {
    final line = _draft[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(line.name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                Text('${line.lineTotal.round()} AFN',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                IconButton(
                  onPressed: _saving ? null : () => _removeLine(index),
                  tooltip: l10n.remove,
                  icon: const Icon(Icons.delete_outline,
                      size: 20, color: Color(0xFFDC2626)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: line.qtyController,
                    keyboardType: TextInputType.number,
                    enabled: !_saving,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: l10n.qtyWithUnit(line.unit),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: line.priceController,
                    keyboardType: TextInputType.number,
                    enabled: !_saving,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: l10n.priceAfn,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DraftLine {
  _DraftLine({
    required this.id,
    required this.productId,
    required this.name,
    required this.unit,
    required double quantity,
    required double unitPrice,
  })  : qtyController = TextEditingController(
            text:
                quantity == 0 ? '' : _InvoiceDetailScreenState._qty(quantity)),
        priceController = TextEditingController(
            text: unitPrice == 0 ? '' : '${unitPrice.round()}');

  factory _DraftLine.fromItem(InvoiceItemWithProduct row) => _DraftLine(
        id: row.item.id,
        productId: row.item.productId,
        name: row.productName,
        unit: row.unit,
        quantity: row.item.quantity,
        unitPrice: row.item.unitPrice,
      );

  factory _DraftLine.fromProduct(Product p) => _DraftLine(
        id: AppUtils.generateUuid(),
        productId: p.id,
        name: p.name,
        unit: p.unit,
        quantity: 1,
        unitPrice: p.price,
      );

  final String id;
  final String productId;
  final String name;
  final String unit;
  final TextEditingController qtyController;
  final TextEditingController priceController;

  double get quantity =>
      (int.tryParse(qtyController.text.trim()) ?? 0).toDouble();

  double get unitPrice =>
      (int.tryParse(priceController.text.trim()) ?? 0).toDouble();

  double get lineTotal => quantity * unitPrice;

  void dispose() {
    qtyController.dispose();
    priceController.dispose();
  }
}
