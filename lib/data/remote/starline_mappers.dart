import '../../domain/entities/device.dart';
import '../../domain/entities/device_state.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/sim_balance.dart';

/// Pure parsers for StarLine Open API payloads (testable without Dio).
abstract final class StarlineMappers {
  static bool asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final s = '$value'.toLowerCase();
    return s == '1' || s == 'true' || s == 'yes';
  }

  static double? asDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse('$value');
  }

  static int? asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse('$value');
  }

  static List<String> stringList(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map((e) => '$e').where((e) => e.isNotEmpty).toList();
  }

  /// `balance.active` from user_info / device data (HA / pystarline).
  static SimBalance? simBalanceFromJson(dynamic raw) {
    if (raw == null) return null;
    Map<String, dynamic>? active;
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      final nested = map['active'];
      if (nested is Map) {
        active = Map<String, dynamic>.from(nested);
      } else if (map.containsKey('value') || map.containsKey('balance')) {
        active = map;
      }
    }
    if (active == null) return null;
    final value = asDouble(active['value'] ?? active['balance'] ?? active['amount']);
    final currency = '${active['currency'] ?? '₽'}';
    final operatorName =
        active['operator']?.toString() ?? active['operatorName']?.toString();
    final ts = asDouble(active['ts'] ?? active['updated']);
    final updatedAt = ts == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch((ts * 1000).round());
    if (value == null &&
        (operatorName == null || operatorName.isEmpty) &&
        updatedAt == null) {
      return null;
    }
    return SimBalance(
      value: value,
      currency: currency.isEmpty ? '₽' : currency,
      operatorName: operatorName,
      updatedAt: updatedAt,
    );
  }

  /// StarLine GSM often reports 1–30; UI Night Drive uses bars 0–5.
  static int? gsmBars(dynamic raw, {int maxBars = 5}) {
    final level = asInt(raw);
    if (level == null) return null;
    if (level <= 0) return 0;
    if (level <= maxBars) return level.clamp(0, maxBars);
    // Map 1..30 → 1..5
    final bars = ((level / 30) * maxBars).ceil();
    return bars.clamp(1, maxBars);
  }

  static List<Device> devicesFromUserInfo(Map<String, dynamic> json) {
    final devices = <Device>[];

    void addList(dynamic raw, {required bool shared}) {
      if (raw is! List) return;
      for (final item in raw) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);
        final id = '${map['device_id'] ?? map['id'] ?? ''}';
        if (id.isEmpty) continue;
        final status = asInt(map['status']);
        final online = map['online'] == true || status == 1;
        devices.add(
          Device(
            id: id,
            alias: '${map['alias'] ?? map['name'] ?? 'Устройство'}',
            typeName: map['typename']?.toString() ?? map['type']?.toString(),
            imei: map['imei']?.toString(),
            phone: map['phone']?.toString(),
            online: online,
            gsmLevel: gsmBars(map['gsm_lvl'] ?? map['gsm']),
            functions: stringList(map['functions']),
            controls: stringList(map['controls']),
            simBalance: simBalanceFromJson(map['balance']),
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

  /// Prefer `/json/v3/device/{id}/data`, also works with user_info device rows.
  static DeviceState deviceStateFromJson(
    String deviceId,
    Map<String, dynamic> json, {
    DateTime? updatedAt,
  }) {
    final root = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    final carState = root['car_state'] is Map
        ? Map<String, dynamic>.from(root['car_state'] as Map)
        : root['state'] is Map
            ? Map<String, dynamic>.from(root['state'] as Map)
            : root;

    final pos = root['position'] is Map
        ? Map<String, dynamic>.from(root['position'] as Map)
        : <String, dynamic>{};

    final status = asInt(root['status']);
    final onlineExplicit = root['online'];
    final online = onlineExplicit != null
        ? asBool(onlineExplicit)
        : status == null
            ? true
            : status == 1;

    final tsActivity = asDouble(root['ts_activity'] ?? pos['ts']);
    final stamp = updatedAt ??
        (tsActivity == null
            ? DateTime.now()
            : DateTime.fromMillisecondsSinceEpoch(
                (tsActivity * 1000).round(),
              ));

    final doorsOpen = asBool(carState['door']) || asBool(carState['doors_open']);
    final engineRunning =
        asBool(carState['ign']) || asBool(carState['run']) || asBool(carState['r_start']);

    return DeviceState(
      deviceId: deviceId,
      updatedAt: stamp,
      armed: asBool(carState['arm']),
      engineRunning: engineRunning,
      alarm: asBool(carState['alarm']) ||
          (root['car_alr_state'] is Map &&
              (root['car_alr_state'] as Map).values.any(asBool)),
      doorsClosed: !doorsOpen,
      online: online,
      valet: asBool(carState['valet']) || asBool(carState['service']),
      batteryVolts: asDouble(root['battery'] ?? root['akb'] ?? carState['battery']),
      cabinTempC: asDouble(root['ctemp'] ?? root['mayak_temp']),
      engineTempC: asDouble(root['etemp']),
      gsmLevel: gsmBars(root['gsm_lvl'] ?? root['gsm']),
      latitude: asDouble(pos['x'] ?? pos['lat']),
      longitude: asDouble(pos['y'] ?? pos['lon']),
      address: root['address']?.toString() ?? pos['address']?.toString(),
      simBalance: simBalanceFromJson(root['balance']),
    );
  }

  static List<VehicleEvent> eventsFromJson(
    String deviceId,
    Map<String, dynamic> json,
  ) {
    final raw = json['events'] ?? json['data'] ?? json['history'] ?? [];
    if (raw is! List) return const [];
    return raw.whereType<Map>().map((item) {
      final map = Map<String, dynamic>.from(item);
      final ts = asInt(map['ts'] ?? map['time'] ?? map['timestamp']);
      final title =
          '${map['title'] ?? map['event'] ?? map['type'] ?? map['alias'] ?? 'Событие'}';
      return VehicleEvent(
        id: '${map['id'] ?? map['event_id'] ?? ts ?? map.hashCode}',
        deviceId: deviceId,
        title: title,
        timestamp: ts == null
            ? DateTime.now()
            : DateTime.fromMillisecondsSinceEpoch(
                ts > 2000000000 ? ts : ts * 1000,
              ),
        kind: eventKindFrom(map),
      );
    }).toList();
  }

  static EventKind eventKindFrom(Map<String, dynamic> map) {
    final t =
        '${map['type'] ?? map['event'] ?? map['title'] ?? ''}'.toLowerCase();
    if (t.contains('alarm') ||
        t.contains('тревог') ||
        t.contains('удар') ||
        t.contains('shock')) {
      return EventKind.alarm;
    }
    if (t.contains('arm') ||
        t.contains('disarm') ||
        t.contains('start') ||
        t.contains('ign') ||
        t.contains('охрану') ||
        t.contains('двигател') ||
        t.contains('команд')) {
      return EventKind.command;
    }
    if (t.contains('online') || t.contains('status') || t.contains('offline')) {
      return EventKind.status;
    }
    return EventKind.other;
  }

  /// Extract nested SLID `desc` / success flags.
  static Map<String, dynamic> slidDesc(Map<String, dynamic> json) {
    final desc = json['desc'];
    if (desc is Map) return Map<String, dynamic>.from(desc);
    return json;
  }

  static bool slidOk(Map<String, dynamic> json) {
    final state = asInt(json['state']);
    return state == 1;
  }

  static bool apiCodeOk(Map<String, dynamic> json) {
    final code = asInt(json['code']);
    return code == null || code == 200;
  }
}
