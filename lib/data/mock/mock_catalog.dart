import '../../domain/entities/device.dart';
import '../../domain/entities/device_state.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/geofence.dart';
import '../../domain/entities/obd_params.dart';
import '../../domain/entities/sim_balance.dart';
import '../../domain/entities/track.dart';

abstract final class MockCatalog {
  static const demoSimBalance = SimBalance(
    value: 186.40,
    currency: '₽',
    operatorName: 'МТС',
  );

  static final devices = <Device>[
    const Device(
      id: 'demo-bmw',
      alias: 'BMW X5',
      typeName: 'S96',
      phone: '+79001234567',
      online: true,
      gsmLevel: 4,
      isPrimary: true,
      functions: [
        'state',
        'position',
        'tracking',
        'obd_params',
        'arm',
        'ign',
        'poke',
        'arm_quiet',
        'panic',
        'valet',
        'webasto',
        'out',
      ],
      controls: [
        'arm',
        'ign',
        'poke',
        'arm_quiet',
        'panic',
        'valet',
        'webasto',
        'out',
      ],
      simBalance: demoSimBalance,
    ),
    const Device(
      id: 'demo-skoda',
      alias: 'Skoda Octavia',
      typeName: 'A96',
      online: true,
      gsmLevel: 3,
      functions: [
        'state',
        'position',
        'tracking',
        'arm',
        'ign',
        'poke',
        'arm_quiet',
        'webasto',
      ],
      controls: ['arm', 'ign', 'poke', 'arm_quiet', 'webasto'],
      simBalance: SimBalance(
        value: 52,
        currency: '₽',
        operatorName: 'Билайн',
      ),
    ),
    const Device(
      id: 'demo-vesta',
      alias: 'Lada Vesta',
      typeName: 'S96',
      online: false,
      gsmLevel: 1,
      isShared: true,
      functions: ['state', 'arm'],
      controls: ['arm'],
    ),
  ];

  static DeviceState stateFor(String deviceId, {bool offline = false}) {
    final now = DateTime.now();
    SimBalance? balance;
    for (final d in devices) {
      if (d.id == deviceId) {
        balance = d.simBalance;
        break;
      }
    }
    return DeviceState(
      deviceId: deviceId,
      updatedAt: offline ? now.subtract(const Duration(minutes: 42)) : now,
      armed: true,
      engineRunning: false,
      doorsClosed: true,
      online: !offline,
      valet: false,
      webasto: false,
      auxOn: false,
      batteryVolts: 12.4,
      cabinTempC: 4,
      engineTempC: 12,
      gsmLevel: offline ? 0 : 4,
      latitude: 55.7784,
      longitude: 37.5865,
      address: 'Москва, ул. Лесная',
      simBalance: balance ?? demoSimBalance,
    );
  }

  static List<VehicleEvent> eventsFor(String deviceId) {
    final now = DateTime.now();
    DateTime ago(int minutes) => now.subtract(Duration(minutes: minutes));
    return [
      VehicleEvent(
        id: 'e1',
        deviceId: deviceId,
        title: 'Тревога: удар',
        timestamp: ago(42),
        kind: EventKind.alarm,
      ),
      VehicleEvent(
        id: 'e2',
        deviceId: deviceId,
        title: 'Вход в геозону «Дом»',
        timestamp: ago(55),
        kind: EventKind.status,
      ),
      VehicleEvent(
        id: 'e3',
        deviceId: deviceId,
        title: 'Поставлено на охрану',
        timestamp: ago(70),
        kind: EventKind.command,
      ),
      VehicleEvent(
        id: 'e4',
        deviceId: deviceId,
        title: 'Двигатель заглушен',
        timestamp: ago(72),
        kind: EventKind.command,
      ),
      VehicleEvent(
        id: 'e5',
        deviceId: deviceId,
        title: 'Двигатель запущен',
        timestamp: ago(95),
        kind: EventKind.command,
      ),
      VehicleEvent(
        id: 'e6',
        deviceId: deviceId,
        title: 'Снято с охраны',
        timestamp: ago(98),
        kind: EventKind.command,
      ),
      VehicleEvent(
        id: 'e7',
        deviceId: deviceId,
        title: 'Выход из геозоны «Офис»',
        timestamp: ago(210),
        kind: EventKind.status,
      ),
      VehicleEvent(
        id: 'e8',
        deviceId: deviceId,
        title: 'Online',
        timestamp: ago(220),
        kind: EventKind.status,
      ),
    ];
  }

