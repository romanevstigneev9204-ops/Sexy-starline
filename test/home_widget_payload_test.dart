import 'package:flutter_test/flutter_test.dart';
import 'package:sexy_starline/application/widgets/home_widget_bridge.dart';
import 'package:sexy_starline/domain/entities/device.dart';
import 'package:sexy_starline/domain/entities/device_state.dart';
import 'package:sexy_starline/domain/widgets/home_widget_payload.dart';

void main() {
  group('HomeWidgetDeepLink', () {
    test('builds and parses arm/disarm/open URIs', () {
      expect(
        HomeWidgetDeepLink.uriFor(HomeWidgetAction.arm).toString(),
        'sexystarline://widget/arm',
      );
      expect(
        HomeWidgetDeepLink.uriFor(HomeWidgetAction.disarm).toString(),
        'sexystarline://widget/disarm',
      );
      expect(
        HomeWidgetDeepLink.uriFor(HomeWidgetAction.open).toString(),
        'sexystarline://widget/open',
      );

      expect(
        HomeWidgetDeepLink.parse(Uri.parse('sexystarline://widget/arm')),
        HomeWidgetAction.arm,
      );
      expect(
        HomeWidgetDeepLink.parse(Uri.parse('sexystarline://widget/disarm')),
        HomeWidgetAction.disarm,
      );
      expect(
        HomeWidgetDeepLink.parse(Uri.parse('sexystarline://widget/open')),
        HomeWidgetAction.open,
      );
      expect(HomeWidgetDeepLink.parse(Uri.parse('https://example.com')), isNull);
      expect(HomeWidgetDeepLink.parse(null), isNull);
    });
  });

  group('HomeWidgetSnapshot', () {
    test('signed-out snapshot asks to open the app', () {
      final map = const HomeWidgetSnapshot(hasSession: false).toStorageMap();
      expect(map[HomeWidgetKeys.hasSession], isFalse);
      expect(map[HomeWidgetKeys.statusLabel], 'Нет сессии');
      expect(map[HomeWidgetKeys.actionLabel], 'Открыть');
      expect(
        const HomeWidgetSnapshot(hasSession: false).primaryAction,
        HomeWidgetAction.open,
      );
    });

    test('armed online → disarm CTA + RU labels', () {
      final snap = HomeWidgetSnapshot(
        hasSession: true,
        deviceName: 'Camry',
        armed: true,
        online: true,
        updatedAt: DateTime.now(),
      );
      final map = snap.toStorageMap();
      expect(map[HomeWidgetKeys.deviceName], 'Camry');
      expect(map[HomeWidgetKeys.statusLabel], 'Под охраной');
      expect(map[HomeWidgetKeys.armed], isTrue);
      expect(map[HomeWidgetKeys.actionLabel], 'Снять');
      expect(snap.primaryAction, HomeWidgetAction.disarm);
    });

    test('disarmed online → arm CTA', () {
      final snap = const HomeWidgetSnapshot(
        hasSession: true,
        deviceName: 'Camry',
        armed: false,
        online: true,
      );
      expect(snap.toStorageMap()[HomeWidgetKeys.statusLabel], 'Снято');
      expect(snap.primaryAction, HomeWidgetAction.arm);
    });

    test('offline falls back to open', () {
      final snap = const HomeWidgetSnapshot(
        hasSession: true,
        deviceName: 'Camry',
        armed: true,
        online: false,
      );
      expect(snap.toStorageMap()[HomeWidgetKeys.statusLabel], 'Офлайн');
      expect(snap.primaryAction, HomeWidgetAction.open);
    });

    test('EN locale labels', () {
      final map = const HomeWidgetSnapshot(
        hasSession: true,
        deviceName: 'Camry',
        armed: false,
        online: true,
        localeIsRussian: false,
      ).toStorageMap();
      expect(map[HomeWidgetKeys.statusLabel], 'Disarmed');
      expect(map[HomeWidgetKeys.actionLabel], 'Arm');
    });
  });

  group('HomeWidgetBridge', () {
    test('syncSnapshot writes keys and updates Android provider name', () async {
      final saved = <String, Object?>{};
      String? updatedAndroid;
      final bridge = HomeWidgetBridge(
        enabled: true,
        save: <T>(id, data) async {
          saved[id] = data;
          return true;
        },
        update: ({
          name,
          androidName,
          iOSName,
          qualifiedAndroidName,
        }) async {
          updatedAndroid = androidName ?? name;
          return true;
        },
      );

      await bridge.syncFromHome(
        hasSession: true,
        device: const Device(id: '1', alias: 'Camry'),
        state: DeviceState(
          deviceId: '1',
          updatedAt: DateTime.now(),
          armed: true,
          online: true,
        ),
      );

      expect(saved[HomeWidgetKeys.deviceName], 'Camry');
      expect(saved[HomeWidgetKeys.armed], isTrue);
      expect(saved[HomeWidgetKeys.statusLabel], 'Под охраной');
      expect(updatedAndroid, kAndroidArmStatusWidgetName);
    });

    test('disabled bridge is a no-op', () async {
      var saveCalls = 0;
      final bridge = HomeWidgetBridge(
        enabled: false,
        save: <T>(id, data) async {
          saveCalls++;
          return true;
        },
      );
      await bridge.clear();
      expect(saveCalls, 0);
    });
  });
}
