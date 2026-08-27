import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../state/games_provider.dart';
import '../../state/backup_provider.dart';
import '../../state/auth_provider.dart';
import '../common/empty_state.dart';

/// Right-hand detail panel shown next to the game library list.
/// Mirrors GameDetailPanel from the concept design's right column.
class GameDetailPanel extends StatelessWidget {
  const GameDetailPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GamesProvider>().selectedGame;
    final backupProvider = context.watch<BackupProvider>();
    final user = context.watch<AuthProvider>().user;

    if (game == null) {
      return const EmptyState(icon: '🎮', title: 'Select a game', message: 'Choose a game from the list to see details.');
    }

    final isSyncing = backupProvider.isSyncing(game.id);

    return Container(
      color: AppColors.bg2,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(game.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.text)),
          const SizedBox(height: 4),
          Text('${game.savePaths.length} save path(s) watched',
              style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isSyncing || game.savePaths.isEmpty || user == null
                  ? null
                  : () => backupProvider.backupNow(
                        gameId: game.id,
                        gameSlug: game.slug,
                        savePath: game.savePaths.first,
                        userId: user.id,
                      ),
              icon: isSyncing
                  ? const SizedBox(width: 12, height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.cloud_upload, size: 15),
              label: Text(isSyncing ? 'Backing up…' : 'Backup Now'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.border),
          const SizedBox(height: 12),
          const Text('SAVE LOCATIONS',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppColors.muted)),
          const SizedBox(height: 8),
          ...game.savePaths.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(p, style: const TextStyle(fontSize: 10, color: AppColors.muted2), maxLines: 2, overflow: TextOverflow.ellipsis),
              )),
        ],
      ),
    );
  }
}
