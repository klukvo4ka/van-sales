import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/auth/auth_service.dart';
import 'core/auth/go_router_refresh_stream.dart';
import 'core/constants/app_constants.dart';
import 'core/database/database_provider.dart';
import 'core/locale/l10n.dart';
import 'core/locale/locale_controller.dart';
import 'core/services/location_service.dart';
import 'core/services/push_service.dart';
import 'core/sync/sync_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/customers/screens/route_screen.dart';
import 'features/dashboard/screens/day_summary_screen.dart';
import 'features/dashboard/screens/driver_shell.dart';
import 'features/dashboard/screens/office_shell.dart';
import 'features/inventory/screens/truck_stock_screen.dart';
import 'l10n/app_localizations.dart';

final SyncProvider syncProvider = SyncProvider();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    publishableKey: AppConstants.supabaseAnonKey,
  );
  DatabaseProvider.instance;
  await LocaleController.instance.load();
  syncProvider.start();
  await PushService.instance.init(onNavigate: (route) => _router.go(route));
  await LocationService.instance.init();
  runApp(const VanSalesApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  refreshListenable: GoRouterRefreshStream(
    Supabase.instance.client.auth.onAuthStateChange,
  ),
  redirect: (context, state) async {
    final isLoggedIn = AuthService.currentSession != null;
    final isLoginRoute = state.matchedLocation == '/';

    if (!isLoggedIn) return isLoginRoute ? null : '/';

    if (isLoginRoute) {
      final role = await AuthService.getUserRole();
      return role == AuthService.roleOffice || role == AuthService.roleAdmin
          ? '/dashboard/office'
          : '/dashboard/driver';
    }

    final role = await AuthService.getUserRole();
    final isOffice =
        role == AuthService.roleOffice || role == AuthService.roleAdmin;
    final location = state.matchedLocation;

    final isDriverOnlyRoute = location.startsWith('/dashboard/driver') ||
        location.startsWith('/day/') ||
        location.startsWith('/inventory/') ||
        location.startsWith('/route/');

    if (location.startsWith('/dashboard/office') && !isOffice) {
      return '/dashboard/driver';
    }
    if (isDriverOnlyRoute && isOffice) {
      return '/dashboard/office';
    }
    return null;
  },
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/dashboard/driver',
      name: 'driverDashboard',
      builder: (context, state) => const DriverShell(),
    ),
    GoRoute(
      path: '/dashboard/office',
      name: 'officeDashboard',
      builder: (context, state) => const OfficeShell(),
    ),
    GoRoute(
      path: '/inventory/stock',
      name: 'truckStock',
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: Text(l10n.myStock)),
        body: const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
          child: TruckStockScreen(),
        ),
      ),
    ),
    GoRoute(
      path: '/day/summary',
      name: 'daySummary',
      builder: (context, state) => const DaySummaryScreen(),
    ),
    GoRoute(
      path: '/route/today',
      name: 'routeToday',
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: Text(l10n.routeOfTheDay)),
        body: const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppTheme.screenPadding),
          child: RouteScreen(),
        ),
      ),
    ),
  ],
);

class VanSalesApp extends StatefulWidget {
  const VanSalesApp({super.key});

  @override
  State<VanSalesApp> createState() => _VanSalesAppState();
}

class _VanSalesAppState extends State<VanSalesApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    LocaleController.instance.locale.addListener(_rebuildAllOnLocaleChange);
  }

  @override
  void dispose() {
    LocaleController.instance.locale.removeListener(_rebuildAllOnLocaleChange);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _rebuildAllOnLocaleChange() {
    void markDirty(Element element) {
      element.markNeedsBuild();
      element.visitChildren(markDirty);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(markDirty);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      syncProvider.syncNow();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LocaleController.instance.locale,
      builder: (context, locale, _) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: PushService.scaffoldMessengerKey,
          theme: AppTheme.lightTheme,
          routerConfig: _router,
          locale: locale,
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        );
      },
    );
  }
}
