import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/entities/api_budget.dart';
import '../../domain/entities/command.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/device_state.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/obd_params.dart';
import '../../domain/entities/session.dart';
import '../../domain/entities/sim_balance.dart';
import '../../domain/entities/track.dart';
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
  ObdParams? _cachedObd;
  TrackPeriod? _cachedTracks;
  DateTime? _lastWaysFetchAt;
  bool rateLimited = false;
  bool lastWaysThrottled = false;

  /// OBD is refreshed rarely (HA default ~3h) — on-demand + cache.
  static const obdStaleAfter = Duration(hours: 3);

  /// StarLine: ways ≤24h total more often than once / 10 min per device.
  static const waysMinInterval = Duration(minutes: 10);

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
    _cachedObd = null;
    _cachedTracks = null;
    _lastWaysFetchAt = null;
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
      var state = await _api.fetchDeviceState(deviceId);
      // Balance often lives on user_info device rows; merge if data omit it.
      if (state.simBalance == null) {
        for (final d in _cachedDevices) {
          if (d.id == deviceId && d.simBalance != null) {
            state = state.copyWith(simBalance: d.simBalance);
            break;
          }
        }
      }
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

  ObdParams? get cachedObd => _cachedObd;

  Future<ObdParams?> obdParams(
    String deviceId, {
    bool force = false,
    Duration staleAfter = obdStaleAfter,
  }) async {
    final device = _deviceById(deviceId);
    if (device != null && !device.supportsObd) {
      return null;
    }
    if (!force &&
        _cachedObd != null &&
        _cachedObd!.deviceId == deviceId &&
        _cachedObd!.fetchedAt != null &&
        DateTime.now().difference(_cachedObd!.fetchedAt!) < staleAfter) {
      return _cachedObd;
    }
    try {
      final obd = await _api.fetchObdParams(deviceId);
      _cachedObd = obd;
      rateLimited = false;
      return obd;
    } on StarlineApiException catch (e) {
      if (e.code == 'obd_unsupported') return null;
      if (e.isRateLimited) {
        rateLimited = true;
        if (_cachedObd != null && _cachedObd!.deviceId == deviceId) {
          return _cachedObd;
        }
      }
      rethrow;
    }
  }

  TrackPeriod? get cachedTracks => _cachedTracks;

  Future<TrackPeriod> tracks(
    String deviceId, {
    DateTime? begin,
    DateTime? end,
    bool force = false,
  }) async {
    final now = DateTime.now();
    final periodBegin =
        begin ?? DateTime(now.year, now.month, now.day);
    final periodEnd = end ?? now;
    lastWaysThrottled = false;

    if (!force &&
        _cachedTracks != null &&
        _cachedTracks!.deviceId == deviceId &&
        _sameDay(_cachedTracks!.begin, periodBegin)) {
      return _cachedTracks!;
    }

    // StarLine: ways total ≤24h not more often than once / 10 min per device.
    if (force &&
        _lastWaysFetchAt != null &&
        now.difference(_lastWaysFetchAt!) < waysMinInterval &&
        _cachedTracks != null &&
        _cachedTracks!.deviceId == deviceId) {
      lastWaysThrottled = true;
      return _cachedTracks!;
    }

    try {
      final period = await _api.fetchWays(
        deviceId,
        begin: periodBegin,
        end: periodEnd,
      );
      _cachedTracks = period;
      _lastWaysFetchAt = now;
      rateLimited = false;
      lastWaysThrottled = false;
      return period;
    } on StarlineApiException catch (e) {
      if (e.isRateLimited) {
        rateLimited = true;
        if (_cachedTracks != null && _cachedTracks!.deviceId == deviceId) {
          return _cachedTracks!;
        }
      }
      rethrow;
    }
  }

  Device? _deviceById(String id) {
    for (final d in _cachedDevices) {
      if (d.id == id) return d;
    }
    return null;
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

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
              'phone': d.phone,
              'online': d.online,
              'gsmLevel': d.gsmLevel,
              'functions': d.functions,
              'controls': d.controls,
              'isShared': d.isShared,
              if (d.simBalance != null)
                'simBalance': {
                  'value': d.simBalance!.value,
                  'currency': d.simBalance!.currency,
                  'operatorName': d.simBalance!.operatorName,
                  'updatedAt': d.simBalance!.updatedAt?.toIso8601String(),
                },
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
        phone: payload['phone']?.toString(),
        online: payload['online'] == true,
        gsmLevel: StarlineMappers.asInt(payload['gsmLevel']),
        functions: StarlineMappers.stringList(payload['functions']),
        controls: StarlineMappers.stringList(payload['controls']),
        simBalance: _simBalanceFromPayload(payload['simBalance']),
        isPrimary: row.isPrimary,
        isShared: row.isShared,
      );
    }).toList();
  }

  SimBalance? _simBalanceFromPayload(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final updatedRaw = map['updatedAt']?.toString();
    return SimBalance(
      value: StarlineMappers.asDouble(map['value']),
      currency: '${map['currency'] ?? '₽'}',
      operatorName: map['operatorName']?.toString(),
      updatedAt:
          updatedRaw == null || updatedRaw.isEmpty ? null : DateTime.tryParse(updatedRaw),
    );
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
              'valet': state.valet,
              'batteryVolts': state.batteryVolts,
              'cabinTempC': state.cabinTempC,
              'engineTempC': state.engineTempC,
              'gsmLevel': state.gsmLevel,
              'latitude': state.latitude,
              'longitude': state.longitude,
              'address': state.address,
              if (state.simBalance != null)
                'simBalance': {
                  'value': state.simBalance!.value,
                  'currency': state.simBalance!.currency,
                  'operatorName': state.simBalance!.operatorName,
                  'updatedAt': state.simBalance!.updatedAt?.toIso8601String(),
                },
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
      valet: p['valet'] == true,
      batteryVolts: StarlineMappers.asDouble(p['batteryVolts']),
      cabinTempC: StarlineMappers.asDouble(p['cabinTempC']),
      engineTempC: StarlineMappers.asDouble(p['engineTempC']),
      gsmLevel: StarlineMappers.asInt(p['gsmLevel']),
      latitude: StarlineMappers.asDouble(p['latitude']),
      longitude: StarlineMappers.asDouble(p['longitude']),
      address: p['address']?.toString(),
      simBalance: _simBalanceFromPayload(p['simBalance']),
    );
  }
}