  /// Demo OBD — only for devices with `obd_params` in functions.
  static ObdParams? obdFor(String deviceId) {
    Device? device;
    for (final d in devices) {
      if (d.id == deviceId) {
        device = d;
        break;
      }
    }
    if (device == null || !device.supportsObd) return null;
    final now = DateTime.now();
    return ObdParams(
      deviceId: deviceId,
      fuelValue: 42,
      fuelUnit: ObdFuelUnit.percent,
      mileageKm: 68420,
      errorCount: 0,
      fuelUpdatedAt: now.subtract(const Duration(minutes: 18)),
      mileageUpdatedAt: now.subtract(const Duration(hours: 2)),
      errorsUpdatedAt: now.subtract(const Duration(days: 1)),
      fetchedAt: now,
    );
  }

  /// Two demo trips near Лесная (Moscow), anchored just before «now»
  /// so they stay visible regardless of wall-clock hour.
  static TrackPeriod tracksFor(
    String deviceId, {
    DateTime? begin,
    DateTime? end,
  }) {
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day);
    final periodBegin = begin ?? dayStart;
    final periodEnd = end ?? now;

    DateTime atMinutesAgo(int minutes) =>
        now.subtract(Duration(minutes: minutes));

    TrackPoint p(double lat, double lon, DateTime ts) => TrackPoint(
          latitude: lat,
          longitude: lon,
          timestamp: ts,
        );

    final recentStart = atMinutesAgo(95);
    final recentEnd = atMinutesAgo(70);
    final olderStart = atMinutesAgo(220);
    final olderEnd = atMinutesAgo(195);

    final recent = GpsTrack(
      id: 'demo-way-1',
      deviceId: deviceId,
      startedAt: recentStart,
      endedAt: recentEnd,
      mileageKm: 6.4,
      duration: recentEnd.difference(recentStart),
      points: [
        p(55.7784, 37.5865, recentStart),
        p(55.7798, 37.5902, recentStart.add(const Duration(minutes: 5))),
        p(55.7821, 37.5958, recentStart.add(const Duration(minutes: 10))),
        p(55.7850, 37.6010, recentStart.add(const Duration(minutes: 15))),
        p(55.7872, 37.6088, recentStart.add(const Duration(minutes: 20))),
        p(55.7890, 37.6145, recentEnd),
      ],
    );

    final older = GpsTrack(
      id: 'demo-way-2',
      deviceId: deviceId,
      startedAt: olderStart,
      endedAt: olderEnd,
      mileageKm: 7.1,
      duration: olderEnd.difference(olderStart),
      points: [
        p(55.7890, 37.6145, olderStart),
        p(55.7865, 37.6060, olderStart.add(const Duration(minutes: 5))),
        p(55.7832, 37.5975, olderStart.add(const Duration(minutes: 12))),
        p(55.7801, 37.5910, olderStart.add(const Duration(minutes: 18))),
        p(55.7784, 37.5865, olderEnd),
      ],
    );

    // Demo always returns both trips (period labels still reflect the request).
    return TrackPeriod(
      deviceId: deviceId,
      begin: periodBegin,
      end: periodEnd,
      tracks: [recent, older],
      fetchedAt: now,
    );
  }

  /// Demo client geofences around Лесная — local only, no StarLine API.
  static List<Geofence> geofencesFor(String deviceId) {
    return [
      Geofence(
        id: 'demo-gf-home-$deviceId',
        deviceId: deviceId,
        name: 'Дом',
        latitude: 55.7784,
        longitude: 37.5865,
        radiusMeters: 250,
        enabled: true,
        alertOnEnter: true,
        alertOnExit: true,
        lastSide: GeofenceSide.inside,
      ),
      Geofence(
        id: 'demo-gf-office-$deviceId',
        deviceId: deviceId,
        name: 'Офис',
        latitude: 55.7890,
        longitude: 37.6145,
        radiusMeters: 300,
        enabled: true,
        alertOnEnter: true,
        alertOnExit: true,
        lastSide: GeofenceSide.outside,
      ),
    ];
  }
}
