import 'package:flutter_test/flutter_test.dart';
import 'package:sexy_starline/data/remote/starline_api_client.dart';
import 'package:sexy_starline/data/remote/starline_api_exception.dart';

void main() {
  group('Mock SLID captcha / SMS challenges', () {
    late StarlineApiClient api;

    setUp(() {
      api = StarlineApiClient(useMock: true);
    });

    test('sms login returns needsExtra until code', () async {
      final first = await api.login(login: 'sms', password: 'x');
      expect(first.needsExtra, isTrue);
      expect(first.needsSms, isTrue);
      expect(first.maskedPhone, isNotNull);

      await expectLater(
        api.login(
          login: 'sms',
          password: 'x',
          captchaOrSms: '0000',
        ),
        throwsA(isA<StarlineApiException>()),
      );

      final ok = await api.login(
        login: 'sms',
        password: 'x',
        captchaOrSms: '1234',
      );
      expect(ok.isOk, isTrue);
      expect(ok.session?.demo, isTrue);
    });

    test('captcha login accepts star or 1234', () async {
      final first = await api.login(login: 'captcha', password: 'x');
      expect(first.needsCaptcha, isTrue);
      expect(first.captchaSid, isNotNull);

      final ok = await api.login(
        login: 'captcha',
        password: 'x',
        captchaOrSms: 'star',
        captchaSid: first.captchaSid,
      );
      expect(ok.isOk, isTrue);
    });

    test('plain demo login skips challenge', () async {
      final ok = await api.login(login: 'demo', password: 'demo');
      expect(ok.isOk, isTrue);
      expect(ok.needsExtra, isFalse);
    });
  });
}
