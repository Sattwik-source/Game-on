import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class DownloadCard extends StatelessWidget {
  const DownloadCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SYNC QUEUE',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppColors.muted)),
          const SizedBox(height: 12),
          const _EmptyQueueHint(),
        ],
      ),
    );
  }
}

class _EmptyQueueHint extends StatelessWidget {
  const _EmptyQueueHint();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: const [
          Text('✓', style: TextStyle(fontSize: 22, color: AppColors.green)),
          SizedBox(height: 8),
          Text('All games backed up', style: TextStyle(fontSize: 12, color: AppColors.muted)),
        ],
      ),
    );
  }
}
