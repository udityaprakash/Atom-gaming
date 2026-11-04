import 'package:drift/drift.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';

class AnalyticsOverviewData {
  final double totalBilledRevenue;
  final double actualCashCollected;
  final double outstandingUnpaid;
  final int totalSessions;
  final Duration averageSessionDuration;
  final double averageTicketSize;

  const AnalyticsOverviewData({
    required this.totalBilledRevenue,
    required this.actualCashCollected,
    required this.outstandingUnpaid,
    required this.totalSessions,
    required this.averageSessionDuration,
    required this.averageTicketSize,
  });
}

class RoomAnalyticsMetric {
  final String roomId;
  final String roomName;
  final String equipmentType;
  final int sessionCount;
  final double totalBilledAmount;
  final Duration totalOccupiedDuration;
  final Duration averageDuration;
  final double occupancyPercentage;

  const RoomAnalyticsMetric({
    required this.roomId,
    required this.roomName,
    required this.equipmentType,
    required this.sessionCount,
    required this.totalBilledAmount,
    required this.totalOccupiedDuration,
    required this.averageDuration,
    required this.occupancyPercentage,
  });
}

class DailyRevenueDataPoint {
  final DateTime date;
  final double billedAmount;
  final double cashCollected;

  const DailyRevenueDataPoint({
    required this.date,
    required this.billedAmount,
    required this.cashCollected,
  });
}

class EquipmentRevenueShare {
  final String equipmentType;
  final double totalRevenue;
  final int sessionCount;

  const EquipmentRevenueShare({
    required this.equipmentType,
    required this.totalRevenue,
    required this.sessionCount,
  });
}

class BusinessInsightsData {
  final String? mostFrequentedRoom;
  final String? highestRevenueRoom;
  final int peakHour; // 0 to 23
  final double weekdayRevenue;
  final double weekendRevenue;

  const BusinessInsightsData({
    this.mostFrequentedRoom,
    this.highestRevenueRoom,
    required this.peakHour,
    required this.weekdayRevenue,
    required this.weekendRevenue,
  });
}

class DailyCashClosingReport {
  final DateTime date;
  final double cashFromTodaySessions;
  final double cashFromPastUnpaidSessions;
  final double totalCashInDrawer;
  final double todayUnpaidDebtAccrued;
  final double totalBilledToday;
  final int sessionsCountToday;

  const DailyCashClosingReport({
    required this.date,
    required this.cashFromTodaySessions,
    required this.cashFromPastUnpaidSessions,
    required this.totalCashInDrawer,
    required this.todayUnpaidDebtAccrued,
    required this.totalBilledToday,
    required this.sessionsCountToday,
  });
}

class AnalyticsRepository {
  final AppDatabase _db;

  AnalyticsRepository(this._db);

