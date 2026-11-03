import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../rooms/providers/room_provider.dart';

class RoomFilterBar extends ConsumerWidget {
  const RoomFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(roomFilterProvider);

    final filters = [
      ('ALL', 'All Rooms'),
      ('AVAILABLE', 'Available'),
      ('OCCUPIED', 'Occupied'),
      ('MAINTENANCE', 'Maint.'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((item) {
          final isSelected = currentFilter == item.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                item.$2,
                style: GoogleFonts.rajdhani(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
              selected: isSelected,
              onSelected: (_) {
                ref.read(roomFilterProvider.notifier).setFilter(item.$1);
              },
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surfaceElevated,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.cardBorder,
                ),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            ),
          );
        }).toList(),
      ),
    );
  }
}
