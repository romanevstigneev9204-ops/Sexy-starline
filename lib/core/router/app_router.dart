import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/auth/auth_controller.dart';
import '../../application/providers.dart';
import '../../presentation/screens/devices/devices_screen.dart';
import '../../presentation/screens/events/events_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/login/captcha_screen.dart';
import '../../presentation/screens/login/login_screen.dart';
import '../../presentation/screens/map/map_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/shell/app_shell.dart';

final _rootKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/splash',
    refreshListenable: _AuthRefresh(ref),
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final status = auth.status;

      if (status == AuthStatus.unknown) {
        return loc == '/splash' ? null : '/splash';
      }
      if (status == AuthStatus.unauthenticated ||
          status == AuthStatus.needsExtra) {
        if (loc == '/login' || loc == '/captcha') return null;
        return '/login';
      }
      // authenticated
      if (loc == '/splash' || loc == '/login' || loc == '/captcha') {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/captcha',
        builder: (_, __) => const CaptchaScreen(),
      ),
      GoRoute(
        path: '/devices',
        builder: (_, __) => const DevicesScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const SettingsScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (_, __) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/map',
                builder: (_, __) => const MapScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/events',
                builder: (_, __) => const EventsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(this._ref) {
    _ref.listen<AuthState>(authControllerProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
}
