import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class FeatureBar extends StatelessWidget {
  const FeatureBar({super.key});

  static const _features = [
    ('🌍', 'Cinematic Worlds', 'Stunning environments with smooth scroll animations.'),
    ('✨', 'Signature Transitions', 'Unique particle transitions make every adventure feel epic.'),
    ('▶', 'One-Click Play', 'Jump into your games instantly with optimised performance.'),
    ('☁', 'Cloud Saves', 'Your progress, always safe and available anywhere.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
      child: Row(
        children: _features.asMap().entries.map((e) {
          final isLast = e.key == _features.length - 1;
          final (icon, title, desc) = e.value;
          return Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(right: isLast ? BorderSide.none : const BorderSide(color: AppColors.border)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(child: Text(icon, style: const TextStyle(fontSize: 13))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.text)),
                        const SizedBox(height: 2),
                        Text(desc, style: const TextStyle(fontSize: 9, color: AppColors.muted, height: 1.4)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
