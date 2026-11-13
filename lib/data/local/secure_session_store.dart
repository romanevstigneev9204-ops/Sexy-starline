import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/session.dart';

/// Session + primary device persistence.
///
/// When [memoryOnly] is true (demo / no AppId), never touches the platform
/// keyring — avoids Linux libsecret prompts on the first-run demo path.
class SecureSessionStore {
  SecureSessionStore({
    FlutterSecureStorage? storage,
    this.memoryOnly = false,
  }) : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  static const _kSlnet = 'slnet';
  static const _kUserId = 'user_id';
  static const _kDemo = 'demo';
  static const _kPrimaryDevice = 'primary_device_id';

  final FlutterSecureStorage _storage;
  final bool memoryOnly;

  Session? _memorySession;
  String? _memoryPrimaryDeviceId;

  Future<Session?> readSession() async {
    if (memoryOnly) return _memorySession;
    try {
      final slnet = await _storage.read(key: _kSlnet);
      final userId = await _storage.read(key: _kUserId);
      if (slnet == null || userId == null) return null;
      final demo = (await _storage.read(key: _kDemo)) == '1';
      return Session(slnet: slnet, userId: userId, demo: demo);
    } catch (_) {
      return _memorySession;
    }
  }

  Future<void> saveSession(Session session) async {
    _memorySession = session;
    if (memoryOnly) return;
    try {
      await _storage.write(key: _kSlnet, value: session.slnet);
      await _storage.write(key: _kUserId, value: session.userId);
      await _storage.write(key: _kDemo, value: session.demo ? '1' : '0');
    } catch (_) {
      // Keep in-memory session so demo / desktop without keyring still works.
    }
  }

  Future<void> clearSession() async {
    _memorySession = null;
    if (memoryOnly) return;
    try {
      await _storage.delete(key: _kSlnet);
      await _storage.delete(key: _kUserId);
      await _storage.delete(key: _kDemo);
    } catch (_) {}
  }

  Future<String?> readPrimaryDeviceId() async {
    if (memoryOnly) return _memoryPrimaryDeviceId;
    try {
      return await _storage.read(key: _kPrimaryDevice);
    } catch (_) {
      return _memoryPrimaryDeviceId;
    }
  }

  Future<void> savePrimaryDeviceId(String id) async {
    _memoryPrimaryDeviceId = id;
    if (memoryOnly) return;
    try {
      await _storage.write(key: _kPrimaryDevice, value: id);
    } catch (_) {}
  }
}
