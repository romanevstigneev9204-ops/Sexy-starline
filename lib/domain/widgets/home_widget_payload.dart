/// Pure payload + deep-link helpers for the home-screen arm status widget.
///
/// Widgets must **not** poll StarLine themselves — Flutter pushes a snapshot
/// after Home refresh / command (respects [PollPolicy] API budget).
abstract final class HomeWidgetKeys {
  static const deviceName = 'device_name';
  static const statusLabel = 'status_label';
  static const subtitle = 'subtitle';
  static const actionLabel = 'action_label';
  static const armed = 'armed';
  static const online = 'online';
  static const hasSession = 'has_session';
  static const updatedAtIso = 'updated_at_iso';
}

enum HomeWidgetAction { open, arm, disarm }

/// Canonical Android AppWidgetProvider class simple name (must match Kotlin).
const kAndroidArmStatusWidgetName = 'ArmStatusWidgetProvider';

/// iOS WidgetKit kind — must match `ArmStatusWidget` in ios/ArmStatusWidget.
const kIosArmStatusWidgetName = 'ArmStatusWidget';

/// App Group shared by Runner + WidgetKit extension (home_widget UserDefaults).
const kIosAppGroupId = 'group.ru.sexystarline.app';

/// Custom scheme used by [HomeWidgetLaunchIntent] / WidgetKit deep links.
const kHomeWidgetScheme = 'sexystarline';

class HomeWidgetSnapshot {
  const HomeWidgetSnapshot({
    required this.hasSession,
    this.deviceName,
    this.armed,
    this.online,
    this.updatedAt,
    this.localeIsRussian = true,
  });

  final bool hasSession;
  final String? deviceName;
  final bool? armed;
  final bool? online;
  final DateTime? updatedAt;
  final bool localeIsRussian;

  /// Flat map written into home_widget SharedPreferences / UserDefaults.
  Map<String, Object?> toStorageMap() {
    if (!hasSession) {
      return {
        HomeWidgetKeys.hasSession: false,
        HomeWidgetKeys.deviceName: 'Sexy Starline',
        HomeWidgetKeys.statusLabel:
            localeIsRussian ? 'Нет сессии' : 'Signed out',
        HomeWidgetKeys.subtitle:
            localeIsRussian ? 'Откройте приложение' : 'Open the app',
        HomeWidgetKeys.actionLabel:
            localeIsRussian ? 'Открыть' : 'Open',
        HomeWidgetKeys.armed: false,
        HomeWidgetKeys.online: false,
        HomeWidgetKeys.updatedAtIso: null,
      };
    }

    final name = (deviceName == null || deviceName!.trim().isEmpty)
        ? (localeIsRussian ? 'Авто' : 'Vehicle')
        : deviceName!.trim();
    final isOnline = online ?? false;
    final isArmed = armed ?? false;

    final String status;
    if (!isOnline) {
      status = localeIsRussian ? 'Офлайн' : 'Offline';
    } else if (isArmed) {
      status = localeIsRussian ? 'Под охраной' : 'Armed';
    } else {
      status = localeIsRussian ? 'Снято' : 'Disarmed';
    }

    final String action;
    if (!isOnline) {
      action = localeIsRussian ? 'Открыть' : 'Open';
    } else if (isArmed) {
      action = localeIsRussian ? 'Снять' : 'Disarm';
    } else {
      action = localeIsRussian ? 'Поставить' : 'Arm';
    }

    final subtitle = _freshnessLabel(updatedAt, localeIsRussian);

    return {
      HomeWidgetKeys.hasSession: true,
      HomeWidgetKeys.deviceName: name,
      HomeWidgetKeys.statusLabel: status,
      HomeWidgetKeys.subtitle: subtitle,
      HomeWidgetKeys.actionLabel: action,
      HomeWidgetKeys.armed: isArmed,
      HomeWidgetKeys.online: isOnline,
      HomeWidgetKeys.updatedAtIso: updatedAt?.toUtc().toIso8601String(),
    };
  }

  /// Primary CTA action for the widget button given current snapshot.
  HomeWidgetAction get primaryAction {
    if (!hasSession || online != true) return HomeWidgetAction.open;
    if (armed == true) return HomeWidgetAction.disarm;
    return HomeWidgetAction.arm;
  }

  static String _freshnessLabel(DateTime? updatedAt, bool ru) {
    if (updatedAt == null) {
      return ru ? 'Нет данных' : 'No data';
    }
    final mins = DateTime.now().difference(updatedAt).inMinutes;
    if (mins <= 0) {
      return ru ? 'только что' : 'just now';
    }
    if (mins < 60) {
      return ru ? '$mins мин назад' : '${mins}m ago';
    }
    final hours = mins ~/ 60;
    return ru ? '$hours ч назад' : '${hours}h ago';
  }
}

abstract final class HomeWidgetDeepLink {
  /// Builds a widget deep-link. On iOS, [forIos] adds the `homeWidget` query
  /// param required by the home_widget plugin to detect widget launches.
  static Uri uriFor(HomeWidgetAction action, {bool forIos = false}) {
    final path = switch (action) {
      HomeWidgetAction.open => 'open',
      HomeWidgetAction.arm => 'arm',
      HomeWidgetAction.disarm => 'disarm',
    };
    return Uri(
      scheme: kHomeWidgetScheme,
      host: 'widget',
      path: '/$path',
      queryParameters: forIos ? const {'homeWidget': ''} : null,
    );
  }

  static HomeWidgetAction? parse(Uri? uri) {
    if (uri == null) return null;
    if (uri.scheme != kHomeWidgetScheme) return null;
    if (uri.host != 'widget') return null;
    final seg = uri.pathSegments.isEmpty ? '' : uri.pathSegments.first;
    return switch (seg) {
      'arm' => HomeWidgetAction.arm,
      'disarm' => HomeWidgetAction.disarm,
      'open' || '' => HomeWidgetAction.open,
      _ => HomeWidgetAction.open,
    };
  }
}
