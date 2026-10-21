import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../locale/l10n.dart';
import '../services/storage_service.dart';
import '../services/supabase_service.dart';
import '../utils/app_logger.dart';
import '../utils/app_utils.dart';
import 'customer_repository.dart' show CustomerRepository, SaveResult;

class InvoiceItemWithProduct {
  const InvoiceItemWithProduct({required this.item, this.product});

  final InvoiceItem item;
  final Product? product;

  String get productName => product?.name ?? l10n.unknown;
  String get unit => product?.unit ?? '';
}

class InvoiceItemInput {
  const InvoiceItemInput({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
  });

  final String id;
  final String productId;
  final double quantity;
  final double unitPrice;

  double get total => quantity * unitPrice;
}

class CreateInvoiceResult {
  const CreateInvoiceResult({required this.result, required this.invoice});

  final SaveResult result;
  final Invoice invoice;
}

class InvoiceRepository {
  InvoiceRepository({AppDatabase? db, SupabaseClient? client})
      : _db = db ?? DatabaseProvider.instance,
        _client = client ?? SupabaseService.client;

  final AppDatabase _db;
  final SupabaseClient _client;

  Future<void> hydrateForCustomer(String customerId) async {
    try {
      final invoiceRows =
          await _client.from('invoices').select().eq('customer_id', customerId);
      if (invoiceRows.isEmpty) return;

      final localInvoices = await (_db.select(_db.invoices)
            ..where((t) => t.customerId.equals(customerId)))
          .get();
      final dirtyInvoiceIds =
          localInvoices.where((r) => !r.synced).map((r) => r.id).toSet();
      final cleanRows = invoiceRows
          .where((row) => !dirtyInvoiceIds.contains(row['id']))
          .toList();

      if (cleanRows.isNotEmpty) {
        await _db.batch((b) {
          b.insertAllOnConflictUpdate(
            _db.invoices,
            cleanRows.map((row) => InvoicesCompanion(
                  id: Value(row['id'] as String),
                  invoiceNumber: Value(row['invoice_number'] as String?),
                  truckLoadId: Value(row['truck_load_id'] as String?),
                  customerId: Value(row['customer_id'] as String),
                  driverId: Value(row['driver_id'] as String),
                  invoiceDate: Value(_toDateTime(row['invoice_date'])),
                  totalAmount: Value(_toDouble(row['total_amount'])),
                  paidAmount: Value(_toDouble(row['paid_amount'])),
                  status: Value(row['status'] as String? ?? 'unpaid'),
                  notes: Value(row['notes'] as String?),
                  photoUrl: Value(StorageService.normalizeObjectPath(
                      StorageService.invoicePhotosBucket,
                      row['photo_url'] as String?)),
                  updatedAt: Value(_toDateTime(row['updated_at']).toLocal()),
                  createdAt: Value(_toDateTime(row['created_at'])),
                  synced: const Value(true),
                )),
          );
        });
      }

      final invoiceIds = invoiceRows.map((row) => row['id'] as String).toList();
      final itemRows = await _client
          .from('invoice_items')
          .select()
          .inFilter('invoice_id', invoiceIds);
      if (itemRows.isEmpty) return;

      final localItems = await (_db.select(_db.invoiceItems)
            ..where((t) => t.invoiceId.isIn(invoiceIds)))
          .get();
      final dirtyItemIds =
          localItems.where((r) => !r.synced).map((r) => r.id).toSet();
      final dirtyItemInvoiceIds =
          localItems.where((r) => !r.synced).map((r) => r.invoiceId).toSet();
      final cleanItems = itemRows
          .where((row) =>
              !dirtyItemIds.contains(row['id']) &&
              !dirtyItemInvoiceIds.contains(row['invoice_id']))
          .toList();
      if (cleanItems.isEmpty) return;

      await _db.batch((b) {
        b.insertAllOnConflictUpdate(
          _db.invoiceItems,
          cleanItems.map((row) => InvoiceItemsCompanion(
                id: Value(row['id'] as String),
                invoiceId: Value(row['invoice_id'] as String),
                productId: Value(row['product_id'] as String),
                quantity: Value(_toDouble(row['quantity'])),
                unitPrice: Value(_toDouble(row['unit_price'])),
                total: Value(_toDouble(row['total'])),
                createdAt: Value(_toDateTime(row['created_at'])),
                synced: const Value(true),
              )),
        );
      });
    } catch (e, st) {
      AppLogger.error('InvoiceRepository.hydrateForCustomer', e, st);
    }
  }

