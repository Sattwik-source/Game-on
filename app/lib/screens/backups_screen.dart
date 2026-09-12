import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/colors.dart';
import '../state/auth_provider.dart';
import '../state/games_provider.dart';
import '../state/backup_provider.dart';
import '../widgets/backups/backup_history_list.dart';
import '../widgets/common/empty_state.dart';

/// Full backup history for the selected game. Mirrors Backups.jsx.
/// Shows a "Connect Google Drive" prompt if user is not authenticated.
class BackupsScreen extends StatelessWidget {
  const BackupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final selected = context.watch<GamesProvider>().selectedGame;
    final auth = context.watch<AuthProvider>();

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
            child: !auth.isAuthenticated
                ? _GoogleDrivePrompt()
                : BackupHistoryList(gameId: selected.id),
          ),
        ],
      ),
    );
  }
}

/// Prompt to connect Google Drive for backup/restore functionality.
class _GoogleDrivePrompt extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Center(
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.purpleGlow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.cloud_upload_outlined, color: AppColors.purple2, size: 28),
            ),
            const SizedBox(height: 16),
            const Text(
              'Connect Google Drive',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.text),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Sign in to enable automatic backups and restore your saves across devices.',
              style: TextStyle(fontSize: 13, color: AppColors.muted, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: auth.loading
                    ? null
                    : () async {
                        await auth.signInWithGoogle();
                      },
                icon: auth.loading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.login, size: 16),
                label: Text(auth.loading ? 'Connecting…' : 'Sign in with Google'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            if (auth.error != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.12),
                  border: Border.all(color: AppColors.danger),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  auth.error!,
                  style: const TextStyle(color: AppColors.danger, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
