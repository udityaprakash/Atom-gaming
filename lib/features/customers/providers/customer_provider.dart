import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_provider.dart';
import '../data/customer_repository.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return CustomerRepository(db);
});

class CustomerSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}

final customerSearchQueryProvider =
    NotifierProvider<CustomerSearchQueryNotifier, String>(CustomerSearchQueryNotifier.new);

final customersWithStatsStreamProvider = StreamProvider<List<CustomerWithStats>>((ref) {
  final repo = ref.watch(customerRepositoryProvider);
  final query = ref.watch(customerSearchQueryProvider);
  return repo.watchCustomersWithStats(searchQuery: query);
});

final customerStatsFamilyProvider = FutureProvider.family<CustomerWithStats, String>((ref, customerId) {
  final repo = ref.watch(customerRepositoryProvider);
  return repo.getCustomerStats(customerId);
});

final customerSessionsFamilyProvider = FutureProvider.family<List<CustomerSessionSummary>, String>((ref, customerId) {
  final repo = ref.watch(customerRepositoryProvider);
  return repo.getCustomerSessions(customerId);
});
