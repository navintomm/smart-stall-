import 'package:go_router/go_router.dart';
import 'app_routes.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/training/presentation/training_screen.dart';
import '../../features/manual_control/presentation/manual_control_screen.dart';
import '../../features/auto_cleaning/presentation/auto_cleaning_screen.dart';
import '../../features/aruco_scanner/presentation/aruco_scanner_screen.dart';
import '../../features/connection/presentation/connection_screen.dart';
import '../../features/maintenance/presentation/maintenance_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/ui_showcase/ui_showcase_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.dashboard,
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.training,
      builder: (context, state) => const TrainingScreen(),
    ),
    GoRoute(
      path: AppRoutes.manualControl,
      builder: (context, state) => const ManualControlScreen(),
    ),
    GoRoute(
      path: AppRoutes.autoCleaning,
      builder: (context, state) => const AutoCleaningScreen(),
    ),
    GoRoute(
      path: AppRoutes.arucoScanner,
      builder: (context, state) => const ArucoScannerScreen(),
    ),
    GoRoute(
      path: AppRoutes.connection,
      builder: (context, state) => const ConnectionScreen(),
    ),
    GoRoute(
      path: AppRoutes.maintenance,
      builder: (context, state) => const MaintenanceScreen(),
    ),
    GoRoute(
      path: AppRoutes.history,
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/showcase',
      builder: (context, state) => const UiShowcaseScreen(),
    ),
  ],
);
