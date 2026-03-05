/// Flux Application - App Router
///
/// Centralized route configuration using go_router.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/dashboard/presentation/pages/dashboard_screen.dart';
import '../features/goals/presentation/pages/goals_screen.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/home/presentation/pages/splash_screen.dart';
import '../features/settings/presentation/pages/settings_screen.dart';
import '../features/statistics/presentation/pages/statistics_screen.dart';
import '../features/subscriptions/presentation/pages/subscriptions_screen.dart';
import '../features/transactions/presentation/pages/history_screen.dart';
import '../features/auth/presentation/pages/auth_check_screen.dart';

/// Route path constants.
abstract final class RoutePaths {
  static const String splash = '/splash';
  static const String auth = '/auth';
  static const String dashboard = '/';
  static const String statistics = '/statistics';
  static const String history = '/history';
  static const String subscriptions = '/subscriptions';
  static const String settings = '/settings';
  static const String goals = '/goals';
}

/// Route name constants.
abstract final class RouteNames {
  static const String splash = 'splash';
  static const String auth = 'auth';
  static const String dashboard = 'dashboard';
  static const String statistics = 'statistics';
  static const String history = 'history';
  static const String subscriptions = 'subscriptions';
  static const String settings = 'settings';
  static const String goals = 'goals';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _dashboardNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'dashboard');
final _statisticsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'statistics');
final _historyNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'history');
final _settingsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'settings');

/// Application router configuration.
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: RoutePaths.splash,
  debugLogDiagnostics: true,
  routes: <RouteBase>[
    // Animated Splash Screen
    GoRoute(
      path: RoutePaths.splash,
      name: RouteNames.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    // Auth Check Screen
    GoRoute(
      path: RoutePaths.auth,
      name: RouteNames.auth,
      pageBuilder: (context, state) => _buildPage(
        state: state,
        child: const AuthCheckScreen(),
      ),
    ),
    // Main navigation shell with bottom tab bar
    StatefulShellRoute(
      builder: (context, state, navigationShell) {
        return HomePage(navigationShell: navigationShell);
      },
      navigatorContainerBuilder: (context, navigationShell, children) {
        return _AnimatedBranchContainer(
          currentIndex: navigationShell.currentIndex,
          children: children,
        );
      },
      branches: [
        // Tab 0: Dashboard Branch
        StatefulShellBranch(
          navigatorKey: _dashboardNavigatorKey,
          routes: [
            GoRoute(
              path: RoutePaths.dashboard,
              name: RouteNames.dashboard,
              pageBuilder: (context, state) => _buildPage(
                state: state,
                child: const DashboardScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'subscriptions',
                  name: RouteNames.subscriptions,
                  pageBuilder: (context, state) => _buildPage(
                    state: state,
                    child: const SubscriptionsScreen(),
                  ),
                ),
                GoRoute(
                  path: 'goals',
                  name: RouteNames.goals,
                  pageBuilder: (context, state) => _buildPage(
                    state: state,
                    child: const GoalsScreen(),
                  ),
                ),
              ],
            ),
          ],
        ),
        // Tab 1: Statistics Branch
        StatefulShellBranch(
          navigatorKey: _statisticsNavigatorKey,
          routes: [
            GoRoute(
              path: RoutePaths.statistics,
              name: RouteNames.statistics,
              pageBuilder: (context, state) => _buildPage(
                state: state,
                child: const StatisticsScreen(),
              ),
            ),
          ],
        ),
        // Tab 2: History Branch
        StatefulShellBranch(
          navigatorKey: _historyNavigatorKey,
          routes: [
            GoRoute(
              path: RoutePaths.history,
              name: RouteNames.history,
              pageBuilder: (context, state) => _buildPage(
                state: state,
                child: const HistoryScreen(),
              ),
            ),
          ],
        ),
        // Tab 3: Settings Branch
        StatefulShellBranch(
          navigatorKey: _settingsNavigatorKey,
          routes: [
            GoRoute(
              path: RoutePaths.settings,
              name: RouteNames.settings,
              pageBuilder: (context, state) => _buildPage(
                state: state,
                child: const SettingsScreen(),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
  errorPageBuilder: (context, state) => _buildPage(
    state: state,
    child: _ErrorPage(error: state.error),
  ),
);

/// Builds a custom transition page with a subtle fade effect.
CustomTransitionPage<void> _buildPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curveAnim = CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn);
      final scaleAnim = Tween<double>(begin: 0.98, end: 1.0).animate(curveAnim);
      
      return FadeTransition(
        opacity: curveAnim,
        child: ScaleTransition(
          scale: scaleAnim,
          child: child,
        ),
      );
    },
  );
}

/// A simple error page for unresolvable routes.
class _ErrorPage extends StatelessWidget {
  const _ErrorPage({this.error});

  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Oops! Page not found.',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error?.toString() ?? 'The requested page could not be found.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go(RoutePaths.dashboard),
                icon: const Icon(Icons.home_rounded),
                label: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A custom container that animates transitions between completely different StatefulShellBranches.
class _AnimatedBranchContainer extends StatefulWidget {
  const _AnimatedBranchContainer({
    required this.currentIndex,
    required this.children,
  });

  final int currentIndex;
  final List<Widget> children;

  @override
  State<_AnimatedBranchContainer> createState() => _AnimatedBranchContainerState();
}

class _AnimatedBranchContainerState extends State<_AnimatedBranchContainer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  late int _currentIndex;
  late int _previousIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    _previousIndex = widget.currentIndex;
    _controller = AnimationController(
      vsync: this, 
      duration: const Duration(milliseconds: 350),
    );
    final curve = CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(curve);
    _scaleAnimation = Tween<double>(begin: 0.98, end: 1.0).animate(curve);
    _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(_AnimatedBranchContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _previousIndex = oldWidget.currentIndex;
      _currentIndex = widget.currentIndex;
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          children: List.generate(widget.children.length, (index) {
            final child = widget.children[index];
            final isCurrent = index == _currentIndex;
            final isPrevious = index == _previousIndex;
            
            // If it's neither current nor previous, keep it offstage to retain state.
            if (!isCurrent && !isPrevious) {
               return Offstage(offstage: true, child: child);
            }

            final isTransitioning = _controller.isAnimating;

            if (isTransitioning) {
               if (isPrevious) {
                 // Cross-fade the outgoing page
                 final fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));
                 final scaleOut = Tween<double>(begin: 1.0, end: 0.98).animate(CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));
                 return FadeTransition(
                   opacity: fadeOut,
                   child: ScaleTransition(scale: scaleOut, child: child),
                 );
               } else if (isCurrent) {
                 // Cross-fade the incoming page
                 return FadeTransition(
                   opacity: _fadeAnimation,
                   child: ScaleTransition(scale: _scaleAnimation, child: child),
                 );
               }
            }

            // Normal state: show current, hide others inside Offstage.
            return Offstage(
              offstage: !isCurrent,
              child: child,
            );
          }),
        );
      },
    );
  }
}
