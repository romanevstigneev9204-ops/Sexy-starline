import 'package:drift/drift.dart';

import '../../domain/entities/geofence.dart';
import 'app_database.dart';

/// Local CRUD for client geofences (Drift). No StarLine network calls.
class GeofenceStore {
  GeofenceStore(this._db);

  final AppDatabase _db;

  Future<List<Geofence>> listForDevice(String deviceId) async {
    final rows = await (_db.select(_db.geofencesTable)
          ..where((t) => t.deviceId.equals(deviceId)))
        .get();
    return rows.map(_fromRow).toList(growable: false);
  }

  Future<void> upsert(Geofence fence) async {
    await _db.into(_db.geofencesTable).insertOnConflictUpdate(
          GeofencesTableCompanion.insert(
            id: fence.id,
            deviceId: fence.deviceId,
            name: fence.name,
            latitude: fence.latitude,
            longitude: fence.longitude,
            radiusMeters: fence.radiusMeters,
            enabled: Value(fence.enabled),
            alertOnEnter: Value(fence.alertOnEnter),
            alertOnExit: Value(fence.alertOnExit),
            lastSide: Value(fence.lastSide.name),
          ),
        );
  }

  Future<void> upsertAll(List<Geofence> fences) async {
    for (final fence in fences) {
      await upsert(fence);
    }
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.geofencesTable)..where((t) => t.id.equals(id))).go();
  }

  Future<void> updateLastSide(String id, GeofenceSide side) async {
    await (_db.update(_db.geofencesTable)..where((t) => t.id.equals(id))).write(
      GeofencesTableCompanion(lastSide: Value(side.name)),
    );
  }

  Geofence _fromRow(GeofencesTableData row) {
    return Geofence(
      id: row.id,
      deviceId: row.deviceId,
      name: row.name,
      latitude: row.latitude,
      longitude: row.longitude,
      radiusMeters: row.radiusMeters,
      enabled: row.enabled,
      alertOnEnter: row.alertOnEnter,
      alertOnExit: row.alertOnExit,
      lastSide: GeofenceSide.values.firstWhere(
        (e) => e.name == row.lastSide,
        orElse: () => GeofenceSide.unknown,
      ),
    );
  }
}
