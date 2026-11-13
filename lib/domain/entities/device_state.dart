import 'package:equatable/equatable.dart';

import 'sim_balance.dart';

class DeviceState extends Equatable {
  const DeviceState({
    required this.deviceId,
    required this.updatedAt,
    this.armed = false,
    this.engineRunning = false,
    this.alarm = false,
    this.doorsClosed = true,
    this.online = true,
    this.valet = false,
    this.batteryVolts,
    this.cabinTempC,
    this.engineTempC,
    this.gsmLevel,
    this.latitude,
    this.longitude,
    this.address,
    this.simBalance,
  });

  final String deviceId;
  final DateTime updatedAt;
  final bool armed;
  final bool engineRunning;
  final bool alarm;
  final bool doorsClosed;
  final bool online;
  final bool valet;
  final double? batteryVolts;
  final double? cabinTempC;
  final double? engineTempC;
  final int? gsmLevel;
  final double? latitude;
  final double? longitude;
  final String? address;
  final SimBalance? simBalance;

  Duration get age => DateTime.now().difference(updatedAt);

  DeviceState copyWith({
    String? deviceId,
    DateTime? updatedAt,
    bool? armed,
    bool? engineRunning,
    bool? alarm,
    bool? doorsClosed,
    bool? online,
    bool? valet,
    double? batteryVolts,
    double? cabinTempC,
    double? engineTempC,
    int? gsmLevel,
    double? latitude,
    double? longitude,
    String? address,
    SimBalance? simBalance,
    bool clearSimBalance = false,
  }) {
    return DeviceState(
      deviceId: deviceId ?? this.deviceId,
      updatedAt: updatedAt ?? this.updatedAt,
      armed: armed ?? this.armed,
      engineRunning: engineRunning ?? this.engineRunning,
      alarm: alarm ?? this.alarm,
      doorsClosed: doorsClosed ?? this.doorsClosed,
      online: online ?? this.online,
      valet: valet ?? this.valet,
      batteryVolts: batteryVolts ?? this.batteryVolts,
      cabinTempC: cabinTempC ?? this.cabinTempC,
      engineTempC: engineTempC ?? this.engineTempC,
      gsmLevel: gsmLevel ?? this.gsmLevel,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      simBalance: clearSimBalance ? null : (simBalance ?? this.simBalance),
    );
  }

  @override
  List<Object?> get props => [
        deviceId,
        updatedAt,
        armed,
        engineRunning,
        alarm,
        doorsClosed,
        online,
        valet,
        batteryVolts,
        cabinTempC,
        engineTempC,
        gsmLevel,
        latitude,
        longitude,
        address,
        simBalance,
      ];
}
