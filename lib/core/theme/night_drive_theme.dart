import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';
import 'layout.dart';

ThemeData buildNightDriveTheme() {
  final display = GoogleFonts.archivoNarrowTextTheme();
  final body = GoogleFonts.barlowTextTheme();

  final baseText = body.copyWith(
    displayLarge: display.displayLarge?.copyWith(
      color: NightDriveColors.textPrimary,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
    ),
    displayMedium: display.displayMedium?.copyWith(
      color: NightDriveColors.textPrimary,
      fontWeight: FontWeight.w700,
    ),
    headlineLarge: display.headlineLarge?.copyWith(
      color: NightDriveColors.textPrimary,
      fontWeight: FontWeight.w700,
      fontSize: 28,
      height: 1.15,
      letterSpacing: 0.15,
    ),
    headlineMedium: display.headlineMedium?.copyWith(
      color: NightDriveColors.textPrimary,
      fontWeight: FontWeight.w700,
      fontSize: 24,
      height: 1.2,
    ),
    headlineSmall: display.headlineSmall?.copyWith(
      color: NightDriveColors.textPrimary,
      fontWeight: FontWeight.w600,
      fontSize: 20,
      height: 1.25,
    ),
    titleLarge: display.titleLarge?.copyWith(
      color: NightDriveColors.textPrimary,
      fontWeight: FontWeight.w700,
      fontSize: 18,
      height: 1.25,
    ),
    titleMedium: body.titleMedium?.copyWith(
      color: NightDriveColors.textPrimary,
      fontWeight: FontWeight.w600,
      fontSize: 15,
    ),
    bodyLarge: body.bodyLarge?.copyWith(
      color: NightDriveColors.textPrimary,
      fontSize: 16,
      height: 1.35,
    ),
    bodyMedium: body.bodyMedium?.copyWith(
      color: NightDriveColors.textSecondary,
      fontSize: 14,
      height: 1.4,
    ),
    bodySmall: body.bodySmall?.copyWith(
      color: NightDriveColors.textMuted,
      fontSize: 12,
      height: 1.35,
    ),
    labelLarge: body.labelLarge?.copyWith(
      color: NightDriveColors.textPrimary,
      fontWeight: FontWeight.w700,
      fontSize: 15,
    ),
  );

  final inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(NdLayout.radiusSm),
    borderSide: const BorderSide(color: NightDriveColors.stroke),
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
      hintStyle: body.bodyMedium?.copyWith(
        color: NightDriveColors.textMuted,
        fontSize: 15,
      ),
      border: inputBorder,
      enabledBorder: inputBorder,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(NdLayout.radiusSm),
        borderSide: const BorderSide(color: NightDriveColors.cyan, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: NightDriveColors.cyan,
        foregroundColor: NightDriveColors.graphite,
        disabledBackgroundColor: NightDriveColors.graphiteCard,
        disabledForegroundColor: NightDriveColors.textMuted,
        minimumSize: const Size.fromHeight(NdLayout.buttonHeight),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NdLayout.radiusSm),
        ),
        textStyle: body.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: NightDriveColors.textPrimary,
        minimumSize: const Size.fromHeight(NdLayout.buttonHeight),
        side: const BorderSide(color: NightDriveColors.stroke),
        backgroundColor: NightDriveColors.graphiteCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NdLayout.radiusSm),
        ),
        textStyle: body.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: NightDriveColors.textSecondary,
        textStyle: body.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: NightDriveColors.graphiteElevated,
      modalBarrierColor: NightDriveColors.scrim,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(NdLayout.radiusSheet),
        ),
      ),
      showDragHandle: false,
    ),
    dividerTheme: const DividerThemeData(
      color: NightDriveColors.stroke,
      thickness: 1,
      space: 1,
    ),
    dividerColor: NightDriveColors.stroke,
    snackBarTheme: SnackBarThemeData(
      backgroundColor: NightDriveColors.graphiteCard,
      contentTextStyle: body.bodyMedium?.copyWith(
        color: NightDriveColors.textPrimary,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NdLayout.radiusSm),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: NightDriveColors.graphiteCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(NdLayout.radiusSm),
        side: const BorderSide(color: NightDriveColors.stroke),
      ),
      textStyle: body.bodyMedium?.copyWith(
        color: NightDriveColors.textPrimary,
      ),
    ),
  );
}
