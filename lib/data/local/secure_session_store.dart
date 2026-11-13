import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/session.dart';

class SecureSessionStore {
  SecureSessionStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  static const _kSlnet = 'slnet';
  static const _kUserId = 'user_id';
  static const _kDemo = 'demo';
  static const _kPrimaryDevice = 'primary_device_id';

  final FlutterSecureStorage _storage;

  Future<Session?> readSession() async {
    final slnet = await _storage.read(key: _kSlnet);
    final userId = await _storage.read(key: _kUserId);
    if (slnet == null || userId == null) return null;
    final demo = (await _storage.read(key: _kDemo)) == '1';
    return Session(slnet: slnet, userId: userId, demo: demo);
  }

  Future<void> saveSession(Session session) async {
    await _storage.write(key: _kSlnet, value: session.slnet);
    await _storage.write(key: _kUserId, value: session.userId);
    await _storage.write(key: _kDemo, value: session.demo ? '1' : '0');
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _kSlnet);
    await _storage.delete(key: _kUserId);
    await _storage.delete(key: _kDemo);
  }

  Future<String?> readPrimaryDeviceId() =>
      _storage.read(key: _kPrimaryDevice);

  Future<void> savePrimaryDeviceId(String id) =>
      _storage.write(key: _kPrimaryDevice, value: id);
}
