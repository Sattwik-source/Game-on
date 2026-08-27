import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/colors.dart';
import '../state/games_provider.dart';
import '../state/backup_provider.dart';
import '../widgets/backups/backup_history_list.dart';
import '../widgets/common/empty_state.dart';

/// Full backup history for the selected game. Mirrors Backups.jsx.
class BackupsScreen extends StatelessWidget {
  const BackupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final selected = context.watch<GamesProvider>().selectedGame;

    if (selected == null) {
      return const EmptyState(
        icon: '☁️',
        title: 'No game selected',
        message: 'Pick a game from the Library to see its backup history.',
      );
    }

    final backupProvider = context.watch<BackupProvider>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${selected.name} — Backup History',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.text)),
          const SizedBox(height: 4),
          Text('${backupProvider.gameBackups(selected.id).length} snapshots stored',
              style: const TextStyle(fontSize: 12, color: AppColors.muted)),
          const SizedBox(height: 20),
          Expanded(
            child: BackupHistoryList(gameId: selected.id),
          ),
        ],
      ),
    );
  }
}
