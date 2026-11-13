import 'dart:math' as math;

import 'package:equatable/equatable.dart';

enum GeofenceSide { unknown, inside, outside }

enum GeofenceCrossing { enter, exit }

/// Client-only circular geofence — no StarLine server geofence API.
class Geofence extends Equatable {
  const Geofence({
    required this.id,
    required this.deviceId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    this.enabled = true,
    this.alertOnEnter = true,
    this.alertOnExit = true,
    this.lastSide = GeofenceSide.unknown,
  });

  final String id;
  final String deviceId;
  final String name;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final bool enabled;
  final bool alertOnEnter;
  final bool alertOnExit;
  final GeofenceSide lastSide;

  Geofence copyWith({
    String? id,
    String? deviceId,
    String? name,
    double? latitude,
    double? longitude,
    double? radiusMeters,
    bool? enabled,
    bool? alertOnEnter,
    bool? alertOnExit,
    GeofenceSide? lastSide,
  }) {
    return Geofence(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      enabled: enabled ?? this.enabled,
      alertOnEnter: alertOnEnter ?? this.alertOnEnter,
      alertOnExit: alertOnExit ?? this.alertOnExit,
      lastSide: lastSide ?? this.lastSide,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'deviceId': deviceId,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'radiusMeters': radiusMeters,
        'enabled': enabled,
        'alertOnEnter': alertOnEnter,
        'alertOnExit': alertOnExit,
        'lastSide': lastSide.name,
      };

  factory Geofence.fromJson(Map<String, dynamic> json) {
    return Geofence(
      id: '${json['id']}',
      deviceId: '${json['deviceId']}',
      name: '${json['name'] ?? 'Геозона'}',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radiusMeters: (json['radiusMeters'] as num).toDouble(),
      enabled: json['enabled'] as bool? ?? true,
      alertOnEnter: json['alertOnEnter'] as bool? ?? true,
      alertOnExit: json['alertOnExit'] as bool? ?? true,
      lastSide: GeofenceSide.values.firstWhere(
        (e) => e.name == json['lastSide'],
        orElse: () => GeofenceSide.unknown,
      ),
    );
  }

  @override
  List<Object?> get props => [
        id,
        deviceId,
        name,
        latitude,
        longitude,
        radiusMeters,
        enabled,
        alertOnEnter,
        alertOnExit,
        lastSide,
      ];
}

class GeofenceAlert extends Equatable {
  const GeofenceAlert({
    required this.id,
    required this.geofenceId,
    required this.geofenceName,
    required this.deviceId,
    required this.crossing,
    required this.at,
  });

  final String id;
  final String geofenceId;
  final String geofenceName;
  final String deviceId;
  final GeofenceCrossing crossing;
  final DateTime at;

  String get titleRu => crossing == GeofenceCrossing.enter
      ? 'Вход в «$geofenceName»'
      : 'Выход из «$geofenceName»';

  String get bodyRu => crossing == GeofenceCrossing.enter
      ? 'Авто вошло в геозону «$geofenceName»'
      : 'Авто покинуло геозону «$geofenceName»';

  @override
  List<Object?> get props =>
      [id, geofenceId, geofenceName, deviceId, crossing, at];
}

/// Haversine helpers for client geofence evaluation (no network).
abstract final class GeofenceMath {
  static const earthRadiusMeters = 6371000.0;

  static double distanceMeters({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(lat1)) *
            math.cos(_rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  static bool isInside(Geofence fence, {required double lat, required double lon}) {
    final d = distanceMeters(
      lat1: fence.latitude,
      lon1: fence.longitude,
      lat2: lat,
      lon2: lon,
    );
    return d <= fence.radiusMeters;
  }

  /// Returns crossing if side changed from a known previous side.
  static GeofenceCrossing? crossing({
    required GeofenceSide previous,
    required bool nowInside,
  }) {
    if (previous == GeofenceSide.unknown) return null;
    if (previous == GeofenceSide.outside && nowInside) {
      return GeofenceCrossing.enter;
    }
    if (previous == GeofenceSide.inside && !nowInside) {
      return GeofenceCrossing.exit;
    }
    return null;
  }

  static double _rad(double deg) => deg * math.pi / 180;
}
