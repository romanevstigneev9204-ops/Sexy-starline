/// Runtime credentials via `--dart-define` / env. Never hardcode secrets.
class Env {
  const Env._();

  static const String appId = String.fromEnvironment(
    'STARLINE_APP_ID',
    defaultValue: '',
  );

  static const String appSecret = String.fromEnvironment(
    'STARLINE_APP_SECRET',
    defaultValue: '',
  );

  /// Force demo/mock even if credentials are present.
  static const bool forceDemo = bool.fromEnvironment(
    'STARLINE_DEMO',
    defaultValue: false,
  );

  static bool get hasCredentials =>
      appId.isNotEmpty && appSecret.isNotEmpty;

  static bool get useMock => forceDemo || !hasCredentials;

  static const String slidBaseUrl = String.fromEnvironment(
    'STARLINE_SLID_BASE',
    defaultValue: 'https://id.starline.ru',
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'STARLINE_API_BASE',
    defaultValue: 'https://developer.starline.ru',
  );
}