  static double _toDouble(dynamic v) => v == null
      ? 0
      : v is num
          ? v.toDouble()
          : double.tryParse(v.toString()) ?? 0;

  static DateTime _toDateTime(dynamic v) =>
      v == null ? DateTime.now() : DateTime.parse(v.toString());

  Future<List<Invoice>> getForCustomer(String customerId) async {
    try {
      final query = _db.select(_db.invoices)
        ..where((t) => t.customerId.equals(customerId))
        ..orderBy([
          (t) =>
              OrderingTerm(expression: t.invoiceDate, mode: OrderingMode.desc),
          (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
        ]);
      return await query.get();
    } catch (e, st) {
      AppLogger.error('InvoiceRepository.getForCustomer', e, st);
      return [];
    }
  }

  Future<Invoice?> getById(String id) async {
    try {
      final query = _db.select(_db.invoices)..where((t) => t.id.equals(id));
      return await query.getSingleOrNull();
    } catch (e, st) {
      AppLogger.error('InvoiceRepository.getById', e, st);
      return null;
    }
  }

  Future<List<InvoiceItemWithProduct>> getItems(String invoiceId) async {
    try {
      final items = _db.invoiceItems;
      final products = _db.products;
      final query = _db.select(items).join([
        leftOuterJoin(products, products.id.equalsExp(items.productId)),
      ])
        ..where(items.invoiceId.equals(invoiceId))
        ..orderBy([OrderingTerm(expression: items.createdAt)]);
      final rows = await query.get();
      return rows
          .map((r) => InvoiceItemWithProduct(
                item: r.readTable(items),
                product: r.readTableOrNull(products),
              ))
          .toList();
    } catch (e, st) {
      AppLogger.error('InvoiceRepository.getItems', e, st);
      return [];
    }
  }

  Future<List<Product>> getActiveProducts() async {
    try {
      final query = _db.select(_db.products)
        ..where((t) => t.isActive.equals(true))
        ..orderBy([(t) => OrderingTerm(expression: t.name)]);
      return await query.get();
    } catch (e, st) {
      AppLogger.error('InvoiceRepository.getActiveProducts', e, st);
      return [];
    }
  }

  static String statusFor(double total, double paid) {
    if (total > 0 && paid >= total) return 'paid';
    if (paid > 0 && paid < total) return 'partial';
    return 'unpaid';
  }

  static String composeInvoiceNumber(
    String prefix,
    DateTime now, {
    Random? random,
  }) {
    final r = random ?? Random();
    String two(int v) => v.toString().padLeft(2, '0');
    final date = '${two(now.year % 100)}${two(now.month)}${two(now.day)}';
    final time = '${two(now.hour)}${two(now.minute)}${two(now.second)}';
    final rand = r.nextInt(100).toString().padLeft(2, '0');
    return '$prefix-$date-$time$rand';
  }

  static String sanitizeNumberPrefix(String raw) {
    final cleaned = raw.toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '');
    return cleaned.length > 8 ? cleaned.substring(0, 8) : cleaned;
  }

