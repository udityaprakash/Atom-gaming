import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_provider.dart';
import '../data/reservation_repository.dart';

final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ReservationRepository(db);
});

final upcomingReservationsStreamProvider = StreamProvider<List<ReservationWithRoom>>((ref) {
  final repo = ref.watch(reservationRepositoryProvider);
  return repo.watchUpcomingReservations();
});
