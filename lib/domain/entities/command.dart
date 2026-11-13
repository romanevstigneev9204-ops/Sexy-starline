enum DeviceCommand {
  arm,
  disarm,
  start,
  stop,
  horn,
}

extension DeviceCommandX on DeviceCommand {
  /// StarLine `set_param` field name (HA / pystarline).
  String get paramName => switch (this) {
        DeviceCommand.arm || DeviceCommand.disarm => 'arm',
        DeviceCommand.start || DeviceCommand.stop => 'ign',
        DeviceCommand.horn => 'poke',
      };

  /// Value for set_param body.
  int get paramValue => switch (this) {
        DeviceCommand.arm || DeviceCommand.start || DeviceCommand.horn => 1,
        DeviceCommand.disarm || DeviceCommand.stop => 0,
      };

  /// Body accepted by `/json/v1/device/{id}/set_param`.
  Map<String, dynamic> get setParamBody => {
        'type': paramName,
        paramName: paramValue,
      };

  /// Capability keys that unlock this command in `controls` / `functions`.
  List<String> get capabilityKeys => switch (this) {
        DeviceCommand.arm || DeviceCommand.disarm => const ['arm', 'disarm'],
        DeviceCommand.start || DeviceCommand.stop => const [
            'ign',
            'start',
            'stop',
            'engine',
            'r_start',
          ],
        DeviceCommand.horn => const ['poke', 'horn', 'signal'],
      };

  @Deprecated('Use paramName')
  String get apiKey => paramName;

  bool get requiresConfirm =>
      this == DeviceCommand.disarm || this == DeviceCommand.start;

  bool get requiresHold => this == DeviceCommand.start;
}

/// Gate UI/commands against device `controls`/`functions`.
abstract final class CommandGate {
  static bool allows(DeviceCommand command, {
    required List<String> controls,
    required List<String> functions,
  }) {
    final pool = {...controls, ...functions}.map((e) => e.toLowerCase()).toSet();
    if (pool.isEmpty) {
      // Unknown capabilities — allow core commands (owner MVP).
      return true;
    }
    return command.capabilityKeys
        .any((key) => pool.contains(key.toLowerCase()));
  }
}
