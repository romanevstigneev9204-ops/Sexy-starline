import '../../domain/entities/device.dart';
import '../../domain/entities/device_state.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/sim_balance.dart';

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
        'arm',
        'ign',
        'poke',
        'arm_quiet',
        'panic',
        'valet',
      ],
      controls: [
        'arm',
        'ign',
        'poke',
        'arm_quiet',
        'panic',
        'valet',
      ],
      simBalance: demoSimBalance,
    ),
    const Device(
      id: 'demo-skoda',
      alias: 'Skoda Octavia',
      typeName: 'A96',
      online: true,
      gsmLevel: 3,
      functions: ['state', 'position', 'arm', 'ign', 'poke', 'arm_quiet'],
      controls: ['arm', 'ign', 'poke', 'arm_quiet'],
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
    final today = DateTime.now();
    DateTime at(int h, int m) =>
        DateTime(today.year, today.month, today.day, h, m);
    return [
      VehicleEvent(
        id: 'e1',
        deviceId: deviceId,
        title: 'Тревога: удар',
        timestamp: at(8, 14),
        kind: EventKind.alarm,
      ),
      VehicleEvent(
        id: 'e2',
        deviceId: deviceId,
        title: 'Поставлено на охрану',
        timestamp: at(7, 52),
        kind: EventKind.command,
      ),
      VehicleEvent(
        id: 'e3',
        deviceId: deviceId,
        title: 'Двигатель запущен',
        timestamp: at(7, 40),
        kind: EventKind.command,
      ),
      VehicleEvent(
        id: 'e4',
        deviceId: deviceId,
        title: 'Снято с охраны',
        timestamp: at(7, 38),
        kind: EventKind.command,
      ),
      VehicleEvent(
        id: 'e5',
        deviceId: deviceId,
        title: 'Online',
        timestamp: at(7, 30),
        kind: EventKind.status,
      ),
    ];
  }
}
