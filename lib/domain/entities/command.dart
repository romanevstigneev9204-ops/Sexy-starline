enum DeviceCommand {
  arm,
  disarm,
  start,
  stop,
  horn,
}

extension DeviceCommandX on DeviceCommand {
  String get apiKey => switch (this) {
        DeviceCommand.arm => 'arm',
        DeviceCommand.disarm => 'disarm',
        DeviceCommand.start => 'start',
        DeviceCommand.stop => 'stop',
        DeviceCommand.horn => 'horn',
      };

  bool get requiresConfirm =>
      this == DeviceCommand.disarm || this == DeviceCommand.start;

  bool get requiresHold => this == DeviceCommand.start;
}
