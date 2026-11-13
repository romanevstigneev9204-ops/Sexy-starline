import 'package:equatable/equatable.dart';

import 'sim_balance.dart';

class Device extends Equatable {
  const Device({
    required this.id,
    required this.alias,
    this.typeName,
    this.imei,
    this.phone,
    this.online = false,
    this.gsmLevel,
    this.functions = const [],
    this.controls = const [],
    this.simBalance,
    this.isPrimary = false,
    this.isShared = false,
  });

  final String id;
  final String alias;
  final String? typeName;
  final String? imei;
  final String? phone;
  final bool online;
  final int? gsmLevel;
  final List<String> functions;
  final List<String> controls;
  final SimBalance? simBalance;
  final bool isPrimary;
  final bool isShared;

  bool supports(String command) {
    final pool = {...controls, ...functions}.map((e) => e.toLowerCase());
    return pool.contains(command.toLowerCase());
  }

  /// OBD fuel/mileage/errors — gated by device `functions` (`obd_params`).
  bool get supportsObd => supports('obd_params');

  /// GPS tracks/ways — `tracking` preferred; `position` alone is last-point only.
  bool get supportsTracks =>
      supports('tracking') || supports('ways') || supports('position');

  Device copyWith({
    String? id,
    String? alias,
    String? typeName,
    String? imei,
    String? phone,
    bool? online,
    int? gsmLevel,
    List<String>? functions,
    List<String>? controls,
    SimBalance? simBalance,
    bool clearSimBalance = false,
    bool? isPrimary,
    bool? isShared,
  }) {
    return Device(
      id: id ?? this.id,
      alias: alias ?? this.alias,
      typeName: typeName ?? this.typeName,
      imei: imei ?? this.imei,
      phone: phone ?? this.phone,
      online: online ?? this.online,
      gsmLevel: gsmLevel ?? this.gsmLevel,
      functions: functions ?? this.functions,
      controls: controls ?? this.controls,
      simBalance: clearSimBalance ? null : (simBalance ?? this.simBalance),
      isPrimary: isPrimary ?? this.isPrimary,
      isShared: isShared ?? this.isShared,
    );
  }

  @override
  List<Object?> get props => [
        id,
        alias,
        typeName,
        imei,
        phone,
        online,
        gsmLevel,
        functions,
        controls,
        simBalance,
        isPrimary,
        isShared,
      ];
}
