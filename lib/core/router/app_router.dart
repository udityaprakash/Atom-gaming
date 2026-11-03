import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/analytics/presentation/analytics_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/rooms/presentation/rooms_screen.dart';
import '../../features/sessions/presentation/sessions_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../shared/widgets/app_scaffold.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppScaffold(navigationShell: navigationShell);
      },
      branches: [
        // Tab 1: Dashboard
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        // Tab 2: Rooms Management
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/rooms',
              builder: (context, state) => const RoomsScreen(),
            ),
          ],
        ),
        // Tab 3: Sessions & History
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/sessions',
              builder: (context, state) => const SessionsScreen(),
            ),
          ],
        ),
        // Tab 4: Analytics
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/analytics',
              builder: (context, state) => const AnalyticsScreen(),
            ),
          ],
        ),
        // Tab 5: Settings
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