  Future<String> nextInvoiceNumber(String driverId) async {
    var prefix = '';
    try {
      final profile = await (_db.select(_db.driverProfiles)
            ..where((t) => t.id.equals(driverId)))
          .getSingleOrNull();
      final truckId = profile?.truckId;
      if (truckId != null && truckId.isNotEmpty) {
        final truck = await (_db.select(_db.trucks)
              ..where((t) => t.id.equals(truckId)))
            .getSingleOrNull();
        prefix = sanitizeNumberPrefix(truck?.plateNumber ?? '');
      }
    } catch (e, st) {
      AppLogger.error('InvoiceRepository.nextInvoiceNumber', e, st);
    }
    if (prefix.isEmpty) {
      final d = sanitizeNumberPrefix(driverId);
      prefix = d.isEmpty ? 'VS' : d.substring(0, d.length < 4 ? d.length : 4);
    }

    var number = composeInvoiceNumber(prefix, DateTime.now());
    try {
      for (var attempt = 0; attempt < 3; attempt++) {
        final exists = await (_db.select(_db.invoices)
              ..where((t) => t.invoiceNumber.equals(number)))
            .getSingleOrNull();
        if (exists == null) break;
        number = composeInvoiceNumber(prefix, DateTime.now());
      }
    } catch (e, st) {
      AppLogger.error('InvoiceRepository.nextInvoiceNumber(check)', e, st);
    }
    return number;
  }

  Future<String> driverNameFor(String driverId) async {
    try {
      final row = await (_db.select(_db.driverProfiles)
            ..where((t) => t.id.equals(driverId)))
          .getSingleOrNull();
      return row?.fullName ?? '';
    } catch (e, st) {
      AppLogger.error('InvoiceRepository.driverNameFor', e, st);
      return '';
    }
  }

  Future<void> setLocalPhotoPath(String invoiceId, String path) async {
    await (_db.update(_db.invoices)..where((t) => t.id.equals(invoiceId)))
        .write(InvoicesCompanion(
      photoPath: Value(path),
      photoUrl: const Value(null),
      synced: const Value(false),
    ));
  }

  Future<SaveResult> updatePhoto(
    String invoiceId,
    String objectPath, {
    bool remote = true,
    bool? wasSyncedBefore,
  }) async {
    final before = await getById(invoiceId);
    final wasSynced = wasSyncedBefore ?? before?.synced ?? false;
    await (_db.update(_db.invoices)..where((t) => t.id.equals(invoiceId)))
        .write(InvoicesCompanion(
      photoUrl: Value(objectPath),
      synced: const Value(false),
    ));

    if (!remote) return SaveResult.localOnly;

    try {
      await _client
          .from('invoices')
          .update({'photo_url': objectPath}).eq('id', invoiceId);
      if (wasSynced) {
        await (_db.update(_db.invoices)..where((t) => t.id.equals(invoiceId)))
            .write(const InvoicesCompanion(synced: Value(true)));
      }
      return SaveResult.synced;
    } catch (e, st) {
      AppLogger.error('InvoiceRepository.updatePhoto', e, st);
      return SaveResult.localOnly;
    }
  }

  Future<SaveResult> attachPhoto(String invoiceId, String localPath) async {
    final before = await getById(invoiceId);
    final wasSynced = before?.synced ?? false;
    await setLocalPhotoPath(invoiceId, localPath);
    try {
      final file = File(localPath);
      if (await file.exists()) {
        final url = await StorageService.uploadInvoicePhoto(invoiceId, file);
        if (url != null && url.isNotEmpty) {
          return updatePhoto(invoiceId, url, wasSyncedBefore: wasSynced);
        }
      }
    } catch (e, st) {
      AppLogger.error('InvoiceRepository.attachPhoto', e, st);
    }
    return SaveResult.localOnly;
  }

