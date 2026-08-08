import 'package:go_router/go_router.dart';
import 'app_routes.dart';

// Shell
import '../../features/shell/presentation/app_shell.dart';

// Primary screens
import '../../features/home/presentation/home_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

// Settings sub-pages
import '../../features/settings/presentation/pages/teaching_page.dart';
import '../../features/settings/presentation/pages/motion_library_page.dart';
import '../../features/settings/presentation/pages/default_routine_page.dart';
import '../../features/settings/presentation/pages/manual_control_page.dart';
import '../../features/vision/presentation/pages/camera_calibration_page.dart';

// Developer / hidden
import '../../features/developer_tools/presentation/developer_dashboard_screen.dart';

// Legacy screens (kept routable for backward compatibility)
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/training/presentation/training_screen.dart';
import '../../features/manual_control/presentation/manual_control_screen.dart';
import '../../features/auto_cleaning/presentation/auto_cleaning_screen.dart';
import '../../features/aruco_scanner/presentation/aruco_scanner_screen.dart';
import '../../features/connection/presentation/connection_screen.dart';
import '../../features/maintenance/presentation/maintenance_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    // ── Operator shell (Home + Settings two-tab nav) ──────────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        // Branch 0 – Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),

        // Branch 1 – Settings
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.settings,
              builder: (context, state) => const SettingsScreen(),
              routes: [
                GoRoute(
                  path: 'teaching',
                  builder: (context, state) => const TeachingPage(),
                ),
                GoRoute(
                  path: 'motion-library',
                  builder: (context, state) => const MotionLibraryPage(),
                ),
                GoRoute(
                  path: 'default-routine',
                  builder: (context, state) => const DefaultRoutinePage(),
                ),
                GoRoute(
                  path: 'manual-control',
                  builder: (context, state) => const ManualControlPage(),
                ),
                GoRoute(
                  path: 'camera-calibration',
                  builder: (context, state) => const CameraCalibrationPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),

    // ── Developer Center (hidden, accessed from Settings) ─────────────────
    GoRoute(
      path: AppRoutes.developerCenter,
      builder: (context, state) => const DeveloperDashboardScreen(),
    ),

    // ── Legacy / compatibility routes ─────────────────────────────────────
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
  ],
);
