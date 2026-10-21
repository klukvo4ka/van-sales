import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/database/app_database.dart';
import '../../core/locale/l10n.dart';
import '../../core/repositories/customer_repository.dart' show SaveResult;
import '../../core/repositories/driver_liability_repository.dart';
import '../../core/repositories/driver_settlement_repository.dart';
import '../../core/repositories/truck_initial_stock_repository.dart';
import '../../core/services/report_export.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../main.dart' show syncProvider;

enum _LiabilityRange { all, month, custom }

class DriverLiabilityView extends StatefulWidget {
  const DriverLiabilityView({super.key});

  @override
  State<DriverLiabilityView> createState() => _DriverLiabilityViewState();
}

class _DriverLiabilityViewState extends State<DriverLiabilityView> {
  final _repo = DriverLiabilityRepository();
  final _stockRepo = TruckInitialStockRepository();

  List<DriverProfile> _drivers = [];
  Map<String, Truck> _truckById = {};
  DriverProfile? _driver;
  _LiabilityRange _range = _LiabilityRange.all;
  DateTime _from = DateTime(2024);
  DateTime _to = DateTime.now();
  DriverLiability _liability = const DriverLiability();
  bool _loading = true;
  bool _fetching = false;

  static const _okColor = Color(0xFF16A34A);
  static const _warnColor = Color(0xFFD97706);
  static const _debtColor = Color(0xFFDC2626);

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _loadLookups(syncFirst: true);
    await _load();
  }

  Future<void> _loadLookups({bool syncFirst = false}) async {
    if (syncFirst) {
      await syncProvider.service.syncNow();
    }
    final profiles = await _stockRepo.getDriverProfiles();
    final trucks = await _stockRepo.getAllTrucks();
    final drivers =
        profiles.where((p) => p.role == 'driver' && p.isActive).toList();
    if (!mounted) return;
    final selectedId = _driver?.id;
    final selected = selectedId == null
        ? null
        : drivers.where((p) => p.id == selectedId).firstOrNull;
    setState(() {
      _drivers = drivers;
      _truckById = {for (final t in trucks) t.id: t};
      _driver = selected ?? (drivers.isEmpty ? null : drivers.first);
      _loading = false;
    });
  }

  Future<void> _setRange(_LiabilityRange range) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (range == _LiabilityRange.custom) {
      final picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2024),
        lastDate: now,
        initialDateRange: DateTimeRange(start: _from, end: _to),
      );
      if (picked == null || !mounted) return;
      setState(() {
        _range = range;
        _from = picked.start;
        _to = picked.end;
      });
    } else {
      setState(() {
        _range = range;
        _from = range == _LiabilityRange.all
            ? DateTime(2024)
            : DateTime(today.year, today.month, 1);
        _to = today;
      });
    }
    await _load();
  }

  Future<void> _load() async {
    final driver = _driver;
    if (driver == null) {
      setState(() {
        _liability = const DriverLiability();
        _fetching = false;
      });
      return;
    }
    setState(() => _fetching = true);
    final liability = await _repo.fetch(
      driverId: driver.id,
      truckId: driver.truckId ?? '',
      from: _from,
      to: _to,
    );
    if (!mounted) return;
    setState(() {
      _liability = liability;
      _fetching = false;
    });
  }

  Future<void> _refresh() async {
    await _loadLookups(syncFirst: true);
    await _load();
  }

  Future<void> _recordHandover() async {
    final driver = _driver;
    if (driver == null) return;
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _HandoverSheet(driver: driver),
    );
    if (saved == true) await _load();
  }

  String _driverLabel(DriverProfile p) {
    final truck = p.truckId == null ? null : _truckById[p.truckId!];
    return truck == null ? p.fullName : '${p.fullName} — ${truck.plateNumber}';
  }

  static String _afn(double v) => '${v.round()} AFN';

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        _filters(),
        const SizedBox(height: 8),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: _body(),
          ),
        ),
      ],
    );
  }

  Widget _filters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 240, maxWidth: 380),
              child: DropdownButtonFormField<String>(
                initialValue: _driver?.id,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.driver,
                  isDense: true,
                ),
                items: _drivers
                    .map((p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(_driverLabel(p),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: _fetching
                    ? null
                    : (id) {
                        setState(() {
                          _driver =
                              _drivers.where((p) => p.id == id).firstOrNull;
                        });
                        _load();
                      },
              ),
            ),
            Text(
              l10n.dateRange(
                  AppUtils.formatDate(_from), AppUtils.formatDate(_to)),
              style: const TextStyle(color: AppTheme.mutedColor, fontSize: 12),
            ),
            ExportButtons(
              enabled: !_fetching && _driver != null && !_liability.isEmpty,
              onPdf: () => ReportExport.exportPdf(
                context,
                reportName: _liabilityReportName,
                filters: _liabilityFilterLine,
                fileBase: _liabilityFileBase,
                tables: _liabilityTables(),
              ),
              onExcel: () => ReportExport.exportExcel(
                context,
                reportName: _liabilityReportName,
                filters: _liabilityFilterLine,
                fileBase: _liabilityFileBase,
                tables: _liabilityTables(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _rangeChip(_LiabilityRange.all, l10n.allTime),
              const SizedBox(width: 8),
              _rangeChip(_LiabilityRange.month, l10n.thisMonth),
              const SizedBox(width: 8),
              _rangeChip(_LiabilityRange.custom, l10n.custom),
            ],
          ),
        ),
      ],
    );
  }

  static String get _liabilityReportName => l10n.driverLiability;

  String get _liabilityFilterLine {
    final driver = _driver;
    final name = driver == null ? '' : '${_driverLabel(driver)} — ';
    return '$name${AppUtils.formatDate(_from)} — ${AppUtils.formatDate(_to)}';
  }

  String get _liabilityFileBase => ReportExport.fileBase(
        'liability',
        _driver?.fullName ?? 'all',
        '${AppUtils.formatDate(_from)}_${AppUtils.formatDate(_to)}',
      );

  List<ReportTable> _liabilityTables() {
    final l = _liability;
    return [
      ReportTable(
        title: l10n.reconciliation,
        columns: [l10n.metric, l10n.valueAfn],
        rows: [
          [l10n.goodsIssuedValue, l.goodsIssuedValue],
          [l10n.goodsSoldValue, l.goodsSoldValue],
          [l10n.remainingStockValue, l.remainingStockValue],
          [l10n.cashCollected, l.cashCollected],
          [l10n.transferCollected, l.transferCollected],
          [l10n.cashHandedIn, l.cashHandedIn],
          [l10n.receivables, l.receivables],
          [l10n.netOwedToCompany, l.netOwed],
          [l10n.sanityDelta, l.sanityDelta],
        ],
      ),
    ];
  }

  Widget _rangeChip(_LiabilityRange range, String label) {
    final selected = _range == range;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      labelStyle: TextStyle(
          color: selected ? Colors.white : AppTheme.primaryColor, fontSize: 12),
      onSelected: _fetching ? null : (_) => _setRange(range),
    );
  }

  Widget _body() {
    if (_fetching) {
      return ListView(
        children: const [
          SizedBox(height: 160),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }
    if (_driver == null) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          const Icon(Icons.people_outline, size: 56, color: Colors.black26),
          const SizedBox(height: 12),
          Text(
            l10n.noDriversYet,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, fontSize: 16),
          ),
        ],
      );
    }

    final l = _liability;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (l.fromCache) _offlineBanner(),
        if (l.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Text(
              l10n.noActivityInThisRange,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.mutedColor, fontSize: 15),
            ),
          ),
        _netOwedCard(l),
        const SizedBox(height: 12),
        _sectionCard(l10n.goods, [
          _row(l10n.issuedValue, _afn(l.goodsIssuedValue)),
          _row(l10n.soldValue, _afn(l.goodsSoldValue)),
          _row(l10n.remainingStockValue, _afn(l.remainingStockValue)),
        ]),
        const SizedBox(height: 12),
        _sectionCard(l10n.money, [
          _row(l10n.cashCollected, _afn(l.cashCollected)),
          _row(l10n.transferCollected, _afn(l.transferCollected)),
          _row(l10n.cashHandedIn, _afn(l.cashHandedIn), valueColor: _okColor),
          _row(l10n.receivables, _afn(l.receivables)),
        ]),
        const SizedBox(height: 12),
        _sanityCard(l),
        const SizedBox(height: 16),
        SizedBox(
          height: 48,
          child: FilledButton.icon(
            onPressed: _fetching ? null : _recordHandover,
            icon: const Icon(Icons.savings_outlined, size: 20),
            label: Text(l10n.recordCashHandover),
          ),
        ),
      ],
    );
  }

  Widget _offlineBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _warnColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        border: Border.all(color: _warnColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_outlined, size: 20, color: _warnColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.offlineShowingLocalData,
              style: const TextStyle(color: _warnColor, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _netOwedCard(DriverLiability l) {
    final owes = l.netOwed > 0;
    final color = owes ? _debtColor : _okColor;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.netOwedToCompany,
              style: const TextStyle(color: AppTheme.mutedColor, fontSize: 13)),
          const SizedBox(height: 6),
          Text(
            owes ? '${l.netOwed.round()} AFN' : l10n.settled,
            style: TextStyle(
                color: color, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.cashCollectedMinusHandedIn(
                _afn(l.cashCollected), _afn(l.cashHandedIn)),
            style: const TextStyle(color: AppTheme.mutedColor, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _sanityCard(DriverLiability l) {
    final ok = l.sanityOk;
    final color = ok ? _okColor : _warnColor;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(ok ? Icons.check_circle_outline : Icons.warning_amber_outlined,
                size: 22, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ok
                        ? l10n.booksBalance
                        : l10n.mismatchAfn(l.sanityDelta.round()),
                    style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.soldVsCollectedCheck(
                        _afn(l.goodsSoldValue),
                        _afn(l.cashCollected + l.transferCollected),
                        _afn(l.receivables)),
                    style: const TextStyle(
                        color: AppTheme.mutedColor, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard(String title, List<Widget> children) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: AppTheme.mutedColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: Colors.black87)),
          ),
          const SizedBox(width: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppTheme.primaryColor)),
        ],
      ),
    );
  }
}

