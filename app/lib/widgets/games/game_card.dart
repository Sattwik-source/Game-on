import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class ShowcaseGameData {
  final String num, name, genre, desc;
  final List<Color> gradient;
  const ShowcaseGameData(this.num, this.name, this.genre, this.desc, this.gradient);
}

const kShowcaseGames = [
  ShowcaseGameData('01', 'CYBER VOID', 'RPG / Open World / Action',
      'Explore a futuristic city where technology and corruption collide.',
      [Color(0xFF2D1066), Color(0xFF0D0F1A)]),
  ShowcaseGameData('02', 'BLOOD HUNT', 'Survival / Horror / Co-op',
      'A cursed forest. A dark secret. A fight for survival.',
      [Color(0xFF1A0000), Color(0xFF4C1010)]),
  ShowcaseGameData('03', 'NEXUS RIDERS', 'Racing / Action',
      'Ride beyond the limits. Speed is your only ally.',
      [Color(0xFF001A2D), Color(0xFF0C3A5C)]),
  ShowcaseGameData('04', 'LOST KINGDOM', 'RPG / Fantasy',
      'A last kingdom waits to be reclaimed.',
      [Color(0xFF1A1000), Color(0xFF4C3010)]),
];

/// Showcase carousel card with clean, modern styling
class GameCard extends StatelessWidget {
  final ShowcaseGameData data;
  final bool active;
  final VoidCallback? onPlay;
  const GameCard({super.key, required this.data, this.active = false, this.onPlay});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: active ? AppColors.primary : AppColors.border),
        boxShadow: active
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: data.gradient,
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0xF207080F), Color(0x4D07080F), Colors.transparent],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 12,
            child: Text(data.num, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.muted)),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.genre.toUpperCase(),
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: AppColors.secondary)),
                const SizedBox(height: 4),
                Text(data.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, height: 1.0, color: AppColors.text)),
                const SizedBox(height: 4),
                Text(data.desc,
                    maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: AppColors.muted, height: 1.4)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: onPlay,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Play', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onPlay,
                          borderRadius: BorderRadius.circular(12),
                          child: const Icon(Icons.play_arrow, size: 12, color: AppColors.muted),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
