import 'package:flutter_test/flutter_test.dart';
import 'package:sexy_starline/domain/entities/command.dart';

void main() {
  group('DeviceCommand set_param body', () {
    test('arm/disarm use arm param', () {
      expect(DeviceCommand.arm.setParamBody, {'type': 'arm', 'arm': 1});
      expect(DeviceCommand.disarm.setParamBody, {'type': 'arm', 'arm': 0});
    });

    test('start/stop use ign param (HA)', () {
      expect(DeviceCommand.start.setParamBody, {'type': 'ign', 'ign': 1});
      expect(DeviceCommand.stop.setParamBody, {'type': 'ign', 'ign': 0});
    });

    test('horn uses poke', () {
      expect(DeviceCommand.horn.setParamBody, {'type': 'poke', 'poke': 1});
    });
  });

  group('CommandGate', () {
    test('allows when controls contain capability', () {
      expect(
        CommandGate.allows(
          DeviceCommand.arm,
          controls: const ['arm', 'ign'],
          functions: const [],
        ),
        isTrue,
      );
      expect(
        CommandGate.allows(
          DeviceCommand.horn,
          controls: const ['poke'],
          functions: const ['state'],
        ),
        isTrue,
      );
    });

    test('blocks missing capability', () {
      expect(
        CommandGate.allows(
          DeviceCommand.start,
          controls: const ['arm'],
          functions: const ['state'],
        ),
        isFalse,
      );
    });

    test('allows all when capability lists empty (unknown device)', () {
      expect(
        CommandGate.allows(
          DeviceCommand.horn,
          controls: const [],
          functions: const [],
        ),
        isTrue,
      );
    });

    test('matches alternate keys (start/horn aliases)', () {
      expect(
        CommandGate.allows(
          DeviceCommand.start,
          controls: const ['engine'],
          functions: const [],
        ),
        isTrue,
      );
      expect(
        CommandGate.allows(
          DeviceCommand.horn,
          controls: const ['horn'],
          functions: const [],
        ),
        isTrue,
      );
    });
  });

  group('confirm / hold policy', () {
    test('dangerous commands require confirm/hold', () {
      expect(DeviceCommand.disarm.requiresConfirm, isTrue);
      expect(DeviceCommand.start.requiresHold, isTrue);
      expect(DeviceCommand.horn.requiresConfirm, isFalse);
      expect(DeviceCommand.arm.requiresConfirm, isFalse);
    });
  });
}
