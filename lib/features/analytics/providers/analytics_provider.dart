import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_provider.dart';
import '../data/analytics_repository.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return AnalyticsRepository(db);
});

class AnalyticsTimePresetNotifier extends Notifier<String> {
  @override
  String build() => 'THIS_MONTH';

  void setPreset(String val) => state = val;
}

final analyticsTimePresetProvider =
    NotifierProvider<AnalyticsTimePresetNotifier, String>(AnalyticsTimePresetNotifier.new);

final analyticsDateRangeProvider = Provider<(DateTime? start, DateTime? end)>((ref) {
  final preset = ref.watch(analyticsTimePresetProvider);
  final now = DateTime.now();

  switch (preset) {
    case 'TODAY':
      return (DateTime(now.year, now.month, now.day), DateTime(now.year, now.month, now.day, 23, 59, 59));
    case 'THIS_WEEK':
      final monday = now.subtract(Duration(days: now.weekday - 1));
      return (DateTime(monday.year, monday.month, monday.day), now);
    case 'THIS_MONTH':
      return (DateTime(now.year, now.month, 1), now);
    case 'ALL':
    default:
      return (null, null);
  }
});

final analyticsOverviewProvider = FutureProvider<AnalyticsOverviewData>((ref) {
  final repo = ref.watch(analyticsRepositoryProvider);
  final range = ref.watch(analyticsDateRangeProvider);
  return repo.getFinancialOverview(startDate: range.$1, endDate: range.$2);
});

final roomMetricsProvider = FutureProvider<List<RoomAnalyticsMetric>>((ref) {
  final repo = ref.watch(analyticsRepositoryProvider);
  final range = ref.watch(analyticsDateRangeProvider);
  return repo.getRoomMetrics(startDate: range.$1, endDate: range.$2);
});

final dailyRevenueTrendProvider = FutureProvider<List<DailyRevenueDataPoint>>((ref) {
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.getDailyRevenueTrend(days: 7);
});

final equipmentRevenueShareProvider = FutureProvider<List<EquipmentRevenueShare>>((ref) {
  final repo = ref.watch(analyticsRepositoryProvider);
  final range = ref.watch(analyticsDateRangeProvider);
  return repo.getEquipmentRevenueShare(startDate: range.$1, endDate: range.$2);
});

final businessInsightsProvider = FutureProvider<BusinessInsightsData>((ref) {
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.getBusinessInsights();
});

final dailyCashClosingProvider = FutureProvider<DailyCashClosingReport>((ref) {
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.getDailyCashClosing();
});
