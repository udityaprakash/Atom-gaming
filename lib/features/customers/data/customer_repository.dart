import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';

class CustomerWithStats {
  final Customer customer;
  final int totalVisits;
  final Duration totalDuration;
  final double totalSpent; // Cash collected
  final double outstandingDebt;
  final DateTime? lastVisit;

  const CustomerWithStats({
    required this.customer,
    required this.totalVisits,
    required this.totalDuration,
    required this.totalSpent,
    required this.outstandingDebt,
    this.lastVisit,
  });
}

class CustomerSessionSummary {
  final Session session;
  final String roomName;
  final String equipmentType;
  final double hourlyRateSnapshot;
  final Payment? payment;

  const CustomerSessionSummary({
    required this.session,
    required this.roomName,
    required this.equipmentType,
    required this.hourlyRateSnapshot,
    this.payment,
  });
}

class CustomerRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  CustomerRepository(this._db);

  /// Streams all customers along with their calculated statistics
  Stream<List<CustomerWithStats>> watchCustomersWithStats({String? searchQuery}) {
    final query = _db.select(_db.customers);
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final term = '%${searchQuery.trim().toLowerCase()}%';
      query.where((t) => t.name.lower().like(term) | t.phone.like(term));
    }
    query.orderBy([(t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc)]);

    return query.watch().asyncMap((customers) async {
      final result = <CustomerWithStats>[];
      for (final customer in customers) {
        final stats = await getCustomerStats(customer.id);
        result.add(CustomerWithStats(
          customer: customer,
          totalVisits: stats.totalVisits,
          totalDuration: stats.totalDuration,
          totalSpent: stats.totalSpent,
          outstandingDebt: stats.outstandingDebt,
          lastVisit: stats.lastVisit,
        ));
      }
      return result;
    });
  }

  /// Calculates real-time statistics for a specific customer
  Future<CustomerWithStats> getCustomerStats(String customerId) async {
    final customer = await (_db.select(_db.customers)..where((t) => t.id.equals(customerId))).getSingle();

    final sessions = await (_db.select(_db.sessions)
          ..where((t) => t.customerId.equals(customerId))
          ..orderBy([(t) => OrderingTerm(expression: t.startedAt, mode: OrderingMode.desc)]))
        .get();

    int totalDurationSeconds = 0;
    double totalSpent = 0.0;
    double outstandingDebt = 0.0;
    DateTime? lastVisit;

    if (sessions.isNotEmpty) {
      lastVisit = sessions.first.startedAt;
      for (final s in sessions) {
        totalDurationSeconds += s.totalDurationSeconds;
        if (s.paymentStatus == AppConstants.paymentPaid) {
          totalSpent += s.totalAmount;
        } else if (s.paymentStatus == AppConstants.paymentUnpaid) {
          outstandingDebt += s.totalAmount;
        }
      }
    }

    return CustomerWithStats(
      customer: customer,
      totalVisits: sessions.length,
      totalDuration: Duration(seconds: totalDurationSeconds),
      totalSpent: totalSpent,
      outstandingDebt: outstandingDebt,
      lastVisit: lastVisit,
    );
  }

  /// Fetches all historical sessions for a given customer with room details
  Future<List<CustomerSessionSummary>> getCustomerSessions(String customerId) async {
    final sessions = await (_db.select(_db.sessions)
          ..where((t) => t.customerId.equals(customerId))
          ..orderBy([(t) => OrderingTerm(expression: t.startedAt, mode: OrderingMode.desc)]))
        .get();

    final list = <CustomerSessionSummary>[];
    for (final s in sessions) {
      // Find latest segment for room details
      final segment = await (_db.select(_db.sessionSegments)
            ..where((t) => t.sessionId.equals(s.id))
            ..orderBy([(t) => OrderingTerm(expression: t.startedAt, mode: OrderingMode.desc)])
            ..limit(1))
          .getSingleOrNull();

      Room? room;
      if (segment != null) {
        room = await (_db.select(_db.rooms)..where((t) => t.id.equals(segment.roomId))).getSingleOrNull();
      }

      final payment = await (_db.select(_db.payments)..where((t) => t.sessionId.equals(s.id))).getSingleOrNull();

      list.add(CustomerSessionSummary(
        session: s,
        roomName: room?.roomName ?? 'Gaming Room',
        equipmentType: room?.equipmentType ?? 'Console',
        hourlyRateSnapshot: segment?.hourlyRateSnapshot ?? 0.0,
        payment: payment,
      ));
    }

    return list;
  }

  Future<String> createCustomer({
    required String name,
    String? phone,
    String? notes,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    await _db.into(_db.customers).insert(
          CustomersCompanion(
            id: Value(id),
            name: Value(name.trim()),
            phone: Value(phone?.trim()),
            notes: Value(notes?.trim()),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );

    return id;
  }

  Future<void> updateCustomer({
    required String id,
    required String name,
    String? phone,
    String? notes,
  }) async {
    final now = DateTime.now();
    await (_db.update(_db.customers)..where((t) => t.id.equals(id))).write(
      CustomersCompanion(
        name: Value(name.trim()),
        phone: Value(phone?.trim()),
        notes: Value(notes?.trim()),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> deleteCustomer(String id) async {
    await _db.transaction(() async {
      // Unlink customer from all historical sessions so they become Guest User sessions
      // and financial / audit logs are preserved without foreign key violations.
      await (_db.update(_db.sessions)..where((t) => t.customerId.equals(id))).write(
        const SessionsCompanion(customerId: Value(null)),
      );

      // Delete customer record from directory
      await (_db.delete(_db.customers)..where((t) => t.id.equals(id))).go();
    });
  }

  /// Searches customers matching name or phone substring (for autocomplete)
  Future<List<Customer>> searchCustomers(String query) async {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return [];

    final term = '%$clean%';
    return (_db.select(_db.customers)
          ..where((t) => t.name.lower().like(term) | t.phone.like(term))
          ..orderBy([(t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc)])
          ..limit(10))
        .get();
  }

  /// Finds customer by exact phone number
  Future<Customer?> findCustomerByPhone(String phone) async {
    final clean = phone.trim();
    if (clean.isEmpty) return null;
    return (_db.select(_db.customers)..where((t) => t.phone.equals(clean))).getSingleOrNull();
  }

  /// Finds customer by exact name (case-insensitive)
  Future<Customer?> findCustomerByName(String name) async {
    final clean = name.trim().toLowerCase();
    if (clean.isEmpty) return null;
    return (_db.select(_db.customers)..where((t) => t.name.lower().equals(clean))).getSingleOrNull();
  }

  /// Finds or creates a customer. Updates missing phone number if newly provided.
  Future<String> upsertCustomer({
    required String name,
    String? phone,
    String? notes,
  }) async {
    final cleanName = name.trim();
    final cleanPhone = phone?.trim();

    // 1. Check by phone first if provided
    Customer? existing;
    if (cleanPhone != null && cleanPhone.isNotEmpty) {
      existing = await findCustomerByPhone(cleanPhone);
    }

    // 2. If not found by phone, check by name
    if (existing == null && cleanName.isNotEmpty) {
      existing = await findCustomerByName(cleanName);
    }

    final now = DateTime.now();

    if (existing != null) {
      final matched = existing;
      // If customer exists but had no phone (or user updated phone), update it
      if (cleanPhone != null && cleanPhone.isNotEmpty && (matched.phone == null || matched.phone!.isEmpty)) {
        await (_db.update(_db.customers)..where((t) => t.id.equals(matched.id))).write(
          CustomersCompanion(
            phone: Value(cleanPhone),
            updatedAt: Value(now),
          ),
        );
      }
      return matched.id;
    }

    // 3. Create new customer
    final newId = _uuid.v4();
    await _db.into(_db.customers).insert(
          CustomersCompanion(
            id: Value(newId),
            name: Value(cleanName.isNotEmpty ? cleanName : 'Customer ${cleanPhone ?? ""}'),
            phone: Value(cleanPhone),
            notes: Value(notes?.trim()),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
    return newId;
  }
}
