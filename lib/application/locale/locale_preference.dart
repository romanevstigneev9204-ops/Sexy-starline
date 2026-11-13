import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_strings.dart';

/// Default RU per market prefs. Optional EN via Settings.
final localePreferenceProvider =
    StateProvider<AppLanguage>((ref) => AppLanguage.ru);
