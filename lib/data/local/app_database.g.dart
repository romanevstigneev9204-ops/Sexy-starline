// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $DevicesTableTable extends DevicesTable
    with TableInfo<$DevicesTableTable, DevicesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aliasMeta = const VerificationMeta('alias');
  @override
  late final GeneratedColumn<String> alias = GeneratedColumn<String>(
    'alias',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPrimaryMeta = const VerificationMeta(
    'isPrimary',
  );
  @override
  late final GeneratedColumn<bool> isPrimary = GeneratedColumn<bool>(
    'is_primary',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_primary" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isSharedMeta = const VerificationMeta(
    'isShared',
  );
  @override
  late final GeneratedColumn<bool> isShared = GeneratedColumn<bool>(
    'is_shared',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_shared" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    alias,
    payloadJson,
    isPrimary,
    isShared,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<DevicesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('alias')) {
      context.handle(
        _aliasMeta,
        alias.isAcceptableOrUnknown(data['alias']!, _aliasMeta),
      );
    } else if (isInserting) {
      context.missing(_aliasMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('is_primary')) {
      context.handle(
        _isPrimaryMeta,
        isPrimary.isAcceptableOrUnknown(data['is_primary']!, _isPrimaryMeta),
      );
    }
    if (data.containsKey('is_shared')) {
      context.handle(
        _isSharedMeta,
        isShared.isAcceptableOrUnknown(data['is_shared']!, _isSharedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DevicesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DevicesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      alias: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alias'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      isPrimary: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_primary'],
      )!,
      isShared: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_shared'],
      )!,
    );
  }

  @override
  $DevicesTableTable createAlias(String alias) {
    return $DevicesTableTable(attachedDatabase, alias);
  }
}

