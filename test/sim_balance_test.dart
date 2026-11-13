import 'package:flutter_test/flutter_test.dart';
import 'package:sexy_starline/data/mock/mock_catalog.dart';
import 'package:sexy_starline/domain/entities/sim_balance.dart';

void main() {
  group('SimBalance', () {
    test('formats RU label', () {
      const bal = SimBalance(
        value: 186.4,
        currency: '₽',
        operatorName: 'МТС',
      );
      expect(bal.hasValue, isTrue);
      expect(bal.labelRu, '186.40 ₽ · МТС');
    });

    test('integer amount without decimals', () {
      const bal = SimBalance(value: 52, currency: '₽');
      expect(bal.labelRu, '52 ₽');
    });
  });

  group('MockCatalog demo SIM', () {
    test('primary demo device exposes balance and P1 controls', () {
      final bmw = MockCatalog.devices.first;
      expect(bmw.simBalance?.value, closeTo(186.4, 0.01));
      expect(bmw.controls, contains('arm_quiet'));
      expect(bmw.controls, contains('panic'));
      expect(bmw.controls, contains('valet'));
      expect(MockCatalog.stateFor(bmw.id).simBalance?.hasValue, isTrue);
    });
  });
}
