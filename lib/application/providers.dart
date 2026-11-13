import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config/env.dart';
import '../data/local/app_database.dart';
import '../data/local/secure_session_store.dart';
import '../data/remote/starline_api_client.dart';
import '../data/repositories/starline_repository.dart';
import '../domain/entities/api_budget.dart';
import '../domain/entities/device.dart';
import '../domain/entities/device_state.dart';
import '../domain/entities/event.dart';
import '../domain/entities/session.dart';
import 'auth/auth_controller.dart';
import 'home/home_controller.dart';

final envDemoProvider = Provider<bool>((ref) => Env.useMock);

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final secureStoreProvider = Provider<SecureSessionStore>((ref) {
  return SecureSessionStore();
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

final homeControllerProvider =
    StateNotifierProvider<HomeController, HomeState>((ref) {
  return HomeController(ref.watch(repositoryProvider));
});

final devicesProvider = FutureProvider<List<Device>>((ref) async {
  final repo = ref.watch(repositoryProvider);
  return repo.devices();
});

final eventsProvider = FutureProvider.family<List<VehicleEvent>, String>(
  (ref, deviceId) async {
    return ref.watch(repositoryProvider).events(deviceId);
  },
);

final budgetProvider = FutureProvider<ApiBudget>((ref) async {
  return ref.watch(repositoryProvider).budget();
});

final activeDeviceStateProvider = Provider<DeviceState?>((ref) {
  return ref.watch(homeControllerProvider).state;
});