class DevicesTableData extends DataClass
    implements Insertable<DevicesTableData> {
  final String id;
  final String alias;
  final String payloadJson;
  final bool isPrimary;
  final bool isShared;
  const DevicesTableData({
    required this.id,
    required this.alias,
    required this.payloadJson,
    required this.isPrimary,
    required this.isShared,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['alias'] = Variable<String>(alias);
    map['payload_json'] = Variable<String>(payloadJson);
    map['is_primary'] = Variable<bool>(isPrimary);
    map['is_shared'] = Variable<bool>(isShared);
    return map;
  }

  DevicesTableCompanion toCompanion(bool nullToAbsent) {
    return DevicesTableCompanion(
      id: Value(id),
      alias: Value(alias),
      payloadJson: Value(payloadJson),
      isPrimary: Value(isPrimary),
      isShared: Value(isShared),
    );
  }

  factory DevicesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DevicesTableData(
      id: serializer.fromJson<String>(json['id']),
      alias: serializer.fromJson<String>(json['alias']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      isPrimary: serializer.fromJson<bool>(json['isPrimary']),
      isShared: serializer.fromJson<bool>(json['isShared']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'alias': serializer.toJson<String>(alias),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'isPrimary': serializer.toJson<bool>(isPrimary),
      'isShared': serializer.toJson<bool>(isShared),
    };
  }

  DevicesTableData copyWith({
    String? id,
    String? alias,
    String? payloadJson,
    bool? isPrimary,
    bool? isShared,
  }) => DevicesTableData(
    id: id ?? this.id,
    alias: alias ?? this.alias,
    payloadJson: payloadJson ?? this.payloadJson,
    isPrimary: isPrimary ?? this.isPrimary,
    isShared: isShared ?? this.isShared,
  );
  DevicesTableData copyWithCompanion(DevicesTableCompanion data) {
    return DevicesTableData(
      id: data.id.present ? data.id.value : this.id,
      alias: data.alias.present ? data.alias.value : this.alias,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      isPrimary: data.isPrimary.present ? data.isPrimary.value : this.isPrimary,
      isShared: data.isShared.present ? data.isShared.value : this.isShared,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DevicesTableData(')
          ..write('id: $id, ')
          ..write('alias: $alias, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('isShared: $isShared')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, alias, payloadJson, isPrimary, isShared);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DevicesTableData &&
          other.id == this.id &&
          other.alias == this.alias &&
          other.payloadJson == this.payloadJson &&
          other.isPrimary == this.isPrimary &&
          other.isShared == this.isShared);
}

class DevicesTableCompanion extends UpdateCompanion<DevicesTableData> {
  final Value<String> id;
  final Value<String> alias;
  final Value<String> payloadJson;
  final Value<bool> isPrimary;
  final Value<bool> isShared;
  final Value<int> rowid;
  const DevicesTableCompanion({
    this.id = const Value.absent(),
    this.alias = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.isShared = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevicesTableCompanion.insert({
    required String id,
    required String alias,
    required String payloadJson,
    this.isPrimary = const Value.absent(),
    this.isShared = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       alias = Value(alias),
       payloadJson = Value(payloadJson);
  static Insertable<DevicesTableData> custom({
    Expression<String>? id,
    Expression<String>? alias,
    Expression<String>? payloadJson,
    Expression<bool>? isPrimary,
    Expression<bool>? isShared,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (alias != null) 'alias': alias,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (isPrimary != null) 'is_primary': isPrimary,
      if (isShared != null) 'is_shared': isShared,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevicesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? alias,
    Value<String>? payloadJson,
    Value<bool>? isPrimary,
    Value<bool>? isShared,
    Value<int>? rowid,
  }) {
    return DevicesTableCompanion(
      id: id ?? this.id,
      alias: alias ?? this.alias,
      payloadJson: payloadJson ?? this.payloadJson,
      isPrimary: isPrimary ?? this.isPrimary,
      isShared: isShared ?? this.isShared,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (alias.present) {
      map['alias'] = Variable<String>(alias.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (isPrimary.present) {
      map['is_primary'] = Variable<bool>(isPrimary.value);
    }
    if (isShared.present) {
      map['is_shared'] = Variable<bool>(isShared.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicesTableCompanion(')
          ..write('id: $id, ')
          ..write('alias: $alias, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('isShared: $isShared, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DeviceStatesTableTable extends DeviceStatesTable
    with TableInfo<$DeviceStatesTableTable, DeviceStatesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeviceStatesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [deviceId, payloadJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'device_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeviceStatesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {deviceId};
  @override
  DeviceStatesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceStatesTableData(
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DeviceStatesTableTable createAlias(String alias) {
    return $DeviceStatesTableTable(attachedDatabase, alias);
  }
}

class DeviceStatesTableData extends DataClass
    implements Insertable<DeviceStatesTableData> {
  final String deviceId;
  final String payloadJson;
  final DateTime updatedAt;
  const DeviceStatesTableData({
    required this.deviceId,
    required this.payloadJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['device_id'] = Variable<String>(deviceId);
    map['payload_json'] = Variable<String>(payloadJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DeviceStatesTableCompanion toCompanion(bool nullToAbsent) {
    return DeviceStatesTableCompanion(
      deviceId: Value(deviceId),
      payloadJson: Value(payloadJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory DeviceStatesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceStatesTableData(
      deviceId: serializer.fromJson<String>(json['deviceId']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'deviceId': serializer.toJson<String>(deviceId),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DeviceStatesTableData copyWith({
    String? deviceId,
    String? payloadJson,
    DateTime? updatedAt,
  }) => DeviceStatesTableData(
    deviceId: deviceId ?? this.deviceId,
    payloadJson: payloadJson ?? this.payloadJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DeviceStatesTableData copyWithCompanion(DeviceStatesTableCompanion data) {
    return DeviceStatesTableData(
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceStatesTableData(')
          ..write('deviceId: $deviceId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(deviceId, payloadJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceStatesTableData &&
          other.deviceId == this.deviceId &&
          other.payloadJson == this.payloadJson &&
          other.updatedAt == this.updatedAt);
}

class DeviceStatesTableCompanion
    extends UpdateCompanion<DeviceStatesTableData> {
  final Value<String> deviceId;
  final Value<String> payloadJson;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DeviceStatesTableCompanion({
    this.deviceId = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeviceStatesTableCompanion.insert({
    required String deviceId,
    required String payloadJson,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : deviceId = Value(deviceId),
       payloadJson = Value(payloadJson),
       updatedAt = Value(updatedAt);
  static Insertable<DeviceStatesTableData> custom({
    Expression<String>? deviceId,
    Expression<String>? payloadJson,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (deviceId != null) 'device_id': deviceId,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeviceStatesTableCompanion copyWith({
    Value<String>? deviceId,
    Value<String>? payloadJson,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DeviceStatesTableCompanion(
      deviceId: deviceId ?? this.deviceId,
      payloadJson: payloadJson ?? this.payloadJson,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeviceStatesTableCompanion(')
          ..write('deviceId: $deviceId, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventsTableTable extends EventsTable
    with TableInfo<$EventsTableTable, EventsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    title,
    kind,
    timestamp,
    payloadJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'events';
  @override
  VerificationContext validateIntegrity(
    Insertable<EventsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EventsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      ),
    );
  }

  @override
  $EventsTableTable createAlias(String alias) {
    return $EventsTableTable(attachedDatabase, alias);
  }
}

class EventsTableData extends DataClass implements Insertable<EventsTableData> {
  final String id;
  final String deviceId;
  final String title;
  final String kind;
  final DateTime timestamp;
  final String? payloadJson;
  const EventsTableData({
    required this.id,
    required this.deviceId,
    required this.title,
    required this.kind,
    required this.timestamp,
    this.payloadJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['title'] = Variable<String>(title);
    map['kind'] = Variable<String>(kind);
    map['timestamp'] = Variable<DateTime>(timestamp);
    if (!nullToAbsent || payloadJson != null) {
      map['payload_json'] = Variable<String>(payloadJson);
    }
    return map;
  }

  EventsTableCompanion toCompanion(bool nullToAbsent) {
    return EventsTableCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      title: Value(title),
      kind: Value(kind),
      timestamp: Value(timestamp),
      payloadJson: payloadJson == null && nullToAbsent
          ? const Value.absent()
          : Value(payloadJson),
    );
  }

  factory EventsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventsTableData(
      id: serializer.fromJson<String>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      title: serializer.fromJson<String>(json['title']),
      kind: serializer.fromJson<String>(json['kind']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      payloadJson: serializer.fromJson<String?>(json['payloadJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'title': serializer.toJson<String>(title),
      'kind': serializer.toJson<String>(kind),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'payloadJson': serializer.toJson<String?>(payloadJson),
    };
  }

  EventsTableData copyWith({
    String? id,
    String? deviceId,
    String? title,
    String? kind,
    DateTime? timestamp,
    Value<String?> payloadJson = const Value.absent(),
  }) => EventsTableData(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    title: title ?? this.title,
    kind: kind ?? this.kind,
    timestamp: timestamp ?? this.timestamp,
    payloadJson: payloadJson.present ? payloadJson.value : this.payloadJson,
  );
  EventsTableData copyWithCompanion(EventsTableCompanion data) {
    return EventsTableData(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      title: data.title.present ? data.title.value : this.title,
      kind: data.kind.present ? data.kind.value : this.kind,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventsTableData(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('title: $title, ')
          ..write('kind: $kind, ')
          ..write('timestamp: $timestamp, ')
          ..write('payloadJson: $payloadJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, deviceId, title, kind, timestamp, payloadJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventsTableData &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.title == this.title &&
          other.kind == this.kind &&
          other.timestamp == this.timestamp &&
          other.payloadJson == this.payloadJson);
}

class EventsTableCompanion extends UpdateCompanion<EventsTableData> {
  final Value<String> id;
  final Value<String> deviceId;
  final Value<String> title;
  final Value<String> kind;
  final Value<DateTime> timestamp;
  final Value<String?> payloadJson;
  final Value<int> rowid;
  const EventsTableCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.title = const Value.absent(),
    this.kind = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventsTableCompanion.insert({
    required String id,
    required String deviceId,
    required String title,
    required String kind,
    required DateTime timestamp,
    this.payloadJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       deviceId = Value(deviceId),
       title = Value(title),
       kind = Value(kind),
       timestamp = Value(timestamp);
  static Insertable<EventsTableData> custom({
    Expression<String>? id,
    Expression<String>? deviceId,
    Expression<String>? title,
    Expression<String>? kind,
    Expression<DateTime>? timestamp,
    Expression<String>? payloadJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (title != null) 'title': title,
      if (kind != null) 'kind': kind,
      if (timestamp != null) 'timestamp': timestamp,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? deviceId,
    Value<String>? title,
    Value<String>? kind,
    Value<DateTime>? timestamp,
    Value<String?>? payloadJson,
    Value<int>? rowid,
  }) {
    return EventsTableCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      title: title ?? this.title,
      kind: kind ?? this.kind,
      timestamp: timestamp ?? this.timestamp,
      payloadJson: payloadJson ?? this.payloadJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventsTableCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('title: $title, ')
          ..write('kind: $kind, ')
          ..write('timestamp: $timestamp, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ApiUsageTableTable extends ApiUsageTable
    with TableInfo<$ApiUsageTableTable, ApiUsageTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ApiUsageTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<DateTime> day = GeneratedColumn<DateTime>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requestCountMeta = const VerificationMeta(
    'requestCount',
  );
  @override
  late final GeneratedColumn<int> requestCount = GeneratedColumn<int>(
    'request_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [day, requestCount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'api_usage';
  @override
  VerificationContext validateIntegrity(
    Insertable<ApiUsageTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('request_count')) {
      context.handle(
        _requestCountMeta,
        requestCount.isAcceptableOrUnknown(
          data['request_count']!,
          _requestCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day};
  @override
  ApiUsageTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ApiUsageTableData(
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}day'],
      )!,
      requestCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}request_count'],
      )!,
    );
  }

  @override
  $ApiUsageTableTable createAlias(String alias) {
    return $ApiUsageTableTable(attachedDatabase, alias);
  }
}

class ApiUsageTableData extends DataClass
    implements Insertable<ApiUsageTableData> {
  final DateTime day;
  final int requestCount;
  const ApiUsageTableData({required this.day, required this.requestCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<DateTime>(day);
    map['request_count'] = Variable<int>(requestCount);
    return map;
  }

  ApiUsageTableCompanion toCompanion(bool nullToAbsent) {
    return ApiUsageTableCompanion(
      day: Value(day),
      requestCount: Value(requestCount),
    );
  }

  factory ApiUsageTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ApiUsageTableData(
      day: serializer.fromJson<DateTime>(json['day']),
      requestCount: serializer.fromJson<int>(json['requestCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<DateTime>(day),
      'requestCount': serializer.toJson<int>(requestCount),
    };
  }

  ApiUsageTableData copyWith({DateTime? day, int? requestCount}) =>
      ApiUsageTableData(
        day: day ?? this.day,
        requestCount: requestCount ?? this.requestCount,
      );
  ApiUsageTableData copyWithCompanion(ApiUsageTableCompanion data) {
    return ApiUsageTableData(
      day: data.day.present ? data.day.value : this.day,
      requestCount: data.requestCount.present
          ? data.requestCount.value
          : this.requestCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ApiUsageTableData(')
          ..write('day: $day, ')
          ..write('requestCount: $requestCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(day, requestCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ApiUsageTableData &&
          other.day == this.day &&
          other.requestCount == this.requestCount);
}

class ApiUsageTableCompanion extends UpdateCompanion<ApiUsageTableData> {
  final Value<DateTime> day;
  final Value<int> requestCount;
  final Value<int> rowid;
  const ApiUsageTableCompanion({
    this.day = const Value.absent(),
    this.requestCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ApiUsageTableCompanion.insert({
    required DateTime day,
    this.requestCount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : day = Value(day);
  static Insertable<ApiUsageTableData> custom({
    Expression<DateTime>? day,
    Expression<int>? requestCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (requestCount != null) 'request_count': requestCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ApiUsageTableCompanion copyWith({
    Value<DateTime>? day,
    Value<int>? requestCount,
    Value<int>? rowid,
  }) {
    return ApiUsageTableCompanion(
      day: day ?? this.day,
      requestCount: requestCount ?? this.requestCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<DateTime>(day.value);
    }
    if (requestCount.present) {
      map['request_count'] = Variable<int>(requestCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ApiUsageTableCompanion(')
          ..write('day: $day, ')
          ..write('requestCount: $requestCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MetaTableTable extends MetaTable
    with TableInfo<$MetaTableTable, MetaTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetaTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetaTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  MetaTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetaTableData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $MetaTableTable createAlias(String alias) {
    return $MetaTableTable(attachedDatabase, alias);
  }
}

class MetaTableData extends DataClass implements Insertable<MetaTableData> {
  final String key;
  final String value;
  const MetaTableData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  MetaTableCompanion toCompanion(bool nullToAbsent) {
    return MetaTableCompanion(key: Value(key), value: Value(value));
  }

  factory MetaTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetaTableData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  MetaTableData copyWith({String? key, String? value}) =>
      MetaTableData(key: key ?? this.key, value: value ?? this.value);
  MetaTableData copyWithCompanion(MetaTableCompanion data) {
    return MetaTableData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetaTableData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetaTableData &&
          other.key == this.key &&
          other.value == this.value);
}

class MetaTableCompanion extends UpdateCompanion<MetaTableData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const MetaTableCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetaTableCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<MetaTableData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MetaTableCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return MetaTableCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetaTableCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GeofencesTableTable extends GeofencesTable
    with TableInfo<$GeofencesTableTable, GeofencesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GeofencesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _radiusMetersMeta = const VerificationMeta(
    'radiusMeters',
  );
  @override
  late final GeneratedColumn<double> radiusMeters = GeneratedColumn<double>(
    'radius_meters',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _alertOnEnterMeta = const VerificationMeta(
    'alertOnEnter',
  );
  @override
  late final GeneratedColumn<bool> alertOnEnter = GeneratedColumn<bool>(
    'alert_on_enter',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("alert_on_enter" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _alertOnExitMeta = const VerificationMeta(
    'alertOnExit',
  );
  @override
  late final GeneratedColumn<bool> alertOnExit = GeneratedColumn<bool>(
    'alert_on_exit',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("alert_on_exit" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastSideMeta = const VerificationMeta(
    'lastSide',
  );
  @override
  late final GeneratedColumn<String> lastSide = GeneratedColumn<String>(
    'last_side',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unknown'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    name,
    latitude,
    longitude,
    radiusMeters,
    enabled,
    alertOnEnter,
    alertOnExit,
    lastSide,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'geofences';
  @override
  VerificationContext validateIntegrity(
    Insertable<GeofencesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('radius_meters')) {
      context.handle(
        _radiusMetersMeta,
        radiusMeters.isAcceptableOrUnknown(
          data['radius_meters']!,
          _radiusMetersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_radiusMetersMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('alert_on_enter')) {
      context.handle(
        _alertOnEnterMeta,
        alertOnEnter.isAcceptableOrUnknown(
          data['alert_on_enter']!,
          _alertOnEnterMeta,
        ),
      );
    }
    if (data.containsKey('alert_on_exit')) {
      context.handle(
        _alertOnExitMeta,
        alertOnExit.isAcceptableOrUnknown(
          data['alert_on_exit']!,
          _alertOnExitMeta,
        ),
      );
    }
    if (data.containsKey('last_side')) {
      context.handle(
        _lastSideMeta,
        lastSide.isAcceptableOrUnknown(data['last_side']!, _lastSideMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GeofencesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GeofencesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      radiusMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}radius_meters'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      alertOnEnter: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}alert_on_enter'],
      )!,
      alertOnExit: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}alert_on_exit'],
      )!,
      lastSide: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_side'],
      )!,
    );
  }

  @override
  $GeofencesTableTable createAlias(String alias) {
    return $GeofencesTableTable(attachedDatabase, alias);
  }
}

class GeofencesTableData extends DataClass
    implements Insertable<GeofencesTableData> {
  final String id;
  final String deviceId;
  final String name;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final bool enabled;
  final bool alertOnEnter;
  final bool alertOnExit;
  final String lastSide;
  const GeofencesTableData({
    required this.id,
    required this.deviceId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.enabled,
    required this.alertOnEnter,
    required this.alertOnExit,
    required this.lastSide,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['name'] = Variable<String>(name);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['radius_meters'] = Variable<double>(radiusMeters);
    map['enabled'] = Variable<bool>(enabled);
    map['alert_on_enter'] = Variable<bool>(alertOnEnter);
    map['alert_on_exit'] = Variable<bool>(alertOnExit);
    map['last_side'] = Variable<String>(lastSide);
    return map;
  }

  GeofencesTableCompanion toCompanion(bool nullToAbsent) {
    return GeofencesTableCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      name: Value(name),
      latitude: Value(latitude),
      longitude: Value(longitude),
      radiusMeters: Value(radiusMeters),
      enabled: Value(enabled),
      alertOnEnter: Value(alertOnEnter),
      alertOnExit: Value(alertOnExit),
      lastSide: Value(lastSide),
    );
  }

  factory GeofencesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GeofencesTableData(
      id: serializer.fromJson<String>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      name: serializer.fromJson<String>(json['name']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      radiusMeters: serializer.fromJson<double>(json['radiusMeters']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      alertOnEnter: serializer.fromJson<bool>(json['alertOnEnter']),
      alertOnExit: serializer.fromJson<bool>(json['alertOnExit']),
      lastSide: serializer.fromJson<String>(json['lastSide']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'name': serializer.toJson<String>(name),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'radiusMeters': serializer.toJson<double>(radiusMeters),
      'enabled': serializer.toJson<bool>(enabled),
      'alertOnEnter': serializer.toJson<bool>(alertOnEnter),
      'alertOnExit': serializer.toJson<bool>(alertOnExit),
      'lastSide': serializer.toJson<String>(lastSide),
    };
  }

  GeofencesTableData copyWith({
    String? id,
    String? deviceId,
    String? name,
    double? latitude,
    double? longitude,
    double? radiusMeters,
    bool? enabled,
    bool? alertOnEnter,
    bool? alertOnExit,
    String? lastSide,
  }) => GeofencesTableData(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    name: name ?? this.name,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    radiusMeters: radiusMeters ?? this.radiusMeters,
    enabled: enabled ?? this.enabled,
    alertOnEnter: alertOnEnter ?? this.alertOnEnter,
    alertOnExit: alertOnExit ?? this.alertOnExit,
    lastSide: lastSide ?? this.lastSide,
  );
  GeofencesTableData copyWithCompanion(GeofencesTableCompanion data) {
    return GeofencesTableData(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      name: data.name.present ? data.name.value : this.name,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      radiusMeters: data.radiusMeters.present
          ? data.radiusMeters.value
          : this.radiusMeters,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      alertOnEnter: data.alertOnEnter.present
          ? data.alertOnEnter.value
          : this.alertOnEnter,
      alertOnExit: data.alertOnExit.present
          ? data.alertOnExit.value
          : this.alertOnExit,
      lastSide: data.lastSide.present ? data.lastSide.value : this.lastSide,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GeofencesTableData(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('name: $name, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('radiusMeters: $radiusMeters, ')
          ..write('enabled: $enabled, ')
          ..write('alertOnEnter: $alertOnEnter, ')
          ..write('alertOnExit: $alertOnExit, ')
          ..write('lastSide: $lastSide')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    name,
    latitude,
    longitude,
    radiusMeters,
    enabled,
    alertOnEnter,
    alertOnExit,
    lastSide,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeofencesTableData &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.name == this.name &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.radiusMeters == this.radiusMeters &&
          other.enabled == this.enabled &&
          other.alertOnEnter == this.alertOnEnter &&
          other.alertOnExit == this.alertOnExit &&
          other.lastSide == this.lastSide);
}

class GeofencesTableCompanion extends UpdateCompanion<GeofencesTableData> {
  final Value<String> id;
  final Value<String> deviceId;
  final Value<String> name;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double> radiusMeters;
  final Value<bool> enabled;
  final Value<bool> alertOnEnter;
  final Value<bool> alertOnExit;
  final Value<String> lastSide;
  final Value<int> rowid;
  const GeofencesTableCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.name = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.radiusMeters = const Value.absent(),
    this.enabled = const Value.absent(),
    this.alertOnEnter = const Value.absent(),
    this.alertOnExit = const Value.absent(),
    this.lastSide = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GeofencesTableCompanion.insert({
    required String id,
    required String deviceId,
    required String name,
    required double latitude,
    required double longitude,
    required double radiusMeters,
    this.enabled = const Value.absent(),
    this.alertOnEnter = const Value.absent(),
    this.alertOnExit = const Value.absent(),
    this.lastSide = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       deviceId = Value(deviceId),
       name = Value(name),
       latitude = Value(latitude),
       longitude = Value(longitude),
       radiusMeters = Value(radiusMeters);
  static Insertable<GeofencesTableData> custom({
    Expression<String>? id,
    Expression<String>? deviceId,
    Expression<String>? name,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? radiusMeters,
    Expression<bool>? enabled,
    Expression<bool>? alertOnEnter,
    Expression<bool>? alertOnExit,
    Expression<String>? lastSide,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (name != null) 'name': name,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (radiusMeters != null) 'radius_meters': radiusMeters,
      if (enabled != null) 'enabled': enabled,
      if (alertOnEnter != null) 'alert_on_enter': alertOnEnter,
      if (alertOnExit != null) 'alert_on_exit': alertOnExit,
      if (lastSide != null) 'last_side': lastSide,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GeofencesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? deviceId,
    Value<String>? name,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<double>? radiusMeters,
    Value<bool>? enabled,
    Value<bool>? alertOnEnter,
    Value<bool>? alertOnExit,
    Value<String>? lastSide,
    Value<int>? rowid,
  }) {
    return GeofencesTableCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      enabled: enabled ?? this.enabled,
      alertOnEnter: alertOnEnter ?? this.alertOnEnter,
      alertOnExit: alertOnExit ?? this.alertOnExit,
      lastSide: lastSide ?? this.lastSide,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (radiusMeters.present) {
      map['radius_meters'] = Variable<double>(radiusMeters.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (alertOnEnter.present) {
      map['alert_on_enter'] = Variable<bool>(alertOnEnter.value);
    }
    if (alertOnExit.present) {
      map['alert_on_exit'] = Variable<bool>(alertOnExit.value);
    }
    if (lastSide.present) {
      map['last_side'] = Variable<String>(lastSide.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GeofencesTableCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('name: $name, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('radiusMeters: $radiusMeters, ')
          ..write('enabled: $enabled, ')
          ..write('alertOnEnter: $alertOnEnter, ')
          ..write('alertOnExit: $alertOnExit, ')
          ..write('lastSide: $lastSide, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DevicesTableTable devicesTable = $DevicesTableTable(this);
  late final $DeviceStatesTableTable deviceStatesTable =
      $DeviceStatesTableTable(this);
  late final $EventsTableTable eventsTable = $EventsTableTable(this);
  late final $ApiUsageTableTable apiUsageTable = $ApiUsageTableTable(this);
  late final $MetaTableTable metaTable = $MetaTableTable(this);
  late final $GeofencesTableTable geofencesTable = $GeofencesTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    devicesTable,
    deviceStatesTable,
    eventsTable,
    apiUsageTable,
    metaTable,
    geofencesTable,
  ];
}

typedef $$DevicesTableTableCreateCompanionBuilder =
    DevicesTableCompanion Function({
      required String id,
      required String alias,
      required String payloadJson,
      Value<bool> isPrimary,
      Value<bool> isShared,
      Value<int> rowid,
    });
typedef $$DevicesTableTableUpdateCompanionBuilder =
    DevicesTableCompanion Function({
      Value<String> id,
      Value<String> alias,
      Value<String> payloadJson,
      Value<bool> isPrimary,
      Value<bool> isShared,
      Value<int> rowid,
    });

class $$DevicesTableTableFilterComposer
    extends Composer<_$AppDatabase, $DevicesTableTable> {
  $$DevicesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alias => $composableBuilder(
    column: $table.alias,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isShared => $composableBuilder(
    column: $table.isShared,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DevicesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DevicesTableTable> {
  $$DevicesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alias => $composableBuilder(
    column: $table.alias,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isShared => $composableBuilder(
    column: $table.isShared,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DevicesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DevicesTableTable> {
  $$DevicesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get alias =>
      $composableBuilder(column: $table.alias, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => column);

  GeneratedColumn<bool> get isShared =>
      $composableBuilder(column: $table.isShared, builder: (column) => column);
}

class $$DevicesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DevicesTableTable,
          DevicesTableData,
          $$DevicesTableTableFilterComposer,
          $$DevicesTableTableOrderingComposer,
          $$DevicesTableTableAnnotationComposer,
          $$DevicesTableTableCreateCompanionBuilder,
          $$DevicesTableTableUpdateCompanionBuilder,
          (
            DevicesTableData,
            BaseReferences<_$AppDatabase, $DevicesTableTable, DevicesTableData>,
          ),
          DevicesTableData,
          PrefetchHooks Function()
        > {
  $$DevicesTableTableTableManager(_$AppDatabase db, $DevicesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevicesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevicesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevicesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> alias = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                Value<bool> isShared = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevicesTableCompanion(
                id: id,
                alias: alias,
                payloadJson: payloadJson,
                isPrimary: isPrimary,
                isShared: isShared,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String alias,
                required String payloadJson,
                Value<bool> isPrimary = const Value.absent(),
                Value<bool> isShared = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevicesTableCompanion.insert(
                id: id,
                alias: alias,
                payloadJson: payloadJson,
                isPrimary: isPrimary,
                isShared: isShared,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DevicesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DevicesTableTable,
      DevicesTableData,
      $$DevicesTableTableFilterComposer,
      $$DevicesTableTableOrderingComposer,
      $$DevicesTableTableAnnotationComposer,
      $$DevicesTableTableCreateCompanionBuilder,
      $$DevicesTableTableUpdateCompanionBuilder,
      (
        DevicesTableData,
        BaseReferences<_$AppDatabase, $DevicesTableTable, DevicesTableData>,
      ),
      DevicesTableData,
      PrefetchHooks Function()
    >;
typedef $$DeviceStatesTableTableCreateCompanionBuilder =
    DeviceStatesTableCompanion Function({
      required String deviceId,
      required String payloadJson,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$DeviceStatesTableTableUpdateCompanionBuilder =
    DeviceStatesTableCompanion Function({
      Value<String> deviceId,
      Value<String> payloadJson,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$DeviceStatesTableTableFilterComposer
    extends Composer<_$AppDatabase, $DeviceStatesTableTable> {
  $$DeviceStatesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DeviceStatesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DeviceStatesTableTable> {
  $$DeviceStatesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DeviceStatesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeviceStatesTableTable> {
  $$DeviceStatesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DeviceStatesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DeviceStatesTableTable,
          DeviceStatesTableData,
          $$DeviceStatesTableTableFilterComposer,
          $$DeviceStatesTableTableOrderingComposer,
          $$DeviceStatesTableTableAnnotationComposer,
          $$DeviceStatesTableTableCreateCompanionBuilder,
          $$DeviceStatesTableTableUpdateCompanionBuilder,
          (
            DeviceStatesTableData,
            BaseReferences<
              _$AppDatabase,
              $DeviceStatesTableTable,
              DeviceStatesTableData
            >,
          ),
          DeviceStatesTableData,
          PrefetchHooks Function()
        > {
  $$DeviceStatesTableTableTableManager(
    _$AppDatabase db,
    $DeviceStatesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeviceStatesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeviceStatesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeviceStatesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> deviceId = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DeviceStatesTableCompanion(
                deviceId: deviceId,
                payloadJson: payloadJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String deviceId,
                required String payloadJson,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DeviceStatesTableCompanion.insert(
                deviceId: deviceId,
                payloadJson: payloadJson,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DeviceStatesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DeviceStatesTableTable,
      DeviceStatesTableData,
      $$DeviceStatesTableTableFilterComposer,
      $$DeviceStatesTableTableOrderingComposer,
      $$DeviceStatesTableTableAnnotationComposer,
      $$DeviceStatesTableTableCreateCompanionBuilder,
      $$DeviceStatesTableTableUpdateCompanionBuilder,
      (
        DeviceStatesTableData,
        BaseReferences<
          _$AppDatabase,
          $DeviceStatesTableTable,
          DeviceStatesTableData
        >,
      ),
      DeviceStatesTableData,
      PrefetchHooks Function()
    >;
typedef $$EventsTableTableCreateCompanionBuilder =
    EventsTableCompanion Function({
      required String id,
      required String deviceId,
      required String title,
      required String kind,
      required DateTime timestamp,
      Value<String?> payloadJson,
      Value<int> rowid,
    });
typedef $$EventsTableTableUpdateCompanionBuilder =
    EventsTableCompanion Function({
      Value<String> id,
      Value<String> deviceId,
      Value<String> title,
      Value<String> kind,
      Value<DateTime> timestamp,
      Value<String?> payloadJson,
      Value<int> rowid,
    });

class $$EventsTableTableFilterComposer
    extends Composer<_$AppDatabase, $EventsTableTable> {
  $$EventsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EventsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $EventsTableTable> {
  $$EventsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EventsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventsTableTable> {
  $$EventsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );
}

class $$EventsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EventsTableTable,
          EventsTableData,
          $$EventsTableTableFilterComposer,
          $$EventsTableTableOrderingComposer,
          $$EventsTableTableAnnotationComposer,
          $$EventsTableTableCreateCompanionBuilder,
          $$EventsTableTableUpdateCompanionBuilder,
          (
            EventsTableData,
            BaseReferences<_$AppDatabase, $EventsTableTable, EventsTableData>,
          ),
          EventsTableData,
          PrefetchHooks Function()
        > {
  $$EventsTableTableTableManager(_$AppDatabase db, $EventsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String?> payloadJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventsTableCompanion(
                id: id,
                deviceId: deviceId,
                title: title,
                kind: kind,
                timestamp: timestamp,
                payloadJson: payloadJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String deviceId,
                required String title,
                required String kind,
                required DateTime timestamp,
                Value<String?> payloadJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventsTableCompanion.insert(
                id: id,
                deviceId: deviceId,
                title: title,
                kind: kind,
                timestamp: timestamp,
                payloadJson: payloadJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EventsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EventsTableTable,
      EventsTableData,
      $$EventsTableTableFilterComposer,
      $$EventsTableTableOrderingComposer,
      $$EventsTableTableAnnotationComposer,
      $$EventsTableTableCreateCompanionBuilder,
      $$EventsTableTableUpdateCompanionBuilder,
      (
        EventsTableData,
        BaseReferences<_$AppDatabase, $EventsTableTable, EventsTableData>,
      ),
      EventsTableData,
      PrefetchHooks Function()
    >;
typedef $$ApiUsageTableTableCreateCompanionBuilder =
    ApiUsageTableCompanion Function({
      required DateTime day,
      Value<int> requestCount,
      Value<int> rowid,
    });
typedef $$ApiUsageTableTableUpdateCompanionBuilder =
    ApiUsageTableCompanion Function({
      Value<DateTime> day,
      Value<int> requestCount,
      Value<int> rowid,
    });

class $$ApiUsageTableTableFilterComposer
    extends Composer<_$AppDatabase, $ApiUsageTableTable> {
  $$ApiUsageTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get requestCount => $composableBuilder(
    column: $table.requestCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ApiUsageTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ApiUsageTableTable> {
  $$ApiUsageTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get requestCount => $composableBuilder(
    column: $table.requestCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ApiUsageTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ApiUsageTableTable> {
  $$ApiUsageTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get requestCount => $composableBuilder(
    column: $table.requestCount,
    builder: (column) => column,
  );
}

class $$ApiUsageTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ApiUsageTableTable,
          ApiUsageTableData,
          $$ApiUsageTableTableFilterComposer,
          $$ApiUsageTableTableOrderingComposer,
          $$ApiUsageTableTableAnnotationComposer,
          $$ApiUsageTableTableCreateCompanionBuilder,
          $$ApiUsageTableTableUpdateCompanionBuilder,
          (
            ApiUsageTableData,
            BaseReferences<
              _$AppDatabase,
              $ApiUsageTableTable,
              ApiUsageTableData
            >,
          ),
          ApiUsageTableData,
          PrefetchHooks Function()
        > {
  $$ApiUsageTableTableTableManager(_$AppDatabase db, $ApiUsageTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ApiUsageTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ApiUsageTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ApiUsageTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> day = const Value.absent(),
                Value<int> requestCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ApiUsageTableCompanion(
                day: day,
                requestCount: requestCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime day,
                Value<int> requestCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ApiUsageTableCompanion.insert(
                day: day,
                requestCount: requestCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ApiUsageTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ApiUsageTableTable,
      ApiUsageTableData,
      $$ApiUsageTableTableFilterComposer,
      $$ApiUsageTableTableOrderingComposer,
      $$ApiUsageTableTableAnnotationComposer,
      $$ApiUsageTableTableCreateCompanionBuilder,
      $$ApiUsageTableTableUpdateCompanionBuilder,
      (
        ApiUsageTableData,
        BaseReferences<_$AppDatabase, $ApiUsageTableTable, ApiUsageTableData>,
      ),
      ApiUsageTableData,
      PrefetchHooks Function()
    >;
typedef $$MetaTableTableCreateCompanionBuilder =
    MetaTableCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$MetaTableTableUpdateCompanionBuilder =
    MetaTableCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$MetaTableTableFilterComposer
    extends Composer<_$AppDatabase, $MetaTableTable> {
  $$MetaTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MetaTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MetaTableTable> {
  $$MetaTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MetaTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MetaTableTable> {
  $$MetaTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$MetaTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MetaTableTable,
          MetaTableData,
          $$MetaTableTableFilterComposer,
          $$MetaTableTableOrderingComposer,
          $$MetaTableTableAnnotationComposer,
          $$MetaTableTableCreateCompanionBuilder,
          $$MetaTableTableUpdateCompanionBuilder,
          (
            MetaTableData,
            BaseReferences<_$AppDatabase, $MetaTableTable, MetaTableData>,
          ),
          MetaTableData,
          PrefetchHooks Function()
        > {
  $$MetaTableTableTableManager(_$AppDatabase db, $MetaTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetaTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetaTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetaTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MetaTableCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => MetaTableCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MetaTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MetaTableTable,
      MetaTableData,
      $$MetaTableTableFilterComposer,
      $$MetaTableTableOrderingComposer,
      $$MetaTableTableAnnotationComposer,
      $$MetaTableTableCreateCompanionBuilder,
      $$MetaTableTableUpdateCompanionBuilder,
      (
        MetaTableData,
        BaseReferences<_$AppDatabase, $MetaTableTable, MetaTableData>,
      ),
      MetaTableData,
      PrefetchHooks Function()
    >;
typedef $$GeofencesTableTableCreateCompanionBuilder =
    GeofencesTableCompanion Function({
      required String id,
      required String deviceId,
      required String name,
      required double latitude,
      required double longitude,
      required double radiusMeters,
      Value<bool> enabled,
      Value<bool> alertOnEnter,
      Value<bool> alertOnExit,
      Value<String> lastSide,
      Value<int> rowid,
    });
typedef $$GeofencesTableTableUpdateCompanionBuilder =
    GeofencesTableCompanion Function({
      Value<String> id,
      Value<String> deviceId,
      Value<String> name,
      Value<double> latitude,
      Value<double> longitude,
      Value<double> radiusMeters,
      Value<bool> enabled,
      Value<bool> alertOnEnter,
      Value<bool> alertOnExit,
      Value<String> lastSide,
      Value<int> rowid,
    });

class $$GeofencesTableTableFilterComposer
    extends Composer<_$AppDatabase, $GeofencesTableTable> {
  $$GeofencesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get radiusMeters => $composableBuilder(
    column: $table.radiusMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get alertOnEnter => $composableBuilder(
    column: $table.alertOnEnter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get alertOnExit => $composableBuilder(
    column: $table.alertOnExit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastSide => $composableBuilder(
    column: $table.lastSide,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GeofencesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $GeofencesTableTable> {
  $$GeofencesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get radiusMeters => $composableBuilder(
    column: $table.radiusMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get alertOnEnter => $composableBuilder(
    column: $table.alertOnEnter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get alertOnExit => $composableBuilder(
    column: $table.alertOnExit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSide => $composableBuilder(
    column: $table.lastSide,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GeofencesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $GeofencesTableTable> {
  $$GeofencesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get radiusMeters => $composableBuilder(
    column: $table.radiusMeters,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<bool> get alertOnEnter => $composableBuilder(
    column: $table.alertOnEnter,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get alertOnExit => $composableBuilder(
    column: $table.alertOnExit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastSide =>
      $composableBuilder(column: $table.lastSide, builder: (column) => column);
}

class $$GeofencesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GeofencesTableTable,
          GeofencesTableData,
          $$GeofencesTableTableFilterComposer,
          $$GeofencesTableTableOrderingComposer,
          $$GeofencesTableTableAnnotationComposer,
          $$GeofencesTableTableCreateCompanionBuilder,
          $$GeofencesTableTableUpdateCompanionBuilder,
          (
            GeofencesTableData,
            BaseReferences<
              _$AppDatabase,
              $GeofencesTableTable,
              GeofencesTableData
            >,
          ),
          GeofencesTableData,
          PrefetchHooks Function()
        > {
  $$GeofencesTableTableTableManager(
    _$AppDatabase db,
    $GeofencesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GeofencesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GeofencesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GeofencesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<double> radiusMeters = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<bool> alertOnEnter = const Value.absent(),
                Value<bool> alertOnExit = const Value.absent(),
                Value<String> lastSide = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GeofencesTableCompanion(
                id: id,
                deviceId: deviceId,
                name: name,
                latitude: latitude,
                longitude: longitude,
                radiusMeters: radiusMeters,
                enabled: enabled,
                alertOnEnter: alertOnEnter,
                alertOnExit: alertOnExit,
                lastSide: lastSide,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String deviceId,
                required String name,
                required double latitude,
                required double longitude,
                required double radiusMeters,
                Value<bool> enabled = const Value.absent(),
                Value<bool> alertOnEnter = const Value.absent(),
                Value<bool> alertOnExit = const Value.absent(),
                Value<String> lastSide = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GeofencesTableCompanion.insert(
                id: id,
                deviceId: deviceId,
                name: name,
                latitude: latitude,
                longitude: longitude,
                radiusMeters: radiusMeters,
                enabled: enabled,
                alertOnEnter: alertOnEnter,
                alertOnExit: alertOnExit,
                lastSide: lastSide,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GeofencesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GeofencesTableTable,
      GeofencesTableData,
      $$GeofencesTableTableFilterComposer,
      $$GeofencesTableTableOrderingComposer,
      $$GeofencesTableTableAnnotationComposer,
      $$GeofencesTableTableCreateCompanionBuilder,
      $$GeofencesTableTableUpdateCompanionBuilder,
      (
        GeofencesTableData,
        BaseReferences<_$AppDatabase, $GeofencesTableTable, GeofencesTableData>,
      ),
      GeofencesTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DevicesTableTableTableManager get devicesTable =>
      $$DevicesTableTableTableManager(_db, _db.devicesTable);
  $$DeviceStatesTableTableTableManager get deviceStatesTable =>
      $$DeviceStatesTableTableTableManager(_db, _db.deviceStatesTable);
  $$EventsTableTableTableManager get eventsTable =>
      $$EventsTableTableTableManager(_db, _db.eventsTable);
  $$ApiUsageTableTableTableManager get apiUsageTable =>
      $$ApiUsageTableTableTableManager(_db, _db.apiUsageTable);
  $$MetaTableTableTableManager get metaTable =>
      $$MetaTableTableTableManager(_db, _db.metaTable);
  $$GeofencesTableTableTableManager get geofencesTable =>
      $$GeofencesTableTableTableManager(_db, _db.geofencesTable);
}