  Future<CreateInvoiceResult> create({
    required String customerId,
    required String driverId,
    required String invoiceNumber,
    required List<InvoiceItemInput> items,
    DateTime? date,
    bool cashSale = false,
    double paidNow = 0,
    String paymentMethod = 'cash',
  }) async {
    final id = AppUtils.generateUuid();
    final invoiceDate = date ?? DateTime.now();
    final total = items.fold<double>(0, (sum, i) => sum + i.total);
    final paid = cashSale ? total : paidNow.clamp(0.0, total);
    final method = cashSale ? 'cash' : paymentMethod;
    final status = statusFor(total, paid);
    final paymentId = paid > 0 ? AppUtils.generateUuid() : null;

    await _db.transaction(() async {
      await _db.into(_db.invoices).insert(InvoicesCompanion(
            id: Value(id),
            invoiceNumber: Value(invoiceNumber),
            truckLoadId: const Value(null),
            customerId: Value(customerId),
            driverId: Value(driverId),
            invoiceDate: Value(invoiceDate),
            totalAmount: Value(total),
            paidAmount: Value(paid),
            status: Value(status),
            synced: const Value(false),
          ));
      for (final i in items) {
        await _db.into(_db.invoiceItems).insert(InvoiceItemsCompanion(
              id: Value(i.id),
              invoiceId: Value(id),
              productId: Value(i.productId),
              quantity: Value(i.quantity),
              unitPrice: Value(i.unitPrice),
              total: Value(i.total),
              synced: const Value(false),
            ));
      }
      if (paymentId != null) {
        await _db.into(_db.payments).insert(PaymentsCompanion(
              id: Value(paymentId),
              invoiceId: Value(id),
              customerId: Value(customerId),
              driverId: Value(driverId),
              amount: Value(paid),
              paymentMethod: Value(method),
              paymentDate: Value(invoiceDate),
              synced: const Value(false),
            ));
      }
    });

    SaveResult result;
    try {
      await _client.from('invoices').upsert({
        'id': id,
        'invoice_number': invoiceNumber,
        'truck_load_id': null,
        'customer_id': customerId,
        'driver_id': driverId,
        'invoice_date': AppUtils.formatDate(invoiceDate),
        'total_amount': total,
        'paid_amount': paid,
        'status': status,
      });
      await _client.from('invoice_items').upsert(items
          .map((i) => {
                'id': i.id,
                'invoice_id': id,
                'product_id': i.productId,
                'quantity': i.quantity,
                'unit_price': i.unitPrice,
              })
          .toList());
      if (paymentId != null) {
        await _client.from('payments').upsert({
          'id': paymentId,
          'invoice_id': id,
          'customer_id': customerId,
          'driver_id': driverId,
          'amount': paid,
          'payment_method': method,
          'payment_date': AppUtils.formatDate(invoiceDate),
        });
        await (_db.update(_db.payments)..where((t) => t.id.equals(paymentId)))
            .write(const PaymentsCompanion(synced: Value(true)));
      }
      await (_db.update(_db.invoiceItems)..where((t) => t.invoiceId.equals(id)))
          .write(const InvoiceItemsCompanion(synced: Value(true)));
      await (_db.update(_db.invoices)..where((t) => t.id.equals(id)))
          .write(const InvoicesCompanion(synced: Value(true)));
      result = SaveResult.synced;
    } catch (e, st) {
      AppLogger.error('InvoiceRepository.create(push)', e, st);
      result = SaveResult.localOnly;
    }

    await CustomerRepository(db: _db, client: _client)
        .recomputeBalance(customerId);
    final saved = await getById(id);
    if (saved == null) {
      throw StateError('Invoice $id missing after insert');
    }
    return CreateInvoiceResult(result: result, invoice: saved);
  }

