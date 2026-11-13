import 'package:equatable/equatable.dart';

/// SIM card balance from `user_info` / device data (`balance.active`).
class SimBalance extends Equatable {
  const SimBalance({
    this.value,
    this.currency = '₽',
    this.operatorName,
    this.updatedAt,
  });

  final double? value;
  final String currency;
  final String? operatorName;
  final DateTime? updatedAt;

  bool get hasValue => value != null;

  String get labelRu {
    if (value == null) return 'Нет данных';
    final amount = value! == value!.roundToDouble()
        ? value!.toStringAsFixed(0)
        : value!.toStringAsFixed(2);
    final op = operatorName == null || operatorName!.isEmpty
        ? ''
        : ' · $operatorName';
    return '$amount $currency$op';
  }

  SimBalance copyWith({
    double? value,
    String? currency,
    String? operatorName,
    DateTime? updatedAt,
  }) {
    return SimBalance(
      value: value ?? this.value,
      currency: currency ?? this.currency,
      operatorName: operatorName ?? this.operatorName,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [value, currency, operatorName, updatedAt];
}
