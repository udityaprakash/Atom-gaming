import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/neon_button.dart';
import '../../sessions/presentation/widgets/start_session_sheet.dart';
import '../providers/reservation_provider.dart';
import 'widgets/book_reservation_dialog.dart';

class ReservationsScreen extends ConsumerWidget {
  const ReservationsScreen({super.key});

  void _openBookingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const BookReservationDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reservationsAsync = ref.watch(upcomingReservationsStreamProvider);
    final timeFormat = DateFormat('hh:mm a');
    final dateFormat = DateFormat('EEE, MMM d');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'RESERVATIONS',
          style: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'New Reservation',
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            onPressed: () => _openBookingDialog(context),
          ),
        ],
      ),
      body: reservationsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Error loading reservations: $err',
              style: GoogleFonts.rajdhani(color: AppColors.error, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (reservations) {
          if (reservations.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: const Icon(
                        Icons.event_note,
                        size: 48,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Upcoming Reservations',
                      style: GoogleFonts.orbitron(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Reserve consoles in advance to avoid double bookings.',
                      style: GoogleFonts.rajdhani(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    NeonButton(
                      label: '+ BOOK A CONSOLE',
                      color: AppColors.primary,
                      onPressed: () => _openBookingDialog(context),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: reservations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = reservations[index];
              final res = item.reservation;
              final room = item.room;
              final endTime = res.reservedFor.add(Duration(minutes: res.durationMinutes));

              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Room badge and Date/Time
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    room.roomName,
                                    style: GoogleFonts.orbitron(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                                    ),
                                    child: Text(
                                      room.equipmentType,
                                      style: GoogleFonts.rajdhani(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                res.customerName,
                                style: GoogleFonts.rajdhani(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accent,
                                ),
                              ),
                              if (res.customerPhone != null && res.customerPhone!.isNotEmpty)
                                Text(
                                  res.customerPhone!,
                                  style: GoogleFonts.rajdhani(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: Text(
                                dateFormat.format(res.reservedFor),
                                style: GoogleFonts.rajdhani(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${timeFormat.format(res.reservedFor)} - ${timeFormat.format(endTime)}',
                              style: GoogleFonts.rajdhani(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              '${res.durationMinutes} mins',
                              style: GoogleFonts.rajdhani(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    if (res.notes != null && res.notes!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Note: ${res.notes}',
                          style: GoogleFonts.rajdhani(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 14),
                    const Divider(color: AppColors.cardBorder, height: 1),
                    const SizedBox(height: 12),

                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: AppColors.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: const BorderSide(color: AppColors.cardBorder),
                                ),
                                title: Text(
                                  'Cancel Reservation?',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.error,
                                  ),
                                ),
                                content: Text(
                                  'Are you sure you want to cancel the reservation for ${res.customerName} on ${room.roomName}?',
                                  style: GoogleFonts.rajdhani(color: AppColors.textSecondary),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('NO'),
                                  ),
                                  NeonButton(
                                    label: 'YES, CANCEL',
                                    color: AppColors.error,
                                    onPressed: () => Navigator.pop(ctx, true),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true) {
                              await ref.read(reservationRepositoryProvider).cancelReservation(res.id);
                            }
                          },
                          child: Text(
                            'CANCEL',
                            style: GoogleFonts.rajdhani(
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        NeonButton(
                          label: 'START SESSION',
                          color: AppColors.primary,
                          onPressed: () {
                            if (room.status != AppConstants.statusAvailable) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${room.roomName} is currently ${room.status}. Wait until it is available.',
                                    style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold),
                                  ),
                                  backgroundColor: AppColors.warning,
                                ),
                              );
                              return;
                            }

                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (_) => StartSessionSheet(
                                room: room,
                                prefillCustomerName: res.customerName,
                                prefillPhone: res.customerPhone,
                                prefillDurationMinutes: res.durationMinutes,
                                onSessionStarted: () async {
                                  // Mark reservation as completed
                                  await ref.read(reservationRepositoryProvider).completeReservation(res.id);
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
