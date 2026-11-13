enum DeviceCommand {
  arm,
  disarm,
  quietArm,
  quietDisarm,
  start,
  stop,
  horn,
  panic,
  valetOn,
  valetOff,
}

extension DeviceCommandX on DeviceCommand {
  /// StarLine `set_param` field name (HA / Raycast / pystarline).
  String get paramName => switch (this) {
        DeviceCommand.arm || DeviceCommand.disarm => 'arm',
        DeviceCommand.quietArm || DeviceCommand.quietDisarm => 'arm_quiet',
        DeviceCommand.start || DeviceCommand.stop => 'ign',
        DeviceCommand.horn => 'poke',
        DeviceCommand.panic => 'panic',
        DeviceCommand.valetOn || DeviceCommand.valetOff => 'valet',
      };

  /// Value for set_param body.
  int get paramValue => switch (this) {
        DeviceCommand.arm ||
        DeviceCommand.quietArm ||
        DeviceCommand.start ||
        DeviceCommand.horn ||
        DeviceCommand.panic ||
        DeviceCommand.valetOn =>
          1,
        DeviceCommand.disarm ||
        DeviceCommand.quietDisarm ||
        DeviceCommand.stop ||
        DeviceCommand.valetOff =>
          0,
      };

  /// Body accepted by `/json/v1/device/{id}/set_param`.
  Map<String, dynamic> get setParamBody => {
        'type': paramName,
        paramName: paramValue,
      };

  /// Capability keys that unlock this command in `controls` / `functions`.
  List<String> get capabilityKeys => switch (this) {
        DeviceCommand.arm || DeviceCommand.disarm => const ['arm', 'disarm'],
        DeviceCommand.quietArm || DeviceCommand.quietDisarm => const [
            'arm_quiet',
            'arm_start_quiet',
            'arm_stop_quiet',
            'quiet',
          ],
        DeviceCommand.start || DeviceCommand.stop => const [
            'ign',
            'start',
            'stop',
            'engine',
            'r_start',
          ],
        DeviceCommand.horn => const ['poke', 'horn', 'signal'],
        DeviceCommand.panic => const ['panic'],
        DeviceCommand.valetOn || DeviceCommand.valetOff => const [
            'valet',
            'service',
          ],
      };

  /// Secondary P1 actions — only when capability lists declare support
  /// (empty lists still allow core arm/start/horn for unknown devices).
  bool get isSecondary => switch (this) {
        DeviceCommand.quietArm ||
        DeviceCommand.quietDisarm ||
        DeviceCommand.panic ||
        DeviceCommand.valetOn ||
        DeviceCommand.valetOff =>
          true,
        _ => false,
      };

  @Deprecated('Use paramName')
  String get apiKey => paramName;

  bool get requiresConfirm =>
      this == DeviceCommand.disarm ||
      this == DeviceCommand.quietDisarm ||
      this == DeviceCommand.start ||
      this == DeviceCommand.panic ||
      this == DeviceCommand.valetOn;

  bool get requiresHold => this == DeviceCommand.start;
}

/// Gate UI/commands against device `controls`/`functions`.
abstract final class CommandGate {
  static bool allows(
    DeviceCommand command, {
    required List<String> controls,
    required List<String> functions,
  }) {
    final pool =
        {...controls, ...functions}.map((e) => e.toLowerCase()).toSet();
    if (pool.isEmpty) {
      // Unknown capabilities — allow core commands only (owner MVP).
      // Secondary P1 (quiet/panic/valet) need an explicit control/function.
      return !command.isSecondary;
    }
    return command.capabilityKeys
        .any((key) => pool.contains(key.toLowerCase()));
  }
}
