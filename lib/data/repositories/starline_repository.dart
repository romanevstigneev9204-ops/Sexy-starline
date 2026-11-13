import '../../domain/entities/api_budget.dart';
import '../../domain/entities/command.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/device_state.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/session.dart';
import '../local/app_database.dart';
import '../local/secure_session_store.dart';
import '../remote/starline_api_client.dart';
import '../remote/starline_api_exception.dart';

class StarlineRepository {
  StarlineRepository({
    required StarlineApiClient api,
    required SecureSessionStore sessionStore,
    required AppDatabase db,
  })  : _api = api,
        _sessionStore = sessionStore,
        _db = db;

  final StarlineApiClient _api;
  final SecureSessionStore _sessionStore;
  final AppDatabase _db;

  DeviceState? _cachedState;
  List<Device> _cachedDevices = const [];
  bool rateLimited = false;

  Future<Session?> restoreSession() async {
    final session = await _sessionStore.readSession();
    if (session != null) {
      _api.attachSession(session);
    }
    return session;
  }

  Future<LoginResult> login({
    required String login,
    required String password,
    String? captchaOrSms,
  }) {
    return _api.login(
      login: login,
      password: password,
      captchaOrSms: captchaOrSms,
    );
  }

  Future<void> persistSession(Session session) async {
    await _sessionStore.saveSession(session);
    _api.attachSession(session);
  }

  Future<void> logout() async {
    await _sessionStore.clearSession();
    _api.clearSession();
    _cachedState = null;
    _cachedDevices = const [];
    rateLimited = false;
  }

  Future<List<Device>> devices({bool force = false}) async {
    if (!force && _cachedDevices.isNotEmpty) return _cachedDevices;
    try {
      final list = await _api.fetchDevices();
      _cachedDevices = list;
      rateLimited = false;
      return list;
    } on StarlineApiException catch (e) {
      if (e.isRateLimited) {
        rateLimited = true;
        if (_cachedDevices.isNotEmpty) return _cachedDevices;
      }
      rethrow;
    }
  }

  Future<void> setPrimaryDevice(String id) async {
    await _sessionStore.savePrimaryDeviceId(id);
    _cachedDevices = _cachedDevices
        .map((d) => d.copyWith(isPrimary: d.id == id))
        .toList();
  }

  Future<String?> primaryDeviceId() => _sessionStore.readPrimaryDeviceId();

  Future<DeviceState> refreshState(String deviceId, {bool force = false}) async {
    if (!force &&
        _cachedState != null &&
        _cachedState!.deviceId == deviceId &&
        _cachedState!.age.inSeconds < 90) {
      return _cachedState!;
    }
    try {
      final state = await _api.fetchDeviceState(deviceId);
      _cachedState = state;
      rateLimited = false;
      return state;
    } on StarlineApiException catch (e) {
      if (e.isRateLimited) {
        rateLimited = true;
        if (_cachedState != null) return _cachedState!;
      }
      rethrow;
    }
  }

  DeviceState? get cachedState => _cachedState;

  Future<void> sendCommand(String deviceId, DeviceCommand command) async {
    try {
      await _api.sendCommand(deviceId, command);
      rateLimited = false;
      _cachedState = await _api.fetchDeviceState(deviceId);
    } on StarlineApiException catch (e) {
      if (e.isRateLimited) rateLimited = true;
      rethrow;
    }
  }

  Future<List<VehicleEvent>> events(String deviceId) async {
    try {
      final list = await _api.fetchEvents(deviceId);
      rateLimited = false;
      return list;
    } on StarlineApiException catch (e) {
      if (e.isRateLimited) {
        rateLimited = true;
      }
      rethrow;
    }
  }

  Future<ApiBudget> budget() async {
    final count = await _db.todayRequestCount();
    final now = DateTime.now();
    return ApiBudget(
      day: DateTime(now.year, now.month, now.day),
      requestCount: count == 0 && _api.useMock ? 180 : count,
    );
  }
}
