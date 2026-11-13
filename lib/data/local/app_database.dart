import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Drift stub: cache for devices, state snapshots, events, API usage.
class DevicesTable extends Table {
  @override
  String get tableName => 'devices';

  TextColumn get id => text()();
  TextColumn get alias => text()();
  TextColumn get payloadJson => text()();
  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();
  BoolColumn get isShared => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class DeviceStatesTable extends Table {
  @override
  String get tableName => 'device_states';

  TextColumn get deviceId => text()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {deviceId};
}

class EventsTable extends Table {
  @override
  String get tableName => 'events';

  TextColumn get id => text()();
  TextColumn get deviceId => text()();
  TextColumn get title => text()();
  TextColumn get kind => text()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get payloadJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ApiUsageTable extends Table {
  @override
  String get tableName => 'api_usage';

  DateTimeColumn get day => dateTime()();
  IntColumn get requestCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {day};
}

class MetaTable extends Table {
  @override
  String get tableName => 'meta';

  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    DevicesTable,
    DeviceStatesTable,
    EventsTable,
    ApiUsageTable,
    MetaTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'sexy_starline'));

  @override
  int get schemaVersion => 1;

  Future<int> todayRequestCount() async {
    final start = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final row =
        await (select(apiUsageTable)..where((t) => t.day.equals(start)))
            .getSingleOrNull();
    return row?.requestCount ?? 0;
  }

  Future<void> incrementRequestCount() async {
    final start = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final existing =
        await (select(apiUsageTable)..where((t) => t.day.equals(start)))
            .getSingleOrNull();
    if (existing == null) {
      await into(apiUsageTable).insert(
        ApiUsageTableCompanion.insert(
          day: start,
          requestCount: const Value(1),
        ),
      );
    } else {
      await (update(apiUsageTable)..where((t) => t.day.equals(start))).write(
        ApiUsageTableCompanion(
          requestCount: Value(existing.requestCount + 1),
        ),
      );
    }
  }
}
