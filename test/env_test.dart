import 'package:flutter_test/flutter_test.dart';
import 'package:sexy_starline/core/config/env.dart';

/// Without `--dart-define`, credentials stay empty → demo/mock path.
/// Real AppId/Secret must never appear in tests or source.
void main() {
  test('Env defaults: empty credentials → useMock', () {
    expect(Env.appId, isEmpty);
    expect(Env.appSecret, isEmpty);
    expect(Env.hasCredentials, isFalse);
    expect(Env.useMock, isTrue);
    expect(Env.forceDemo, isFalse);
  });

  test('Env API base defaults are public hosts (not secrets)', () {
    expect(Env.slidBaseUrl, 'https://id.starline.ru');
    expect(Env.apiBaseUrl, 'https://developer.starline.ru');
  });
}
