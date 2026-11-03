class SegmentBillingDetails {
  final String roomId;
  final String roomName;
  final String equipmentType;
  final DateTime startedAt;
  final DateTime endedAt;
  final Duration duration;
  final double hourlyRateSnapshot;
  final double amount;

  const SegmentBillingDetails({
    required this.roomId,
    required this.roomName,
    required this.equipmentType,
    required this.startedAt,
    required this.endedAt,
    required this.duration,
    required this.hourlyRateSnapshot,
    required this.amount,
  });
}

class SessionBillingBreakdown {
  final List<SegmentBillingDetails> segments;
  final Duration totalDuration;
  final double grossAmount;
  final double discount;
  final double finalAmount;
  final String billingPolicy;

  const SessionBillingBreakdown({
    required this.segments,
    required this.totalDuration,
    required this.grossAmount,
    this.discount = 0.0,
    required this.finalAmount,
    required this.billingPolicy,
  });
}

class BillingEngine {
  BillingEngine._();

  /// Calculates billable duration in minutes based on policy and grace period
  static double calculateBillableMinutes(
    Duration duration, {
    String policy = 'per_minute',
    int gracePeriodMinutes = 0,
  }) {
    final totalSeconds = duration.inSeconds;
    if (totalSeconds <= 0) return 0.0;

    final rawMinutes = totalSeconds / 60.0;

    switch (policy) {
      case 'blocks_15':
        // 15-minute blocks with grace period
        final mod = rawMinutes % 15;
        if (mod == 0) return rawMinutes;
        if (mod <= gracePeriodMinutes) {
          return (rawMinutes ~/ 15) * 15.0;
        }
        return ((rawMinutes ~/ 15) + 1) * 15.0;

      case 'blocks_30':
        // 30-minute blocks with grace period
        final mod = rawMinutes % 30;
        if (mod == 0) return rawMinutes;
        if (mod <= gracePeriodMinutes) {
          return (rawMinutes ~/ 30) * 30.0;
        }
        return ((rawMinutes ~/ 30) + 1) * 30.0;

      case 'hourly':
        // Full hour billing
        final mod = rawMinutes % 60;
        if (mod == 0) return rawMinutes;
        if (mod <= gracePeriodMinutes) {
          return (rawMinutes ~/ 60) * 60.0;
        }
        return ((rawMinutes ~/ 60) + 1) * 60.0;

      case 'per_minute':
      default:
        // Actual time per minute calculation
        return rawMinutes;
    }
  }

  /// Calculates amount for a single segment given its duration and rate snapshot
  static double calculateSegmentAmount({
    required Duration duration,
    required double hourlyRateSnapshot,
    String policy = 'per_minute',
    int gracePeriodMinutes = 0,
    double minimumCharge = 0.0,
  }) {
    final billableMinutes = calculateBillableMinutes(
      duration,
      policy: policy,
      gracePeriodMinutes: gracePeriodMinutes,
    );

    final rawAmount = (billableMinutes / 60.0) * hourlyRateSnapshot;
    final calculated = rawAmount < minimumCharge ? minimumCharge : rawAmount;
    return calculated.roundToDouble();
  }

  /// Builds a [SegmentBillingDetails] instance with calculated billing amount
  static SegmentBillingDetails buildSegmentDetails({
    required String roomId,
    required String roomName,
    required String equipmentType,
    required DateTime startedAt,
    required DateTime endedAt,
    required double hourlyRateSnapshot,
    String policy = 'per_minute',
    int gracePeriodMinutes = 0,
    double minimumCharge = 0.0,
  }) {
    final duration = endedAt.difference(startedAt);
    final amount = calculateSegmentAmount(
      duration: duration,
      hourlyRateSnapshot: hourlyRateSnapshot,
      policy: policy,
      gracePeriodMinutes: gracePeriodMinutes,
      minimumCharge: minimumCharge,
    );
    return SegmentBillingDetails(
      roomId: roomId,
      roomName: roomName,
      equipmentType: equipmentType,
      startedAt: startedAt,
      endedAt: endedAt,
      duration: duration,
      hourlyRateSnapshot: hourlyRateSnapshot,
      amount: amount,
    );
  }

  /// Aggregates all segments for a session into a consolidated billing breakdown
  static SessionBillingBreakdown calculateSessionBreakdown({
    required List<SegmentBillingDetails> segments,
    double discount = 0.0,
    String policy = 'per_minute',
  }) {
    Duration totalDuration = Duration.zero;
    double grossAmount = 0.0;

    for (final seg in segments) {
      totalDuration += seg.duration;
      grossAmount += seg.amount;
    }

    final finalAmount = (grossAmount - discount) > 0 ? (grossAmount - discount).roundToDouble() : 0.0;

    return SessionBillingBreakdown(
      segments: segments,
      totalDuration: totalDuration,
      grossAmount: grossAmount.roundToDouble(),
      discount: discount.roundToDouble(),
      finalAmount: finalAmount,
      billingPolicy: policy,
    );
  }
}
