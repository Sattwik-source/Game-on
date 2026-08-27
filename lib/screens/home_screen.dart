import 'package:flutter/material.dart';
import '../core/constants/colors.dart';
import '../widgets/dashboard/hero_section.dart';
import '../widgets/dashboard/profile_card.dart';
import '../widgets/dashboard/download_card.dart';
import '../widgets/dashboard/feature_bar.dart';
import '../widgets/games/game_card.dart';

/// Main dashboard — mirrors Home.jsx from the Electron/React version.
/// Hero → showcase carousel → 3-col strip → feature bar.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HeroSection(),
          _SectionHeader(title: 'Game Showcase'),
          SizedBox(
            height: 260,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: kShowcaseGames.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => GameCard(data: kShowcaseGames[i], active: i == 0),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(child: ProfileCard()),
                SizedBox(width: 12),
                Expanded(child: DownloadCard()),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const FeatureBar(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        children: [
          Text(title.toUpperCase(),
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1, color: AppColors.text)),
          const SizedBox(width: 10),
          const Expanded(child: Divider(color: AppColors.border, height: 1)),
        ],
      ),
    );
  }
}
