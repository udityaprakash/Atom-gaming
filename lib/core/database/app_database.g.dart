// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RoomsTable extends Rooms with TableInfo<$RoomsTable, Room> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoomsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roomNameMeta = const VerificationMeta(
    'roomName',
  );
  @override
  late final GeneratedColumn<String> roomName = GeneratedColumn<String>(
    'room_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _equipmentTypeMeta = const VerificationMeta(
    'equipmentType',
  );
  @override
  late final GeneratedColumn<String> equipmentType = GeneratedColumn<String>(
    'equipment_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _controllerCountMeta = const VerificationMeta(
    'controllerCount',
  );
  @override
  late final GeneratedColumn<int> controllerCount = GeneratedColumn<int>(
    'controller_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _hourlyRateMeta = const VerificationMeta(
    'hourlyRate',
  );
  @override
  late final GeneratedColumn<double> hourlyRate = GeneratedColumn<double>(
    'hourly_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('AVAILABLE'),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
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
  List<GeneratedColumn> get $columns => [
    id,
    roomName,
    equipmentType,
    controllerCount,
    hourlyRate,
    status,
    description,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rooms';
  @override
  VerificationContext validateIntegrity(
    Insertable<Room> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('room_name')) {
      context.handle(
        _roomNameMeta,
        roomName.isAcceptableOrUnknown(data['room_name']!, _roomNameMeta),
      );
    } else if (isInserting) {
      context.missing(_roomNameMeta);
    }
    if (data.containsKey('equipment_type')) {
      context.handle(
        _equipmentTypeMeta,
        equipmentType.isAcceptableOrUnknown(
          data['equipment_type']!,
          _equipmentTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_equipmentTypeMeta);
    }
    if (data.containsKey('controller_count')) {
      context.handle(
        _controllerCountMeta,
        controllerCount.isAcceptableOrUnknown(
          data['controller_count']!,
          _controllerCountMeta,
        ),
      );
    }
    if (data.containsKey('hourly_rate')) {
      context.handle(
        _hourlyRateMeta,
        hourlyRate.isAcceptableOrUnknown(data['hourly_rate']!, _hourlyRateMeta),
      );
    } else if (isInserting) {
      context.missing(_hourlyRateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Room map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Room(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      roomName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room_name'],
      )!,
      equipmentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipment_type'],
      )!,
      controllerCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}controller_count'],
      )!,
      hourlyRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hourly_rate'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RoomsTable createAlias(String alias) {
    return $RoomsTable(attachedDatabase, alias);
  }
}

