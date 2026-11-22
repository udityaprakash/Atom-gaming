import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/neon_button.dart';
import '../../providers/game_provider.dart';

class AddEditGameDialog extends ConsumerStatefulWidget {
  final Game? game;
  final String? initialTitle;
  final ValueChanged<Game>? onGameCreated;

  const AddEditGameDialog({
    super.key,
    this.game,
    this.initialTitle,
    this.onGameCreated,
  });

  @override
  ConsumerState<AddEditGameDialog> createState() => _AddEditGameDialogState();
}

class _AddEditGameDialogState extends ConsumerState<AddEditGameDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _rateController;
  late final TextEditingController _genreController;

  static const List<String> _platforms = ['PS5', 'Xbox', 'PC', 'VR', 'PS4', 'Nintendo', 'All'];
  String _selectedPlatform = 'PS5';
  bool _isActive = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final g = widget.game;
    _titleController = TextEditingController(text: g?.title ?? widget.initialTitle ?? '');
    _rateController = TextEditingController(text: g != null ? g.hourlyRate.toStringAsFixed(0) : '150');
    _genreController = TextEditingController(text: g?.genre ?? '');
    if (g != null && g.platform != null && _platforms.contains(g.platform)) {
      _selectedPlatform = g.platform!;
    } else if (g?.platform != null) {
      _selectedPlatform = g!.platform!;
    }
    _isActive = g?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _rateController.dispose();
    _genreController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final rate = double.tryParse(_rateController.text.trim()) ?? 0.0;
    final genre = _genreController.text.trim();

    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(gameRepositoryProvider);
      if (widget.game == null) {
        final newGame = await repo.createGame(
          title: title,
          platform: _selectedPlatform,
          genre: genre.isNotEmpty ? genre : null,
          hourlyRate: rate,
          isActive: _isActive,
        );
        if (mounted) {
          widget.onGameCreated?.call(newGame);
          Navigator.pop(context, newGame);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added "${newGame.title}" to Games Catalog'),
              backgroundColor: AppColors.surfaceElevated,
            ),
          );
        }
      } else {
        await repo.updateGame(
          id: widget.game!.id,
          title: title,
          platform: _selectedPlatform,
          genre: genre.isNotEmpty ? genre : null,
          hourlyRate: rate,
          isActive: _isActive,
        );
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Updated "${widget.game!.title}"'),
              backgroundColor: AppColors.surfaceElevated,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving game: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.game != null;

    return Dialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.cardBorder, width: 1.5),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                          ),
                          child: const Icon(Icons.sports_esports, color: AppColors.primary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEditing ? 'EDIT GAME' : 'ADD NEW GAME',
                              style: GoogleFonts.orbitron(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              isEditing ? 'Update rate & platform' : 'Set custom hourly pricing',
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
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textMuted, size: 20),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Game Title Input
                Text(
                  'GAME TITLE *',
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.words,
                  style: GoogleFonts.rajdhani(fontSize: 15, fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(
                    hintText: 'e.g. FIFA 24, Tekken 8, GTA V',
                    prefixIcon: Icon(Icons.title, size: 18, color: AppColors.textMuted),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Game title is required';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Hourly Rate Input
                Text(
                  'HOURLY RATE (OVERRIDE) *',
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _rateController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                  style: GoogleFonts.orbitron(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.available,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      child: Text(
                        '₹',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.available),
                      ),
                    ),
                    suffixText: '/hr per player',
                    suffixStyle: GoogleFonts.rajdhani(fontSize: 12, color: AppColors.textSecondary),
                    hintText: '150',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Hourly rate is required';
                    final n = double.tryParse(v.trim());
                    if (n == null || n < 0) return 'Enter a valid rate';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Platform Selector
                Text(
                  'CONSOLE / PLATFORM',
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _platforms.map((plat) {
                    final isSel = _selectedPlatform == plat;
                    return InkWell(
                      onTap: () => setState(() => _selectedPlatform = plat),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.primary.withValues(alpha: 0.2) : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSel ? AppColors.primary : AppColors.cardBorder,
                            width: isSel ? 1.5 : 1,
                          ),
                        ),
                        child: Text(
                          plat,
                          style: GoogleFonts.orbitron(
                            fontSize: 11,
                            fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                            color: isSel ? AppColors.primary : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),

                // Genre / Category (Optional)
                Text(
                  'GENRE / CATEGORY (OPTIONAL)',
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _genreController,
                  textCapitalization: TextCapitalization.words,
                  style: GoogleFonts.rajdhani(fontSize: 14, fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(
                    hintText: 'e.g. Sports, Racing, Fighting, Action',
                    prefixIcon: Icon(Icons.category_outlined, size: 18, color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(height: 14),

                // Active Status (If editing)
                if (isEditing) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AVAILABLE FOR SESSIONS',
                            style: GoogleFonts.orbitron(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMuted,
                            ),
                          ),
                          Text(
                            _isActive ? 'Visible in start session dropdown' : 'Hidden from new sessions',
                            style: GoogleFonts.rajdhani(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      Switch(
                        value: _isActive,
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) => setState(() => _isActive = val),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],

                const SizedBox(height: 10),
                // Action Buttons
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
                          style: GoogleFonts.orbitron(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: NeonButton(
                        label: _isSubmitting ? 'SAVING...' : (isEditing ? 'SAVE' : 'ADD GAME'),
                        icon: Icons.check,
                        color: AppColors.primary,
                        height: 44,
                        fontSize: 12,
                        onPressed: _isSubmitting ? null : _handleSave,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
