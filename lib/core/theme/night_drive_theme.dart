import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

ThemeData buildNightDriveTheme() {
  final display = GoogleFonts.archivoNarrowTextTheme();
  final body = GoogleFonts.barlowTextTheme();

  final baseText = body.copyWith(
    displayLarge: display.displayLarge?.copyWith(
      color: NightDriveColors.textPrimary,
      fontWeight: FontWeight.w700,
    ),
    displayMedium: display.displayMedium?.copyWith(
      color: NightDriveColors.textPrimary,
      fontWeight: FontWeight.w700,
    ),
    headlineLarge: display.headlineLarge?.copyWith(
      color: NightDriveColors.textPrimary,
      fontWeight: FontWeight.w700,
      fontSize: 28,
    ),
    headlineMedium: display.headlineMedium?.copyWith(
      color: NightDriveColors.textPrimary,
      fontWeight: FontWeight.w700,
      fontSize: 24,
    ),
    headlineSmall: display.headlineSmall?.copyWith(
      color: NightDriveColors.textPrimary,
      fontWeight: FontWeight.w600,
      fontSize: 20,
    ),
    titleLarge: display.titleLarge?.copyWith(
      color: NightDriveColors.textPrimary,
      fontWeight: FontWeight.w700,
      fontSize: 18,
    ),
    titleMedium: body.titleMedium?.copyWith(
      color: NightDriveColors.textPrimary,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: body.bodyLarge?.copyWith(
      color: NightDriveColors.textPrimary,
      fontSize: 16,
    ),
    bodyMedium: body.bodyMedium?.copyWith(
      color: NightDriveColors.textSecondary,
      fontSize: 14,
    ),
    bodySmall: body.bodySmall?.copyWith(
      color: NightDriveColors.textMuted,
      fontSize: 12,
    ),
    labelLarge: body.labelLarge?.copyWith(
      color: NightDriveColors.textPrimary,
      fontWeight: FontWeight.w700,
      fontSize: 15,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: NightDriveColors.graphite,
    colorScheme: const ColorScheme.dark(
      surface: NightDriveColors.graphite,
      primary: NightDriveColors.cyan,
      secondary: NightDriveColors.amber,
      error: NightDriveColors.danger,
      onPrimary: NightDriveColors.graphite,
      onSecondary: NightDriveColors.graphite,
      onSurface: NightDriveColors.textPrimary,
    ),
    textTheme: baseText,
    appBarTheme: AppBarTheme(
      backgroundColor: NightDriveColors.graphite,
      foregroundColor: NightDriveColors.textPrimary,
      elevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: display.titleLarge?.copyWith(
        color: NightDriveColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 22,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: NightDriveColors.graphiteInput,
      hintStyle: const TextStyle(color: NightDriveColors.textMuted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: NightDriveColors.cyan, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: NightDriveColors.cyan,
        foregroundColor: NightDriveColors.graphite,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: body.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: NightDriveColors.textPrimary,
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: NightDriveColors.stroke),
        backgroundColor: NightDriveColors.graphiteCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: body.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: NightDriveColors.graphiteElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    dividerColor: NightDriveColors.stroke,
    snackBarTheme: SnackBarThemeData(
      backgroundColor: NightDriveColors.graphiteCard,
      contentTextStyle: body.bodyMedium?.copyWith(
        color: NightDriveColors.textPrimary,
      ),
    ),
  );
}
