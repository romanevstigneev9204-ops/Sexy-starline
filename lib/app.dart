import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'application/auth/auth_controller.dart';
import 'application/locale/locale_preference.dart';
import 'application/providers.dart';
import 'application/widgets/home_widget_launch.dart';
import 'core/l10n/app_strings.dart';
import 'core/router/app_router.dart';
import 'core/theme/night_drive_theme.dart';
import 'domain/widgets/home_widget_payload.dart';

class SexyStarlineApp extends ConsumerWidget {
  const SexyStarlineApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final language = ref.watch(localePreferenceProvider);
    S.bind(language);

    return MaterialApp.router(
      title: 'Sexy Starline',
      debugShowCheckedModeBanner: false,
      theme: buildNightDriveTheme(),
      locale: language.locale,
      supportedLocales: const [Locale('ru'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}

/// Bootstraps auth session restore once + home-widget deep links.
class AppBootstrap extends ConsumerStatefulWidget {
  const AppBootstrap({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends ConsumerState<AppBootstrap> {
  late final HomeWidgetLaunchListener _widgetLaunch;

  @override
  void initState() {
    super.initState();
    _widgetLaunch = HomeWidgetLaunchListener();
    _widgetLaunch.onAction = (action) {
      ref.read(pendingHomeWidgetActionProvider.notifier).state = action;
      final auth = ref.read(authControllerProvider);
      if (auth.status == AuthStatus.authenticated &&
          action != HomeWidgetAction.open) {
        // Prefer Home route so the screen can run confirm + command.
        final router = ref.read(routerProvider);
        router.go('/home');
      }
    };
    Future.microtask(() async {
      await ref.read(authControllerProvider.notifier).bootstrap();
      await _widgetLaunch.start();
      syncHomeWidget(ref.read);
    });
  }

  @override
  void dispose() {
    _widgetLaunch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (prev, next) {
      if (prev?.status == next.status) return;
      if (next.status == AuthStatus.unauthenticated) {
        final lang = ref.read(localePreferenceProvider);
        ref.read(homeWidgetBridgeProvider).clear(
              localeIsRussian: lang == AppLanguage.ru,
            );
      } else if (next.status == AuthStatus.authenticated) {
        syncHomeWidget(ref.read);
      }
    });
    return widget.child;
  }
}
