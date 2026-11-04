import 'package:drift/drift.dart';

@DataClassName('Room')
class Rooms extends Table {
  TextColumn get id => text()();
  TextColumn get roomName => text().withLength(min: 1, max: 100)();
  TextColumn get equipmentType => text()();
  IntColumn get controllerCount => integer().withDefault(const Constant(1))();
  RealColumn get hourlyRate => real()();
  TextColumn get status => text().withDefault(const Constant('AVAILABLE'))();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Customer')
class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Session')
class Sessions extends Table {
  TextColumn get id => text()();
  TextColumn get customerId => text().nullable().references(Customers, #id)();
  TextColumn get status => text().withDefault(const Constant('ACTIVE'))();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get scheduledEndAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  TextColumn get billingPolicy => text().withDefault(const Constant('per_minute'))();
  IntColumn get totalDurationSeconds => integer().withDefault(const Constant(0))();
  RealColumn get totalAmount => real().withDefault(const Constant(0.0))();
  TextColumn get paymentStatus => text().withDefault(const Constant('UNPAID'))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SessionSegment')
class SessionSegments extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(Sessions, #id)();
  TextColumn get roomId => text().references(Rooms, #id)();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  RealColumn get hourlyRateSnapshot => real()();
  RealColumn get amount => real().withDefault(const Constant(0.0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SessionExtension')
class SessionExtensions extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(Sessions, #id)();
  DateTimeColumn get previousEndTime => dateTime()();
  DateTimeColumn get newEndTime => dateTime()();
  IntColumn get extensionMinutes => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Payment')
class Payments extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(Sessions, #id)();
  RealColumn get amountDue => real()();
  RealColumn get amountCollected => real().withDefault(const Constant(0.0))();
  TextColumn get paymentMethod => text().withDefault(const Constant('CASH'))();
  TextColumn get paymentStatus => text().withDefault(const Constant('UNPAID'))();
  TextColumn get transactionReference => text().nullable()();
  DateTimeColumn get paidAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SessionEvent')
class SessionEvents extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(Sessions, #id)();
  TextColumn get eventType => text()();
  DateTimeColumn get eventTimestamp => dateTime()();
  TextColumn get oldValue => text().nullable()();
  TextColumn get newValue => text().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AppSetting')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}

@DataClassName('Reservation')
class Reservations extends Table {
  TextColumn get id => text()();
  TextColumn get roomId => text().references(Rooms, #id)();
  TextColumn get customerName => text()();
  TextColumn get customerPhone => text().nullable()();
  DateTimeColumn get reservedFor => dateTime()();
  IntColumn get durationMinutes => integer()();
  TextColumn get status => text().withDefault(const Constant('CONFIRMED'))(); // CONFIRMED, CANCELLED, COMPLETED
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
