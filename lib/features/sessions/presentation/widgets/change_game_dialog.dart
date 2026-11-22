import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/services/receipt_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/neon_button.dart';
import '../../../games/presentation/widgets/add_edit_game_dialog.dart';
import '../../../games/providers/game_provider.dart';
import '../../data/session_repository.dart';
import '../../providers/session_provider.dart';

class ChangeGameDialog extends ConsumerStatefulWidget {
  final ActiveRoomSession activeSession;

  const ChangeGameDialog({super.key, required this.activeSession});

  @override
  ConsumerState<ChangeGameDialog> createState() => _ChangeGameDialogState();
}

class _ChangeGameDialogState extends ConsumerState<ChangeGameDialog> {
  Game? _selectedGame;
  bool _initialized = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedGame = widget.activeSession.game;
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.activeSession.session;
    final room = widget.activeSession.room;
    final currentGame = widget.activeSession.game;
    final controllers = session.controllerCount;

    final activeGamesAsync = ref.watch(activeGamesStreamProvider);

    // Calculate effective rates
    final newBaseRate = _selectedGame != null ? _selectedGame!.hourlyRate : room.hourlyRate;
    final newEffectiveHourlyRate = newBaseRate * controllers;

    final currentBaseRate = currentGame != null ? currentGame.hourlyRate : room.hourlyRate;
    final currentEffectiveHourlyRate = currentBaseRate * controllers;

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
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
            ),
            child: const Icon(Icons.sports_esports, color: AppColors.accent, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CHANGE GAME / RATE',
                style: GoogleFonts.orbitron(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                '${room.roomName} • ${ReceiptService.formatPlayerCount(controllers)}',
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
              // Current Active Game Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CURRENT PRICING',
                          style: GoogleFonts.orbitron(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          currentGame != null ? currentGame.title : 'Default Room Rate',
                          style: GoogleFonts.orbitron(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    Text(
                      '${CurrencyFormatter.format(currentEffectiveHourlyRate)}/hr',
                      style: GoogleFonts.orbitron(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Game Selection Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'SELECT NEW GAME',
                    style: GoogleFonts.orbitron(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      showDialog<Game>(
                        context: context,
                        builder: (_) => AddEditGameDialog(
                          onGameCreated: (newGame) {
                            if (mounted) setState(() => _selectedGame = newGame);
                          },
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add, size: 12, color: AppColors.primary),
                          const SizedBox(width: 2),
                          Text(
                            'NEW',
                            style: GoogleFonts.orbitron(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              activeGamesAsync.when(
                data: (games) {
                  // Preselect current game on first load
                  if (!_initialized) {
                    if (currentGame != null) {
                      try {
                        _selectedGame = games.firstWhere((g) => g.id == currentGame.id);
                      } catch (_) {
                        _selectedGame = currentGame;
                      }
                    }
                    _initialized = true;
                  }

                  return DropdownButtonFormField<String?>(
                    value: _selectedGame?.id,
                    isExpanded: true,
                    dropdownColor: AppColors.surfaceElevated,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.sports_esports, size: 18, color: AppColors.accent),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    style: GoogleFonts.rajdhani(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(
                          'None (Use Room Rate: ${CurrencyFormatter.format(room.hourlyRate)}/hr)',
                          style: GoogleFonts.rajdhani(fontSize: 14, color: AppColors.textSecondary),
                        ),
                      ),
                      ...games.map((g) {
                        final plat = g.platform != null ? '[${g.platform}] ' : '';
                        return DropdownMenuItem<String?>(
                          value: g.id,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '$plat${g.title}',
                                  style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.available.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${CurrencyFormatter.format(g.hourlyRate)}/hr',
                                  style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.available),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                    onChanged: (selectedId) {
                      setState(() {
                        if (selectedId == null) {
                          _selectedGame = null;
                        } else {
                          try {
                            _selectedGame = games.firstWhere((g) => g.id == selectedId);
                          } catch (_) {
                            _selectedGame = null;
                          }
                        }
                      });
                    },
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 14),

              // Rate impact preview
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'NEW EFFECTIVE RATE:',
                          style: GoogleFonts.orbitron(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.accent),
                        ),
                        Text(
                          '${CurrencyFormatter.format(newEffectiveHourlyRate)}/hr',
                          style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.accent),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '(${CurrencyFormatter.format(newBaseRate)}/hr × $controllers Players)',
                      style: GoogleFonts.rajdhani(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '• Time played up to now is billed at the previous rate.\n• Remaining session time will be billed at this new rate.',
                      style: GoogleFonts.rajdhani(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.cardBorder),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        'CANCEL',
                        style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NeonButton(
                      label: _isSubmitting ? 'UPDATING...' : 'APPLY GAME',
                      icon: Icons.check,
                      color: AppColors.accent,
                      height: 44,
                      fontSize: 11,
                      onPressed: _isSubmitting ? null : _handleChangeGame,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleChangeGame() async {
    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(sessionRepositoryProvider);
      await repo.changeGame(
        sessionId: widget.activeSession.session.id,
        newGameId: _selectedGame?.id,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _selectedGame != null
                  ? 'Game updated to "${_selectedGame!.title}"!'
                  : 'Game cleared: reverted to Room rate!',
            ),
            backgroundColor: AppColors.surfaceElevated,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error changing game: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
