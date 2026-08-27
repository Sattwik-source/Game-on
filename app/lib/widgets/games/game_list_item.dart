import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/models/game.dart';
import '../common/badge.dart';

/// Single row in the Library screen's game list.
class GameListItem extends StatelessWidget {
  final Game game;
  final bool selected;
  final VoidCallback onTap;
  const GameListItem({super.key, required this.game, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? AppColors.purpleGlow : AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: selected ? AppColors.purple2 : AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.videogame_asset, color: AppColors.muted, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(game.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text)),
                      const SizedBox(height: 2),
                      Text(game.formattedSize, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                    ],
                  ),
                ),
                StatusBadge(state: game.syncState),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
