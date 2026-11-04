import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../rooms/presentation/widgets/add_edit_room_dialog.dart';
import '../../rooms/providers/room_provider.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/room_card.dart';
import 'widgets/room_filter_bar.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredRoomsAsync = ref.watch(filteredRoomsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
              ),
              child: const Icon(Icons.sports_esports, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ATOM',
                  style: GoogleFonts.orbitron(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'LIVE OCCUPANCY DASHBOARD',
                  style: GoogleFonts.rajdhani(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.event_available_outlined, color: AppColors.accent),
            tooltip: 'Advance Reservations',
            onPressed: () => context.push('/reservations'),
          ),
          IconButton(
            icon: const Icon(Icons.people_outline, color: AppColors.primary),
            tooltip: 'Customer Directory',
            onPressed: () => context.push('/customers'),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.available),
            tooltip: 'Add New Room',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const AddEditRoomDialog(),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(allRoomsStreamProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Top Overview Stats
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: DashboardHeader(),
              ),
            ),

            // Search Bar & Filters
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search room or equipment...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: ref.watch(roomSearchQueryProvider).isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  ref.read(roomSearchQueryProvider.notifier).setSearch('');
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      onChanged: (val) {
                        ref.read(roomSearchQueryProvider.notifier).setSearch(val);
                      },
                    ),
                    const SizedBox(height: 10),
                    const RoomFilterBar(),
                  ],
                ),
              ),
            ),

            // Room Grid / List
            filteredRoomsAsync.when(
              data: (rooms) {
                if (rooms.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.meeting_room_outlined, size: 54, color: AppColors.cardBorder),
                          const SizedBox(height: 12),
                          Text(
                            'No Gaming Rooms Found',
                            style: GoogleFonts.orbitron(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Tap the button below to add your first room.',
                            style: GoogleFonts.rajdhani(
                              fontSize: 14,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => const AddEditRoomDialog(),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('ADD NEW ROOM'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.58,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return RoomCard(room: rooms[index]);
                      },
                      childCount: rooms.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => SliverFillRemaining(
                child: Center(
                  child: Text('Error loading rooms: $err', style: const TextStyle(color: AppColors.error)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