class _HandoverSheet extends StatefulWidget {
  const _HandoverSheet({required this.driver});

  final DriverProfile driver;

  @override
  State<_HandoverSheet> createState() => _HandoverSheetState();
}

class _HandoverSheetState extends State<_HandoverSheet> {
  final _repo = DriverSettlementRepository();
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _notes = TextEditingController();
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  int get _parsedAmount => int.tryParse(_amount.text.trim()) ?? 0;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    final amount = _parsedAmount;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.recordCashHandoverQuestion,
            style: const TextStyle(fontSize: 17)),
        content: Text(
          l10n.afnFromOn(
              amount, widget.driver.fullName, AppUtils.formatDate(_date)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.record),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _saving = true);
    final result = await _repo.create(
      driverId: widget.driver.id,
      amount: amount.toDouble(),
      date: _date,
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
    );
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context, true);
    final recorded = l10n.handoverRecordedAfn(amount);
    messenger.showSnackBar(SnackBar(
      content: Text(result == SaveResult.synced
          ? recorded
          : l10n.withOfflineNote(recorded)),
    ));
  }

  @override
  Widget build(BuildContext context) {
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
              Text(l10n.recordCashHandover,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(widget.driver.fullName,
                  style: const TextStyle(
                      color: AppTheme.mutedColor, fontSize: 14)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amount,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(labelText: l10n.amountAfn),
                validator: (v) {
                  final parsed = int.tryParse((v ?? '').trim());
                  if (parsed == null || parsed <= 0) {
                    return l10n.mustBeMoreThanZero;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: _saving ? null : _pickDate,
                icon: const Icon(Icons.calendar_today_outlined, size: 18),
                label: Text(l10n.dateWithLabel(AppUtils.formatDate(_date))),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _notes,
                decoration: InputDecoration(labelText: l10n.notes),
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
                      : const Icon(Icons.savings_outlined),
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
