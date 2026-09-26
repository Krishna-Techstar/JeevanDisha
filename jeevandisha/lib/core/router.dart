import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/activity_screen.dart';
import '../screens/goals_screen.dart';
import '../screens/home_screen.dart';
import '../screens/journey_screen.dart';
import '../screens/login_screen.dart';
import '../screens/module_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/progress_screen.dart';
import '../screens/register_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/stress_screen.dart';
import '../screens/study_screen.dart';
import '../screens/support_screen.dart';
import '../screens/welcome_screen.dart';
import '../widgets/bottom_nav.dart';
import 'theme.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, _) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (_, _) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, _) => const RegisterScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (_, _) => const NoTransitionPage(child: HomeBody()),
          ),
          GoRoute(
            path: '/journey',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: JourneyScreen(embedded: true)),
          ),
          GoRoute(
            path: '/study',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: StudyScreen()),
          ),
          GoRoute(
            path: '/goals',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: GoalsScreen(embedded: true)),
          ),
          GoRoute(
            path: '/progress',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: ProgressScreen(embedded: true)),
          ),
          GoRoute(
            path: '/support',
            pageBuilder: (_, _) =>
                const NoTransitionPage(child: SupportScreen(embedded: true)),
          ),
        ],
      ),
      GoRoute(
        path: '/modules/:id',
        builder: (_, state) =>
            ModuleScreen(moduleId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/module/:id',
        builder: (_, state) =>
            ModuleScreen(moduleId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/activities/:id',
        builder: (_, state) =>
            ActivityScreen(activityId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/stress', builder: (_, _) => const StressScreen()),
      GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
    ],
  );
});

/// Navigation shell: blob background + glass bottom nav.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _tabs = ['/home', '/journey', '/study', '/goals', '/progress'];

  int _index(String location) {
    final i = _tabs.indexWhere((t) => location.startsWith(t));
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _index(location);

    return JeevanBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: child,
        bottomNavigationBar: BottomNav(
          currentIndex: index,
          onTap: (i) => context.go(_tabs[i]),
        ),
      ),
    );
  }
}
