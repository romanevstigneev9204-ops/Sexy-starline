import 'package:flutter_test/flutter_test.dart';
import 'package:sexy_starline/data/remote/starline_mappers.dart';
import 'package:sexy_starline/domain/entities/event.dart';

void main() {
  group('StarlineMappers.devicesFromUserInfo', () {
    test('parses devices and shared_devices', () {
      final devices = StarlineMappers.devicesFromUserInfo({
        'code': 200,
        'devices': [
          {
            'device_id': 111,
            'alias': 'BMW X5',
            'typename': 'S96',
            'status': 1,
            'gsm_lvl': 24,
            'functions': ['state', 'arm', 'ign', 'poke', 'arm_quiet', 'panic'],
            'controls': ['arm', 'ign', 'poke', 'arm_quiet', 'panic', 'valet'],
            'balance': {
              'active': {
                'value': 186.4,
                'currency': '₽',
                'operator': 'МТС',
                'ts': 1700000000,
              },
            },
          },
        ],
        'shared_devices': [
          {
            'device_id': '222',
            'alias': 'Lada Vesta',
            'status': 0,
            'functions': ['state'],
          },
        ],
      });

      expect(devices, hasLength(2));
      expect(devices.first.id, '111');
      expect(devices.first.isPrimary, isTrue);
      expect(devices.first.online, isTrue);
      expect(devices.first.gsmLevel, inInclusiveRange(1, 5));
      expect(devices.first.simBalance?.value, closeTo(186.4, 0.01));
      expect(devices.first.simBalance?.operatorName, 'МТС');
      expect(devices.last.isShared, isTrue);
      expect(devices.last.online, isFalse);
    });
  });

  group('StarlineMappers.deviceStateFromJson', () {
    test('maps car_state and position from device data', () {
      final state = StarlineMappers.deviceStateFromJson('111', {
        'code': 200,
        'car_state': {
          'arm': '1',
          'ign': '0',
          'door': false,
          'run': '0',
          'valet': '1',
        },
        'battery': 12.4,
        'ctemp': 4,
        'etemp': 12,
        'gsm_lvl': 18,
        'status': 1,
        'position': {'x': 55.77, 'y': 37.58, 'ts': 1700000000},
        'balance': {
          'active': {'value': 50, 'currency': '₽', 'operator': 'Билайн'},
        },
      });

      expect(state.armed, isTrue);
      expect(state.engineRunning, isFalse);
      expect(state.doorsClosed, isTrue);
      expect(state.online, isTrue);
      expect(state.valet, isTrue);
      expect(state.batteryVolts, 12.4);
      expect(state.cabinTempC, 4);
      expect(state.latitude, closeTo(55.77, 0.001));
      expect(state.longitude, closeTo(37.58, 0.001));
      expect(state.simBalance?.value, 50);
      expect(state.simBalance?.labelRu, contains('Билайн'));
    });

    test('engine running from r_start / run', () {
      final state = StarlineMappers.deviceStateFromJson('1', {
        'car_state': {'arm': 0, 'r_start': true, 'run': 1},
        'status': 1,
      });
      expect(state.engineRunning, isTrue);
      expect(state.armed, isFalse);
    });
  });

  group('simBalanceFromJson', () {
    test('reads active nested balance', () {
      final bal = StarlineMappers.simBalanceFromJson({
        'active': {'value': '12.5', 'currency': '₽', 'operator': 'МТС'},
      });
      expect(bal?.value, 12.5);
      expect(bal?.labelRu, '12.50 ₽ · МТС');
    });

    test('returns null for empty payload', () {
      expect(StarlineMappers.simBalanceFromJson(null), isNull);
      expect(StarlineMappers.simBalanceFromJson(<String, dynamic>{}), isNull);
    });
  });

  group('StarlineMappers.eventsFromJson', () {
    test('classifies alarm / command / status', () {
      final events = StarlineMappers.eventsFromJson('1', {
        'events': [
          {'id': 1, 'title': 'Тревога: удар', 'ts': 1700000000, 'type': 'alarm'},
          {'id': 2, 'event': 'arm', 'ts': 1700000100},
          {'id': 3, 'type': 'online', 'ts': 1700000200},
        ],
      });
      expect(events[0].kind, EventKind.alarm);
      expect(events[1].kind, EventKind.command);
      expect(events[2].kind, EventKind.status);
    });
  });

  group('gsmBars', () {
    test('maps 1-30 scale to 1-5 bars', () {
      expect(StarlineMappers.gsmBars(0), 0);
      expect(StarlineMappers.gsmBars(3), 3);
      expect(StarlineMappers.gsmBars(30), 5);
      expect(StarlineMappers.gsmBars(15), inInclusiveRange(1, 5));
    });
  });

  group('slid helpers', () {
    test('slidDesc and slidOk', () {
      expect(
        StarlineMappers.slidOk({
          'state': 1,
          'desc': {'code': 'abc'},
        }),
        isTrue,
      );
      expect(
        StarlineMappers.slidDesc({
          'desc': {'token': 't'},
        })['token'],
        't',
      );
      expect(StarlineMappers.apiCodeOk({'code': 200}), isTrue);
      expect(StarlineMappers.apiCodeOk({'code': 429}), isFalse);
    });
  });
}
