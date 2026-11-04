import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/services/security_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/neon_button.dart';
import '../../../shared/widgets/status_badge.dart';
import '../providers/room_provider.dart';
import 'widgets/add_edit_room_dialog.dart';

class RoomsScreen extends ConsumerWidget {
  const RoomsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allRoomsAsync = ref.watch(allRoomsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ROOM MANAGEMENT',
          style: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppColors.primary),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const AddEditRoomDialog(),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const AddEditRoomDialog(),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'NEW ROOM',
          style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
      body: allRoomsAsync.when(
        data: (rooms) {
          if (rooms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.meeting_room_outlined, size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text(
                    'No Rooms Configured',
                    style: GoogleFonts.orbitron(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: rooms.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final room = rooms[index];
              return _buildRoomTile(context, ref, room);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildRoomTile(BuildContext context, WidgetRef ref, Room room) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                room.roomName,
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              StatusBadge(status: room.status),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '${room.equipmentType} • ${room.controllerCount} Controllers',
                style: GoogleFonts.rajdhani(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
              const Spacer(),
              Text(
                '${CurrencyFormatter.format(room.hourlyRate)}/hr',
                style: GoogleFonts.orbitron(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          if (room.description != null && room.description!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              room.description!,
              style: GoogleFonts.rajdhani(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ],
          const Divider(color: AppColors.cardBorder, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Maintenance toggle
              if (room.status != AppConstants.statusOccupied)
                TextButton.icon(
                  onPressed: () => _toggleMaintenance(context, ref, room),
                  icon: Icon(
                    room.status == AppConstants.statusMaintenance
                        ? Icons.check_circle_outline
                        : Icons.build_outlined,
                    size: 16,
                    color: AppColors.maintenance,
                  ),
                  label: Text(
                    room.status == AppConstants.statusMaintenance ? 'MAKE AVAILABLE' : 'MAINTENANCE',
                    style: GoogleFonts.rajdhani(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.maintenance,
                    ),
                  ),
                ),
              const SizedBox(width: 8),

              // Edit Button
              TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AddEditRoomDialog(roomToEdit: room),
                  );
                },
                icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                label: Text(
                  'EDIT',
                  style: GoogleFonts.rajdhani(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Delete Button
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.occupied),
                tooltip: 'Delete Room',
                onPressed: () => _confirmDeleteRoom(context, ref, room),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _toggleMaintenance(BuildContext context, WidgetRef ref, Room room) async {
    final repo = ref.read(roomRepositoryProvider);
    if (room.status == AppConstants.statusMaintenance) {
      await repo.restoreRoomAvailability(room.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${room.roomName} is now AVAILABLE'),
            backgroundColor: AppColors.success,
          ),
        );
      }
      return;
    }

    // Prompt for reason notes
    final noteController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: Row(
          children: [
            const Icon(Icons.build, color: AppColors.maintenance),
            const SizedBox(width: 8),
            Text(
              'Set Under Maintenance',
              style: GoogleFonts.orbitron(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mark "${room.roomName}" as temporarily unavailable. Add a note explaining the maintenance reason:',
              style: GoogleFonts.rajdhani(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              style: GoogleFonts.rajdhani(fontSize: 14, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'e.g. Controller repair, software update...',
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          NeonButton(
            label: 'MARK MAINTENANCE',
            color: AppColors.maintenance,
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final note = noteController.text.trim();
      await repo.markRoomMaintenance(
        roomId: room.id,
        reasonNotes: note.isNotEmpty ? note : 'Scheduled Maintenance',
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${room.roomName} marked under maintenance'),
            backgroundColor: AppColors.maintenance,
          ),
        );
      }
    }
  }

  Future<void> _confirmDeleteRoom(BuildContext context, WidgetRef ref, Room room) async {
    final repo = ref.read(roomRepositoryProvider);
    final hasDeps = await repo.hasDependencies(room.id);

    if (hasDeps) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text('Cannot Delete Room'),
            content: Text(
              'Room "${room.roomName}" has past gaming sessions linked to it. To protect financial and session records, it cannot be deleted. You can mark it as Deactivated or Maintenance instead.',
              style: GoogleFonts.rajdhani(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      return;
    }

    if (context.mounted) {
      final security = ref.read(securityServiceProvider);
      final confirmed = await security.authenticateAction(
        context,
        title: 'Delete Room?',
        message: 'Are you sure you want to permanently delete "${room.roomName}"? This action cannot be undone.',
        confirmLabel: 'DELETE ROOM',
        isDestructive: true,
      );

      if (confirmed == true) {
        await repo.deleteRoom(room.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Room ${room.roomName} deleted.')),
          );
        }
      }
    }
  }
}
