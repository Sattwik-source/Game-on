import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/models/game.dart';

/// Small colored status pill showing a game's current sync state.
class StatusBadge extends StatelessWidget {
  final SyncState state;
  const StatusBadge({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (state) {
      SyncState.syncing  => (AppColors.secondary, 'Syncing'),
      SyncState.watching => (AppColors.success, 'Watching'),
      SyncState.error    => (AppColors.danger, 'Error'),
      SyncState.idle      => (AppColors.muted, 'Idle'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
