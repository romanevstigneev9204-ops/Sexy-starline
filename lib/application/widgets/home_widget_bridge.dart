import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../../domain/entities/device.dart';
import '../../domain/entities/device_state.dart';
import '../../domain/widgets/home_widget_payload.dart';

/// Pushes Home/device snapshots into the OS home-screen widget.
///
/// No StarLine polling here — callers invoke [syncFromHome] only after an
/// existing Home refresh / command already paid the API budget.
class HomeWidgetBridge {
  HomeWidgetBridge({
    bool? enabled,
    Future<bool?> Function<T>(String id, T? data)? save,
    Future<bool?> Function({
      String? name,
      String? androidName,
      String? iOSName,
      String? qualifiedAndroidName,
    })? update,
    Future<bool?> Function(String groupId)? setAppGroupId,
  })  : _save = save ?? HomeWidget.saveWidgetData,
        _update = update ?? HomeWidget.updateWidget,
        _setAppGroupId = setAppGroupId ?? HomeWidget.setAppGroupId,
        _enabledOverride = enabled;

  final bool? _enabledOverride;
  final Future<bool?> Function<T>(String id, T? data) _save;
  final Future<bool?> Function({
    String? name,
    String? androidName,
    String? iOSName,
    String? qualifiedAndroidName,
  }) _update;
  final Future<bool?> Function(String groupId) _setAppGroupId;
  bool _appGroupReady = false;

  bool get isSupported {
    final override = _enabledOverride;
    if (override != null) return override;
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  Future<void> ensureConfigured() async {
    if (!isSupported || _appGroupReady) return;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      try {
        await _setAppGroupId(kIosAppGroupId);
      } catch (_) {
        // Best-effort; sync will no-op if App Group is missing.
      }
    }
    _appGroupReady = true;
  }

  Future<void> syncFromHome({
    required bool hasSession,
    Device? device,
    DeviceState? state,
    bool localeIsRussian = true,
  }) async {
    if (!isSupported) return;

    final snapshot = HomeWidgetSnapshot(
      hasSession: hasSession,
      deviceName: device?.alias,
      armed: state?.armed,
      online: state?.online ?? device?.online,
      updatedAt: state?.updatedAt,
      localeIsRussian: localeIsRussian,
    );

    await syncSnapshot(snapshot);
  }

  Future<void> syncSnapshot(HomeWidgetSnapshot snapshot) async {
    if (!isSupported) return;
    try {
      await ensureConfigured();
      final map = snapshot.toStorageMap();
      for (final entry in map.entries) {
        final value = entry.value;
        if (value is bool) {
          await _save<bool>(entry.key, value);
        } else if (value is String) {
          await _save<String>(entry.key, value);
        } else {
          await _save<String>(entry.key, null);
        }
      }
      await _update(
        name: kAndroidArmStatusWidgetName,
        androidName: kAndroidArmStatusWidgetName,
        iOSName: kIosArmStatusWidgetName,
      );
    } catch (_) {
      // Widget sync is best-effort (desktop / missing provider / plugin errors).
    }
  }

  Future<void> clear({bool localeIsRussian = true}) {
    return syncFromHome(hasSession: false, localeIsRussian: localeIsRussian);
  }
}
