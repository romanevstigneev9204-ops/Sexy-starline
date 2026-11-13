import 'package:flutter_test/flutter_test.dart';
import 'package:sexy_starline/domain/entities/command.dart';

void main() {
  group('DeviceCommand set_param body', () {
    test('arm/disarm use arm param', () {
      expect(DeviceCommand.arm.setParamBody, {'type': 'arm', 'arm': 1});
      expect(DeviceCommand.disarm.setParamBody, {'type': 'arm', 'arm': 0});
    });

    test('quiet arm/disarm use arm_quiet', () {
      expect(
        DeviceCommand.quietArm.setParamBody,
        {'type': 'arm_quiet', 'arm_quiet': 1},
      );
      expect(
        DeviceCommand.quietDisarm.setParamBody,
        {'type': 'arm_quiet', 'arm_quiet': 0},
      );
    });

    test('start/stop use ign param (HA)', () {
      expect(DeviceCommand.start.setParamBody, {'type': 'ign', 'ign': 1});
      expect(DeviceCommand.stop.setParamBody, {'type': 'ign', 'ign': 0});
    });

    test('horn uses poke', () {
      expect(DeviceCommand.horn.setParamBody, {'type': 'poke', 'poke': 1});
    });

    test('panic and valet bodies', () {
      expect(DeviceCommand.panic.setParamBody, {'type': 'panic', 'panic': 1});
      expect(DeviceCommand.valetOn.setParamBody, {'type': 'valet', 'valet': 1});
      expect(
        DeviceCommand.valetOff.setParamBody,
        {'type': 'valet', 'valet': 0},
      );
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

    test('allows core when capability lists empty; blocks secondary', () {
      expect(
        CommandGate.allows(
          DeviceCommand.horn,
          controls: const [],
          functions: const [],
        ),
        isTrue,
      );
      expect(
        CommandGate.allows(
          DeviceCommand.panic,
          controls: const [],
          functions: const [],
        ),
        isFalse,
      );
      expect(
        CommandGate.allows(
          DeviceCommand.quietArm,
          controls: const [],
          functions: const [],
        ),
        isFalse,
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

    test('gates quiet / panic / valet by controls', () {
      expect(
        CommandGate.allows(
          DeviceCommand.quietArm,
          controls: const ['arm_quiet'],
          functions: const [],
        ),
        isTrue,
      );
      expect(
        CommandGate.allows(
          DeviceCommand.panic,
          controls: const ['panic'],
          functions: const [],
        ),
        isTrue,
      );
      expect(
        CommandGate.allows(
          DeviceCommand.valetOn,
          controls: const ['valet'],
          functions: const [],
        ),
        isTrue,
      );
      expect(
        CommandGate.allows(
          DeviceCommand.valetOff,
          controls: const ['service'],
          functions: const [],
        ),
        isTrue,
      );
      expect(
        CommandGate.allows(
          DeviceCommand.panic,
          controls: const ['arm'],
          functions: const ['state'],
        ),
        isFalse,
      );
    });
  });

  group('confirm / hold policy', () {
    test('dangerous commands require confirm/hold', () {
      expect(DeviceCommand.disarm.requiresConfirm, isTrue);
      expect(DeviceCommand.quietDisarm.requiresConfirm, isTrue);
      expect(DeviceCommand.start.requiresHold, isTrue);
      expect(DeviceCommand.panic.requiresConfirm, isTrue);
      expect(DeviceCommand.valetOn.requiresConfirm, isTrue);
      expect(DeviceCommand.horn.requiresConfirm, isFalse);
      expect(DeviceCommand.arm.requiresConfirm, isFalse);
      expect(DeviceCommand.quietArm.requiresConfirm, isFalse);
    });
  });
}
