import 'package:flutter_test/flutter_test.dart';
import 'package:sexy_starline/data/mock/mock_catalog.dart';
import 'package:sexy_starline/data/remote/starline_mappers.dart';
import 'package:sexy_starline/domain/entities/command.dart';
import 'package:sexy_starline/domain/entities/geofence.dart';

void main() {
  group('comfort DeviceCommand', () {
    test('webasto / aux set_param bodies', () {
      expect(
        DeviceCommand.webastoOn.setParamBody,
        {'type': 'webasto', 'webasto': 1},
      );
      expect(
        DeviceCommand.webastoOff.setParamBody,
        {'type': 'webasto', 'webasto': 0},
      );
      expect(
        DeviceCommand.auxOn.setParamBody,
        {'type': 'out', 'out': 1},
      );
      expect(
        DeviceCommand.auxOff.setParamBody,
        {'type': 'out', 'out': 0},
      );
    });

    test('comfort gated as secondary', () {
      expect(DeviceCommand.webastoOn.isSecondary, isTrue);
      expect(DeviceCommand.auxOn.isComfort, isTrue);
      expect(
        CommandGate.allows(
          DeviceCommand.webastoOn,
          controls: const [],
          functions: const [],
        ),
        isFalse,
      );
      expect(
        CommandGate.allows(
          DeviceCommand.webastoOn,
          controls: const ['webasto'],
          functions: const [],
        ),
        isTrue,
      );
      expect(
        CommandGate.allows(
          DeviceCommand.auxOff,
          controls: const [],
          functions: const ['out'],
        ),
        isTrue,
      );
      expect(
        CommandGate.allows(
          DeviceCommand.auxOn,
          controls: const ['aux'],
          functions: const [],
        ),
        isTrue,
      );
      expect(
        CommandGate.allows(
          DeviceCommand.webastoOff,
          controls: const ['arm'],
          functions: const ['state'],
        ),
        isFalse,
      );
    });

    test('webasto/aux require confirm when turning on', () {
      expect(DeviceCommand.webastoOn.requiresConfirm, isTrue);
      expect(DeviceCommand.auxOn.requiresConfirm, isTrue);
      expect(DeviceCommand.webastoOff.requiresConfirm, isFalse);
      expect(DeviceCommand.auxOff.requiresConfirm, isFalse);
    });
  });

  group('mock comfort capabilities', () {
    test('BMW has webasto+out; Skoda webasto only; Vesta neither', () {
      final bmw = MockCatalog.devices.firstWhere((d) => d.id == 'demo-bmw');
      final skoda = MockCatalog.devices.firstWhere((d) => d.id == 'demo-skoda');
      final vesta = MockCatalog.devices.firstWhere((d) => d.id == 'demo-vesta');

      expect(
        CommandGate.allows(
          DeviceCommand.webastoOn,
          controls: bmw.controls,
          functions: bmw.functions,
        ),
        isTrue,
      );
      expect(
        CommandGate.allows(
          DeviceCommand.auxOn,
          controls: bmw.controls,
          functions: bmw.functions,
        ),
        isTrue,
      );
      expect(
        CommandGate.allows(
          DeviceCommand.webastoOn,
          controls: skoda.controls,
          functions: skoda.functions,
        ),
        isTrue,
      );
      expect(
        CommandGate.allows(
          DeviceCommand.auxOn,
          controls: skoda.controls,
          functions: skoda.functions,
        ),
        isFalse,
      );
      expect(
        CommandGate.allows(
          DeviceCommand.webastoOn,
          controls: vesta.controls,
          functions: vesta.functions,
        ),
        isFalse,
      );
    });
  });

  group('DeviceState webasto/aux mapping', () {
    test('parses car_state webasto and out', () {
      final state = StarlineMappers.deviceStateFromJson('d1', {
        'code': 200,
        'car_state': {
          'arm': 1,
          'ign': 0,
          'webasto': 1,
          'out': 1,
          'valet': 0,
        },
        'position': {'x': 55.7, 'y': 37.5},
      });
      expect(state.webasto, isTrue);
      expect(state.auxOn, isTrue);
    });
  });

  group('GeofenceMath', () {
    const home = Geofence(
      id: 'g1',
      deviceId: 'demo-bmw',
      name: 'Дом',
      latitude: 55.7784,
      longitude: 37.5865,
      radiusMeters: 250,
      lastSide: GeofenceSide.inside,
    );

    test('point near center is inside', () {
      expect(
        GeofenceMath.isInside(home, lat: 55.7785, lon: 37.5866),
        isTrue,
      );
    });

    test('point ~1km away is outside', () {
      expect(
        GeofenceMath.isInside(home, lat: 55.7900, lon: 37.6000),
        isFalse,
      );
    });

    test('detects enter and exit crossings', () {
      expect(
        GeofenceMath.crossing(
          previous: GeofenceSide.outside,
          nowInside: true,
        ),
        GeofenceCrossing.enter,
      );
      expect(
        GeofenceMath.crossing(
          previous: GeofenceSide.inside,
          nowInside: false,
        ),
        GeofenceCrossing.exit,
      );
      expect(
        GeofenceMath.crossing(
          previous: GeofenceSide.unknown,
          nowInside: true,
        ),
        isNull,
      );
      expect(
        GeofenceMath.crossing(
          previous: GeofenceSide.inside,
          nowInside: true,
        ),
        isNull,
      );
    });

    test('json roundtrip', () {
      final json = home.toJson();
      final again = Geofence.fromJson(json);
      expect(again, home);
    });
  });

  group('MockCatalog geofences', () {
    test('seeds home+office for device', () {
      final fences = MockCatalog.geofencesFor('demo-bmw');
      expect(fences.length, 2);
      expect(fences.map((f) => f.name), containsAll(['Дом', 'Офис']));
      expect(fences.every((f) => f.deviceId == 'demo-bmw'), isTrue);
    });
  });
}
