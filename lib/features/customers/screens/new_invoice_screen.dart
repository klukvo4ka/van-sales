import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/database/app_database.dart';
import '../../../core/locale/l10n.dart';
import '../../../core/repositories/category_repository.dart';
import '../../../core/repositories/customer_repository.dart'
    show CustomerRepository, SaveResult;
import '../../../core/repositories/invoice_repository.dart';
import '../../../core/repositories/truck_initial_stock_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../widgets/product_picker_sheet.dart';
import 'invoice_success_screen.dart';

class NewInvoiceScreen extends StatefulWidget {
  const NewInvoiceScreen({super.key, required this.customer});

  final Customer customer;

  @override
  State<NewInvoiceScreen> createState() => _NewInvoiceScreenState();
}

class _LineDraft {
  _LineDraft(this.product)
      : qty = TextEditingController(text: '1'),
        price = TextEditingController(text: product.price.round().toString());

  final Product product;
  final TextEditingController qty;
  final TextEditingController price;

  int get qtyValue => int.tryParse(qty.text.trim()) ?? 0;
  int get priceValue => int.tryParse(price.text.trim()) ?? -1;
  bool get valid => qtyValue > 0 && priceValue >= 0;
  int get total => valid ? qtyValue * priceValue : 0;

  void dispose() {
    qty.dispose();
    price.dispose();
  }
}

class _NewInvoiceScreenState extends State<NewInvoiceScreen> {
  final _repo = InvoiceRepository();
  final _stockRepo = TruckInitialStockRepository();

  String _driverId = '';
  String _invoiceNumber = '';
  List<Product> _products = [];
  List<Category> _categories = [];
  Map<String, RemainingStockRow> _stock = {};
  final List<_LineDraft> _lines = [];
  final _paidCtrl = TextEditingController();
  String _method = 'cash';
  String _payMethod = 'cash';
  double _outstanding = 0;
  double _creditLimit = 0;
  bool _loading = true;
  bool _saving = false;
  bool _confirmingLimit = false;