  /// Computes overall financial overview for a given date range
  Future<AnalyticsOverviewData> getFinancialOverview({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final query = _db.select(_db.sessions)..where((t) => t.status.equals(AppConstants.sessionCompleted));
    if (startDate != null) {
      query.where((t) => t.startedAt.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      query.where((t) => t.startedAt.isSmallerOrEqualValue(endDate));
    }

    final sessions = await query.get();

    double totalBilled = 0.0;
    double actualCash = 0.0;
    double unpaidDebt = 0.0;
    int totalDurationSeconds = 0;

    for (final s in sessions) {
      totalBilled += s.totalAmount;
      totalDurationSeconds += s.totalDurationSeconds;
      if (s.paymentStatus == AppConstants.paymentPaid) {
        actualCash += s.totalAmount;
      } else {
        unpaidDebt += s.totalAmount;
      }
    }

    final totalSessions = sessions.length;
    final avgDuration = totalSessions > 0
        ? Duration(seconds: totalDurationSeconds ~/ totalSessions)
        : Duration.zero;
    final avgTicket = totalSessions > 0 ? (totalBilled / totalSessions).roundToDouble() : 0.0;

    return AnalyticsOverviewData(
      totalBilledRevenue: totalBilled,
      actualCashCollected: actualCash,
      outstandingUnpaid: unpaidDebt,
      totalSessions: totalSessions,
      averageSessionDuration: avgDuration,
      averageTicketSize: avgTicket,
    );
  }

  /// Calculates room-wise utilization and revenue breakdown
  Future<List<RoomAnalyticsMetric>> getRoomMetrics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final rooms = await _db.select(_db.rooms).get();
    final result = <RoomAnalyticsMetric>[];

    final now = DateTime.now();
    final effectiveStart = startDate ?? DateTime(now.year, now.month, 1);
    final effectiveEnd = endDate ?? now;
    final totalRangeHours = effectiveEnd.difference(effectiveStart).inHours.clamp(1, 87600);

    for (final room in rooms) {
      final segmentsQuery = _db.select(_db.sessionSegments).join([
        innerJoin(_db.sessions, _db.sessions.id.equalsExp(_db.sessionSegments.sessionId)),
      ])..where(_db.sessionSegments.roomId.equals(room.id) &
                _db.sessions.status.equals(AppConstants.sessionCompleted));

      if (startDate != null) {
        segmentsQuery.where(_db.sessionSegments.startedAt.isBiggerOrEqualValue(startDate));
      }
      if (endDate != null) {
        segmentsQuery.where(_db.sessionSegments.startedAt.isSmallerOrEqualValue(endDate));
      }

      final rows = await segmentsQuery.get();
      int sessionCount = rows.length;
      double totalBilled = 0.0;
      int totalSeconds = 0;

      for (final row in rows) {
        final seg = row.readTable(_db.sessionSegments);
        final end = seg.endedAt ?? now;
        final dur = end.difference(seg.startedAt);
        totalSeconds += dur.inSeconds;
        totalBilled += seg.amount;
      }

      final occupiedHours = totalSeconds / 3600.0;
      final occupancyPct = (occupiedHours / totalRangeHours * 100.0).clamp(0.0, 100.0);
      final avgDuration = sessionCount > 0
          ? Duration(seconds: totalSeconds ~/ sessionCount)
          : Duration.zero;

      result.add(RoomAnalyticsMetric(
        roomId: room.id,
        roomName: room.roomName,
        equipmentType: room.equipmentType,
        sessionCount: sessionCount,
        totalBilledAmount: totalBilled,
        totalOccupiedDuration: Duration(seconds: totalSeconds),
        averageDuration: avgDuration,
        occupancyPercentage: double.parse(occupancyPct.toStringAsFixed(1)),
      ));
    }

    result.sort((a, b) => b.totalBilledAmount.compareTo(a.totalBilledAmount));
    return result;
  }

  /// Calculates revenue data points for the last [days] (default 7 days for trend chart)
  Future<List<DailyRevenueDataPoint>> getDailyRevenueTrend({int days = 7}) async {
    final now = DateTime.now();
    final list = <DailyRevenueDataPoint>[];

    for (int i = days - 1; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = DateTime(day.year, day.month, day.day, 23, 59, 59);

      // Sessions completed on this day
      final sessions = await (_db.select(_db.sessions)
            ..where((t) => t.status.equals(AppConstants.sessionCompleted) &
                           t.startedAt.isBiggerOrEqualValue(dayStart) &
                           t.startedAt.isSmallerOrEqualValue(dayEnd)))
          .get();

      double billed = 0.0;
      for (final s in sessions) {
        billed += s.totalAmount;
      }

      // Cash collected on this day
      final payments = await (_db.select(_db.payments)
            ..where((t) => t.paidAt.isBiggerOrEqualValue(dayStart) &
                           t.paidAt.isSmallerOrEqualValue(dayEnd)))
          .get();

      double collected = 0.0;
      for (final p in payments) {
        collected += p.amountCollected;
      }

      list.add(DailyRevenueDataPoint(
        date: dayStart,
        billedAmount: billed,
        cashCollected: collected,
      ));
    }

    return list;
  }

  /// Computes revenue breakdown grouped by equipment type
  Future<List<EquipmentRevenueShare>> getEquipmentRevenueShare({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final rooms = await _db.select(_db.rooms).get();
    final map = <String, double>{};
    final countMap = <String, int>{};

    for (final room in rooms) {
      final segmentsQuery = _db.select(_db.sessionSegments).join([
        innerJoin(_db.sessions, _db.sessions.id.equalsExp(_db.sessionSegments.sessionId)),
      ])..where(_db.sessionSegments.roomId.equals(room.id) &
                _db.sessions.status.equals(AppConstants.sessionCompleted));

      if (startDate != null) {
        segmentsQuery.where(_db.sessionSegments.startedAt.isBiggerOrEqualValue(startDate));
      }
      if (endDate != null) {
        segmentsQuery.where(_db.sessionSegments.startedAt.isSmallerOrEqualValue(endDate));
      }

      final rows = await segmentsQuery.get();
      for (final row in rows) {
        final seg = row.readTable(_db.sessionSegments);
        map[room.equipmentType] = (map[room.equipmentType] ?? 0.0) + seg.amount;
        countMap[room.equipmentType] = (countMap[room.equipmentType] ?? 0) + 1;
      }
    }

    final result = map.entries.map((e) {
      return EquipmentRevenueShare(
        equipmentType: e.key,
        totalRevenue: e.value,
        sessionCount: countMap[e.key] ?? 0,
      );
    }).toList();

    result.sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));
    return result;
  }

