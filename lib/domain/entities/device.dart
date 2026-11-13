import 'package:equatable/equatable.dart';

class Device extends Equatable {
  const Device({
    required this.id,
    required this.alias,
    this.typeName,
    this.imei,
    this.online = false,
    this.gsmLevel,
    this.functions = const [],
    this.controls = const [],
    this.isPrimary = false,
    this.isShared = false,
  });

  final String id;
  final String alias;
  final String? typeName;
  final String? imei;
  final bool online;
  final int? gsmLevel;
  final List<String> functions;
  final List<String> controls;
  final bool isPrimary;
  final bool isShared;

  bool supports(String command) =>
      controls.contains(command) || functions.contains(command);

  Device copyWith({
    String? id,
    String? alias,
    String? typeName,
    String? imei,
    bool? online,
    int? gsmLevel,
    List<String>? functions,
    List<String>? controls,
    bool? isPrimary,
    bool? isShared,
  }) {
    return Device(
      id: id ?? this.id,
      alias: alias ?? this.alias,
      typeName: typeName ?? this.typeName,
      imei: imei ?? this.imei,
      online: online ?? this.online,
      gsmLevel: gsmLevel ?? this.gsmLevel,
      functions: functions ?? this.functions,
      controls: controls ?? this.controls,
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
        online,
        gsmLevel,
        functions,
        controls,
        isPrimary,
        isShared,
      ];
}
