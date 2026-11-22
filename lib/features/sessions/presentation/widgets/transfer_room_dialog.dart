import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/services/receipt_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/neon_button.dart';
import '../../../games/providers/game_provider.dart';
import '../../../rooms/providers/room_provider.dart';
import '../../data/session_repository.dart';
import '../../providers/session_provider.dart';

enum TransferGameMode { same, different, none }

class TransferRoomDialog extends ConsumerStatefulWidget {
  final ActiveRoomSession activeSession;

  const TransferRoomDialog({super.key, required this.activeSession});

  @override
  ConsumerState<TransferRoomDialog> createState() => _TransferRoomDialogState();
}

class _TransferRoomDialogState extends ConsumerState<TransferRoomDialog> {
  String? _selectedDestinationRoomId;
  late TransferGameMode _gameMode;
  Game? _differentGame;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Default: if currently playing a game, default to keeping the same game
    _gameMode = widget.activeSession.game != null ? TransferGameMode.same : TransferGameMode.none;
  }

  @override
  Widget build(BuildContext context) {
    final availableRoomsAsync = ref.watch(availableRoomsProvider);
    final activeGamesAsync = ref.watch(activeGamesStreamProvider);

    final currentRoom = widget.activeSession.room;
    final currentSegment = widget.activeSession.segment;
    final currentGame = widget.activeSession.game;
    final session = widget.activeSession.session;
    final controllers = session.controllerCount;

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.cardBorder, width: 1.5),
      ),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.all(20),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.secondary.withValues(alpha: 0.4)),
            ),
            child: const Icon(Icons.swap_horiz, color: AppColors.secondary, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TRANSFER ROOM',
                style: GoogleFonts.orbitron(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                '${currentRoom.roomName} • ${ReceiptService.formatPlayerCount(controllers)}',
                style: GoogleFonts.rajdhani(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Current Room summary
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
                          'CURRENT MACHINE',
                          style: GoogleFonts.orbitron(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          currentRoom.roomName,
                          style: GoogleFonts.orbitron(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          currentGame != null
                              ? '🎮 ${currentGame.title} (@ ₹${currentGame.hourlyRate}/hr)'
                              : '${currentRoom.equipmentType} • Default Rate',
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
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Destination Room Selection
              Text(
                'SELECT DESTINATION ROOM *',
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),

              availableRoomsAsync.when(
                data: (availableRooms) {
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

                  final isValidSelection = candidates.any((r) => r.id == _selectedDestinationRoomId);
                  final effectiveSelectedId = isValidSelection ? _selectedDestinationRoomId : null;

                  return DropdownButtonFormField<String>(
                    value: effectiveSelectedId,
                    decoration: const InputDecoration(
                      hintText: 'Select Available Room',
                      prefixIcon: Icon(Icons.meeting_room, size: 18),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    dropdownColor: AppColors.surfaceElevated,
                    style: GoogleFonts.rajdhani(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    items: candidates.map((room) {
                      return DropdownMenuItem<String>(
                        value: room.id,
                        child: Text(
                          '${room.roomName} (${room.equipmentType}) - ${CurrencyFormatter.format(room.hourlyRate)}/hr',
                          style: GoogleFonts.rajdhani(fontWeight: FontWeight.w600),
                        ),
                      );
                    }).toList(),
                    onChanged: (roomId) {
                      setState(() => _selectedDestinationRoomId = roomId);
                    },
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (err, _) => Text('Error: $err', style: const TextStyle(color: AppColors.error)),
              ),
              const SizedBox(height: 16),

              // Game on Destination Room Choice
              Text(
                'GAME FOR NEW ROOM',
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMuted,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),

              // Mode 1: Keep same game (if current session had one)
              if (currentGame != null) ...[
                RadioListTile<TransferGameMode>(
                  value: TransferGameMode.same,
                  groupValue: _gameMode,
                  activeColor: AppColors.secondary,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    'Keep playing "${currentGame.title}"',
                    style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  subtitle: Text(
                    'Retain game rate: ${CurrencyFormatter.format(currentGame.hourlyRate)}/hr per player',
                    style: GoogleFonts.rajdhani(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  onChanged: (mode) {
                    if (mode != null) setState(() => _gameMode = mode);
                  },
                ),
              ],

              // Mode 2: Play different game
              RadioListTile<TransferGameMode>(
                value: TransferGameMode.different,
                groupValue: _gameMode,
                activeColor: AppColors.secondary,
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(
                  currentGame != null ? 'Play a different game' : 'Choose a game for new room',
                  style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                subtitle: Text(
                  'Select a title with custom game pricing',
                  style: GoogleFonts.rajdhani(fontSize: 11, color: AppColors.textSecondary),
                ),
                onChanged: (mode) {
                  if (mode != null) setState(() => _gameMode = mode);
                },
              ),

              // If playing different game, show game dropdown
              if (_gameMode == TransferGameMode.different) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 8),
                  child: activeGamesAsync.when(
                    data: (games) {
                      return DropdownButtonFormField<String>(
                        value: _differentGame?.id,
                        hint: Text('Select game...', style: GoogleFonts.rajdhani(fontSize: 13, color: AppColors.textMuted)),
                        isExpanded: true,
                        dropdownColor: AppColors.surfaceElevated,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.sports_esports, size: 18, color: AppColors.accent),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        items: games.map((g) {
                          final plat = g.platform != null ? '[${g.platform}] ' : '';
                          return DropdownMenuItem<String>(
                            value: g.id,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '$plat${g.title}',
                                    style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '${CurrencyFormatter.format(g.hourlyRate)}/hr',
                                  style: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.available),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (gId) {
                          setState(() {
                            _differentGame = games.firstWhere((g) => g.id == gId);
                          });
                        },
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),
              ],

              // Mode 3: No game / default room rate
              RadioListTile<TransferGameMode>(
                value: TransferGameMode.none,
                groupValue: _gameMode,
                activeColor: AppColors.secondary,
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(
                  'No game (Use new room default rate)',
                  style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                subtitle: Text(
                  'Standard machine hourly rate applies',
                  style: GoogleFonts.rajdhani(fontSize: 11, color: AppColors.textSecondary),
                ),
                onChanged: (mode) {
                  if (mode != null) setState(() => _gameMode = mode);
                },
              ),

              // Rate snapshot preview for selected room & game
              availableRoomsAsync.maybeWhen(
                data: (availableRooms) {
                  final selectedRoom = availableRooms
                      .where((r) => r.id == _selectedDestinationRoomId && r.id != currentRoom.id)
                      .firstOrNull;

                  if (selectedRoom == null) return const SizedBox.shrink();

                  // Calculate new effective rate
                  double baseRate = selectedRoom.hourlyRate;
                  String rateLabel = 'Room Base Rate';
                  if (_gameMode == TransferGameMode.same && currentGame != null) {
                    baseRate = currentGame.hourlyRate;
                    rateLabel = 'Game (${currentGame.title})';
                  } else if (_gameMode == TransferGameMode.different && _differentGame != null) {
                    baseRate = _differentGame!.hourlyRate;
                    rateLabel = 'Game (${_differentGame!.title})';
                  }
                  final effectiveRate = baseRate * controllers;

                  return Padding(
                    padding: const EdgeInsets.only(top: 14.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
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
                                style: GoogleFonts.orbitron(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondary,
                                ),
                              ),
                              Text(
                                '${CurrencyFormatter.format(effectiveRate)}/hr',
                                style: GoogleFonts.orbitron(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${CurrencyFormatter.format(baseRate)}/hr ($rateLabel) × $controllers Players',
                            style: GoogleFonts.rajdhani(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Time spent on ${currentRoom.roomName} is finalized. Time on ${selectedRoom.roomName} will accrue at this new rate.',
                            style: GoogleFonts.rajdhani(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                orElse: () => const SizedBox.shrink(),
              ),
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
          onPressed: (_isSubmitting ||
                  _selectedDestinationRoomId == null ||
                  (_gameMode == TransferGameMode.different && _differentGame == null))
              ? null
              : () => _handleTransfer(availableRoomsAsync.asData?.value),
        ),
      ],
    );
  }

  Future<void> _handleTransfer(List<Room>? availableRooms) async {
    final destId = _selectedDestinationRoomId;
    if (destId == null) return;

    final destRoom = availableRooms?.where((r) => r.id == destId).firstOrNull;
    final destName = destRoom?.roomName ?? 'New Room';

    String? targetGameId;
    bool keepCurrent = false;

    if (_gameMode == TransferGameMode.same) {
      keepCurrent = true;
      targetGameId = widget.activeSession.game?.id;
    } else if (_gameMode == TransferGameMode.different) {
      keepCurrent = false;
      targetGameId = _differentGame?.id;
    } else {
      keepCurrent = false;
      targetGameId = null;
    }

    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(sessionRepositoryProvider);
      await repo.transferRoom(
        sessionId: widget.activeSession.session.id,
        destinationRoomId: destId,
        destinationGameId: targetGameId,
        keepCurrentGame: keepCurrent,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Transferred to $destName successfully!',
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
