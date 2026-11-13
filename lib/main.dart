import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'domain/widgets/home_widget_payload.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru');
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
    try {
      await HomeWidget.setAppGroupId(kIosAppGroupId);
    } catch (_) {
      // App Group missing until Xcode signing — widget sync is best-effort.
    }
  }
  runApp(
    const ProviderScope(
      child: AppBootstrap(
        child: SexyStarlineApp(),
      ),
    ),
  );
}
