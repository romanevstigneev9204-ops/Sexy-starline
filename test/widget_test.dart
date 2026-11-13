import 'package:flutter_test/flutter_test.dart';
import 'package:sexy_starline/core/config/env.dart';
import 'package:sexy_starline/domain/entities/command.dart';

void main() {
  test('Env defaults to mock without credentials', () {
    expect(Env.hasCredentials, isFalse);
    expect(Env.useMock, isTrue);
  });

  test('dangerous commands require confirm', () {
    expect(DeviceCommand.disarm.requiresConfirm, isTrue);
    expect(DeviceCommand.start.requiresHold, isTrue);
    expect(DeviceCommand.horn.requiresConfirm, isFalse);
  });
}
