import 'package:equatable/equatable.dart';

class ApiBudget extends Equatable {
  const ApiBudget({
    required this.day,
    required this.requestCount,
    this.dailyLimit = 1000,
  });

  final DateTime day;
  final int requestCount;
  final int dailyLimit;

  bool get isNearLimit => requestCount >= (dailyLimit * 0.8).round();
  bool get isExceeded => requestCount >= dailyLimit;
  double get progress => (requestCount / dailyLimit).clamp(0, 1);

  ApiBudget copyWith({int? requestCount}) => ApiBudget(
        day: day,
        requestCount: requestCount ?? this.requestCount,
        dailyLimit: dailyLimit,
      );

  @override
  List<Object?> get props => [day, requestCount, dailyLimit];
}
