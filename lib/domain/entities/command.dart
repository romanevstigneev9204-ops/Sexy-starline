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
  webastoOn,
  webastoOff,
  auxOn,
  auxOff,
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
        DeviceCommand.webastoOn || DeviceCommand.webastoOff => 'webasto',
        DeviceCommand.auxOn || DeviceCommand.auxOff => 'out',
      };

  /// Value for set_param body.
  int get paramValue => switch (this) {
        DeviceCommand.arm ||
        DeviceCommand.quietArm ||
        DeviceCommand.start ||
        DeviceCommand.horn ||
        DeviceCommand.panic ||
        DeviceCommand.valetOn ||
        DeviceCommand.webastoOn ||
        DeviceCommand.auxOn =>
          1,
        DeviceCommand.disarm ||
        DeviceCommand.quietDisarm ||
        DeviceCommand.stop ||
        DeviceCommand.valetOff ||
        DeviceCommand.webastoOff ||
        DeviceCommand.auxOff =>
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
        DeviceCommand.webastoOn || DeviceCommand.webastoOff => const [
            'webasto',
            'heater',
            'web_asto',
          ],
        DeviceCommand.auxOn || DeviceCommand.auxOff => const [
            'out',
            'aux',
            'channel',
            'additional_channel',
          ],
      };

  /// Secondary / comfort actions — only when capability lists declare support
  /// (empty lists still allow core arm/start/horn for unknown devices).
  bool get isSecondary => switch (this) {
        DeviceCommand.quietArm ||
        DeviceCommand.quietDisarm ||
        DeviceCommand.panic ||
        DeviceCommand.valetOn ||
        DeviceCommand.valetOff ||
        DeviceCommand.webastoOn ||
        DeviceCommand.webastoOff ||
        DeviceCommand.auxOn ||
        DeviceCommand.auxOff =>
          true,
        _ => false,
      };

  /// Comfort block on Home (webasto / aux channel).
  bool get isComfort => switch (this) {
        DeviceCommand.webastoOn ||
        DeviceCommand.webastoOff ||
        DeviceCommand.auxOn ||
        DeviceCommand.auxOff =>
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
      this == DeviceCommand.valetOn ||
      this == DeviceCommand.webastoOn ||
      this == DeviceCommand.auxOn;

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
      // Secondary / comfort need an explicit control/function.
      return !command.isSecondary;
    }
    return command.capabilityKeys
        .any((key) => pool.contains(key.toLowerCase()));
  }
}
