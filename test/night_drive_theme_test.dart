import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sexy_starline/core/l10n/app_strings.dart';
import 'package:sexy_starline/core/theme/colors.dart';
import 'package:sexy_starline/core/theme/night_drive_theme.dart';
import 'package:sexy_starline/presentation/widgets/brand_mark.dart';
import 'package:sexy_starline/presentation/widgets/metric_chip.dart';
import 'package:sexy_starline/presentation/widgets/rate_limit_view.dart';

void main() {
  test('Night Drive tokens stay on v1 palette', () {
    expect(NightDriveColors.graphite, const Color(0xFF0B0E12));
    expect(NightDriveColors.cyan, const Color(0xFF3DDBD9));
    expect(NightDriveColors.amber, const Color(0xFFF0A04B));
  });

  testWidgets('theme uses graphite scaffold and cyan primary', (tester) async {
    final theme = buildNightDriveTheme();
    expect(theme.scaffoldBackgroundColor, NightDriveColors.graphite);
    expect(theme.colorScheme.primary, NightDriveColors.cyan);
    expect(theme.colorScheme.secondary, NightDriveColors.amber);
  });

  testWidgets('BrandMark shows SEXY STARLINE in cyan', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildNightDriveTheme(),
        home: const Scaffold(body: BrandMark()),
      ),
    );
    expect(find.text(S.appName), findsOneWidget);
    final text = tester.widget<Text>(find.text(S.appName));
    expect(text.style?.color, NightDriveColors.cyan);
  });

  testWidgets('MetricChip left-aligns label and value', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildNightDriveTheme(),
        home: const Scaffold(
          body: Row(
            children: [
              MetricChip(label: 'АКБ', value: '12.4 В'),
            ],
          ),
        ),
      ),
    );
    expect(find.text('АКБ'), findsOneWidget);
    expect(find.text('12.4 В'), findsOneWidget);
  });

  testWidgets('RateLimitView shows HTTP 429 badge and two-line title',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildNightDriveTheme(),
        home: RateLimitView(onAck: () {}),
      ),
    );
    expect(find.text(S.rateLimitBadge), findsOneWidget);
    expect(find.text(S.rateLimitTitle), findsOneWidget);
    expect(find.text(S.rateLimitCta), findsOneWidget);
  });
}
