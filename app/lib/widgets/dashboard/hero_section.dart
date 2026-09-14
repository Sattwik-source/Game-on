import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

/// Clean, minimalistic hero section with subtle gradient background
class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.w800, letterSpacing: -1, color: AppColors.text),
                  children: [
                    TextSpan(text: 'Game'),
                    TextSpan(text: 'On', style: TextStyle(color: AppColors.primary)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text('Play more. Never lose your saves.',
                  style: TextStyle(fontSize: 14, letterSpacing: 0, color: AppColors.muted)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Get Started'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
