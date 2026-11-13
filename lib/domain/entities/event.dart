import 'package:equatable/equatable.dart';

enum EventKind { alarm, command, status, other }

class VehicleEvent extends Equatable {
  const VehicleEvent({
    required this.id,
    required this.deviceId,
    required this.title,
    required this.timestamp,
    required this.kind,
  });

  final String id;
  final String deviceId;
  final String title;
  final DateTime timestamp;
  final EventKind kind;

  @override
  List<Object?> get props => [id, deviceId, title, timestamp, kind];
}
