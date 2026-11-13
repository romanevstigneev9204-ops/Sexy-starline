import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sexy_starline/application/theme/theme_preference.dart';
import 'package:sexy_starline/core/l10n/app_strings.dart';
import 'package:sexy_starline/core/theme/night_drive_theme.dart';
import 'package:sexy_starline/presentation/screens/settings/settings_screen.dart';

void main() {
  testWidgets('Settings Theme tile opens theme sheet', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: buildNightDriveTheme(),
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(S.theme), findsOneWidget);
    await tester.tap(find.text(S.theme));
    await tester.pumpAndSettle();

    expect(find.text(S.themeSheetTitle), findsOneWidget);
    expect(find.text(S.themeNightDrive), findsWidgets);
    expect(find.text(S.themeSystem), findsOneWidget);
    expect(find.text(S.themeDayMetal), findsOneWidget);

    await tester.tap(find.text(S.themeSystem));
    await tester.pumpAndSettle();
    await tester.tap(find.text(S.themeClose));
    await tester.pumpAndSettle();

    expect(find.text(S.themeSheetTitle), findsNothing);
    expect(find.textContaining(S.themeSystem), findsOneWidget);
  });

  test('theme preference labels follow bound S catalog', () {
    S.bind(AppLanguage.ru);
    expect(AppThemeChoice.nightDrive.settingsLabelRu, S.themeNightDrive);
    expect(
      AppThemeChoice.system.settingsLabelRu,
      contains(S.themeSystem),
    );

    S.bind(AppLanguage.en);
    expect(AppThemeChoice.nightDrive.settingsLabelRu, 'Night Drive');
    expect(AppThemeChoice.system.settingsLabelRu, contains('System'));
    S.bind(AppLanguage.ru);
  });
}