  Future<double> allocateToOpenInvoices(
      String customerId, double amount) async {
    var left = amount;
    if (left <= 0) return 0;
    try {
      final open = await (_db.select(_db.invoices)
            ..where((t) =>
                t.customerId.equals(customerId) &
                t.status.isIn(const ['unpaid', 'partial']))
            ..orderBy([
              (t) => OrderingTerm(expression: t.invoiceDate),
              (t) => OrderingTerm(expression: t.createdAt),
            ]))
          .get();
      for (final inv in open) {
        if (left <= 0) break;
        final remaining = inv.totalAmount - inv.paidAmount;
        if (remaining <= 0) continue;
        final pay = left < remaining ? left : remaining;
        final newPaid = inv.paidAmount + pay;
        final status = statusFor(inv.totalAmount, newPaid);
        await (_db.update(_db.invoices)..where((t) => t.id.equals(inv.id)))
            .write(InvoicesCompanion(
          paidAmount: Value(newPaid),
          status: Value(status),
          synced: const Value(false),
        ));
        try {
          await _client.from('invoices').update({
            'paid_amount': newPaid,
            'status': status,
          }).eq('id', inv.id);
          if (inv.synced) {
            await (_db.update(_db.invoices)..where((t) => t.id.equals(inv.id)))
                .write(const InvoicesCompanion(synced: Value(true)));
          }
        } catch (e, st) {
          AppLogger.error(
              'InvoiceRepository.allocateToOpenInvoices(push ${inv.id})',
              e,
              st);
        }
        left -= pay;
      }
    } catch (e, st) {
      AppLogger.error('InvoiceRepository.allocateToOpenInvoices', e, st);
    }
    return left < 0 ? 0 : left;
  }

  Future<void> reconcileAllocations(String customerId) async {
    try {
      final inv = _db.invoices;
      final allocatedSum = inv.paidAmount.sum();
      final invRow = await (_db.selectOnly(inv)
            ..addColumns([allocatedSum])
            ..where(inv.customerId.equals(customerId)))
          .getSingle();

      final pay = _db.payments;
      final paidSum = pay.amount.sum();
      final payRow = await (_db.selectOnly(pay)
            ..addColumns([paidSum])
            ..where(pay.customerId.equals(customerId)))
          .getSingle();

      final unallocated =
          (payRow.read(paidSum) ?? 0) - (invRow.read(allocatedSum) ?? 0);
      if (unallocated >= 1) {
        await allocateToOpenInvoices(customerId, unallocated);
      }
    } catch (e, st) {
      AppLogger.error('InvoiceRepository.reconcileAllocations', e, st);
    }
  }

  Future<SaveResult> addPayment({
    required Invoice invoice,
    required String driverId,
    required double amount,
    required String method,
    String? notes,
  }) async {
    final paymentId = AppUtils.generateUuid();
    final paymentDate = DateTime.now();
    final newPaid = min(invoice.totalAmount, invoice.paidAmount + amount);
    final status = statusFor(invoice.totalAmount, newPaid);

    await _db.transaction(() async {
      await _db.into(_db.payments).insert(PaymentsCompanion(
            id: Value(paymentId),
            invoiceId: Value(invoice.id),
            customerId: Value(invoice.customerId),
            driverId: Value(driverId),
            amount: Value(amount),
            paymentMethod: Value(method),
            paymentDate: Value(paymentDate),
            notes: Value(notes),
            synced: const Value(false),
          ));
      await (_db.update(_db.invoices)..where((t) => t.id.equals(invoice.id)))
          .write(InvoicesCompanion(
        paidAmount: Value(newPaid),
        status: Value(status),
        synced: const Value(false),
      ));
    });

    SaveResult result;
    try {
      await _client.from('payments').upsert({
        'id': paymentId,
        'invoice_id': invoice.id,
        'customer_id': invoice.customerId,
        'driver_id': driverId,
        'amount': amount,
        'payment_method': method,
        'payment_date': AppUtils.formatDate(paymentDate),
        'notes': notes,
      });
      await _client.from('invoices').update({
        'paid_amount': newPaid,
        'status': status,
      }).eq('id', invoice.id);
      await (_db.update(_db.payments)..where((t) => t.id.equals(paymentId)))
          .write(const PaymentsCompanion(synced: Value(true)));
      if (invoice.synced) {
        await (_db.update(_db.invoices)..where((t) => t.id.equals(invoice.id)))
            .write(const InvoicesCompanion(synced: Value(true)));
      }
      result = SaveResult.synced;
    } catch (e, st) {
      AppLogger.error('InvoiceRepository.addPayment', e, st);
      result = SaveResult.localOnly;
    }

    await CustomerRepository(db: _db, client: _client)
        .recomputeBalance(invoice.customerId);
    return result;
  }

