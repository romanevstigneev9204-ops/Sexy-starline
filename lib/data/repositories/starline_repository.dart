import 'dart:convert';

import 'package:drift/drift.dart';

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
import '../remote/starline_mappers.dart';

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
  List<VehicleEvent> _cachedEvents = const [];
  String? _cachedEventsDeviceId;
  bool rateLimited = false;

  bool get useMock => _api.useMock;

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
    String? captchaSid,
  }) {
    return _api.login(
      login: login,
      password: password,
      captchaOrSms: captchaOrSms,
      captchaSid: captchaSid,
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
    _cachedEvents = const [];
    _cachedEventsDeviceId = null;
    rateLimited = false;
  }

  Future<List<Device>> devices({bool force = false}) async {
    if (!force && _cachedDevices.isNotEmpty) return _cachedDevices;
    try {
      final list = await _api.fetchDevices();
      final primaryId = await _sessionStore.readPrimaryDeviceId();
      _cachedDevices = list
          .map(
            (d) => d.copyWith(
              isPrimary: primaryId != null
                  ? d.id == primaryId
                  : d.isPrimary || d.id == list.first.id,
            ),
          )
          .toList();
      if (primaryId == null && _cachedDevices.isNotEmpty) {
        await _sessionStore.savePrimaryDeviceId(_cachedDevices.first.id);
      }
      await _persistDevices(_cachedDevices);
      rateLimited = false;
      return _cachedDevices;
    } on StarlineApiException catch (e) {
      if (e.isRateLimited) {
        rateLimited = true;
        if (_cachedDevices.isNotEmpty) return _cachedDevices;
        final fromDb = await _loadDevicesFromDb();
        if (fromDb.isNotEmpty) {
          _cachedDevices = fromDb;
          return fromDb;
        }
      }
      rethrow;
    }
  }

  Future<void> setPrimaryDevice(String id) async {
    await _sessionStore.savePrimaryDeviceId(id);
    _cachedDevices = _cachedDevices
        .map((d) => d.copyWith(isPrimary: d.id == id))
        .toList();
    await _persistDevices(_cachedDevices);
  }

  Future<String?> primaryDeviceId() => _sessionStore.readPrimaryDeviceId();

  Future<DeviceState> refreshState(
    String deviceId, {
    bool force = false,
    Duration staleAfter = const Duration(seconds: 90),
  }) async {
    if (!force &&
        _cachedState != null &&
        _cachedState!.deviceId == deviceId &&
        _cachedState!.age < staleAfter) {
      return _cachedState!;
    }
    try {
      final state = await _api.fetchDeviceState(deviceId);
      _cachedState = state;
      await _persistState(state);
      rateLimited = false;
      return state;
    } on StarlineApiException catch (e) {
      if (e.isRateLimited) {
        rateLimited = true;
        if (_cachedState != null && _cachedState!.deviceId == deviceId) {
          return _cachedState!;
        }
        final fromDb = await _loadStateFromDb(deviceId);
        if (fromDb != null) {
          _cachedState = fromDb;
          return fromDb;
        }
      }
      rethrow;
    }
  }

  DeviceState? get cachedState => _cachedState;

  Future<void> sendCommand(String deviceId, DeviceCommand command) async {
    try {
      await _api.sendCommand(deviceId, command);
      rateLimited = false;
      // Force refresh after command.
      _cachedState = await _api.fetchDeviceState(deviceId);
      await _persistState(_cachedState!);
    } on StarlineApiException catch (e) {
      if (e.isRateLimited) rateLimited = true;
      rethrow;
    }
  }

  Future<List<VehicleEvent>> events(
    String deviceId, {
    bool force = false,
  }) async {
    if (!force &&
        _cachedEventsDeviceId == deviceId &&
        _cachedEvents.isNotEmpty) {
      return _cachedEvents;
    }
    try {
      final list = await _api.fetchEvents(deviceId);
      _cachedEvents = list;
      _cachedEventsDeviceId = deviceId;
      rateLimited = false;
      return list;
    } on StarlineApiException catch (e) {
      if (e.isRateLimited) {
        rateLimited = true;
        if (_cachedEventsDeviceId == deviceId && _cachedEvents.isNotEmpty) {
          return _cachedEvents;
        }
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

  Future<void> _persistDevices(List<Device> devices) async {
    await _db.batch((batch) {
      batch.deleteAll(_db.devicesTable);
      for (final d in devices) {
        batch.insert(
          _db.devicesTable,
          DevicesTableCompanion.insert(
            id: d.id,
            alias: d.alias,
            payloadJson: jsonEncode({
              'typeName': d.typeName,
              'imei': d.imei,
              'online': d.online,
              'gsmLevel': d.gsmLevel,
              'functions': d.functions,
              'controls': d.controls,
              'isShared': d.isShared,
            }),
            isPrimary: Value(d.isPrimary),
            isShared: Value(d.isShared),
          ),
        );
      }
    });
  }

  Future<List<Device>> _loadDevicesFromDb() async {
    final rows = await _db.select(_db.devicesTable).get();
    return rows.map((row) {
      final payload = jsonDecode(row.payloadJson) as Map<String, dynamic>;
      return Device(
        id: row.id,
        alias: row.alias,
        typeName: payload['typeName']?.toString(),
        imei: payload['imei']?.toString(),
        online: payload['online'] == true,
        gsmLevel: StarlineMappers.asInt(payload['gsmLevel']),
        functions: StarlineMappers.stringList(payload['functions']),
        controls: StarlineMappers.stringList(payload['controls']),
        isPrimary: row.isPrimary,
        isShared: row.isShared,
      );
    }).toList();
  }

  Future<void> _persistState(DeviceState state) async {
    await _db.into(_db.deviceStatesTable).insertOnConflictUpdate(
          DeviceStatesTableCompanion.insert(
            deviceId: state.deviceId,
            payloadJson: jsonEncode({
              'armed': state.armed,
              'engineRunning': state.engineRunning,
              'alarm': state.alarm,
              'doorsClosed': state.doorsClosed,
              'online': state.online,
              'batteryVolts': state.batteryVolts,
              'cabinTempC': state.cabinTempC,
              'engineTempC': state.engineTempC,
              'gsmLevel': state.gsmLevel,
              'latitude': state.latitude,
              'longitude': state.longitude,
              'address': state.address,
            }),
            updatedAt: state.updatedAt,
          ),
        );
  }

  Future<DeviceState?> _loadStateFromDb(String deviceId) async {
    final row = await (_db.select(_db.deviceStatesTable)
          ..where((t) => t.deviceId.equals(deviceId)))
        .getSingleOrNull();
    if (row == null) return null;
    final p = jsonDecode(row.payloadJson) as Map<String, dynamic>;
    return DeviceState(
      deviceId: deviceId,
      updatedAt: row.updatedAt,
      armed: p['armed'] == true,
      engineRunning: p['engineRunning'] == true,
      alarm: p['alarm'] == true,
      doorsClosed: p['doorsClosed'] != false,
      online: p['online'] != false,
      batteryVolts: StarlineMappers.asDouble(p['batteryVolts']),
      cabinTempC: StarlineMappers.asDouble(p['cabinTempC']),
      engineTempC: StarlineMappers.asDouble(p['engineTempC']),
      gsmLevel: StarlineMappers.asInt(p['gsmLevel']),
      latitude: StarlineMappers.asDouble(p['latitude']),
      longitude: StarlineMappers.asDouble(p['longitude']),
      address: p['address']?.toString(),
    );
  }
}