  /// Computes business insights (peak hour, top room, weekday vs weekend revenue)
  Future<BusinessInsightsData> getBusinessInsights() async {
    final sessions = await (_db.select(_db.sessions)
          ..where((t) => t.status.equals(AppConstants.sessionCompleted)))
        .get();

    final hourDistribution = List<int>.filled(24, 0);
    double weekdayRev = 0.0;
    double weekendRev = 0.0;

    for (final s in sessions) {
      final hour = s.startedAt.hour;
      hourDistribution[hour]++;

      // 6 is Saturday, 7 is Sunday
      if (s.startedAt.weekday == DateTime.saturday || s.startedAt.weekday == DateTime.sunday) {
        weekendRev += s.totalAmount;
      } else {
        weekdayRev += s.totalAmount;
      }
    }

    int peakHour = 0;
    int maxCount = -1;
    for (int h = 0; h < 24; h++) {
      if (hourDistribution[h] > maxCount) {
        maxCount = hourDistribution[h];
        peakHour = h;
      }
    }

    final roomMetrics = await getRoomMetrics();
    String? topRoom;
    String? mostFrequented;

    if (roomMetrics.isNotEmpty) {
      topRoom = roomMetrics.first.roomName;

      final sortedByVisits = List<RoomAnalyticsMetric>.from(roomMetrics)
        ..sort((a, b) => b.sessionCount.compareTo(a.sessionCount));
      mostFrequented = sortedByVisits.first.roomName;
    }

    return BusinessInsightsData(
      mostFrequentedRoom: mostFrequented,
      highestRevenueRoom: topRoom,
      peakHour: peakHour,
      weekdayRevenue: weekdayRev,
      weekendRevenue: weekendRev,
    );
  }

  /// Generates the Daily Cash Drawer Closing Report
  Future<DailyCashClosingReport> getDailyCashClosing([DateTime? targetDate]) async {
    final date = targetDate ?? DateTime.now();
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = DateTime(date.year, date.month, date.day, 23, 59, 59);

    // 1. Sessions completed today
    final todaySessions = await (_db.select(_db.sessions)
          ..where((t) => t.status.equals(AppConstants.sessionCompleted) &
                         t.startedAt.isBiggerOrEqualValue(dayStart) &
                         t.startedAt.isSmallerOrEqualValue(dayEnd)))
        .get();

    double totalBilledToday = 0.0;
    double todayUnpaidDebt = 0.0;

    for (final s in todaySessions) {
      totalBilledToday += s.totalAmount;
      if (s.paymentStatus == AppConstants.paymentUnpaid) {
        todayUnpaidDebt += s.totalAmount;
      }
    }

    // 2. All payments collected today
    final todayPayments = await (_db.select(_db.payments)
          ..where((t) => t.paidAt.isBiggerOrEqualValue(dayStart) &
                         t.paidAt.isSmallerOrEqualValue(dayEnd)))
        .get();

    double cashTodaySessions = 0.0;
    double cashPastUnpaid = 0.0;

    for (final p in todayPayments) {
      final session = await (_db.select(_db.sessions)..where((t) => t.id.equals(p.sessionId))).getSingleOrNull();
      if (session != null) {
        if (session.startedAt.isBefore(dayStart)) {
          // Collected from a past unpaid session
          cashPastUnpaid += p.amountCollected;
        } else {
          cashTodaySessions += p.amountCollected;
        }
      } else {
        cashTodaySessions += p.amountCollected;
      }
    }

    final totalCash = cashTodaySessions + cashPastUnpaid;

    return DailyCashClosingReport(
      date: dayStart,
      cashFromTodaySessions: cashTodaySessions,
      cashFromPastUnpaidSessions: cashPastUnpaid,
      totalCashInDrawer: totalCash,
      todayUnpaidDebtAccrued: todayUnpaidDebt,
      totalBilledToday: totalBilledToday,
      sessionsCountToday: todaySessions.length,
    );
  }
}
