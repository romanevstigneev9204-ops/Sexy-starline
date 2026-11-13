import 'package:equatable/equatable.dart';

enum ObdFuelUnit { percent, litres, unknown }

/// Snapshot from `GET .../obd_params` (fuel, mileage, error count).
class ObdParams extends Equatable {
  const ObdParams({
    required this.deviceId,
    this.fuelValue,
    this.fuelUnit = ObdFuelUnit.unknown,
    this.mileageKm,
    this.errorCount,
    this.fuelUpdatedAt,
    this.mileageUpdatedAt,
    this.errorsUpdatedAt,
    this.fetchedAt,
  });

  final String deviceId;
  final double? fuelValue;
  final ObdFuelUnit fuelUnit;
  final double? mileageKm;
  final int? errorCount;
  final DateTime? fuelUpdatedAt;
  final DateTime? mileageUpdatedAt;
  final DateTime? errorsUpdatedAt;
  final DateTime? fetchedAt;

  bool get hasAny =>
      fuelValue != null || mileageKm != null || errorCount != null;

  String get fuelLabelRu {
    if (fuelValue == null) return '—';
    final v = fuelValue!;
    switch (fuelUnit) {
      case ObdFuelUnit.percent:
        return '${v.round()} %';
      case ObdFuelUnit.litres:
        return v == v.roundToDouble()
            ? '${v.toStringAsFixed(0)} л'
            : '${v.toStringAsFixed(1)} л';
      case ObdFuelUnit.unknown:
        return v == v.roundToDouble()
            ? v.toStringAsFixed(0)
            : v.toStringAsFixed(1);
    }
  }

  String get mileageLabelRu {
    if (mileageKm == null) return '—';
    final v = mileageKm!;
    return '${v.round()} км';
  }

  String get errorsLabelRu {
    if (errorCount == null) return '—';
    final n = errorCount!;
    if (n == 0) return 'Нет ошибок';
    if (n == 1) return '1 ошибка';
    if (n >= 2 && n <= 4) return '$n ошибки';
    return '$n ошибок';
  }

  String get summaryLabelRu {
    final parts = <String>[];
    if (fuelValue != null) parts.add('Топливо $fuelLabelRu');
    if (mileageKm != null) parts.add('Пробег $mileageLabelRu');
    if (errorCount != null) parts.add(errorsLabelRu);
    return parts.isEmpty ? 'Нет данных OBD' : parts.join(' · ');
  }

  ObdParams copyWith({
    String? deviceId,
    double? fuelValue,
    ObdFuelUnit? fuelUnit,
    double? mileageKm,
    int? errorCount,
    DateTime? fuelUpdatedAt,
    DateTime? mileageUpdatedAt,
    DateTime? errorsUpdatedAt,
    DateTime? fetchedAt,
  }) {
    return ObdParams(
      deviceId: deviceId ?? this.deviceId,
      fuelValue: fuelValue ?? this.fuelValue,
      fuelUnit: fuelUnit ?? this.fuelUnit,
      mileageKm: mileageKm ?? this.mileageKm,
      errorCount: errorCount ?? this.errorCount,
      fuelUpdatedAt: fuelUpdatedAt ?? this.fuelUpdatedAt,
      mileageUpdatedAt: mileageUpdatedAt ?? this.mileageUpdatedAt,
      errorsUpdatedAt: errorsUpdatedAt ?? this.errorsUpdatedAt,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }

  @override
  List<Object?> get props => [
        deviceId,
        fuelValue,
        fuelUnit,
        mileageKm,
        errorCount,
        fuelUpdatedAt,
        mileageUpdatedAt,
        errorsUpdatedAt,
        fetchedAt,
      ];
}
