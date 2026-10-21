import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:van_sales/core/database/app_database.dart';
import 'package:van_sales/core/database/database_provider.dart';
import 'package:van_sales/core/locale/locale_controller.dart';
import 'package:van_sales/core/sync/sync_service.dart';
import 'package:van_sales/core/widgets/sync_status_bar.dart';
import 'package:van_sales/features/auth/screens/login_screen.dart';
import 'package:van_sales/features/customers/screens/new_invoice_screen.dart';
import 'package:van_sales/l10n/app_localizations.dart';
import 'package:van_sales/main.dart';

Widget _host(Widget child) => ValueListenableBuilder<Locale>(
      valueListenable: LocaleController.instance.locale,
      builder: (context, locale, _) => MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );

void main() {
  late AppDatabase db;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      publishableKey: 'test-key',
    );
  });

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    DatabaseProvider.useForTesting(db);
    await LocaleController.instance.setLocale('en');
  });

  tearDown(() async {
    await DatabaseProvider.close();
  });

  testWidgets('login screen renders and rejects empty fields', (tester) async {
    await tester.pumpWidget(_host(const LoginScreen()));
    await tester.pump();

    expect(find.text('Van Sales'), findsOneWidget);
    expect(find.text('Sign in to continue'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();

    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
  });

  group('SyncStatusBar', () {
    SyncService service() => SyncService(db: db);

    testWidgets('idle without a previous sync', (tester) async {
      await tester.pumpWidget(_host(Scaffold(
        body: SyncStatusBar(service: service(), onSync: () {}),
      )));

      expect(find.text('Not synced yet'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('syncing shows a spinner and disables the button',
        (tester) async {
      final s = service()..isSyncing = true;
      await tester.pumpWidget(_host(Scaffold(
        body: SyncStatusBar(service: s, onSync: () {}),
      )));

      expect(find.text('Syncing…'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final button = tester.widget<IconButton>(find.byType(IconButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('failed sync leaves an unsynced badge and allows retry',
        (tester) async {
      var retries = 0;
      final s = service()
        ..lastSyncedAt = DateTime(2026, 1, 1, 9, 5)
        ..lastErrors.add('invoices')
        ..dirtyCount = 3;
      await tester.pumpWidget(_host(Scaffold(
        body: SyncStatusBar(service: s, onSync: () => retries++),
      )));

      expect(find.text('Last sync: 09:05'), findsOneWidget);
      expect(find.text('3 unsynced'), findsOneWidget);

      await tester.tap(find.byType(IconButton));
      expect(retries, 1);
    });
  });

  testWidgets('new invoice total follows the added lines', (tester) async {
    await db.into(db.products).insert(ProductsCompanion.insert(
          id: 'p-cola',
          name: 'Cola',
          price: const Value(100),
          unit: const Value('carton'),
        ));
    await db.into(db.products).insert(ProductsCompanion.insert(
          id: 'p-chips',
          name: 'Chips',
          price: const Value(50),
          unit: const Value('carton'),
        ));
    await db.into(db.customers).insert(CustomersCompanion.insert(
          id: 'c-1',
          name: 'Shop 01',
        ));
    final customer = await (db.select(db.customers)
          ..where((t) => t.id.equals('c-1')))
        .getSingle();

    await tester.runAsync(() async {
      await tester.pumpWidget(_host(NewInvoiceScreen(customer: customer)));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();

    String grandTotal() => tester
        .widget<Text>(
            find.byWidgetPredicate((w) => w is Text && w.style?.fontSize == 20))
        .data!;

    expect(grandTotal(), '0 AFN');

    Future<void> addProduct(String name) async {
      await tester.tap(find.text('Add item'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(name));
      await tester.pumpAndSettle();
    }

    await addProduct('Cola');
    expect(grandTotal(), '100 AFN');

    await addProduct('Chips');
    expect(grandTotal(), '150 AFN');
    expect(find.text('Items: 2 — Qty: 2'), findsOneWidget);

    await tester.enterText(
      find
          .byWidgetPredicate(
            (w) => w is TextField && w.controller?.text == '1',
          )
          .first,
      '3',
    );
    await tester.pumpAndSettle();
    expect(grandTotal(), '350 AFN');
  });

  testWidgets('switching to Dari flips the app to right-to-left',
      (tester) async {
    await tester.pumpWidget(const VanSalesApp());
    await tester.pumpAndSettle();

    BuildContext loginContext() => tester.element(find.byType(LoginScreen));
    expect(Directionality.of(loginContext()), TextDirection.ltr);
    expect(find.text('Login'), findsWidgets);

    await LocaleController.instance.setLocale('fa');
    await tester.pumpAndSettle();

    expect(Directionality.of(loginContext()), TextDirection.rtl);
    expect(find.text('ورود'), findsWidgets);
    expect(find.text('Login'), findsNothing);
  });
}
