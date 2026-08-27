import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../core/models/backup.dart';
import '../../state/backup_provider.dart';
import '../common/empty_state.dart';

/// Scrollable list of past backup snapshots for one game, with
/// restore/delete actions per row.
class BackupHistoryList extends StatefulWidget {
  final String gameId;
  const BackupHistoryList({super.key, required this.gameId});

  @override
  State<BackupHistoryList> createState() => _BackupHistoryListState();
}

class _BackupHistoryListState extends State<BackupHistoryList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BackupProvider>().fetchHistory(widget.gameId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final backups = context.watch<BackupProvider>().gameBackups(widget.gameId);

    if (backups.isEmpty) {
      return const EmptyState(icon: '📦', title: 'No backups yet', message: 'Click "Backup Now" to create your first snapshot.');
    }

    return ListView.separated(
      itemCount: backups.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _BackupRow(backup: backups[i], gameId: widget.gameId),
    );
  }
}

class _BackupRow extends StatelessWidget {
  final Backup backup;
  final String gameId;
  const _BackupRow({required this.backup, required this.gameId});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, yyyy · h:mm a').format(backup.createdAt);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.purpleGlow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.inventory_2, color: AppColors.purple2, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(backup.label ?? backup.fileName,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.text)),
                const SizedBox(height: 2),
                Text('$dateStr · ${backup.trigger == BackupTrigger.manual ? "Manual" : "Auto"}',
                    style: const TextStyle(fontSize: 11, color: AppColors.muted)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _confirmRestore(context),
            child: const Text('Restore', style: TextStyle(fontSize: 12, color: AppColors.purple2)),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.muted),
            onPressed: () => context.read<BackupProvider>().deleteBackup(backup.id, gameId),
          ),
        ],
      ),
    );
  }

  void _confirmRestore(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Restore this backup?', style: TextStyle(color: AppColors.text, fontSize: 16)),
        content: const Text(
          'This will overwrite your current save file with this backup. This cannot be undone.',
          style: TextStyle(color: AppColors.muted, fontSize: 13),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }
}
