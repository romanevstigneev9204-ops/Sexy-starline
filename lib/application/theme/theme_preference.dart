import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_strings.dart';

/// MVP theme choices. Only Night Drive is fully implemented;
/// System currently resolves to the same palette.
enum AppThemeChoice {
  nightDrive,
  system,
}

extension AppThemeChoiceX on AppThemeChoice {
  String get titleRu {
    switch (this) {
      case AppThemeChoice.nightDrive:
        return S.themeNightDrive;
      case AppThemeChoice.system:
        return S.themeSystem;
    }
  }

  String get subtitleRu {
    switch (this) {
      case AppThemeChoice.nightDrive:
        return S.themeNightDriveHint;
      case AppThemeChoice.system:
        return S.themeSystemHint;
    }
  }

  /// Compact label for Settings tile.
  String get settingsLabelRu {
    switch (this) {
      case AppThemeChoice.nightDrive:
        return S.themeNightDrive;
      case AppThemeChoice.system:
        return '${S.themeSystem} (${S.themeNightDrive})';
    }
  }
}

final themePreferenceProvider =
    StateProvider<AppThemeChoice>((ref) => AppThemeChoice.nightDrive);
