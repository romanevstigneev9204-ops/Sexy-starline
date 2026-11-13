import '../entities/api_budget.dart';

/// Foreground poll intervals for the ~1000 req/day StarLine Open API budget.
///
/// Calm day target: ~100–300 requests. Home polls only the active device.
abstract final class PollPolicy {
  /// Soft floor — never poll faster than this in foreground.
  static const Duration minInterval = Duration(seconds: 90);

  /// Default Home timer when budget is comfortable.
  static const Duration defaultInterval = Duration(seconds: 120);

  /// Soft ceiling when nearing the daily limit.
  static const Duration stretchedInterval = Duration(seconds: 180);

  /// Stop auto-poll when remaining headroom is this thin.
  static const int hardStopRemaining = 50;

  /// Prefer resume + pull-to-refresh over aggressive timers.
  static Duration intervalFor(ApiBudget budget) {
    if (budget.isExceeded || budget.remaining <= hardStopRemaining) {
      return stretchedInterval;
    }
    if (budget.isNearLimit) {
      return stretchedInterval;
    }
    return defaultInterval;
  }

  /// Whether an automatic (timer / resume) refresh should fire.
  static bool shouldAutoRefresh({
    required ApiBudget budget,
    required Duration sinceLastSuccess,
    required bool force,
  }) {
    if (force) return !budget.isExceeded;
    if (budget.isExceeded) return false;
    if (budget.remaining <= hardStopRemaining) return false;
    final needed = intervalFor(budget);
    return sinceLastSuccess >= needed;
  }

  static Duration clampInterval(Duration raw) {
    if (raw < minInterval) return minInterval;
    if (raw > stretchedInterval) return stretchedInterval;
    return raw;
  }
}
