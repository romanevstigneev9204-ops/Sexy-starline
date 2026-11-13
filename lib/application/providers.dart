import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/env.dart';
import '../core/l10n/app_strings.dart';
import '../data/local/app_database.dart';
import '../data/local/geofence_store.dart';
import '../data/local/secure_session_store.dart';
import '../data/remote/starline_api_client.dart';
import '../data/repositories/starline_repository.dart';
import '../domain/entities/api_budget.dart';
import '../domain/entities/device.dart';
import '../domain/entities/device_state.dart';
import '../domain/entities/session.dart';
import '../domain/widgets/home_widget_payload.dart';
import 'auth/auth_controller.dart';
import 'events/events_controller.dart';
import 'geofences/geofences_controller.dart';
import 'home/home_controller.dart';
import 'locale/locale_preference.dart';
import 'obd/obd_controller.dart';
import 'tracks/tracks_controller.dart';
import 'widgets/home_widget_bridge.dart';

final envDemoProvider = Provider<bool>((ref) => Env.useMock);

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final secureStoreProvider = Provider<SecureSessionStore>((ref) {
  // Demo / no credentials: in-memory only — no Linux keyring prompts.
  return SecureSessionStore(memoryOnly: ref.watch(envDemoProvider));
});

final apiClientProvider = Provider<StarlineApiClient>((ref) {
  final db = ref.watch(databaseProvider);
  return StarlineApiClient(
    onRequestCounted: () => db.incrementRequestCount(),
  );
});

final repositoryProvider = Provider<StarlineRepository>((ref) {
  return StarlineRepository(
    api: ref.watch(apiClientProvider),
    sessionStore: ref.watch(secureStoreProvider),
    db: ref.watch(databaseProvider),
  );
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.watch(repositoryProvider));
});

final sessionProvider = Provider<Session?>((ref) {
  return ref.watch(authControllerProvider).session;
});

final geofenceStoreProvider = Provider<GeofenceStore>((ref) {
  return GeofenceStore(ref.watch(databaseProvider));
});

final geofencesControllerProvider =
    StateNotifierProvider<GeofencesController, GeofencesState>((ref) {
  return GeofencesController(
    store: ref.watch(geofenceStoreProvider),
    useMock: ref.watch(envDemoProvider) ||
        ref.watch(repositoryProvider).useMock,
  );
});

final homeWidgetBridgeProvider = Provider<HomeWidgetBridge>((ref) {
  return HomeWidgetBridge();
});

/// Pending deep-link action from the Android home-screen widget.
final pendingHomeWidgetActionProvider =
    StateProvider<HomeWidgetAction?>((ref) => null);

/// Works with both [Ref.read] and [WidgetRef.read] tear-offs.
void syncHomeWidget(T Function<T>(ProviderListenable<T> provider) read) {
  final auth = read(authControllerProvider);
  final home = read(homeControllerProvider);
  final lang = read(localePreferenceProvider);
  unawaited(
    read(homeWidgetBridgeProvider).syncFromHome(
      hasSession: auth.status == AuthStatus.authenticated,
      device: home.device,
      state: home.state,
      localeIsRussian: lang == AppLanguage.ru,
    ),
  );
}

final homeControllerProvider =
    StateNotifierProvider<HomeController, HomeState>((ref) {
  final controller = HomeController(ref.watch(repositoryProvider));
  controller.onBudgetChanged = () {
    ref.invalidate(budgetProvider);
  };
  // Client geofences evaluate cached GPS — no extra StarLine requests.
  // Home widget mirrors the same snapshot (no extra StarLine poll).
  controller.onStateUpdated = (ds) {
    ref.read(geofencesControllerProvider.notifier).evaluate(ds);
    syncHomeWidget(ref.read);
  };
  return controller;
});

final eventsControllerProvider =
    StateNotifierProvider<EventsController, EventsState>((ref) {
  return EventsController(ref.watch(repositoryProvider));
});

final tracksControllerProvider =
    StateNotifierProvider<TracksController, TracksState>((ref) {
  return TracksController(ref.watch(repositoryProvider));
});

final obdControllerProvider =
    StateNotifierProvider<ObdController, ObdState>((ref) {
  return ObdController(ref.watch(repositoryProvider));
});

final devicesProvider = FutureProvider<List<Device>>((ref) async {
  final repo = ref.watch(repositoryProvider);
  return repo.devices();
});

final budgetProvider = FutureProvider<ApiBudget>((ref) async {
  return ref.watch(repositoryProvider).budget();
});

final activeDeviceStateProvider = Provider<DeviceState?>((ref) {
  return ref.watch(homeControllerProvider).state;
});