  static const _warnColor = Color(0xFFD97706);
  static const _removeColor = Color(0xFFDC2626);

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    for (final l in _lines) {
      l.dispose();
    }
    _paidCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    _driverId = AuthService().currentUser?.id ?? '';
    final number = await _repo.nextInvoiceNumber(_driverId);
    final products = await _repo.getActiveProducts();
    final categories = await CategoryRepository().getAll();
    final customerRepo = CustomerRepository();
    final summary = await customerRepo.getDebtSummary(widget.customer.id);
    final fresh = await customerRepo.getById(widget.customer.id);
    final truckId = await _stockRepo.truckIdForDriver(_driverId);
    final stock = <String, RemainingStockRow>{};
    if (truckId.isNotEmpty) {
      final rows = await _stockRepo.getRemainingStock(_driverId, truckId);
      for (final r in rows) {
        stock[r.productId] = r;
      }
    }
    if (mounted) {
      setState(() {
        _invoiceNumber = number;
        _products = products;
        _categories = categories;
        _outstanding = summary.outstanding;
        _creditLimit = fresh?.creditLimit ?? widget.customer.creditLimit;
        _stock = stock;
        _loading = false;
      });
    }
  }

  bool get _canSave =>
      _lines.isNotEmpty &&
      _lines.every((l) => l.valid) &&
      (_method != 'partial' || _partialValid);

  int get _paidNow => int.tryParse(_paidCtrl.text.trim()) ?? 0;

  bool get _partialValid => _paidNow > 0 && _paidNow < _total;

  int get _total => _lines.fold<int>(0, (sum, l) => sum + l.total);

  int get _totalQty => _lines.fold<int>(0, (sum, l) => sum + l.qtyValue);

  static String _qtyText(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  Future<void> _addLine() async {
    final chosen = await ProductPickerSheet.show(
      context,
      products: _products,
      categories: _categories,
      stock: _stock,
    );
    if (chosen == null || !mounted) return;
    final existing = _lines.where((l) => l.product.id == chosen.id).toList();
    setState(() {
      if (existing.isEmpty) {
        _lines.add(_LineDraft(chosen));
      } else {
        final line = existing.first;
        line.qty.text = '${line.qtyValue + 1}';
      }
    });
  }

  void _removeLine(_LineDraft line) {
    _lines.remove(line);
    line.dispose();
    setState(() {});
  }

  void _bumpQty(_LineDraft line, int delta) {
    final next = line.qtyValue + delta;
    line.qty.text = '${next < 1 ? 1 : next}';
    setState(() {});
  }

  Future<void> _save() async {
    if (_saving || _confirmingLimit || !_canSave) return;
    final cash = _method == 'cash';
    if (!cash && _overLimit) {
      setState(() => _confirmingLimit = true);
      final confirmed = await _confirmOverLimit();
      if (mounted) setState(() => _confirmingLimit = false);
      if (!confirmed || !mounted) return;
    }
    setState(() => _saving = true);
    final items = _lines
        .map((l) => InvoiceItemInput(
              id: AppUtils.generateUuid(),
              productId: l.product.id,
              quantity: l.qtyValue.toDouble(),
              unitPrice: l.priceValue.toDouble(),
            ))
        .toList();
    final total = _total;
    final partial = _method == 'partial';
    final paidNow = partial ? _paidNow : 0;

    CreateInvoiceResult created;
    try {
      created = await _repo.create(
        customerId: widget.customer.id,
        driverId: _driverId,
        invoiceNumber: _invoiceNumber,
        items: items,
        cashSale: cash,
        paidNow: paidNow.toDouble(),
        paymentMethod: _payMethod,
      );
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.saveFailed)),
        );
      }
      return;
    }

    if (!mounted) return;
    final message = switch (_method) {
      'cash' => l10n.cashSaleAfn(total),
      'partial' => l10n.partialPaymentAfn(paidNow),
      _ => l10n.creditSaleAfn(total),
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(created.result == SaveResult.synced
          ? message
          : l10n.withOfflineNote(message)),
    ));
    await Navigator.pushReplacement<void, bool>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => InvoiceSuccessScreen(
          invoice: created.invoice,
          customer: widget.customer,
          cashSale: cash,
        ),
      ),
      result: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newInvoice, style: const TextStyle(fontSize: 16)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(AppTheme.screenPadding),
                    children: [
                      _headerCard(),
                      const SizedBox(height: 12),
                      for (final line in _lines) _lineCard(line),
                      _addButton(),
                      const SizedBox(height: 12),
                      _paymentCard(),
                    ],
                  ),
                ),
                _summaryBar(),
              ],
            ),
    );
  }

  Widget _headerCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.customer.name,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_invoiceNumber,
                    style: const TextStyle(
                        color: AppTheme.mutedColor, fontSize: 13)),
                Text(AppUtils.formatDate(DateTime.now()),
                    style: const TextStyle(
                        color: AppTheme.mutedColor, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _lineCard(_LineDraft line) {
    final p = line.product;
    final row = _stock[p.id];
    final over = row != null && line.qtyValue > row.remaining;
    return Dismissible(
      key: ValueKey(p.id),
      direction: _saving ? DismissDirection.none : DismissDirection.endToStart,
      onDismissed: (_) => _removeLine(line),
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsetsDirectional.only(end: 20),
        alignment: AlignmentDirectional.centerEnd,
        decoration: BoxDecoration(
          color: _removeColor,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 4, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      p.nameFa == null || p.nameFa!.isEmpty
                          ? p.name
                          : '${p.name} · ${p.nameFa}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: _saving ? null : () => _removeLine(line),
                    tooltip: l10n.remove,
                    icon: const Icon(Icons.delete_outline,
                        size: 20, color: _removeColor),
                  ),
                ],
              ),
              if (row != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    over
                        ? l10n.onlyLeft(_qtyText(row.remaining), p.unit)
                        : l10n.leftWithUnit(_qtyText(row.remaining), p.unit),
                    style: TextStyle(
                      color: over ? _warnColor : AppTheme.mutedColor,
                      fontSize: 12,
                      fontWeight: over ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: Row(
                  children: [
                    _stepButton(
                      Icons.remove,
                      enabled: !_saving && line.qtyValue > 1,
                      onTap: () => _bumpQty(line, -1),
                    ),
                    SizedBox(
                      width: 56,
                      child: TextField(
                        controller: line.qty,
                        enabled: !_saving,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 10),
                          enabledBorder: over
                              ? OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.borderRadius),
                                  borderSide:
                                      const BorderSide(color: _warnColor),
                                )
                              : null,
                        ),
                      ),
                    ),
                    _stepButton(
                      Icons.add,
                      enabled: !_saving,
                      onTap: () => _bumpQty(line, 1),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: line.price,
                        enabled: !_saving,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: l10n.price,
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('${line.total} AFN',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepButton(
    IconData icon, {
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        width: 36,
        height: 36,
        child: IconButton(
          padding: EdgeInsets.zero,
          onPressed: enabled ? onTap : null,
          icon: Icon(icon, size: 20),
          style: IconButton.styleFrom(
            backgroundColor: AppTheme.accentColor.withValues(alpha: 0.08),
            foregroundColor: AppTheme.accentColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _methodChip(String value, String label) {
    final selected = _method == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      labelStyle: TextStyle(
          color: selected ? Colors.white : AppTheme.primaryColor, fontSize: 13),
      onSelected: _saving ? null : (_) => setState(() => _method = value),
    );
  }

  double get _debtAdded => switch (_method) {
        'cash' => 0.0,
        'partial' => _paidNow >= _total ? 0.0 : (_total - _paidNow).toDouble(),
        _ => _total.toDouble(),
      };

  double get _newBalance => _outstanding + _debtAdded;

  bool get _overLimit => _creditLimit > 0 && _newBalance > _creditLimit;

  Widget _paymentCard() {
    final cash = _method == 'cash';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.payment,
                style:
                    const TextStyle(color: AppTheme.mutedColor, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _methodChip('cash', l10n.cash),
                _methodChip('partial', l10n.partialLabel),
                _methodChip('credit', l10n.credit),
              ],
            ),
            const SizedBox(height: 8),
            if (cash)
              Text(
                l10n.paidInFullNow,
                style:
                    const TextStyle(color: AppTheme.mutedColor, fontSize: 12),
              )
            else if (_method == 'partial')
              _partialInfo()
            else
              _creditInfo(),
          ],
        ),
      ),
    );
  }

  Widget _payMethodChip(String value, String label) {
    final selected = _payMethod == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      labelStyle: TextStyle(
          color: selected ? Colors.white : AppTheme.primaryColor, fontSize: 12),
      onSelected: _saving ? null : (_) => setState(() => _payMethod = value),
    );
  }

  Widget _partialInfo() {
    final showError = _paidCtrl.text.trim().isNotEmpty && !_partialValid;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _paidCtrl,
          enabled: !_saving,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: l10n.paidNowAfn,
            isDense: true,
          ),
        ),
        if (showError)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              l10n.mustBeBetweenZeroAndTotal(_total),
              style: const TextStyle(color: _removeColor, fontSize: 12),
            ),
          ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _payMethodChip('cash', l10n.cash),
            _payMethodChip('transfer', l10n.transfer),
          ],
        ),
        if (_partialValid)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l10n.remainderAfnOnCredit(_total - _paidNow),
              style: const TextStyle(color: AppTheme.mutedColor, fontSize: 12),
            ),
          ),
        const SizedBox(height: 8),
        _creditInfo(),
      ],
    );
  }

  Widget _creditInfo() {
    final over = _overLimit;
    final color = over ? _warnColor : AppTheme.mutedColor;
    final limitText = _creditLimit > 0
        ? l10n.creditLimitLabel(_creditLimit.round())
        : l10n.noLimit;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: over ? _warnColor.withValues(alpha: 0.08) : null,
        borderRadius: BorderRadius.circular(8),
        border:
            over ? Border.all(color: _warnColor.withValues(alpha: 0.5)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.newBalanceAfn(_newBalance.round(), limitText),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: over ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (over)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l10n.overCreditLimit,
                style: const TextStyle(
                    color: _warnColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Future<bool> _confirmOverLimit() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.overCreditLimit, style: const TextStyle(fontSize: 17)),
        content: Text(
          l10n.creditLimitExceededConfirm(
              _newBalance.round(), _creditLimit.round()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: _warnColor),
            child: Text(l10n.continueAction),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Widget _addButton() {
    return OutlinedButton.icon(
      onPressed: _saving ? null : _addLine,
      icon: const Icon(Icons.add),
      label: Text(l10n.addItem),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        ),
      ),
    );
  }

  Widget _summaryBar() {
    return Container(
      padding: EdgeInsets.only(
        left: AppTheme.screenPadding,
        right: AppTheme.screenPadding,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.borderColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.itemsQty(_lines.length, _totalQty),
                  style:
                      const TextStyle(color: AppTheme.mutedColor, fontSize: 12),
                ),
                Text('$_total AFN',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed:
                  _canSave && !_saving && !_confirmingLimit ? _save : null,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: Colors.white),
                    )
                  : const Icon(Icons.check),
              label: Text(l10n.save),
            ),
          ),
        ],
      ),
    );
  }
}
