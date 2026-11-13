import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import '../../core/config/env.dart';
import '../../domain/entities/command.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/device_state.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/session.dart';
import '../mock/mock_catalog.dart';
import 'starline_api_exception.dart';

typedef OnRequestCounted = Future<void> Function();

/// Skeleton SLID → SLNet client. Uses mock catalog when credentials missing.
class StarlineApiClient {
  StarlineApiClient({
    Dio? slidDio,
    Dio? apiDio,
    this.onRequestCounted,
    bool? useMock,
  })  : useMock = useMock ?? Env.useMock,
        _slid = slidDio ??
            Dio(
              BaseOptions(
                baseUrl: Env.slidBaseUrl,
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 20),
              ),
            ),
        _api = apiDio ??
            Dio(
              BaseOptions(
                baseUrl: Env.apiBaseUrl,
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 20),
              ),
            ) {
    _api.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final cookie = _slnet;
          if (cookie != null && cookie.isNotEmpty) {
            options.headers['Cookie'] = 'slnet=$cookie';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          final status = error.response?.statusCode;
          if (status == 429) {
            handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                response: error.response,
                error: StarlineApiException(
                  'Exceeding limit',
                  statusCode: 429,
                  code: 'rate_limit',
                ),
                type: DioExceptionType.badResponse,
              ),
            );
            return;
          }
          handler.next(error);
        },
      ),
    );
  }

  final Dio _slid;
  final Dio _api;
  final bool useMock;
  final OnRequestCounted? onRequestCounted;

  String? _slnet;
  String? _userId;

  // In-memory mock command mutations.
  final Map<String, DeviceState> _mockStates = {};

  void attachSession(Session session) {
    _slnet = session.slnet;
    _userId = session.userId;
  }

  void clearSession() {
    _slnet = null;
    _userId = null;
  }

  Future<void> _count() async {
    await onRequestCounted?.call();
  }

  static String _md5(String input) =>
      md5.convert(utf8.encode(input)).toString();

  static String _sha1(String input) =>
      sha1.convert(utf8.encode(input)).toString();

  /// Full SLID → SLNet login. Captcha/SMS not fully wired — returns needExtra.
  Future<LoginResult> login({
    required String login,
    required String password,
    String? captchaOrSms,
  }) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      final session = Session(
        slnet: 'demo-slnet',
        userId: 'demo-user',
        demo: true,
      );
      attachSession(session);
      return LoginResult.ok(session);
    }

    if (!Env.hasCredentials) {
      throw StarlineApiException(
        'STARLINE_APP_ID / STARLINE_APP_SECRET не заданы',
        code: 'missing_credentials',
      );
    }

    await _count();
    final codeRes = await _slid.get<Map<String, dynamic>>(
      '/apiV3/application/getCode',
      queryParameters: {
        'appId': Env.appId,
        'secret': _md5(Env.appSecret),
      },
    );
    final appCode = codeRes.data?['code']?.toString();
    if (appCode == null) {
      throw StarlineApiException('getCode: нет code');
    }

    await _count();
    final tokenRes = await _slid.get<Map<String, dynamic>>(
      '/apiV3/application/getToken',
      queryParameters: {
        'appId': Env.appId,
        'secret': _md5('${Env.appSecret}$appCode'),
      },
    );
    final appToken = tokenRes.data?['token']?.toString();
    if (appToken == null) {
      throw StarlineApiException('getToken: нет token');
    }

    await _count();
    final loginBody = <String, dynamic>{
      'login': login,
      'pass': _sha1(password),
      'token': appToken,
    };
    if (captchaOrSms != null && captchaOrSms.isNotEmpty) {
      loginBody['code'] = captchaOrSms;
    }
    final userRes = await _slid.post<Map<String, dynamic>>(
      '/apiV3/user/login',
      data: loginBody,
    );
    final data = userRes.data ?? {};
    if (data['captcha'] == true || data['sms'] == true) {
      return LoginResult.needsExtra(
        captcha: data['captcha'] == true,
        sms: data['sms'] == true,
      );
    }
    final userToken = data['user_token']?.toString() ?? data['token']?.toString();
    if (userToken == null) {
      throw StarlineApiException('login: нет user_token');
    }

    await _count();
    final authRes = await _api.post<Map<String, dynamic>>(
      '/json/v2/auth.slid',
      data: {'slid_token': userToken},
    );
    final auth = authRes.data ?? {};
    final cookies = authRes.headers['set-cookie'] ?? [];
    String? slnet;
    for (final c in cookies) {
      final match = RegExp(r'slnet=([^;]+)').firstMatch(c);
      if (match != null) {
        slnet = match.group(1);
        break;
      }
    }
    slnet ??= auth['slnet']?.toString();
    final userId = auth['user_id']?.toString();
    if (slnet == null || userId == null) {
      throw StarlineApiException('auth.slid: нет slnet/user_id');
    }
    final session = Session(slnet: slnet, userId: userId);
    attachSession(session);
    return LoginResult.ok(session);
  }

  Future<List<Device>> fetchDevices() async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return List.of(MockCatalog.devices);
    }
    final userId = _userId;
    if (userId == null) {
      throw StarlineApiException('Нет сессии', statusCode: 401);
    }
    await _count();
    try {
      final res = await _api.get<Map<String, dynamic>>(
        '/json/v2/user/$userId/user_info',
      );
      return _mapDevices(res.data ?? {});
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<DeviceState> fetchDeviceState(String deviceId) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return _mockStates.putIfAbsent(
        deviceId,
        () => MockCatalog.stateFor(deviceId),
      );
    }
    await _count();
    try {
      final res = await _api.get<Map<String, dynamic>>(
        '/json/v3/device/$deviceId/data',
      );
      return _mapState(deviceId, res.data ?? {});
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<void> sendCommand(String deviceId, DeviceCommand command) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      final current = await fetchDeviceState(deviceId);
      final next = switch (command) {
        DeviceCommand.arm => current.copyWith(
            armed: true,
            updatedAt: DateTime.now(),
          ),
        DeviceCommand.disarm => current.copyWith(
            armed: false,
            updatedAt: DateTime.now(),
          ),
        DeviceCommand.start => current.copyWith(
            engineRunning: true,
            updatedAt: DateTime.now(),
          ),
        DeviceCommand.stop => current.copyWith(
            engineRunning: false,
            updatedAt: DateTime.now(),
          ),
        DeviceCommand.horn => current.copyWith(updatedAt: DateTime.now()),
      };
      _mockStates[deviceId] = next;
      return;
    }
    await _count();
    try {
      await _api.post<Map<String, dynamic>>(
        '/json/v1/device/$deviceId/set_param',
        data: {command.apiKey: 1},
      );
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<List<VehicleEvent>> fetchEvents(
    String deviceId, {
    DateTime? from,
    DateTime? to,
  }) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return MockCatalog.eventsFor(deviceId);
    }
    final periodStart =
        (from ?? DateTime.now().subtract(const Duration(days: 1)))
            .millisecondsSinceEpoch ~/
            1000;
    final periodEnd =
        (to ?? DateTime.now()).millisecondsSinceEpoch ~/ 1000;
    await _count();
    try {
      final res = await _api.post<Map<String, dynamic>>(
        '/json/v1/device/$deviceId/events',
        data: {
          'period_start': periodStart,
          'period_end': periodEnd,
        },
      );
      return _mapEvents(deviceId, res.data ?? {});
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Never _rethrow(DioException e) {
    final nested = e.error;
    if (nested is StarlineApiException) throw nested;
    throw StarlineApiException(
      e.message ?? 'network error',
      statusCode: e.response?.statusCode,
    );
  }

  List<Device> _mapDevices(Map<String, dynamic> json) {
    final devices = <Device>[];
    void addList(dynamic raw, {required bool shared}) {
      if (raw is! List) return;
      for (final item in raw) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        devices.add(
          Device(
            id: '${map['device_id'] ?? map['id'] ?? ''}',
            alias: '${map['alias'] ?? map['name'] ?? 'Устройство'}',
            typeName: map['typename']?.toString() ?? map['type']?.toString(),
            imei: map['imei']?.toString(),
            online: map['online'] == true || map['status'] == 1,
            gsmLevel: int.tryParse('${map['gsm_lvl'] ?? map['gsm'] ?? ''}'),
            functions: _stringList(map['functions']),
            controls: _stringList(map['controls']),
            isShared: shared,
          ),
        );
      }
    }

    addList(json['devices'], shared: false);
    addList(json['shared_devices'], shared: true);
    if (devices.isNotEmpty) {
      devices[0] = devices[0].copyWith(isPrimary: true);
    }
    return devices;
  }

  DeviceState _mapState(String deviceId, Map<String, dynamic> json) {
    final state = json['state'] is Map
        ? Map<String, dynamic>.from(json['state'] as Map)
        : json;
    final pos = json['position'] is Map
        ? Map<String, dynamic>.from(json['position'] as Map)
        : <String, dynamic>{};
    return DeviceState(
      deviceId: deviceId,
      updatedAt: DateTime.now(),
      armed: state['arm'] == true || state['arm'] == 1,
      engineRunning: state['engine'] == true ||
          state['run'] == true ||
          state['r_start'] == true,
      alarm: state['alarm'] == true || state['alarm'] == 1,
      doorsClosed: state['door'] != true && state['doors_open'] != true,
      online: state['online'] != false,
      batteryVolts: double.tryParse('${state['battery'] ?? state['akb'] ?? ''}'),
      cabinTempC: double.tryParse('${state['ctemp'] ?? ''}'),
      engineTempC: double.tryParse('${state['etemp'] ?? ''}'),
      gsmLevel: int.tryParse('${state['gsm_lvl'] ?? state['gsm'] ?? ''}'),
      latitude: double.tryParse('${pos['x'] ?? pos['lat'] ?? ''}'),
      longitude: double.tryParse('${pos['y'] ?? pos['lon'] ?? ''}'),
    );
  }

  List<VehicleEvent> _mapEvents(String deviceId, Map<String, dynamic> json) {
    final raw = json['events'] ?? json['data'] ?? [];
    if (raw is! List) return const [];
    return raw.whereType<Map>().map((item) {
      final map = Map<String, dynamic>.from(item);
      final ts = int.tryParse('${map['ts'] ?? map['time'] ?? ''}');
      return VehicleEvent(
        id: '${map['id'] ?? ts ?? map.hashCode}',
        deviceId: deviceId,
        title: '${map['title'] ?? map['event'] ?? map['type'] ?? 'Событие'}',
        timestamp: ts == null
            ? DateTime.now()
            : DateTime.fromMillisecondsSinceEpoch(ts * 1000),
        kind: _kindFrom(map),
      );
    }).toList();
  }

  EventKind _kindFrom(Map<String, dynamic> map) {
    final t = '${map['type'] ?? map['event'] ?? ''}'.toLowerCase();
    if (t.contains('alarm') || t.contains('тревог')) return EventKind.alarm;
    if (t.contains('arm') ||
        t.contains('start') ||
        t.contains('команд') ||
        t.contains('disarm')) {
      return EventKind.command;
    }
    if (t.contains('online') || t.contains('status')) return EventKind.status;
    return EventKind.other;
  }

  List<String> _stringList(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map((e) => '$e').toList();
  }
}

class LoginResult {
  LoginResult._({
    this.session,
    this.needsCaptcha = false,
    this.needsSms = false,
  });

  factory LoginResult.ok(Session session) => LoginResult._(session: session);

  factory LoginResult.needsExtra({bool captcha = false, bool sms = false}) =>
      LoginResult._(needsCaptcha: captcha, needsSms: sms);

  final Session? session;
  final bool needsCaptcha;
  final bool needsSms;

  bool get isOk => session != null;
  bool get needsExtra => needsCaptcha || needsSms;
}
