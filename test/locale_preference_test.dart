import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sexy_starline/application/locale/locale_preference.dart';
import 'package:sexy_starline/core/l10n/app_strings.dart';
import 'package:sexy_starline/core/theme/night_drive_theme.dart';
import 'package:sexy_starline/presentation/screens/settings/settings_screen.dart';
import 'package:sexy_starline/presentation/widgets/confirm_sheets.dart';

void main() {
  tearDown(() {
    S.bind(AppLanguage.ru);
  });

  test('default language is RU', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    expect(container.read(localePreferenceProvider), AppLanguage.ru);
    expect(AppLanguage.ru.locale, const Locale('ru'));
  });

  test('S.bind switches catalog between RU and EN', () {
    S.bind(AppLanguage.ru);
    expect(S.loginDemoCta, 'Продолжить в демо');
    expect(S.language, 'Язык');

    S.bind(AppLanguage.en);
    expect(S.loginDemoCta, 'Continue in demo');
    expect(S.language, 'Language');
    expect(S.settingsTitle, 'Settings');
  });

  test('ARB-style catalogs expose the same keys', () {
    expect(AppStrings.ru.loginCta, isNotEmpty);
    expect(AppStrings.en.loginCta, isNotEmpty);
    expect(AppStrings.ru.loginCta, isNot(AppStrings.en.loginCta));
    expect(
      AppStrings.forLanguage(AppLanguage.en).navHome,
      AppStrings.en.navHome,
    );
  });

  testWidgets('Settings language tile opens sheet and switches to EN',
      (tester) async {
    S.bind(AppLanguage.ru);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildNightDriveTheme(),
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(S.language), findsOneWidget);
    expect(find.text(S.languageRu), findsOneWidget);

    await tester.tap(find.text(S.language));
    await tester.pumpAndSettle();

    expect(find.text(S.languageSheetTitle), findsOneWidget);
    expect(find.text(S.languageEn), findsOneWidget);

    await tester.tap(find.text(S.languageEn));
    await tester.pumpAndSettle();
    await tester.tap(find.text(S.themeClose));
    await tester.pumpAndSettle();

    expect(find.text(S.languageSheetTitle), findsNothing);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(S.current, same(AppStrings.en));
  });

  testWidgets('showLanguageSheet returns selection', (tester) async {
    AppLanguage? result;
    await tester.pumpWidget(
      MaterialApp(
        theme: buildNightDriveTheme(),
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await showLanguageSheet(
                    context,
                    current: AppLanguage.ru,
                  );
                },
                child: const Text('open'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(S.languageEn));
    await tester.pumpAndSettle();
    await tester.tap(find.text(S.themeClose));
    await tester.pumpAndSettle();

    expect(result, AppLanguage.en);
  });
}
