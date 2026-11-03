import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/neon_button.dart';
import '../../../rooms/providers/room_provider.dart';
import '../../data/session_repository.dart';
import '../../providers/session_provider.dart';

class TransferRoomDialog extends ConsumerStatefulWidget {
  final ActiveRoomSession activeSession;

  const TransferRoomDialog({super.key, required this.activeSession});

  @override
  ConsumerState<TransferRoomDialog> createState() => _TransferRoomDialogState();
}

class _TransferRoomDialogState extends ConsumerState<TransferRoomDialog> {
  Room? _selectedDestinationRoom;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final availableRoomsAsync = ref.watch(availableRoomsProvider);
    final currentRoom = widget.activeSession.room;
    final currentSegment = widget.activeSession.segment;

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.cardBorder, width: 1.5),
      ),
      title: Row(
        children: [
          const Icon(Icons.swap_horiz, color: AppColors.secondary, size: 24),
          const SizedBox(width: 8),
          Text(
            'TRANSFER ROOM',
            style: GoogleFonts.orbitron(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Origin Room summary
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CURRENT ROOM',
                          style: GoogleFonts.rajdhani(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          currentRoom.roomName,
                          style: GoogleFonts.orbitron(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${currentRoom.equipmentType} • ${currentRoom.controllerCount}P',
                          style: GoogleFonts.rajdhani(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${CurrencyFormatter.format(currentSegment.hourlyRateSnapshot)}/hr',
                      style: GoogleFonts.orbitron(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'SELECT DESTINATION ROOM',
                style: GoogleFonts.orbitron(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),

              availableRoomsAsync.when(
                data: (availableRooms) {
                  // Filter out current room if it was somehow marked available
                  final candidates = availableRooms.where((r) => r.id != currentRoom.id).toList();

                  if (candidates.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.endingSoon, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'No other rooms are currently available for transfer.',
                              style: GoogleFonts.rajdhani(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return DropdownButtonFormField<Room>(
                    initialValue: _selectedDestinationRoom,
                    decoration: const InputDecoration(
                      labelText: 'Available Room *',
                      prefixIcon: Icon(Icons.meeting_room, size: 18),
                    ),
                    dropdownColor: AppColors.surfaceElevated,
                    items: candidates.map((room) {
                      return DropdownMenuItem(
                        value: room,
                        child: Text(
                          '${room.roomName} (${room.equipmentType}) - ${CurrencyFormatter.format(room.hourlyRate)}/hr',
                          style: GoogleFonts.rajdhani(fontWeight: FontWeight.w600),
                        ),
                      );
                    }).toList(),
                    onChanged: (room) {
                      setState(() => _selectedDestinationRoom = room);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('Error: $err'),
              ),

              if (_selectedDestinationRoom != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'NEW RATE SNAPSHOT',
                            style: GoogleFonts.rajdhani(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                          Text(
                            '${CurrencyFormatter.format(_selectedDestinationRoom!.hourlyRate)}/hr',
                            style: GoogleFonts.orbitron(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'The previous segment on ${currentRoom.roomName} will be closed at its original rate. Time in ${_selectedDestinationRoom!.roomName} will accrue at its new rate.',
                        style: GoogleFonts.rajdhani(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.cardBorder),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text('CANCEL', style: GoogleFonts.rajdhani(color: AppColors.textSecondary)),
        ),
        NeonButton(
          label: _isSubmitting ? 'TRANSFERRING...' : 'CONFIRM TRANSFER',
          icon: Icons.check,
          color: AppColors.secondary,
          height: 38,
          fontSize: 12,
          onPressed: (_isSubmitting || _selectedDestinationRoom == null) ? null : _handleTransfer,
        ),
      ],
    );
  }

  Future<void> _handleTransfer() async {
    if (_selectedDestinationRoom == null) return;

    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(sessionRepositoryProvider);
      await repo.transferRoom(
        sessionId: widget.activeSession.session.id,
        destinationRoomId: _selectedDestinationRoom!.id,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Transferred to ${_selectedDestinationRoom!.roomName} successfully!',
            ),
            backgroundColor: AppColors.surfaceElevated,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
