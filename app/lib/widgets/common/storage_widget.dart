import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/constants/colors.dart';

/// Circular storage gauge showing used/total space
class StorageWidget extends StatelessWidget {
  final double usedGB;
  final double totalGB;
  final double size;
  final bool showDetails;

  const StorageWidget({
    super.key,
    required this.usedGB,
    required this.totalGB,
    this.size = 120,
    this.showDetails = true,
  });

  double get percentage => (usedGB / totalGB).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final color = _getColorForPercentage();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              CustomPaint(
                size: Size(size, size),
                painter: _CircleProgressPainter(
                  progress: 1.0,
                  color: AppColors.surface2,
                  strokeWidth: 8,
                ),
              ),
              // Progress circle
              CustomPaint(
                size: Size(size, size),
                painter: _CircleProgressPainter(
                  progress: percentage,
                  color: color,
                  strokeWidth: 8,
                ),
              ),
              // Center text
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(percentage * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${usedGB.toStringAsFixed(1)} GB',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.muted2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showDetails) ...[
          const SizedBox(height: 12),
          Text(
            'of ${totalGB.toStringAsFixed(0)} GB used',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.muted,
            ),
          ),
          if (percentage > 0.8) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Upgrade Storage',
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }

  Color _getColorForPercentage() {
    if (percentage < 0.5) return AppColors.success;
    if (percentage < 0.8) return AppColors.warning;
    return AppColors.danger;
  }
}

class _CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _CircleProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2; // Start at top
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
