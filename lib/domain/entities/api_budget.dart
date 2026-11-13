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

  int get remaining => (dailyLimit - requestCount).clamp(0, dailyLimit);

  /// Soft warn at 80% — stretch poll interval, show banner.
  bool get isNearLimit => requestCount >= (dailyLimit * 0.8).round();

  bool get isExceeded => requestCount >= dailyLimit;

  double get progress => (requestCount / dailyLimit).clamp(0, 1);

  String get labelRu => '~$requestCount / $dailyLimit запросов сегодня';

  ApiBudget copyWith({int? requestCount}) => ApiBudget(
        day: day,
        requestCount: requestCount ?? this.requestCount,
        dailyLimit: dailyLimit,
      );

  @override
  List<Object?> get props => [day, requestCount, dailyLimit];
}