class Room extends DataClass implements Insertable<Room> {
  final String id;
  final String roomName;
  final String equipmentType;
  final int controllerCount;
  final double hourlyRate;
  final String status;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Room({
    required this.id,
    required this.roomName,
    required this.equipmentType,
    required this.controllerCount,
    required this.hourlyRate,
    required this.status,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['room_name'] = Variable<String>(roomName);
    map['equipment_type'] = Variable<String>(equipmentType);
    map['controller_count'] = Variable<int>(controllerCount);
    map['hourly_rate'] = Variable<double>(hourlyRate);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RoomsCompanion toCompanion(bool nullToAbsent) {
    return RoomsCompanion(
      id: Value(id),
      roomName: Value(roomName),
      equipmentType: Value(equipmentType),
      controllerCount: Value(controllerCount),
      hourlyRate: Value(hourlyRate),
      status: Value(status),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Room.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Room(
      id: serializer.fromJson<String>(json['id']),
      roomName: serializer.fromJson<String>(json['roomName']),
      equipmentType: serializer.fromJson<String>(json['equipmentType']),
      controllerCount: serializer.fromJson<int>(json['controllerCount']),
      hourlyRate: serializer.fromJson<double>(json['hourlyRate']),
      status: serializer.fromJson<String>(json['status']),
      description: serializer.fromJson<String?>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'roomName': serializer.toJson<String>(roomName),
      'equipmentType': serializer.toJson<String>(equipmentType),
      'controllerCount': serializer.toJson<int>(controllerCount),
      'hourlyRate': serializer.toJson<double>(hourlyRate),
      'status': serializer.toJson<String>(status),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Room copyWith({
    String? id,
    String? roomName,
    String? equipmentType,
    int? controllerCount,
    double? hourlyRate,
    String? status,
    Value<String?> description = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Room(
    id: id ?? this.id,
    roomName: roomName ?? this.roomName,
    equipmentType: equipmentType ?? this.equipmentType,
    controllerCount: controllerCount ?? this.controllerCount,
    hourlyRate: hourlyRate ?? this.hourlyRate,
    status: status ?? this.status,
    description: description.present ? description.value : this.description,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Room copyWithCompanion(RoomsCompanion data) {
    return Room(
      id: data.id.present ? data.id.value : this.id,
      roomName: data.roomName.present ? data.roomName.value : this.roomName,
      equipmentType: data.equipmentType.present
          ? data.equipmentType.value
          : this.equipmentType,
      controllerCount: data.controllerCount.present
          ? data.controllerCount.value
          : this.controllerCount,
      hourlyRate: data.hourlyRate.present
          ? data.hourlyRate.value
          : this.hourlyRate,
      status: data.status.present ? data.status.value : this.status,
      description: data.description.present
          ? data.description.value
          : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Room(')
          ..write('id: $id, ')
          ..write('roomName: $roomName, ')
          ..write('equipmentType: $equipmentType, ')
          ..write('controllerCount: $controllerCount, ')
          ..write('hourlyRate: $hourlyRate, ')
          ..write('status: $status, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    roomName,
    equipmentType,
    controllerCount,
    hourlyRate,
    status,
    description,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Room &&
          other.id == this.id &&
          other.roomName == this.roomName &&
          other.equipmentType == this.equipmentType &&
          other.controllerCount == this.controllerCount &&
          other.hourlyRate == this.hourlyRate &&
          other.status == this.status &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class RoomsCompanion extends UpdateCompanion<Room> {
  final Value<String> id;
  final Value<String> roomName;
  final Value<String> equipmentType;
  final Value<int> controllerCount;
  final Value<double> hourlyRate;
  final Value<String> status;
  final Value<String?> description;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RoomsCompanion({
    this.id = const Value.absent(),
    this.roomName = const Value.absent(),
    this.equipmentType = const Value.absent(),
    this.controllerCount = const Value.absent(),
    this.hourlyRate = const Value.absent(),
    this.status = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoomsCompanion.insert({
    required String id,
    required String roomName,
    required String equipmentType,
    this.controllerCount = const Value.absent(),
    required double hourlyRate,
    this.status = const Value.absent(),
    this.description = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       roomName = Value(roomName),
       equipmentType = Value(equipmentType),
       hourlyRate = Value(hourlyRate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Room> custom({
    Expression<String>? id,
    Expression<String>? roomName,
    Expression<String>? equipmentType,
    Expression<int>? controllerCount,
    Expression<double>? hourlyRate,
    Expression<String>? status,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (roomName != null) 'room_name': roomName,
      if (equipmentType != null) 'equipment_type': equipmentType,
      if (controllerCount != null) 'controller_count': controllerCount,
      if (hourlyRate != null) 'hourly_rate': hourlyRate,
      if (status != null) 'status': status,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoomsCompanion copyWith({
    Value<String>? id,
    Value<String>? roomName,
    Value<String>? equipmentType,
    Value<int>? controllerCount,
    Value<double>? hourlyRate,
    Value<String>? status,
    Value<String?>? description,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return RoomsCompanion(
      id: id ?? this.id,
      roomName: roomName ?? this.roomName,
      equipmentType: equipmentType ?? this.equipmentType,
      controllerCount: controllerCount ?? this.controllerCount,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      status: status ?? this.status,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (roomName.present) {
      map['room_name'] = Variable<String>(roomName.value);
    }
    if (equipmentType.present) {
      map['equipment_type'] = Variable<String>(equipmentType.value);
    }
    if (controllerCount.present) {
      map['controller_count'] = Variable<int>(controllerCount.value);
    }
    if (hourlyRate.present) {
      map['hourly_rate'] = Variable<double>(hourlyRate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('RoomsCompanion(')
          ..write('id: $id, ')
          ..write('roomName: $roomName, ')
          ..write('equipmentType: $equipmentType, ')
          ..write('controllerCount: $controllerCount, ')
          ..write('hourlyRate: $hourlyRate, ')
          ..write('status: $status, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, Customer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
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
  List<GeneratedColumn> get $columns => [
    id,
    name,
    phone,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Customer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Customer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Customer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class Customer extends DataClass implements Insertable<Customer> {
  final String id;
  final String name;
  final String? phone;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Customer({
    required this.id,
    required this.name,
    this.phone,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      name: Value(name),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Customer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Customer(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Customer copyWith({
    String? id,
    String? name,
    Value<String?> phone = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Customer(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone.present ? phone.value : this.phone,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Customer copyWithCompanion(CustomersCompanion data) {
    return Customer(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Customer(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, phone, notes, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Customer &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CustomersCompanion extends UpdateCompanion<Customer> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomersCompanion.insert({
    required String id,
    required String name,
    this.phone = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Customer> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? phone,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CustomersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES customers (id)',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ACTIVE'),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledEndAtMeta = const VerificationMeta(
    'scheduledEndAt',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledEndAt =
      GeneratedColumn<DateTime>(
        'scheduled_end_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _billingPolicyMeta = const VerificationMeta(
    'billingPolicy',
  );
  @override
  late final GeneratedColumn<String> billingPolicy = GeneratedColumn<String>(
    'billing_policy',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('per_minute'),
  );
  static const VerificationMeta _totalDurationSecondsMeta =
      const VerificationMeta('totalDurationSeconds');
  @override
  late final GeneratedColumn<int> totalDurationSeconds = GeneratedColumn<int>(
    'total_duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalAmountMeta = const VerificationMeta(
    'totalAmount',
  );
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
    'total_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _paymentStatusMeta = const VerificationMeta(
    'paymentStatus',
  );
  @override
  late final GeneratedColumn<String> paymentStatus = GeneratedColumn<String>(
    'payment_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('UNPAID'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerId,
    status,
    startedAt,
    scheduledEndAt,
    endedAt,
    billingPolicy,
    totalDurationSeconds,
    totalAmount,
    paymentStatus,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('scheduled_end_at')) {
      context.handle(
        _scheduledEndAtMeta,
        scheduledEndAt.isAcceptableOrUnknown(
          data['scheduled_end_at']!,
          _scheduledEndAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledEndAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('billing_policy')) {
      context.handle(
        _billingPolicyMeta,
        billingPolicy.isAcceptableOrUnknown(
          data['billing_policy']!,
          _billingPolicyMeta,
        ),
      );
    }
    if (data.containsKey('total_duration_seconds')) {
      context.handle(
        _totalDurationSecondsMeta,
        totalDurationSeconds.isAcceptableOrUnknown(
          data['total_duration_seconds']!,
          _totalDurationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('total_amount')) {
      context.handle(
        _totalAmountMeta,
        totalAmount.isAcceptableOrUnknown(
          data['total_amount']!,
          _totalAmountMeta,
        ),
      );
    }
    if (data.containsKey('payment_status')) {
      context.handle(
        _paymentStatusMeta,
        paymentStatus.isAcceptableOrUnknown(
          data['payment_status']!,
          _paymentStatusMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      scheduledEndAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_end_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      billingPolicy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}billing_policy'],
      )!,
      totalDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_duration_seconds'],
      )!,
      totalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_amount'],
      )!,
      paymentStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final String id;
  final String? customerId;
  final String status;
  final DateTime startedAt;
  final DateTime scheduledEndAt;
  final DateTime? endedAt;
  final String billingPolicy;
  final int totalDurationSeconds;
  final double totalAmount;
  final String paymentStatus;
  final DateTime createdAt;
  const Session({
    required this.id,
    this.customerId,
    required this.status,
    required this.startedAt,
    required this.scheduledEndAt,
    this.endedAt,
    required this.billingPolicy,
    required this.totalDurationSeconds,
    required this.totalAmount,
    required this.paymentStatus,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    map['status'] = Variable<String>(status);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['scheduled_end_at'] = Variable<DateTime>(scheduledEndAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['billing_policy'] = Variable<String>(billingPolicy);
    map['total_duration_seconds'] = Variable<int>(totalDurationSeconds);
    map['total_amount'] = Variable<double>(totalAmount);
    map['payment_status'] = Variable<String>(paymentStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      status: Value(status),
      startedAt: Value(startedAt),
      scheduledEndAt: Value(scheduledEndAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      billingPolicy: Value(billingPolicy),
      totalDurationSeconds: Value(totalDurationSeconds),
      totalAmount: Value(totalAmount),
      paymentStatus: Value(paymentStatus),
      createdAt: Value(createdAt),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<String>(json['id']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      status: serializer.fromJson<String>(json['status']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      scheduledEndAt: serializer.fromJson<DateTime>(json['scheduledEndAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      billingPolicy: serializer.fromJson<String>(json['billingPolicy']),
      totalDurationSeconds: serializer.fromJson<int>(
        json['totalDurationSeconds'],
      ),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      paymentStatus: serializer.fromJson<String>(json['paymentStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'customerId': serializer.toJson<String?>(customerId),
      'status': serializer.toJson<String>(status),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'scheduledEndAt': serializer.toJson<DateTime>(scheduledEndAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'billingPolicy': serializer.toJson<String>(billingPolicy),
      'totalDurationSeconds': serializer.toJson<int>(totalDurationSeconds),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'paymentStatus': serializer.toJson<String>(paymentStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Session copyWith({
    String? id,
    Value<String?> customerId = const Value.absent(),
    String? status,
    DateTime? startedAt,
    DateTime? scheduledEndAt,
    Value<DateTime?> endedAt = const Value.absent(),
    String? billingPolicy,
    int? totalDurationSeconds,
    double? totalAmount,
    String? paymentStatus,
    DateTime? createdAt,
  }) => Session(
    id: id ?? this.id,
    customerId: customerId.present ? customerId.value : this.customerId,
    status: status ?? this.status,
    startedAt: startedAt ?? this.startedAt,
    scheduledEndAt: scheduledEndAt ?? this.scheduledEndAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    billingPolicy: billingPolicy ?? this.billingPolicy,
    totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
    totalAmount: totalAmount ?? this.totalAmount,
    paymentStatus: paymentStatus ?? this.paymentStatus,
    createdAt: createdAt ?? this.createdAt,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      status: data.status.present ? data.status.value : this.status,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      scheduledEndAt: data.scheduledEndAt.present
          ? data.scheduledEndAt.value
          : this.scheduledEndAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      billingPolicy: data.billingPolicy.present
          ? data.billingPolicy.value
          : this.billingPolicy,
      totalDurationSeconds: data.totalDurationSeconds.present
          ? data.totalDurationSeconds.value
          : this.totalDurationSeconds,
      totalAmount: data.totalAmount.present
          ? data.totalAmount.value
          : this.totalAmount,
      paymentStatus: data.paymentStatus.present
          ? data.paymentStatus.value
          : this.paymentStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('scheduledEndAt: $scheduledEndAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('billingPolicy: $billingPolicy, ')
          ..write('totalDurationSeconds: $totalDurationSeconds, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    customerId,
    status,
    startedAt,
    scheduledEndAt,
    endedAt,
    billingPolicy,
    totalDurationSeconds,
    totalAmount,
    paymentStatus,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.status == this.status &&
          other.startedAt == this.startedAt &&
          other.scheduledEndAt == this.scheduledEndAt &&
          other.endedAt == this.endedAt &&
          other.billingPolicy == this.billingPolicy &&
          other.totalDurationSeconds == this.totalDurationSeconds &&
          other.totalAmount == this.totalAmount &&
          other.paymentStatus == this.paymentStatus &&
          other.createdAt == this.createdAt);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<String> id;
  final Value<String?> customerId;
  final Value<String> status;
  final Value<DateTime> startedAt;
  final Value<DateTime> scheduledEndAt;
  final Value<DateTime?> endedAt;
  final Value<String> billingPolicy;
  final Value<int> totalDurationSeconds;
  final Value<double> totalAmount;
  final Value<String> paymentStatus;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.status = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.scheduledEndAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.billingPolicy = const Value.absent(),
    this.totalDurationSeconds = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.paymentStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsCompanion.insert({
    required String id,
    this.customerId = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime startedAt,
    required DateTime scheduledEndAt,
    this.endedAt = const Value.absent(),
    this.billingPolicy = const Value.absent(),
    this.totalDurationSeconds = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.paymentStatus = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       startedAt = Value(startedAt),
       scheduledEndAt = Value(scheduledEndAt),
       createdAt = Value(createdAt);
  static Insertable<Session> custom({
    Expression<String>? id,
    Expression<String>? customerId,
    Expression<String>? status,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? scheduledEndAt,
    Expression<DateTime>? endedAt,
    Expression<String>? billingPolicy,
    Expression<int>? totalDurationSeconds,
    Expression<double>? totalAmount,
    Expression<String>? paymentStatus,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (status != null) 'status': status,
      if (startedAt != null) 'started_at': startedAt,
      if (scheduledEndAt != null) 'scheduled_end_at': scheduledEndAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (billingPolicy != null) 'billing_policy': billingPolicy,
      if (totalDurationSeconds != null)
        'total_duration_seconds': totalDurationSeconds,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (paymentStatus != null) 'payment_status': paymentStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsCompanion copyWith({
    Value<String>? id,
    Value<String?>? customerId,
    Value<String>? status,
    Value<DateTime>? startedAt,
    Value<DateTime>? scheduledEndAt,
    Value<DateTime?>? endedAt,
    Value<String>? billingPolicy,
    Value<int>? totalDurationSeconds,
    Value<double>? totalAmount,
    Value<String>? paymentStatus,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      scheduledEndAt: scheduledEndAt ?? this.scheduledEndAt,
      endedAt: endedAt ?? this.endedAt,
      billingPolicy: billingPolicy ?? this.billingPolicy,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (scheduledEndAt.present) {
      map['scheduled_end_at'] = Variable<DateTime>(scheduledEndAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (billingPolicy.present) {
      map['billing_policy'] = Variable<String>(billingPolicy.value);
    }
    if (totalDurationSeconds.present) {
      map['total_duration_seconds'] = Variable<int>(totalDurationSeconds.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (paymentStatus.present) {
      map['payment_status'] = Variable<String>(paymentStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('scheduledEndAt: $scheduledEndAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('billingPolicy: $billingPolicy, ')
          ..write('totalDurationSeconds: $totalDurationSeconds, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionSegmentsTable extends SessionSegments
    with TableInfo<$SessionSegmentsTable, SessionSegment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionSegmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id)',
    ),
  );
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<String> roomId = GeneratedColumn<String>(
    'room_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rooms (id)',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hourlyRateSnapshotMeta =
      const VerificationMeta('hourlyRateSnapshot');
  @override
  late final GeneratedColumn<double> hourlyRateSnapshot =
      GeneratedColumn<double>(
        'hourly_rate_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    roomId,
    startedAt,
    endedAt,
    hourlyRateSnapshot,
    amount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_segments';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionSegment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('room_id')) {
      context.handle(
        _roomIdMeta,
        roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta),
      );
    } else if (isInserting) {
      context.missing(_roomIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('hourly_rate_snapshot')) {
      context.handle(
        _hourlyRateSnapshotMeta,
        hourlyRateSnapshot.isAcceptableOrUnknown(
          data['hourly_rate_snapshot']!,
          _hourlyRateSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hourlyRateSnapshotMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionSegment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionSegment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      roomId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      hourlyRateSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hourly_rate_snapshot'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
    );
  }

  @override
  $SessionSegmentsTable createAlias(String alias) {
    return $SessionSegmentsTable(attachedDatabase, alias);
  }
}

class SessionSegment extends DataClass implements Insertable<SessionSegment> {
  final String id;
  final String sessionId;
  final String roomId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final double hourlyRateSnapshot;
  final double amount;
  const SessionSegment({
    required this.id,
    required this.sessionId,
    required this.roomId,
    required this.startedAt,
    this.endedAt,
    required this.hourlyRateSnapshot,
    required this.amount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['room_id'] = Variable<String>(roomId);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['hourly_rate_snapshot'] = Variable<double>(hourlyRateSnapshot);
    map['amount'] = Variable<double>(amount);
    return map;
  }

  SessionSegmentsCompanion toCompanion(bool nullToAbsent) {
    return SessionSegmentsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      roomId: Value(roomId),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      hourlyRateSnapshot: Value(hourlyRateSnapshot),
      amount: Value(amount),
    );
  }

  factory SessionSegment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionSegment(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      roomId: serializer.fromJson<String>(json['roomId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      hourlyRateSnapshot: serializer.fromJson<double>(
        json['hourlyRateSnapshot'],
      ),
      amount: serializer.fromJson<double>(json['amount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'roomId': serializer.toJson<String>(roomId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'hourlyRateSnapshot': serializer.toJson<double>(hourlyRateSnapshot),
      'amount': serializer.toJson<double>(amount),
    };
  }

  SessionSegment copyWith({
    String? id,
    String? sessionId,
    String? roomId,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    double? hourlyRateSnapshot,
    double? amount,
  }) => SessionSegment(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    roomId: roomId ?? this.roomId,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    hourlyRateSnapshot: hourlyRateSnapshot ?? this.hourlyRateSnapshot,
    amount: amount ?? this.amount,
  );
  SessionSegment copyWithCompanion(SessionSegmentsCompanion data) {
    return SessionSegment(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      hourlyRateSnapshot: data.hourlyRateSnapshot.present
          ? data.hourlyRateSnapshot.value
          : this.hourlyRateSnapshot,
      amount: data.amount.present ? data.amount.value : this.amount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionSegment(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('roomId: $roomId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('hourlyRateSnapshot: $hourlyRateSnapshot, ')
          ..write('amount: $amount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    roomId,
    startedAt,
    endedAt,
    hourlyRateSnapshot,
    amount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionSegment &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.roomId == this.roomId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.hourlyRateSnapshot == this.hourlyRateSnapshot &&
          other.amount == this.amount);
}

class SessionSegmentsCompanion extends UpdateCompanion<SessionSegment> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> roomId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<double> hourlyRateSnapshot;
  final Value<double> amount;
  final Value<int> rowid;
  const SessionSegmentsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.roomId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.hourlyRateSnapshot = const Value.absent(),
    this.amount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionSegmentsCompanion.insert({
    required String id,
    required String sessionId,
    required String roomId,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    required double hourlyRateSnapshot,
    this.amount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       roomId = Value(roomId),
       startedAt = Value(startedAt),
       hourlyRateSnapshot = Value(hourlyRateSnapshot);
  static Insertable<SessionSegment> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? roomId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<double>? hourlyRateSnapshot,
    Expression<double>? amount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (roomId != null) 'room_id': roomId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (hourlyRateSnapshot != null)
        'hourly_rate_snapshot': hourlyRateSnapshot,
      if (amount != null) 'amount': amount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionSegmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? roomId,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<double>? hourlyRateSnapshot,
    Value<double>? amount,
    Value<int>? rowid,
  }) {
    return SessionSegmentsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      roomId: roomId ?? this.roomId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      hourlyRateSnapshot: hourlyRateSnapshot ?? this.hourlyRateSnapshot,
      amount: amount ?? this.amount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (hourlyRateSnapshot.present) {
      map['hourly_rate_snapshot'] = Variable<double>(hourlyRateSnapshot.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionSegmentsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('roomId: $roomId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('hourlyRateSnapshot: $hourlyRateSnapshot, ')
          ..write('amount: $amount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionExtensionsTable extends SessionExtensions
    with TableInfo<$SessionExtensionsTable, SessionExtension> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionExtensionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id)',
    ),
  );
  static const VerificationMeta _previousEndTimeMeta = const VerificationMeta(
    'previousEndTime',
  );
  @override
  late final GeneratedColumn<DateTime> previousEndTime =
      GeneratedColumn<DateTime>(
        'previous_end_time',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _newEndTimeMeta = const VerificationMeta(
    'newEndTime',
  );
  @override
  late final GeneratedColumn<DateTime> newEndTime = GeneratedColumn<DateTime>(
    'new_end_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _extensionMinutesMeta = const VerificationMeta(
    'extensionMinutes',
  );
  @override
  late final GeneratedColumn<int> extensionMinutes = GeneratedColumn<int>(
    'extension_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    previousEndTime,
    newEndTime,
    extensionMinutes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_extensions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionExtension> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('previous_end_time')) {
      context.handle(
        _previousEndTimeMeta,
        previousEndTime.isAcceptableOrUnknown(
          data['previous_end_time']!,
          _previousEndTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_previousEndTimeMeta);
    }
    if (data.containsKey('new_end_time')) {
      context.handle(
        _newEndTimeMeta,
        newEndTime.isAcceptableOrUnknown(
          data['new_end_time']!,
          _newEndTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_newEndTimeMeta);
    }
    if (data.containsKey('extension_minutes')) {
      context.handle(
        _extensionMinutesMeta,
        extensionMinutes.isAcceptableOrUnknown(
          data['extension_minutes']!,
          _extensionMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_extensionMinutesMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionExtension map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionExtension(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      previousEndTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}previous_end_time'],
      )!,
      newEndTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}new_end_time'],
      )!,
      extensionMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}extension_minutes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SessionExtensionsTable createAlias(String alias) {
    return $SessionExtensionsTable(attachedDatabase, alias);
  }
}

class SessionExtension extends DataClass
    implements Insertable<SessionExtension> {
  final String id;
  final String sessionId;
  final DateTime previousEndTime;
  final DateTime newEndTime;
  final int extensionMinutes;
  final DateTime createdAt;
  const SessionExtension({
    required this.id,
    required this.sessionId,
    required this.previousEndTime,
    required this.newEndTime,
    required this.extensionMinutes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['previous_end_time'] = Variable<DateTime>(previousEndTime);
    map['new_end_time'] = Variable<DateTime>(newEndTime);
    map['extension_minutes'] = Variable<int>(extensionMinutes);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SessionExtensionsCompanion toCompanion(bool nullToAbsent) {
    return SessionExtensionsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      previousEndTime: Value(previousEndTime),
      newEndTime: Value(newEndTime),
      extensionMinutes: Value(extensionMinutes),
      createdAt: Value(createdAt),
    );
  }

  factory SessionExtension.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionExtension(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      previousEndTime: serializer.fromJson<DateTime>(json['previousEndTime']),
      newEndTime: serializer.fromJson<DateTime>(json['newEndTime']),
      extensionMinutes: serializer.fromJson<int>(json['extensionMinutes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'previousEndTime': serializer.toJson<DateTime>(previousEndTime),
      'newEndTime': serializer.toJson<DateTime>(newEndTime),
      'extensionMinutes': serializer.toJson<int>(extensionMinutes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SessionExtension copyWith({
    String? id,
    String? sessionId,
    DateTime? previousEndTime,
    DateTime? newEndTime,
    int? extensionMinutes,
    DateTime? createdAt,
  }) => SessionExtension(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    previousEndTime: previousEndTime ?? this.previousEndTime,
    newEndTime: newEndTime ?? this.newEndTime,
    extensionMinutes: extensionMinutes ?? this.extensionMinutes,
    createdAt: createdAt ?? this.createdAt,
  );
  SessionExtension copyWithCompanion(SessionExtensionsCompanion data) {
    return SessionExtension(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      previousEndTime: data.previousEndTime.present
          ? data.previousEndTime.value
          : this.previousEndTime,
      newEndTime: data.newEndTime.present
          ? data.newEndTime.value
          : this.newEndTime,
      extensionMinutes: data.extensionMinutes.present
          ? data.extensionMinutes.value
          : this.extensionMinutes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionExtension(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('previousEndTime: $previousEndTime, ')
          ..write('newEndTime: $newEndTime, ')
          ..write('extensionMinutes: $extensionMinutes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    previousEndTime,
    newEndTime,
    extensionMinutes,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionExtension &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.previousEndTime == this.previousEndTime &&
          other.newEndTime == this.newEndTime &&
          other.extensionMinutes == this.extensionMinutes &&
          other.createdAt == this.createdAt);
}

class SessionExtensionsCompanion extends UpdateCompanion<SessionExtension> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<DateTime> previousEndTime;
  final Value<DateTime> newEndTime;
  final Value<int> extensionMinutes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SessionExtensionsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.previousEndTime = const Value.absent(),
    this.newEndTime = const Value.absent(),
    this.extensionMinutes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionExtensionsCompanion.insert({
    required String id,
    required String sessionId,
    required DateTime previousEndTime,
    required DateTime newEndTime,
    required int extensionMinutes,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       previousEndTime = Value(previousEndTime),
       newEndTime = Value(newEndTime),
       extensionMinutes = Value(extensionMinutes),
       createdAt = Value(createdAt);
  static Insertable<SessionExtension> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<DateTime>? previousEndTime,
    Expression<DateTime>? newEndTime,
    Expression<int>? extensionMinutes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (previousEndTime != null) 'previous_end_time': previousEndTime,
      if (newEndTime != null) 'new_end_time': newEndTime,
      if (extensionMinutes != null) 'extension_minutes': extensionMinutes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionExtensionsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<DateTime>? previousEndTime,
    Value<DateTime>? newEndTime,
    Value<int>? extensionMinutes,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SessionExtensionsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      previousEndTime: previousEndTime ?? this.previousEndTime,
      newEndTime: newEndTime ?? this.newEndTime,
      extensionMinutes: extensionMinutes ?? this.extensionMinutes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (previousEndTime.present) {
      map['previous_end_time'] = Variable<DateTime>(previousEndTime.value);
    }
    if (newEndTime.present) {
      map['new_end_time'] = Variable<DateTime>(newEndTime.value);
    }
    if (extensionMinutes.present) {
      map['extension_minutes'] = Variable<int>(extensionMinutes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionExtensionsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('previousEndTime: $previousEndTime, ')
          ..write('newEndTime: $newEndTime, ')
          ..write('extensionMinutes: $extensionMinutes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTable extends Payments with TableInfo<$PaymentsTable, Payment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id)',
    ),
  );
  static const VerificationMeta _amountDueMeta = const VerificationMeta(
    'amountDue',
  );
  @override
  late final GeneratedColumn<double> amountDue = GeneratedColumn<double>(
    'amount_due',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountCollectedMeta = const VerificationMeta(
    'amountCollected',
  );
  @override
  late final GeneratedColumn<double> amountCollected = GeneratedColumn<double>(
    'amount_collected',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('CASH'),
  );
  static const VerificationMeta _paymentStatusMeta = const VerificationMeta(
    'paymentStatus',
  );
  @override
  late final GeneratedColumn<String> paymentStatus = GeneratedColumn<String>(
    'payment_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('UNPAID'),
  );
  static const VerificationMeta _transactionReferenceMeta =
      const VerificationMeta('transactionReference');
  @override
  late final GeneratedColumn<String> transactionReference =
      GeneratedColumn<String>(
        'transaction_reference',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _paidAtMeta = const VerificationMeta('paidAt');
  @override
  late final GeneratedColumn<DateTime> paidAt = GeneratedColumn<DateTime>(
    'paid_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
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
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    amountDue,
    amountCollected,
    paymentMethod,
    paymentStatus,
    transactionReference,
    paidAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Payment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('amount_due')) {
      context.handle(
        _amountDueMeta,
        amountDue.isAcceptableOrUnknown(data['amount_due']!, _amountDueMeta),
      );
    } else if (isInserting) {
      context.missing(_amountDueMeta);
    }
    if (data.containsKey('amount_collected')) {
      context.handle(
        _amountCollectedMeta,
        amountCollected.isAcceptableOrUnknown(
          data['amount_collected']!,
          _amountCollectedMeta,
        ),
      );
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    }
    if (data.containsKey('payment_status')) {
      context.handle(
        _paymentStatusMeta,
        paymentStatus.isAcceptableOrUnknown(
          data['payment_status']!,
          _paymentStatusMeta,
        ),
      );
    }
    if (data.containsKey('transaction_reference')) {
      context.handle(
        _transactionReferenceMeta,
        transactionReference.isAcceptableOrUnknown(
          data['transaction_reference']!,
          _transactionReferenceMeta,
        ),
      );
    }
    if (data.containsKey('paid_at')) {
      context.handle(
        _paidAtMeta,
        paidAt.isAcceptableOrUnknown(data['paid_at']!, _paidAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Payment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Payment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      amountDue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_due'],
      )!,
      amountCollected: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_collected'],
      )!,
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      )!,
      paymentStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_status'],
      )!,
      transactionReference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_reference'],
      ),
      paidAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paid_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PaymentsTable createAlias(String alias) {
    return $PaymentsTable(attachedDatabase, alias);
  }
}

class Payment extends DataClass implements Insertable<Payment> {
  final String id;
  final String sessionId;
  final double amountDue;
  final double amountCollected;
  final String paymentMethod;
  final String paymentStatus;
  final String? transactionReference;
  final DateTime? paidAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Payment({
    required this.id,
    required this.sessionId,
    required this.amountDue,
    required this.amountCollected,
    required this.paymentMethod,
    required this.paymentStatus,
    this.transactionReference,
    this.paidAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['amount_due'] = Variable<double>(amountDue);
    map['amount_collected'] = Variable<double>(amountCollected);
    map['payment_method'] = Variable<String>(paymentMethod);
    map['payment_status'] = Variable<String>(paymentStatus);
    if (!nullToAbsent || transactionReference != null) {
      map['transaction_reference'] = Variable<String>(transactionReference);
    }
    if (!nullToAbsent || paidAt != null) {
      map['paid_at'] = Variable<DateTime>(paidAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PaymentsCompanion toCompanion(bool nullToAbsent) {
    return PaymentsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      amountDue: Value(amountDue),
      amountCollected: Value(amountCollected),
      paymentMethod: Value(paymentMethod),
      paymentStatus: Value(paymentStatus),
      transactionReference: transactionReference == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionReference),
      paidAt: paidAt == null && nullToAbsent
          ? const Value.absent()
          : Value(paidAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Payment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Payment(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      amountDue: serializer.fromJson<double>(json['amountDue']),
      amountCollected: serializer.fromJson<double>(json['amountCollected']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      paymentStatus: serializer.fromJson<String>(json['paymentStatus']),
      transactionReference: serializer.fromJson<String?>(
        json['transactionReference'],
      ),
      paidAt: serializer.fromJson<DateTime?>(json['paidAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'amountDue': serializer.toJson<double>(amountDue),
      'amountCollected': serializer.toJson<double>(amountCollected),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'paymentStatus': serializer.toJson<String>(paymentStatus),
      'transactionReference': serializer.toJson<String?>(transactionReference),
      'paidAt': serializer.toJson<DateTime?>(paidAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Payment copyWith({
    String? id,
    String? sessionId,
    double? amountDue,
    double? amountCollected,
    String? paymentMethod,
    String? paymentStatus,
    Value<String?> transactionReference = const Value.absent(),
    Value<DateTime?> paidAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Payment(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    amountDue: amountDue ?? this.amountDue,
    amountCollected: amountCollected ?? this.amountCollected,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    paymentStatus: paymentStatus ?? this.paymentStatus,
    transactionReference: transactionReference.present
        ? transactionReference.value
        : this.transactionReference,
    paidAt: paidAt.present ? paidAt.value : this.paidAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Payment copyWithCompanion(PaymentsCompanion data) {
    return Payment(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      amountDue: data.amountDue.present ? data.amountDue.value : this.amountDue,
      amountCollected: data.amountCollected.present
          ? data.amountCollected.value
          : this.amountCollected,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      paymentStatus: data.paymentStatus.present
          ? data.paymentStatus.value
          : this.paymentStatus,
      transactionReference: data.transactionReference.present
          ? data.transactionReference.value
          : this.transactionReference,
      paidAt: data.paidAt.present ? data.paidAt.value : this.paidAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Payment(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('amountDue: $amountDue, ')
          ..write('amountCollected: $amountCollected, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('transactionReference: $transactionReference, ')
          ..write('paidAt: $paidAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    amountDue,
    amountCollected,
    paymentMethod,
    paymentStatus,
    transactionReference,
    paidAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Payment &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.amountDue == this.amountDue &&
          other.amountCollected == this.amountCollected &&
          other.paymentMethod == this.paymentMethod &&
          other.paymentStatus == this.paymentStatus &&
          other.transactionReference == this.transactionReference &&
          other.paidAt == this.paidAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PaymentsCompanion extends UpdateCompanion<Payment> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<double> amountDue;
  final Value<double> amountCollected;
  final Value<String> paymentMethod;
  final Value<String> paymentStatus;
  final Value<String?> transactionReference;
  final Value<DateTime?> paidAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PaymentsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.amountDue = const Value.absent(),
    this.amountCollected = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.paymentStatus = const Value.absent(),
    this.transactionReference = const Value.absent(),
    this.paidAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsCompanion.insert({
    required String id,
    required String sessionId,
    required double amountDue,
    this.amountCollected = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.paymentStatus = const Value.absent(),
    this.transactionReference = const Value.absent(),
    this.paidAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       amountDue = Value(amountDue),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Payment> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<double>? amountDue,
    Expression<double>? amountCollected,
    Expression<String>? paymentMethod,
    Expression<String>? paymentStatus,
    Expression<String>? transactionReference,
    Expression<DateTime>? paidAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (amountDue != null) 'amount_due': amountDue,
      if (amountCollected != null) 'amount_collected': amountCollected,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (paymentStatus != null) 'payment_status': paymentStatus,
      if (transactionReference != null)
        'transaction_reference': transactionReference,
      if (paidAt != null) 'paid_at': paidAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<double>? amountDue,
    Value<double>? amountCollected,
    Value<String>? paymentMethod,
    Value<String>? paymentStatus,
    Value<String?>? transactionReference,
    Value<DateTime?>? paidAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PaymentsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      amountDue: amountDue ?? this.amountDue,
      amountCollected: amountCollected ?? this.amountCollected,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      transactionReference: transactionReference ?? this.transactionReference,
      paidAt: paidAt ?? this.paidAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (amountDue.present) {
      map['amount_due'] = Variable<double>(amountDue.value);
    }
    if (amountCollected.present) {
      map['amount_collected'] = Variable<double>(amountCollected.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (paymentStatus.present) {
      map['payment_status'] = Variable<String>(paymentStatus.value);
    }
    if (transactionReference.present) {
      map['transaction_reference'] = Variable<String>(
        transactionReference.value,
      );
    }
    if (paidAt.present) {
      map['paid_at'] = Variable<DateTime>(paidAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('PaymentsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('amountDue: $amountDue, ')
          ..write('amountCollected: $amountCollected, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('transactionReference: $transactionReference, ')
          ..write('paidAt: $paidAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionEventsTable extends SessionEvents
    with TableInfo<$SessionEventsTable, SessionEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id)',
    ),
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventTimestampMeta = const VerificationMeta(
    'eventTimestamp',
  );
  @override
  late final GeneratedColumn<DateTime> eventTimestamp =
      GeneratedColumn<DateTime>(
        'event_timestamp',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _oldValueMeta = const VerificationMeta(
    'oldValue',
  );
  @override
  late final GeneratedColumn<String> oldValue = GeneratedColumn<String>(
    'old_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _newValueMeta = const VerificationMeta(
    'newValue',
  );
  @override
  late final GeneratedColumn<String> newValue = GeneratedColumn<String>(
    'new_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    eventType,
    eventTimestamp,
    oldValue,
    newValue,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('event_timestamp')) {
      context.handle(
        _eventTimestampMeta,
        eventTimestamp.isAcceptableOrUnknown(
          data['event_timestamp']!,
          _eventTimestampMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_eventTimestampMeta);
    }
    if (data.containsKey('old_value')) {
      context.handle(
        _oldValueMeta,
        oldValue.isAcceptableOrUnknown(data['old_value']!, _oldValueMeta),
      );
    }
    if (data.containsKey('new_value')) {
      context.handle(
        _newValueMeta,
        newValue.isAcceptableOrUnknown(data['new_value']!, _newValueMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      eventTimestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}event_timestamp'],
      )!,
      oldValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}old_value'],
      ),
      newValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}new_value'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $SessionEventsTable createAlias(String alias) {
    return $SessionEventsTable(attachedDatabase, alias);
  }
}

class SessionEvent extends DataClass implements Insertable<SessionEvent> {
  final String id;
  final String sessionId;
  final String eventType;
  final DateTime eventTimestamp;
  final String? oldValue;
  final String? newValue;
  final String? notes;
  const SessionEvent({
    required this.id,
    required this.sessionId,
    required this.eventType,
    required this.eventTimestamp,
    this.oldValue,
    this.newValue,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['event_type'] = Variable<String>(eventType);
    map['event_timestamp'] = Variable<DateTime>(eventTimestamp);
    if (!nullToAbsent || oldValue != null) {
      map['old_value'] = Variable<String>(oldValue);
    }
    if (!nullToAbsent || newValue != null) {
      map['new_value'] = Variable<String>(newValue);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  SessionEventsCompanion toCompanion(bool nullToAbsent) {
    return SessionEventsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      eventType: Value(eventType),
      eventTimestamp: Value(eventTimestamp),
      oldValue: oldValue == null && nullToAbsent
          ? const Value.absent()
          : Value(oldValue),
      newValue: newValue == null && nullToAbsent
          ? const Value.absent()
          : Value(newValue),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory SessionEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionEvent(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      eventTimestamp: serializer.fromJson<DateTime>(json['eventTimestamp']),
      oldValue: serializer.fromJson<String?>(json['oldValue']),
      newValue: serializer.fromJson<String?>(json['newValue']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'eventType': serializer.toJson<String>(eventType),
      'eventTimestamp': serializer.toJson<DateTime>(eventTimestamp),
      'oldValue': serializer.toJson<String?>(oldValue),
      'newValue': serializer.toJson<String?>(newValue),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  SessionEvent copyWith({
    String? id,
    String? sessionId,
    String? eventType,
    DateTime? eventTimestamp,
    Value<String?> oldValue = const Value.absent(),
    Value<String?> newValue = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => SessionEvent(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    eventType: eventType ?? this.eventType,
    eventTimestamp: eventTimestamp ?? this.eventTimestamp,
    oldValue: oldValue.present ? oldValue.value : this.oldValue,
    newValue: newValue.present ? newValue.value : this.newValue,
    notes: notes.present ? notes.value : this.notes,
  );
  SessionEvent copyWithCompanion(SessionEventsCompanion data) {
    return SessionEvent(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      eventTimestamp: data.eventTimestamp.present
          ? data.eventTimestamp.value
          : this.eventTimestamp,
      oldValue: data.oldValue.present ? data.oldValue.value : this.oldValue,
      newValue: data.newValue.present ? data.newValue.value : this.newValue,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionEvent(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('eventType: $eventType, ')
          ..write('eventTimestamp: $eventTimestamp, ')
          ..write('oldValue: $oldValue, ')
          ..write('newValue: $newValue, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    eventType,
    eventTimestamp,
    oldValue,
    newValue,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionEvent &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.eventType == this.eventType &&
          other.eventTimestamp == this.eventTimestamp &&
          other.oldValue == this.oldValue &&
          other.newValue == this.newValue &&
          other.notes == this.notes);
}

class SessionEventsCompanion extends UpdateCompanion<SessionEvent> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> eventType;
  final Value<DateTime> eventTimestamp;
  final Value<String?> oldValue;
  final Value<String?> newValue;
  final Value<String?> notes;
  final Value<int> rowid;
  const SessionEventsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.eventTimestamp = const Value.absent(),
    this.oldValue = const Value.absent(),
    this.newValue = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionEventsCompanion.insert({
    required String id,
    required String sessionId,
    required String eventType,
    required DateTime eventTimestamp,
    this.oldValue = const Value.absent(),
    this.newValue = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       eventType = Value(eventType),
       eventTimestamp = Value(eventTimestamp);
  static Insertable<SessionEvent> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? eventType,
    Expression<DateTime>? eventTimestamp,
    Expression<String>? oldValue,
    Expression<String>? newValue,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (eventType != null) 'event_type': eventType,
      if (eventTimestamp != null) 'event_timestamp': eventTimestamp,
      if (oldValue != null) 'old_value': oldValue,
      if (newValue != null) 'new_value': newValue,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? eventType,
    Value<DateTime>? eventTimestamp,
    Value<String?>? oldValue,
    Value<String?>? newValue,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return SessionEventsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      eventType: eventType ?? this.eventType,
      eventTimestamp: eventTimestamp ?? this.eventTimestamp,
      oldValue: oldValue ?? this.oldValue,
      newValue: newValue ?? this.newValue,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (eventTimestamp.present) {
      map['event_timestamp'] = Variable<DateTime>(eventTimestamp.value);
    }
    if (oldValue.present) {
      map['old_value'] = Variable<String>(oldValue.value);
    }
    if (newValue.present) {
      map['new_value'] = Variable<String>(newValue.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionEventsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('eventType: $eventType, ')
          ..write('eventTimestamp: $eventTimestamp, ')
          ..write('oldValue: $oldValue, ')
          ..write('newValue: $newValue, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
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
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
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
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const AppSetting({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSetting copyWith({String? key, String? value, DateTime? updatedAt}) =>
      AppSetting(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
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
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RoomsTable rooms = $RoomsTable(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $SessionSegmentsTable sessionSegments = $SessionSegmentsTable(
    this,
  );
  late final $SessionExtensionsTable sessionExtensions =
      $SessionExtensionsTable(this);
  late final $PaymentsTable payments = $PaymentsTable(this);
  late final $SessionEventsTable sessionEvents = $SessionEventsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    rooms,
    customers,
    sessions,
    sessionSegments,
    sessionExtensions,
    payments,
    sessionEvents,
    appSettings,
  ];
}

typedef $$RoomsTableCreateCompanionBuilder = RoomsCompanion Function({
  required String id,
  required String roomName,
  required String equipmentType,
  Value<int> controllerCount,
  required double hourlyRate,
  Value<String> status,
  Value<String?> description,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$RoomsTableUpdateCompanionBuilder = RoomsCompanion Function({
  Value<String> id,
  Value<String> roomName,
  Value<String> equipmentType,
  Value<int> controllerCount,
  Value<double> hourlyRate,
  Value<String> status,
  Value<String?> description,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$RoomsTableReferences
    extends BaseReferences<_$AppDatabase, $RoomsTable, Room> {
  $$RoomsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SessionSegmentsTable, List<SessionSegment>>
  _sessionSegmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sessionSegments,
    aliasName: 'rooms__id__session_segments__room_id',
  );

  $$SessionSegmentsTableProcessedTableManager get sessionSegmentsRefs {
    final manager = $$SessionSegmentsTableTableManager(
      $_db,
      $_db.sessionSegments,
    ).filter((f) => f.roomId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _sessionSegmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RoomsTableFilterComposer extends Composer<_$AppDatabase, $RoomsTable> {
  $$RoomsTableFilterComposer({
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

  ColumnFilters<String> get roomName => $composableBuilder(
    column: $table.roomName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipmentType => $composableBuilder(
    column: $table.equipmentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get controllerCount => $composableBuilder(
    column: $table.controllerCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hourlyRate => $composableBuilder(
    column: $table.hourlyRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sessionSegmentsRefs(
    Expression<bool> Function($$SessionSegmentsTableFilterComposer f) f,
  ) {
    final $$SessionSegmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionSegments,
      getReferencedColumn: (t) => t.roomId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionSegmentsTableFilterComposer(
            $db: $db,
            $table: $db.sessionSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoomsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoomsTable> {
  $$RoomsTableOrderingComposer({
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

  ColumnOrderings<String> get roomName => $composableBuilder(
    column: $table.roomName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipmentType => $composableBuilder(
    column: $table.equipmentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get controllerCount => $composableBuilder(
    column: $table.controllerCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hourlyRate => $composableBuilder(
    column: $table.hourlyRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoomsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoomsTable> {
  $$RoomsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get roomName =>
      $composableBuilder(column: $table.roomName, builder: (column) => column);

  GeneratedColumn<String> get equipmentType => $composableBuilder(
    column: $table.equipmentType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get controllerCount => $composableBuilder(
    column: $table.controllerCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get hourlyRate => $composableBuilder(
    column: $table.hourlyRate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> sessionSegmentsRefs<T extends Object>(
    Expression<T> Function($$SessionSegmentsTableAnnotationComposer a) f,
  ) {
    final $$SessionSegmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionSegments,
      getReferencedColumn: (t) => t.roomId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionSegmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RoomsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoomsTable,
          Room,
          $$RoomsTableFilterComposer,
          $$RoomsTableOrderingComposer,
          $$RoomsTableAnnotationComposer,
          $$RoomsTableCreateCompanionBuilder,
          $$RoomsTableUpdateCompanionBuilder,
          (Room, $$RoomsTableReferences),
          Room,
          PrefetchHooks Function({bool sessionSegmentsRefs})
        > {
  $$RoomsTableTableManager(_$AppDatabase db, $RoomsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoomsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoomsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoomsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> roomName = const Value.absent(),
                Value<String> equipmentType = const Value.absent(),
                Value<int> controllerCount = const Value.absent(),
                Value<double> hourlyRate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoomsCompanion(
                id: id,
                roomName: roomName,
                equipmentType: equipmentType,
                controllerCount: controllerCount,
                hourlyRate: hourlyRate,
                status: status,
                description: description,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String roomName,
                required String equipmentType,
                Value<int> controllerCount = const Value.absent(),
                required double hourlyRate,
                Value<String> status = const Value.absent(),
                Value<String?> description = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => RoomsCompanion.insert(
                id: id,
                roomName: roomName,
                equipmentType: equipmentType,
                controllerCount: controllerCount,
                hourlyRate: hourlyRate,
                status: status,
                description: description,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RoomsTable, Room>(table),
                  $$RoomsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionSegmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (sessionSegmentsRefs) db.sessionSegments,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sessionSegmentsRefs)
                    await $_getPrefetchedDataByColumns<
                      Room,
                      $RoomsTable,
                      SessionSegment,
                      $SessionSegmentsTable
                    >(
                      currentTable: table,
                      referencedTable: $$RoomsTableReferences
                          ._sessionSegmentsRefsTable(db),
                      managerFromTypedResult: (p0) => $$RoomsTableReferences(
                        db,
                        table,
                        p0,
                      ).sessionSegmentsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'room_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$RoomsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoomsTable,
      Room,
      $$RoomsTableFilterComposer,
      $$RoomsTableOrderingComposer,
      $$RoomsTableAnnotationComposer,
      $$RoomsTableCreateCompanionBuilder,
      $$RoomsTableUpdateCompanionBuilder,
      (Room, $$RoomsTableReferences),
      Room,
      PrefetchHooks Function({bool sessionSegmentsRefs})
    >;
typedef $$CustomersTableCreateCompanionBuilder = CustomersCompanion Function({
  required String id,
  required String name,
  Value<String?> phone,
  Value<String?> notes,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$CustomersTableUpdateCompanionBuilder = CustomersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> phone,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$CustomersTableReferences
    extends BaseReferences<_$AppDatabase, $CustomersTable, Customer> {
  $$CustomersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SessionsTable, List<Session>> _sessionsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sessions,
    aliasName: 'customers__id__sessions__customer_id',
  );

  $$SessionsTableProcessedTableManager get sessionsRefs {
    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.customerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sessionsRefs(
    Expression<bool> Function($$SessionsTableFilterComposer f) f,
  ) {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> sessionsRefs<T extends Object>(
    Expression<T> Function($$SessionsTableAnnotationComposer a) f,
  ) {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomersTable,
          Customer,
          $$CustomersTableFilterComposer,
          $$CustomersTableOrderingComposer,
          $$CustomersTableAnnotationComposer,
          $$CustomersTableCreateCompanionBuilder,
          $$CustomersTableUpdateCompanionBuilder,
          (Customer, $$CustomersTableReferences),
          Customer,
          PrefetchHooks Function({bool sessionsRefs})
        > {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion(
                id: id,
                name: name,
                phone: phone,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> phone = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion.insert(
                id: id,
                name: name,
                phone: phone,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CustomersTable, Customer>(table),
                  $$CustomersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (sessionsRefs) db.sessions],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sessionsRefs)
                    await $_getPrefetchedDataByColumns<
                      Customer,
                      $CustomersTable,
                      Session,
                      $SessionsTable
                    >(
                      currentTable: table,
                      referencedTable: $$CustomersTableReferences
                          ._sessionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CustomersTableReferences(
                            db,
                            table,
                            p0,
                          ).sessionsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'customer_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CustomersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomersTable,
      Customer,
      $$CustomersTableFilterComposer,
      $$CustomersTableOrderingComposer,
      $$CustomersTableAnnotationComposer,
      $$CustomersTableCreateCompanionBuilder,
      $$CustomersTableUpdateCompanionBuilder,
      (Customer, $$CustomersTableReferences),
      Customer,
      PrefetchHooks Function({bool sessionsRefs})
    >;
typedef $$SessionsTableCreateCompanionBuilder = SessionsCompanion Function({
  required String id,
  Value<String?> customerId,
  Value<String> status,
  required DateTime startedAt,
  required DateTime scheduledEndAt,
  Value<DateTime?> endedAt,
  Value<String> billingPolicy,
  Value<int> totalDurationSeconds,
  Value<double> totalAmount,
  Value<String> paymentStatus,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$SessionsTableUpdateCompanionBuilder = SessionsCompanion Function({
  Value<String> id,
  Value<String?> customerId,
  Value<String> status,
  Value<DateTime> startedAt,
  Value<DateTime> scheduledEndAt,
  Value<DateTime?> endedAt,
  Value<String> billingPolicy,
  Value<int> totalDurationSeconds,
  Value<double> totalAmount,
  Value<String> paymentStatus,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, Session> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CustomersTable _customerIdTable(_$AppDatabase db) =>
      db.customers.createAlias('sessions__customer_id__customers__id');

  $$CustomersTableProcessedTableManager? get customerId {
    final $_column = $_itemColumn<String>('customer_id');
    if ($_column == null) return null;
    final manager = $$CustomersTableTableManager(
      $_db,
      $_db.customers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SessionSegmentsTable, List<SessionSegment>>
  _sessionSegmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sessionSegments,
    aliasName: 'sessions__id__session_segments__session_id',
  );

  $$SessionSegmentsTableProcessedTableManager get sessionSegmentsRefs {
    final manager = $$SessionSegmentsTableTableManager(
      $_db,
      $_db.sessionSegments,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _sessionSegmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SessionExtensionsTable, List<SessionExtension>>
  _sessionExtensionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.sessionExtensions,
        aliasName: 'sessions__id__session_extensions__session_id',
      );

  $$SessionExtensionsTableProcessedTableManager get sessionExtensionsRefs {
    final manager = $$SessionExtensionsTableTableManager(
      $_db,
      $_db.sessionExtensions,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _sessionExtensionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PaymentsTable, List<Payment>> _paymentsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.payments,
    aliasName: 'sessions__id__payments__session_id',
  );

  $$PaymentsTableProcessedTableManager get paymentsRefs {
    final manager = $$PaymentsTableTableManager(
      $_db,
      $_db.payments,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SessionEventsTable, List<SessionEvent>>
  _sessionEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sessionEvents,
    aliasName: 'sessions__id__session_events__session_id',
  );

  $$SessionEventsTableProcessedTableManager get sessionEventsRefs {
    final manager = $$SessionEventsTableTableManager(
      $_db,
      $_db.sessionEvents,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
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

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledEndAt => $composableBuilder(
    column: $table.scheduledEndAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get billingPolicy => $composableBuilder(
    column: $table.billingPolicy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalDurationSeconds => $composableBuilder(
    column: $table.totalDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CustomersTableFilterComposer get customerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableFilterComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> sessionSegmentsRefs(
    Expression<bool> Function($$SessionSegmentsTableFilterComposer f) f,
  ) {
    final $$SessionSegmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionSegments,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionSegmentsTableFilterComposer(
            $db: $db,
            $table: $db.sessionSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sessionExtensionsRefs(
    Expression<bool> Function($$SessionExtensionsTableFilterComposer f) f,
  ) {
    final $$SessionExtensionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionExtensions,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionExtensionsTableFilterComposer(
            $db: $db,
            $table: $db.sessionExtensions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> paymentsRefs(
    Expression<bool> Function($$PaymentsTableFilterComposer f) f,
  ) {
    final $$PaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableFilterComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sessionEventsRefs(
    Expression<bool> Function($$SessionEventsTableFilterComposer f) f,
  ) {
    final $$SessionEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionEvents,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionEventsTableFilterComposer(
            $db: $db,
            $table: $db.sessionEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
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

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledEndAt => $composableBuilder(
    column: $table.scheduledEndAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get billingPolicy => $composableBuilder(
    column: $table.billingPolicy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalDurationSeconds => $composableBuilder(
    column: $table.totalDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CustomersTableOrderingComposer get customerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableOrderingComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledEndAt => $composableBuilder(
    column: $table.scheduledEndAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get billingPolicy => $composableBuilder(
    column: $table.billingPolicy,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalDurationSeconds => $composableBuilder(
    column: $table.totalDurationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CustomersTableAnnotationComposer get customerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableAnnotationComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> sessionSegmentsRefs<T extends Object>(
    Expression<T> Function($$SessionSegmentsTableAnnotationComposer a) f,
  ) {
    final $$SessionSegmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionSegments,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionSegmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionSegments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sessionExtensionsRefs<T extends Object>(
    Expression<T> Function($$SessionExtensionsTableAnnotationComposer a) f,
  ) {
    final $$SessionExtensionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.sessionExtensions,
          getReferencedColumn: (t) => t.sessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SessionExtensionsTableAnnotationComposer(
                $db: $db,
                $table: $db.sessionExtensions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> paymentsRefs<T extends Object>(
    Expression<T> Function($$PaymentsTableAnnotationComposer a) f,
  ) {
    final $$PaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payments,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.payments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> sessionEventsRefs<T extends Object>(
    Expression<T> Function($$SessionEventsTableAnnotationComposer a) f,
  ) {
    final $$SessionEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionEvents,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, $$SessionsTableReferences),
          Session,
          PrefetchHooks Function({
            bool customerId,
            bool sessionSegmentsRefs,
            bool sessionExtensionsRefs,
            bool paymentsRefs,
            bool sessionEventsRefs,
          })
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime> scheduledEndAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String> billingPolicy = const Value.absent(),
                Value<int> totalDurationSeconds = const Value.absent(),
                Value<double> totalAmount = const Value.absent(),
                Value<String> paymentStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                customerId: customerId,
                status: status,
                startedAt: startedAt,
                scheduledEndAt: scheduledEndAt,
                endedAt: endedAt,
                billingPolicy: billingPolicy,
                totalDurationSeconds: totalDurationSeconds,
                totalAmount: totalAmount,
                paymentStatus: paymentStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> customerId = const Value.absent(),
                Value<String> status = const Value.absent(),
                required DateTime startedAt,
                required DateTime scheduledEndAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String> billingPolicy = const Value.absent(),
                Value<int> totalDurationSeconds = const Value.absent(),
                Value<double> totalAmount = const Value.absent(),
                Value<String> paymentStatus = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                customerId: customerId,
                status: status,
                startedAt: startedAt,
                scheduledEndAt: scheduledEndAt,
                endedAt: endedAt,
                billingPolicy: billingPolicy,
                totalDurationSeconds: totalDurationSeconds,
                totalAmount: totalAmount,
                paymentStatus: paymentStatus,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionsTable, Session>(table),
                  $$SessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                customerId = false,
                sessionSegmentsRefs = false,
                sessionExtensionsRefs = false,
                paymentsRefs = false,
                sessionEventsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (sessionSegmentsRefs) db.sessionSegments,
                    if (sessionExtensionsRefs) db.sessionExtensions,
                    if (paymentsRefs) db.payments,
                    if (sessionEventsRefs) db.sessionEvents,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (customerId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.customerId,
                            referencedTable: $$SessionsTableReferences
                                ._customerIdTable(db),
                            referencedColumn: $$SessionsTableReferences
                                ._customerIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sessionSegmentsRefs)
                        await $_getPrefetchedDataByColumns<
                          Session,
                          $SessionsTable,
                          SessionSegment,
                          $SessionSegmentsTable
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._sessionSegmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).sessionSegmentsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'session_id',
                          typedResults: items,
                        ),
                      if (sessionExtensionsRefs)
                        await $_getPrefetchedDataByColumns<
                          Session,
                          $SessionsTable,
                          SessionExtension,
                          $SessionExtensionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._sessionExtensionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).sessionExtensionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'session_id',
                          typedResults: items,
                        ),
                      if (paymentsRefs)
                        await $_getPrefetchedDataByColumns<
                          Session,
                          $SessionsTable,
                          Payment,
                          $PaymentsTable
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._paymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'session_id',
                          typedResults: items,
                        ),
                      if (sessionEventsRefs)
                        await $_getPrefetchedDataByColumns<
                          Session,
                          $SessionsTable,
                          SessionEvent,
                          $SessionEventsTable
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._sessionEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).sessionEventsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'session_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, $$SessionsTableReferences),
      Session,
      PrefetchHooks Function({
        bool customerId,
        bool sessionSegmentsRefs,
        bool sessionExtensionsRefs,
        bool paymentsRefs,
        bool sessionEventsRefs,
      })
    >;
typedef $$SessionSegmentsTableCreateCompanionBuilder =
    SessionSegmentsCompanion Function({
      required String id,
      required String sessionId,
      required String roomId,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      required double hourlyRateSnapshot,
      Value<double> amount,
      Value<int> rowid,
    });
typedef $$SessionSegmentsTableUpdateCompanionBuilder =
    SessionSegmentsCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String> roomId,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<double> hourlyRateSnapshot,
      Value<double> amount,
      Value<int> rowid,
    });

final class $$SessionSegmentsTableReferences
    extends
        BaseReferences<_$AppDatabase, $SessionSegmentsTable, SessionSegment> {
  $$SessionSegmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias('session_segments__session_id__sessions__id');

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RoomsTable _roomIdTable(_$AppDatabase db) =>
      db.rooms.createAlias('session_segments__room_id__rooms__id');

  $$RoomsTableProcessedTableManager get roomId {
    final $_column = $_itemColumn<String>('room_id')!;

    final manager = $$RoomsTableTableManager(
      $_db,
      $_db.rooms,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_roomIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SessionSegmentsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionSegmentsTable> {
  $$SessionSegmentsTableFilterComposer({
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

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hourlyRateSnapshot => $composableBuilder(
    column: $table.hourlyRateSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoomsTableFilterComposer get roomId {
    final $$RoomsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roomId,
      referencedTable: $db.rooms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoomsTableFilterComposer(
            $db: $db,
            $table: $db.rooms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionSegmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionSegmentsTable> {
  $$SessionSegmentsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hourlyRateSnapshot => $composableBuilder(
    column: $table.hourlyRateSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoomsTableOrderingComposer get roomId {
    final $$RoomsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roomId,
      referencedTable: $db.rooms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoomsTableOrderingComposer(
            $db: $db,
            $table: $db.rooms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionSegmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionSegmentsTable> {
  $$SessionSegmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<double> get hourlyRateSnapshot => $composableBuilder(
    column: $table.hourlyRateSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoomsTableAnnotationComposer get roomId {
    final $$RoomsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roomId,
      referencedTable: $db.rooms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoomsTableAnnotationComposer(
            $db: $db,
            $table: $db.rooms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionSegmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionSegmentsTable,
          SessionSegment,
          $$SessionSegmentsTableFilterComposer,
          $$SessionSegmentsTableOrderingComposer,
          $$SessionSegmentsTableAnnotationComposer,
          $$SessionSegmentsTableCreateCompanionBuilder,
          $$SessionSegmentsTableUpdateCompanionBuilder,
          (SessionSegment, $$SessionSegmentsTableReferences),
          SessionSegment,
          PrefetchHooks Function({bool sessionId, bool roomId})
        > {
  $$SessionSegmentsTableTableManager(
    _$AppDatabase db,
    $SessionSegmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionSegmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionSegmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionSegmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> roomId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<double> hourlyRateSnapshot = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionSegmentsCompanion(
                id: id,
                sessionId: sessionId,
                roomId: roomId,
                startedAt: startedAt,
                endedAt: endedAt,
                hourlyRateSnapshot: hourlyRateSnapshot,
                amount: amount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required String roomId,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                required double hourlyRateSnapshot,
                Value<double> amount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionSegmentsCompanion.insert(
                id: id,
                sessionId: sessionId,
                roomId: roomId,
                startedAt: startedAt,
                endedAt: endedAt,
                hourlyRateSnapshot: hourlyRateSnapshot,
                amount: amount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionSegmentsTable, SessionSegment>(table),
                  $$SessionSegmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false, roomId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$SessionSegmentsTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$SessionSegmentsTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (roomId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.roomId,
                        referencedTable: $$SessionSegmentsTableReferences
                            ._roomIdTable(db),
                        referencedColumn: $$SessionSegmentsTableReferences
                            ._roomIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SessionSegmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionSegmentsTable,
      SessionSegment,
      $$SessionSegmentsTableFilterComposer,
      $$SessionSegmentsTableOrderingComposer,
      $$SessionSegmentsTableAnnotationComposer,
      $$SessionSegmentsTableCreateCompanionBuilder,
      $$SessionSegmentsTableUpdateCompanionBuilder,
      (SessionSegment, $$SessionSegmentsTableReferences),
      SessionSegment,
      PrefetchHooks Function({bool sessionId, bool roomId})
    >;
typedef $$SessionExtensionsTableCreateCompanionBuilder =
    SessionExtensionsCompanion Function({
      required String id,
      required String sessionId,
      required DateTime previousEndTime,
      required DateTime newEndTime,
      required int extensionMinutes,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$SessionExtensionsTableUpdateCompanionBuilder =
    SessionExtensionsCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<DateTime> previousEndTime,
      Value<DateTime> newEndTime,
      Value<int> extensionMinutes,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$SessionExtensionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SessionExtensionsTable,
          SessionExtension
        > {
  $$SessionExtensionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias('session_extensions__session_id__sessions__id');

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SessionExtensionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionExtensionsTable> {
  $$SessionExtensionsTableFilterComposer({
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

  ColumnFilters<DateTime> get previousEndTime => $composableBuilder(
    column: $table.previousEndTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get newEndTime => $composableBuilder(
    column: $table.newEndTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get extensionMinutes => $composableBuilder(
    column: $table.extensionMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionExtensionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionExtensionsTable> {
  $$SessionExtensionsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get previousEndTime => $composableBuilder(
    column: $table.previousEndTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get newEndTime => $composableBuilder(
    column: $table.newEndTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get extensionMinutes => $composableBuilder(
    column: $table.extensionMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionExtensionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionExtensionsTable> {
  $$SessionExtensionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get previousEndTime => $composableBuilder(
    column: $table.previousEndTime,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get newEndTime => $composableBuilder(
    column: $table.newEndTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get extensionMinutes => $composableBuilder(
    column: $table.extensionMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionExtensionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionExtensionsTable,
          SessionExtension,
          $$SessionExtensionsTableFilterComposer,
          $$SessionExtensionsTableOrderingComposer,
          $$SessionExtensionsTableAnnotationComposer,
          $$SessionExtensionsTableCreateCompanionBuilder,
          $$SessionExtensionsTableUpdateCompanionBuilder,
          (SessionExtension, $$SessionExtensionsTableReferences),
          SessionExtension,
          PrefetchHooks Function({bool sessionId})
        > {
  $$SessionExtensionsTableTableManager(
    _$AppDatabase db,
    $SessionExtensionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionExtensionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionExtensionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionExtensionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<DateTime> previousEndTime = const Value.absent(),
                Value<DateTime> newEndTime = const Value.absent(),
                Value<int> extensionMinutes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionExtensionsCompanion(
                id: id,
                sessionId: sessionId,
                previousEndTime: previousEndTime,
                newEndTime: newEndTime,
                extensionMinutes: extensionMinutes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required DateTime previousEndTime,
                required DateTime newEndTime,
                required int extensionMinutes,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SessionExtensionsCompanion.insert(
                id: id,
                sessionId: sessionId,
                previousEndTime: previousEndTime,
                newEndTime: newEndTime,
                extensionMinutes: extensionMinutes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionExtensionsTable, SessionExtension>(table),
                  $$SessionExtensionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$SessionExtensionsTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$SessionExtensionsTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SessionExtensionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionExtensionsTable,
      SessionExtension,
      $$SessionExtensionsTableFilterComposer,
      $$SessionExtensionsTableOrderingComposer,
      $$SessionExtensionsTableAnnotationComposer,
      $$SessionExtensionsTableCreateCompanionBuilder,
      $$SessionExtensionsTableUpdateCompanionBuilder,
      (SessionExtension, $$SessionExtensionsTableReferences),
      SessionExtension,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$PaymentsTableCreateCompanionBuilder = PaymentsCompanion Function({
  required String id,
  required String sessionId,
  required double amountDue,
  Value<double> amountCollected,
  Value<String> paymentMethod,
  Value<String> paymentStatus,
  Value<String?> transactionReference,
  Value<DateTime?> paidAt,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$PaymentsTableUpdateCompanionBuilder = PaymentsCompanion Function({
  Value<String> id,
  Value<String> sessionId,
  Value<double> amountDue,
  Value<double> amountCollected,
  Value<String> paymentMethod,
  Value<String> paymentStatus,
  Value<String?> transactionReference,
  Value<DateTime?> paidAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$PaymentsTableReferences
    extends BaseReferences<_$AppDatabase, $PaymentsTable, Payment> {
  $$PaymentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias('payments__session_id__sessions__id');

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableFilterComposer({
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

  ColumnFilters<double> get amountDue => $composableBuilder(
    column: $table.amountDue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amountCollected => $composableBuilder(
    column: $table.amountCollected,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionReference => $composableBuilder(
    column: $table.transactionReference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableOrderingComposer({
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

  ColumnOrderings<double> get amountDue => $composableBuilder(
    column: $table.amountDue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amountCollected => $composableBuilder(
    column: $table.amountCollected,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionReference => $composableBuilder(
    column: $table.transactionReference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTable> {
  $$PaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amountDue =>
      $composableBuilder(column: $table.amountDue, builder: (column) => column);

  GeneratedColumn<double> get amountCollected => $composableBuilder(
    column: $table.amountCollected,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transactionReference => $composableBuilder(
    column: $table.transactionReference,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get paidAt =>
      $composableBuilder(column: $table.paidAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentsTable,
          Payment,
          $$PaymentsTableFilterComposer,
          $$PaymentsTableOrderingComposer,
          $$PaymentsTableAnnotationComposer,
          $$PaymentsTableCreateCompanionBuilder,
          $$PaymentsTableUpdateCompanionBuilder,
          (Payment, $$PaymentsTableReferences),
          Payment,
          PrefetchHooks Function({bool sessionId})
        > {
  $$PaymentsTableTableManager(_$AppDatabase db, $PaymentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<double> amountDue = const Value.absent(),
                Value<double> amountCollected = const Value.absent(),
                Value<String> paymentMethod = const Value.absent(),
                Value<String> paymentStatus = const Value.absent(),
                Value<String?> transactionReference = const Value.absent(),
                Value<DateTime?> paidAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsCompanion(
                id: id,
                sessionId: sessionId,
                amountDue: amountDue,
                amountCollected: amountCollected,
                paymentMethod: paymentMethod,
                paymentStatus: paymentStatus,
                transactionReference: transactionReference,
                paidAt: paidAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required double amountDue,
                Value<double> amountCollected = const Value.absent(),
                Value<String> paymentMethod = const Value.absent(),
                Value<String> paymentStatus = const Value.absent(),
                Value<String?> transactionReference = const Value.absent(),
                Value<DateTime?> paidAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PaymentsCompanion.insert(
                id: id,
                sessionId: sessionId,
                amountDue: amountDue,
                amountCollected: amountCollected,
                paymentMethod: paymentMethod,
                paymentStatus: paymentStatus,
                transactionReference: transactionReference,
                paidAt: paidAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PaymentsTable, Payment>(table),
                  $$PaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$PaymentsTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$PaymentsTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentsTable,
      Payment,
      $$PaymentsTableFilterComposer,
      $$PaymentsTableOrderingComposer,
      $$PaymentsTableAnnotationComposer,
      $$PaymentsTableCreateCompanionBuilder,
      $$PaymentsTableUpdateCompanionBuilder,
      (Payment, $$PaymentsTableReferences),
      Payment,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$SessionEventsTableCreateCompanionBuilder =
    SessionEventsCompanion Function({
      required String id,
      required String sessionId,
      required String eventType,
      required DateTime eventTimestamp,
      Value<String?> oldValue,
      Value<String?> newValue,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$SessionEventsTableUpdateCompanionBuilder =
    SessionEventsCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String> eventType,
      Value<DateTime> eventTimestamp,
      Value<String?> oldValue,
      Value<String?> newValue,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$SessionEventsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionEventsTable, SessionEvent> {
  $$SessionEventsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias('session_events__session_id__sessions__id');

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SessionEventsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionEventsTable> {
  $$SessionEventsTableFilterComposer({
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

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get eventTimestamp => $composableBuilder(
    column: $table.eventTimestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oldValue => $composableBuilder(
    column: $table.oldValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get newValue => $composableBuilder(
    column: $table.newValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionEventsTable> {
  $$SessionEventsTableOrderingComposer({
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

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get eventTimestamp => $composableBuilder(
    column: $table.eventTimestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oldValue => $composableBuilder(
    column: $table.oldValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get newValue => $composableBuilder(
    column: $table.newValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionEventsTable> {
  $$SessionEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<DateTime> get eventTimestamp => $composableBuilder(
    column: $table.eventTimestamp,
    builder: (column) => column,
  );

  GeneratedColumn<String> get oldValue =>
      $composableBuilder(column: $table.oldValue, builder: (column) => column);

  GeneratedColumn<String> get newValue =>
      $composableBuilder(column: $table.newValue, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionEventsTable,
          SessionEvent,
          $$SessionEventsTableFilterComposer,
          $$SessionEventsTableOrderingComposer,
          $$SessionEventsTableAnnotationComposer,
          $$SessionEventsTableCreateCompanionBuilder,
          $$SessionEventsTableUpdateCompanionBuilder,
          (SessionEvent, $$SessionEventsTableReferences),
          SessionEvent,
          PrefetchHooks Function({bool sessionId})
        > {
  $$SessionEventsTableTableManager(_$AppDatabase db, $SessionEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<DateTime> eventTimestamp = const Value.absent(),
                Value<String?> oldValue = const Value.absent(),
                Value<String?> newValue = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionEventsCompanion(
                id: id,
                sessionId: sessionId,
                eventType: eventType,
                eventTimestamp: eventTimestamp,
                oldValue: oldValue,
                newValue: newValue,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required String eventType,
                required DateTime eventTimestamp,
                Value<String?> oldValue = const Value.absent(),
                Value<String?> newValue = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionEventsCompanion.insert(
                id: id,
                sessionId: sessionId,
                eventType: eventType,
                eventTimestamp: eventTimestamp,
                oldValue: oldValue,
                newValue: newValue,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionEventsTable, SessionEvent>(table),
                  $$SessionEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$SessionEventsTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$SessionEventsTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SessionEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionEventsTable,
      SessionEvent,
      $$SessionEventsTableFilterComposer,
      $$SessionEventsTableOrderingComposer,
      $$SessionEventsTableAnnotationComposer,
      $$SessionEventsTableCreateCompanionBuilder,
      $$SessionEventsTableUpdateCompanionBuilder,
      (SessionEvent, $$SessionEventsTableReferences),
      SessionEvent,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSetting>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RoomsTableTableManager get rooms =>
      $$RoomsTableTableManager(_db, _db.rooms);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$SessionSegmentsTableTableManager get sessionSegments =>
      $$SessionSegmentsTableTableManager(_db, _db.sessionSegments);
  $$SessionExtensionsTableTableManager get sessionExtensions =>
      $$SessionExtensionsTableTableManager(_db, _db.sessionExtensions);
  $$PaymentsTableTableManager get payments =>
      $$PaymentsTableTableManager(_db, _db.payments);
  $$SessionEventsTableTableManager get sessionEvents =>
      $$SessionEventsTableTableManager(_db, _db.sessionEvents);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
