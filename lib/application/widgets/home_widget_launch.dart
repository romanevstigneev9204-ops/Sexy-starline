import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../../domain/widgets/home_widget_payload.dart';

/// Listens for launches originating from the home-screen widget.
class HomeWidgetLaunchListener {
  HomeWidgetLaunchListener({
    Future<Uri?> Function()? initiallyLaunched,
    Stream<Uri?>? clicked,
  })  : _initiallyLaunched =
            initiallyLaunched ?? HomeWidget.initiallyLaunchedFromHomeWidget,
        _clicked = clicked ?? HomeWidget.widgetClicked;

  final Future<Uri?> Function() _initiallyLaunched;
  final Stream<Uri?> _clicked;

  StreamSubscription<Uri?>? _sub;
  void Function(HomeWidgetAction action)? onAction;

  bool get isSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  Future<void> start() async {
    if (!isSupported) return;
    try {
      final initial = await _initiallyLaunched();
      _emit(initial);
      await _sub?.cancel();
      _sub = _clicked.listen(_emit);
    } catch (_) {
      // Plugin unavailable on this platform build.
    }
  }

  void _emit(Uri? uri) {
    final action = HomeWidgetDeepLink.parse(uri);
    if (action != null) {
      onAction?.call(action);
    }
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
  }
}