  Future<SaveResult> saveItems({
    required Invoice invoice,
    required List<InvoiceItemInput> items,
  }) async {
    final total = items.fold<double>(0, (sum, i) => sum + i.total);
    final linkedCashPayments = await (_db.select(_db.payments)
          ..where((t) =>
              t.invoiceId.equals(invoice.id) & t.paymentMethod.equals('cash')))
        .get();
    final wasFullyPaid =
        invoice.status == 'paid' && invoice.paidAmount >= invoice.totalAmount;
    final cashPayment = linkedCashPayments.isEmpty || !wasFullyPaid
        ? null
        : linkedCashPayments.reduce(
            (a, b) => a.createdAt.isBefore(b.createdAt) ? a : b,
          );
    final paid = cashPayment == null ? min(invoice.paidAmount, total) : total;
    final status = statusFor(total, paid);

    await _db.transaction(() async {
      await (_db.delete(_db.invoiceItems)
            ..where((t) => t.invoiceId.equals(invoice.id)))
          .go();
      for (final i in items) {
        await _db.into(_db.invoiceItems).insert(InvoiceItemsCompanion(
              id: Value(i.id),
              invoiceId: Value(invoice.id),
              productId: Value(i.productId),
              quantity: Value(i.quantity),
              unitPrice: Value(i.unitPrice),
              total: Value(i.total),
              synced: const Value(false),
            ));
      }
      await (_db.update(_db.invoices)..where((t) => t.id.equals(invoice.id)))
          .write(InvoicesCompanion(
        totalAmount: Value(total),
        paidAmount: Value(paid),
        status: Value(status),
        synced: const Value(false),
      ));
      if (cashPayment != null) {
        await (_db.update(_db.payments)
              ..where((t) => t.id.equals(cashPayment.id)))
            .write(PaymentsCompanion(
          amount: Value(total),
          synced: const Value(false),
        ));
      }
    });

    SaveResult result;
    try {
      await _client.from('invoice_items').delete().eq('invoice_id', invoice.id);
      if (items.isNotEmpty) {
        await _client.from('invoice_items').upsert(items
            .map((i) => {
                  'id': i.id,
                  'invoice_id': invoice.id,
                  'product_id': i.productId,
                  'quantity': i.quantity,
                  'unit_price': i.unitPrice,
                })
            .toList());
      }
      await _client.from('invoices').update({
        'total_amount': total,
        'paid_amount': paid,
        'status': status,
      }).eq('id', invoice.id);
      if (cashPayment != null) {
        await _client.from('payments').update({
          'amount': total,
        }).eq('id', cashPayment.id);
      }

      final ids = items.map((i) => i.id).toList();
      if (ids.isNotEmpty) {
        await (_db.update(_db.invoiceItems)..where((t) => t.id.isIn(ids)))
            .write(const InvoiceItemsCompanion(synced: Value(true)));
      }
      if (cashPayment != null) {
        await (_db.update(_db.payments)
              ..where((t) => t.id.equals(cashPayment.id)))
            .write(const PaymentsCompanion(synced: Value(true)));
      }
      await (_db.update(_db.invoices)..where((t) => t.id.equals(invoice.id)))
          .write(const InvoicesCompanion(synced: Value(true)));
      result = SaveResult.synced;
    } catch (e, st) {
      AppLogger.error('InvoiceRepository.saveItems', e, st);
      result = SaveResult.localOnly;
    }

    await CustomerRepository(db: _db, client: _client)
        .recomputeBalance(invoice.customerId);
    return result;
  }
}
