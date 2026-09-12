import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

/// Animated sync status indicator with pulsing glow
class SyncIndicator extends StatefulWidget {
  final SyncStatus status;
  final double size;
  final bool showLabel;

  const SyncIndicator({
    super.key,
    required this.status,
    this.size = 12,
    this.showLabel = false,
  });

  @override
  State<SyncIndicator> createState() => _SyncIndicatorState();
}

class _SyncIndicatorState extends State<SyncIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    if (widget.status == SyncStatus.syncing) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(SyncIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status == SyncStatus.syncing && !_controller.isAnimating) {
      _controller.repeat();
    } else if (widget.status != SyncStatus.syncing && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.syncStatusColor(widget.status);
    final label = _getLabel();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final opacity = widget.status == SyncStatus.syncing
                ? 0.3 + (_controller.value * 0.7)
                : 1.0;

            return Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: widget.status == SyncStatus.syncing
                    ? [
                        BoxShadow(
                          color: color.withOpacity(opacity * 0.6),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
            );
          },
        ),
        if (widget.showLabel) ...[
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.muted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  String _getLabel() {
    switch (widget.status) {
      case SyncStatus.synced:
        return 'All synced';
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.error:
        return 'Sync error';
      case SyncStatus.pending:
        return 'Pending';
    }
  }
}
