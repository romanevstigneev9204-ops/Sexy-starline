import 'package:equatable/equatable.dart';

/// One GPS sample on a StarLine way/track.
class TrackPoint extends Equatable {
  const TrackPoint({
    required this.latitude,
    required this.longitude,
    this.timestamp,
    this.speedKmh,
  });

  final double latitude;
  final double longitude;
  final DateTime? timestamp;
  final double? speedKmh;

  @override
  List<Object?> get props => [latitude, longitude, timestamp, speedKmh];
}

/// One trip/segment from `POST .../ways` (may be a full day or a split way).
class GpsTrack extends Equatable {
  const GpsTrack({
    required this.id,
    required this.deviceId,
    required this.points,
    this.startedAt,
    this.endedAt,
    this.mileageKm,
    this.duration,
  });

  final String id;
  final String deviceId;
  final List<TrackPoint> points;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final double? mileageKm;
  final Duration? duration;

  bool get hasGeometry => points.length >= 2;

  String get mileageLabelRu {
    if (mileageKm == null) return '—';
    final v = mileageKm!;
    if (v >= 10) return '${v.toStringAsFixed(0)} км';
    return '${v.toStringAsFixed(1)} км';
  }

  String get durationLabelRu {
    final d = duration;
    if (d == null) return '—';
    final mins = d.inMinutes;
    if (mins < 60) return '$mins мин';
    final h = mins ~/ 60;
    final m = mins % 60;
    return m == 0 ? '$h ч' : '$h ч $m мин';
  }

  @override
  List<Object?> get props =>
      [id, deviceId, points, startedAt, endedAt, mileageKm, duration];
}

/// Bundle returned for a requested period (max ~24h per StarLine Open API).
class TrackPeriod extends Equatable {
  const TrackPeriod({
    required this.deviceId,
    required this.begin,
    required this.end,
    required this.tracks,
    this.fetchedAt,
  });

  final String deviceId;
  final DateTime begin;
  final DateTime end;
  final List<GpsTrack> tracks;
  final DateTime? fetchedAt;

  double get totalMileageKm =>
      tracks.fold<double>(0, (sum, t) => sum + (t.mileageKm ?? 0));

  int get pointCount =>
      tracks.fold<int>(0, (sum, t) => sum + t.points.length);

  @override
  List<Object?> get props => [deviceId, begin, end, tracks, fetchedAt];
}
