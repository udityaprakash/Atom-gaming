import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/neon_button.dart';
import '../providers/game_provider.dart';
import 'widgets/add_edit_game_dialog.dart';

class GamesScreen extends ConsumerStatefulWidget {
  const GamesScreen({super.key});

  @override
  ConsumerState<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends ConsumerState<GamesScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddEditDialog([Game? game]) {
    showDialog(
      context: context,
      builder: (_) => AddEditGameDialog(game: game),
    );
  }

  Future<void> _confirmDelete(Game game) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: Text(
          'DELETE GAME',
          style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.error),
        ),
        content: Text(
          'Are you sure you want to delete "${game.title}"? Existing historical sessions will retain their billing records.',
          style: GoogleFonts.rajdhani(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('CANCEL', style: GoogleFonts.orbitron(fontSize: 12, color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('DELETE', style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(gameRepositoryProvider).deleteGame(game.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted "${game.title}"'), backgroundColor: AppColors.surfaceElevated),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gamesAsync = ref.watch(allGamesStreamProvider);
    final selectedPlatform = ref.watch(gamePlatformFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'GAMES CATALOG & PRICING',
          style: GoogleFonts.orbitron(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 26),
            tooltip: 'Add Game',
            onPressed: () => _showAddEditDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
              style: GoogleFonts.rajdhani(fontSize: 15, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Search games by title, platform or genre...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18, color: AppColors.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),

          // Platform Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: ['All', 'PS5', 'Xbox', 'PC', 'VR', 'PS4', 'Nintendo'].map((plat) {
                final isSel = selectedPlatform == plat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      plat,
                      style: GoogleFonts.orbitron(
                        fontSize: 11,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                        color: isSel ? Colors.black : AppColors.textSecondary,
                      ),
                    ),
                    selected: isSel,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surfaceElevated,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSel ? AppColors.primary : AppColors.cardBorder,
                      ),
                    ),
                    showCheckmark: false,
                    onSelected: (_) {
                      ref.read(gamePlatformFilterProvider.notifier).setPlatform(plat);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),

          // Games List
          Expanded(
            child: gamesAsync.when(
              data: (allGames) {
                // Filter by search and platform
                final filtered = allGames.where((g) {
                  final matchPlatform = selectedPlatform == 'All' ||
                      (g.platform != null && g.platform!.toLowerCase() == selectedPlatform.toLowerCase());
                  final matchQuery = _searchQuery.isEmpty ||
                      g.title.toLowerCase().contains(_searchQuery) ||
                      (g.platform?.toLowerCase().contains(_searchQuery) ?? false) ||
                      (g.genre?.toLowerCase().contains(_searchQuery) ?? false);
                  return matchPlatform && matchQuery;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sports_esports_outlined, size: 54, color: AppColors.textMuted.withValues(alpha: 0.5)),
                          const SizedBox(height: 14),
                          Text(
                            allGames.isEmpty ? 'No Games in Catalog' : 'No Matching Games',
                            style: GoogleFonts.orbitron(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            allGames.isEmpty
                                ? 'Add games with their custom hourly rates to override default room pricing during sessions.'
                                : 'Try clearing your filters or search keywords.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.rajdhani(fontSize: 13, color: AppColors.textMuted),
                          ),
                          if (allGames.isEmpty) ...[
                            const SizedBox(height: 18),
                            NeonButton(
                              label: 'ADD FIRST GAME',
                              icon: Icons.add,
                              color: AppColors.primary,
                              onPressed: () => _showAddEditDialog(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final game = filtered[index];
                    return _GameCard(
                      game: game,
                      onEdit: () => _showAddEditDialog(game),
                      onDelete: () => _confirmDelete(game),
                      onToggleActive: (val) {
                        ref.read(gameRepositoryProvider).toggleGameActive(game.id, !val);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Text('Error loading games: $err', style: const TextStyle(color: AppColors.error)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final Game game;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggleActive;

  const _GameCard({
    required this.game,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 16,
      borderColor: game.isActive ? AppColors.cardBorder : AppColors.cardBorder.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Icon / Platform Pill
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: game.isActive ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: game.isActive ? AppColors.primary.withValues(alpha: 0.4) : AppColors.cardBorder,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.sports_esports,
                  color: game.isActive ? AppColors.primary : AppColors.textMuted,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Game details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.title,
                    style: GoogleFonts.orbitron(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: game.isActive ? AppColors.textPrimary : AppColors.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (game.platform != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Text(
                            game.platform!,
                            style: GoogleFonts.orbitron(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.accent),
                          ),
                        ),
                      if (game.platform != null && game.genre != null)
                        const SizedBox(width: 6),
                      if (game.genre != null)
                        Flexible(
                          child: Text(
                            game.genre!,
                            style: GoogleFonts.rajdhani(fontSize: 12, color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Rate badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.available.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.available.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    '${CurrencyFormatter.format(game.hourlyRate)}/hr',
                    style: GoogleFonts.orbitron(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.available,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'per player',
                  style: GoogleFonts.rajdhani(fontSize: 10, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(width: 4),

            // Actions Menu
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textMuted),
              color: AppColors.surfaceElevated,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.cardBorder),
              ),
              onSelected: (val) {
                if (val == 'edit') onEdit();
                if (val == 'toggle') onToggleActive(!game.isActive);
                if (val == 'delete') onDelete();
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('Edit Game & Rate', style: GoogleFonts.rajdhani(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(game.isActive ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 16, color: AppColors.accent),
                      const SizedBox(width: 8),
                      Text(game.isActive ? 'Deactivate (Hide)' : 'Activate (Show)', style: GoogleFonts.rajdhani(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                      const SizedBox(width: 8),
                      Text('Delete Game', style: GoogleFonts.rajdhani(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
