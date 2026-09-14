import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/colors.dart';
import '../core/models/game.dart';
import '../core/services/game_launcher_service.dart';
import '../state/games_provider.dart';
import '../state/ui_provider.dart';
import '../widgets/dashboard/hero_section.dart';
import '../widgets/dashboard/profile_card.dart';
import '../widgets/dashboard/download_card.dart';
import '../widgets/dashboard/feature_bar.dart';
import '../widgets/games/game_card.dart';
import '../widgets/common/empty_state.dart';

/// Main dashboard — mirrors Home.jsx from the Electron/React version.
/// Hero → showcase carousel → 3-col strip → feature bar.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final games = context.watch<GamesProvider>().games;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HeroSection(),
          _SectionHeader(title: 'Your Games'),
          if (games.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              child: EmptyState(
                icon: '🎮',
                title: 'No games added yet',
                message: 'Add your first game from the Library tab to get started.',
              ),
            )
          else
            SizedBox(
              height: 260,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: games.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final game = games[i];
                  // Convert real game to showcase format
                  final showcase = ShowcaseGameData(
                    (i + 1).toString().padLeft(2, '0'),
                    game.name.toUpperCase(),
                    game.platform,
                    '${game.savePaths.length} save path(s)',
                    [const Color(0xFF2D1066), const Color(0xFF0D0F1A)],
                  );
                  return GameCard(
                    data: showcase,
                    active: i == 0,
                    onPlay: () async {
                      final success = await GameLauncherService.instance.launchGame(
                        game.slug,
                        game.name,
                        game.savePaths,
                        exePath: game.exePath,
                      );

                      if (!success) {
                        // Show dialog with browse option
                        if (!context.mounted) return;

                        final browse = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Game Not Found'),
                            content: Text(
                              'Could not find ${game.name}.\n\nWould you like to browse for the game executable?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text('Browse'),
                              ),
                            ],
                          ),
                        );

                        if (browse == true && context.mounted) {
                          final exePath = await GameLauncherService.instance.browseForExecutable();

                          if (exePath != null) {
                            // Update the game with the new path
                            await context.read<GamesProvider>().addGame(
                              Game(
                                id: game.id,
                                name: game.name,
                                slug: game.slug,
                                savePaths: game.savePaths,
                                exePath: exePath,
                                platform: game.platform,
                              ),
                              onSaveChange: (_, __) {},
                            );

                            // Launch the game
                            await GameLauncherService.instance.launchGame(
                              game.slug,
                              game.name,
                              game.savePaths,
                              exePath: exePath,
                            );

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${game.name} launched successfully!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          }
                        }
                      }
                    },
                  );
                },
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
          Text(title,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.3, color: AppColors.text)),
          const SizedBox(width: 10),
          const Expanded(child: Divider(color: AppColors.border, height: 1)),
        ],
      ),
    );
  }
}
