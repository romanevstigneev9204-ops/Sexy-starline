import 'package:flutter_test/flutter_test.dart';
import 'package:sexy_starline/domain/entities/api_budget.dart';
import 'package:sexy_starline/domain/polling/poll_policy.dart';

void main() {
  ApiBudget budget(int count) {
    final now = DateTime.now();
    return ApiBudget(
      day: DateTime(now.year, now.month, now.day),
      requestCount: count,
    );
  }

  group('PollPolicy.intervalFor', () {
    test('comfortable budget uses default 120s', () {
      expect(PollPolicy.intervalFor(budget(100)), PollPolicy.defaultInterval);
    });

    test('near limit stretches to 180s', () {
      expect(PollPolicy.intervalFor(budget(800)), PollPolicy.stretchedInterval);
      expect(PollPolicy.intervalFor(budget(999)), PollPolicy.stretchedInterval);
    });
  });

  group('PollPolicy.shouldAutoRefresh', () {
    test('force refresh allowed until hard exceed', () {
      expect(
        PollPolicy.shouldAutoRefresh(
          budget: budget(500),
          sinceLastSuccess: Duration.zero,
          force: true,
        ),
        isTrue,
      );
      expect(
        PollPolicy.shouldAutoRefresh(
          budget: budget(1000),
          sinceLastSuccess: Duration.zero,
          force: true,
        ),
        isFalse,
      );
    });

    test('respects min age and soft stop headroom', () {
      expect(
        PollPolicy.shouldAutoRefresh(
          budget: budget(100),
          sinceLastSuccess: const Duration(seconds: 30),
          force: false,
        ),
        isFalse,
      );
      expect(
        PollPolicy.shouldAutoRefresh(
          budget: budget(100),
          sinceLastSuccess: const Duration(seconds: 120),
          force: false,
        ),
        isTrue,
      );
      expect(
        PollPolicy.shouldAutoRefresh(
          budget: budget(960),
          sinceLastSuccess: const Duration(seconds: 200),
          force: false,
        ),
        isFalse,
      );
    });
  });

  group('ApiBudget', () {
    test('near / exceeded / remaining', () {
      expect(budget(800).isNearLimit, isTrue);
      expect(budget(799).isNearLimit, isFalse);
      expect(budget(1000).isExceeded, isTrue);
      expect(budget(100).remaining, 900);
      expect(budget(180).labelRu, contains('180'));
    });
  });
}
