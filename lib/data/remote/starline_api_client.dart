import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import '../../core/config/env.dart';
import '../../domain/entities/command.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/device_state.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/obd_params.dart';
import '../../domain/entities/session.dart';
import '../../domain/entities/track.dart';
import '../mock/mock_catalog.dart';
import 'starline_api_exception.dart';
import 'starline_mappers.dart';

typedef OnRequestCounted = Future<void> Function();

/// SLID → SLNet + WebAPI client. Mock catalog when credentials missing.
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
                contentType: Headers.formUrlEncodedContentType,
                responseType: ResponseType.json,
              ),
            ),
        _api = apiDio ??
            Dio(
              BaseOptions(
                baseUrl: Env.apiBaseUrl,
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 20),
                contentType: Headers.jsonContentType,
                responseType: ResponseType.json,
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
          if (status == 401) {
            handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                response: error.response,
                error: StarlineApiException(
                  'Сессия истекла',
                  statusCode: 401,
                  code: 'unauthorized',
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

  final Map<String, DeviceState> _mockStates = {};

  void attachSession(Session session) {
    _slnet = session.slnet;
    _userId = session.userId;
  }

  void clearSession() {
    _slnet = null;
    _userId = null;
  }

  Future<void> _count() async => onRequestCounted?.call();

  static String md5Hex(String input) =>
      md5.convert(utf8.encode(input)).toString();

  static String sha1Hex(String input) =>
      sha1.convert(utf8.encode(input)).toString();

  Future<LoginResult> login({
    required String login,
    required String password,
    String? captchaOrSms,
    String? captchaSid,
  }) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      final normalized = login.trim().toLowerCase();

      // Demo SLID challenges — exercise captcha / SMS UI without AppId.
      if (normalized == 'demo-sms' || normalized == 'sms') {
        if (captchaOrSms == null || captchaOrSms.isEmpty) {
          return LoginResult.needsExtra(
            sms: true,
            maskedPhone: '+7 ••• ••• 12-34',
          );
        }
        if (captchaOrSms.replaceAll(RegExp(r'\D'), '') != '1234' &&
            captchaOrSms.trim() != '1234') {
          throw StarlineApiException('Неверный код SMS', code: 'bad_sms');
        }
      } else if (normalized == 'demo-captcha' || normalized == 'captcha') {
        if (captchaOrSms == null || captchaOrSms.isEmpty) {
          return LoginResult.needsExtra(
            captcha: true,
            captchaSid: 'demo-captcha-sid',
          );
        }
        if (captchaOrSms.trim().toLowerCase() != 'star' &&
            captchaOrSms.replaceAll(RegExp(r'\D'), '') != '1234') {
          throw StarlineApiException(
            'Неверная captcha',
            code: 'bad_captcha',
          );
        }
      }

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

    final appCode = await _getAppCode();
    final appToken = await _getAppToken(appCode);
    final slid = await _userLogin(
      appToken: appToken,
      login: login,
      password: password,
      captchaOrSms: captchaOrSms,
      captchaSid: captchaSid,
    );
    if (slid.needsExtra) return slid;
    final userToken = slid.userToken;
    if (userToken == null) {
      throw StarlineApiException('login: нет user_token');
    }
    final session = await _authSlid(userToken);
    attachSession(session);
    return LoginResult.ok(session);
  }

  Future<String> _getAppCode() async {
    await _count();
    final res = await _slid.get<Map<String, dynamic>>(
      '/apiV3/application/getCode/',
      queryParameters: {
        'appId': Env.appId,
        'secret': md5Hex(Env.appSecret),
      },
    );
    final data = res.data ?? {};
    if (!StarlineMappers.slidOk(data)) {
      throw StarlineApiException('getCode failed: ${data['state']}');
    }
    final code = StarlineMappers.slidDesc(data)['code']?.toString();
    if (code == null || code.isEmpty) {
      throw StarlineApiException('getCode: нет code');
    }
    return code;
  }

  Future<String> _getAppToken(String appCode) async {
    await _count();
    final res = await _slid.get<Map<String, dynamic>>(
      '/apiV3/application/getToken/',
      queryParameters: {
        'appId': Env.appId,
        'secret': md5Hex('${Env.appSecret}$appCode'),
      },
    );
    final data = res.data ?? {};
    if (!StarlineMappers.slidOk(data)) {
      throw StarlineApiException('getToken failed: ${data['state']}');
    }
    final token = StarlineMappers.slidDesc(data)['token']?.toString();
    if (token == null || token.isEmpty) {
      throw StarlineApiException('getToken: нет token');
    }
    return token;
  }

  Future<LoginResult> _userLogin({
    required String appToken,
    required String login,
    required String password,
    String? captchaOrSms,
    String? captchaSid,
  }) async {
    await _count();
    final form = <String, dynamic>{
      'login': login,
      'pass': sha1Hex(password),
    };
    if (captchaOrSms != null && captchaOrSms.isNotEmpty) {
      if (captchaSid != null && captchaSid.isNotEmpty) {
        form['captchaSid'] = captchaSid;
        form['captchaCode'] = captchaOrSms;
      } else {
        form['smsCode'] = captchaOrSms;
      }
    }

    final res = await _slid.post<Map<String, dynamic>>(
      '/apiV3/user/login/',
      queryParameters: {'token': appToken},
      data: form,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    final data = res.data ?? {};
    final state = StarlineMappers.asInt(data['state']) ?? -1;
    final desc = StarlineMappers.slidDesc(data);

    // state 1 = ok; 2 = sometimes also ok / partial; 0 + captcha/phone = extra
    if (state == 0 ||
        desc.containsKey('captchaSid') ||
        desc.containsKey('phone') ||
        desc.containsKey('smsCode')) {
      final phone = desc['phone']?.toString();
      return LoginResult.needsExtra(
        captcha: desc.containsKey('captchaSid'),
        sms: desc.containsKey('phone') || desc.containsKey('smsCode'),
        captchaSid: desc['captchaSid']?.toString(),
        maskedPhone: phone == null || phone.isEmpty ? null : _maskPhone(phone),
      );
    }
    if (state != 1 && state != 2) {
      throw StarlineApiException(
        'login state=$state: ${desc['message'] ?? data}',
      );
    }
    final userToken =
        desc['user_token']?.toString() ?? desc['token']?.toString();
    return LoginResult.token(userToken);
  }

  Future<Session> _authSlid(String slidToken) async {
    await _count();
    final res = await _api.post<Map<String, dynamic>>(
      '/json/v2/auth.slid',
      data: {'slid_token': slidToken},
    );
    final auth = res.data ?? {};
    if (!StarlineMappers.apiCodeOk(auth)) {
      throw StarlineApiException(
        auth['codestring']?.toString() ?? 'auth.slid failed',
        statusCode: StarlineMappers.asInt(auth['code']),
      );
    }

    String? slnet;
    final setCookie = res.headers.map['set-cookie'] ?? [];
    for (final c in setCookie) {
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
    return Session(slnet: slnet, userId: userId);
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
      final data = res.data ?? {};
      if (!StarlineMappers.apiCodeOk(data)) {
        throw StarlineApiException(
          data['codestring']?.toString() ?? 'user_info failed',
          statusCode: StarlineMappers.asInt(data['code']),
        );
      }
      return StarlineMappers.devicesFromUserInfo(data);
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
      final data = res.data ?? {};
      if (!StarlineMappers.apiCodeOk(data)) {
        throw StarlineApiException(
          data['codestring']?.toString() ?? 'device data failed',
          statusCode: StarlineMappers.asInt(data['code']),
        );
      }
      return StarlineMappers.deviceStateFromJson(deviceId, data);
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  Future<void> sendCommand(String deviceId, DeviceCommand command) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 450));
      final current = await fetchDeviceState(deviceId);
      final now = DateTime.now();
      final next = switch (command) {
        DeviceCommand.arm || DeviceCommand.quietArm =>
          current.copyWith(armed: true, updatedAt: now),
        DeviceCommand.disarm || DeviceCommand.quietDisarm =>
          current.copyWith(armed: false, updatedAt: now),
        DeviceCommand.start =>
          current.copyWith(engineRunning: true, updatedAt: now),
        DeviceCommand.stop =>
          current.copyWith(engineRunning: false, updatedAt: now),
        DeviceCommand.horn || DeviceCommand.panic =>
          current.copyWith(updatedAt: now),
        DeviceCommand.valetOn => current.copyWith(valet: true, updatedAt: now),
        DeviceCommand.valetOff =>
          current.copyWith(valet: false, updatedAt: now),
        DeviceCommand.webastoOn =>
          current.copyWith(webasto: true, updatedAt: now),
        DeviceCommand.webastoOff =>
          current.copyWith(webasto: false, updatedAt: now),
        DeviceCommand.auxOn => current.copyWith(auxOn: true, updatedAt: now),
        DeviceCommand.auxOff => current.copyWith(auxOn: false, updatedAt: now),
      };
      _mockStates[deviceId] = next;
      return;
    }
    await _count();
    try {
      final res = await _api.post<Map<String, dynamic>>(
        '/json/v1/device/$deviceId/set_param',
        data: command.setParamBody,
      );
      final data = res.data ?? {};
      if (!StarlineMappers.apiCodeOk(data)) {
        throw StarlineApiException(
          data['codestring']?.toString() ?? 'set_param failed',
          statusCode: StarlineMappers.asInt(data['code']),
        );
      }
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
      // Field names vary across docs; try period_* first, fall back once.
      Future<Response<Map<String, dynamic>>> post(Map<String, dynamic> body) {
        return _api.post<Map<String, dynamic>>(
          '/json/v1/device/$deviceId/events',
          data: body,
        );
      }

      var res = await post({
        'period_start': periodStart,
        'period_end': periodEnd,
      });
      var data = res.data ?? {};
      if (!StarlineMappers.apiCodeOk(data)) {
        res = await post({'from': periodStart, 'to': periodEnd});
        data = res.data ?? {};
      }
      if (!StarlineMappers.apiCodeOk(data)) {
        throw StarlineApiException(
          data['codestring']?.toString() ?? 'events failed',
          statusCode: StarlineMappers.asInt(data['code']),
        );
      }
      return StarlineMappers.eventsFromJson(deviceId, data);
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  /// On-demand OBD — fuel / mileage / errors. Counts toward daily budget.
  Future<ObdParams> fetchObdParams(String deviceId) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 220));
      final mock = MockCatalog.obdFor(deviceId);
      if (mock == null) {
        throw StarlineApiException(
          'OBD недоступен для устройства',
          code: 'obd_unsupported',
        );
      }
      return mock;
    }
    await _count();
    try {
      final res = await _api.get<Map<String, dynamic>>(
        '/json/v1/device/$deviceId/obd_params',
      );
      final data = res.data ?? {};
      if (!StarlineMappers.apiCodeOk(data)) {
        throw StarlineApiException(
          data['codestring']?.toString() ?? 'obd_params failed',
          statusCode: StarlineMappers.asInt(data['code']),
        );
      }
      return StarlineMappers.obdParamsFromJson(deviceId, data);
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  /// GPS tracks for a period. StarLine Open API: max ~24h window; budget-heavy.
  Future<TrackPeriod> fetchWays(
    String deviceId, {
    required DateTime begin,
    required DateTime end,
  }) async {
    final clamped = _clampWaysWindow(begin, end);
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 280));
      return MockCatalog.tracksFor(
        deviceId,
        begin: clamped.$1,
        end: clamped.$2,
      );
    }
    await _count();
    try {
      final res = await _api.post<Map<String, dynamic>>(
        '/json/v1/device/$deviceId/ways',
        data: {
          'begin': clamped.$1.millisecondsSinceEpoch ~/ 1000,
          'end': clamped.$2.millisecondsSinceEpoch ~/ 1000,
          'filtering': true,
          'split_way': true,
          'tz': true,
        },
      );
      final data = res.data ?? {};
      if (!StarlineMappers.apiCodeOk(data)) {
        throw StarlineApiException(
          data['codestring']?.toString() ?? 'ways failed',
          statusCode: StarlineMappers.asInt(data['code']),
        );
      }
      return StarlineMappers.tracksFromJson(
        deviceId,
        data,
        begin: clamped.$1,
        end: clamped.$2,
      );
    } on DioException catch (e) {
      _rethrow(e);
    }
  }

  /// Open API: ways window ≤ 24h.
  static (DateTime, DateTime) _clampWaysWindow(DateTime begin, DateTime end) {
    var b = begin;
    var e = end;
    if (e.isBefore(b)) {
      final tmp = b;
      b = e;
      e = tmp;
    }
    const max = Duration(hours: 24);
    if (e.difference(b) > max) {
      e = b.add(max);
    }
    return (b, e);
  }

  Never _rethrow(DioException e) {
    final nested = e.error;
    if (nested is StarlineApiException) throw nested;
    throw StarlineApiException(
      e.message ?? 'network error',
      statusCode: e.response?.statusCode,
    );
  }
}

class LoginResult {
  LoginResult._({
    this.session,
    this.userToken,
    this.needsCaptcha = false,
    this.needsSms = false,
    this.captchaSid,
    this.maskedPhone,
  });

  factory LoginResult.ok(Session session) => LoginResult._(session: session);

  factory LoginResult.token(String? userToken) =>
      LoginResult._(userToken: userToken);

  factory LoginResult.needsExtra({
    bool captcha = false,
    bool sms = false,
    String? captchaSid,
    String? maskedPhone,
  }) =>
      LoginResult._(
        needsCaptcha: captcha,
        needsSms: sms,
        captchaSid: captchaSid,
        maskedPhone: maskedPhone,
      );

  final Session? session;
  final String? userToken;
  final bool needsCaptcha;
  final bool needsSms;
  final String? captchaSid;
  final String? maskedPhone;

  bool get isOk => session != null;
  bool get needsExtra => needsCaptcha || needsSms;
}

String _maskPhone(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 4) return raw;
  final tail = digits.substring(digits.length - 4);
  return '+7 ••• ••• ${tail.substring(0, 2)}-${tail.substring(2)}';
}
