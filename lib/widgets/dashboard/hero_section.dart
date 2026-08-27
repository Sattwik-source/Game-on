import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

/// Animated glowing portal hero — pulsing rings behind the GameOn wordmark.
class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.heroRadial),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final opacity = 0.4 + (_controller.value * 0.3);
              return Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.purple.withOpacity(opacity), width: 2),
                  boxShadow: [
                    BoxShadow(color: AppColors.purple.withOpacity(opacity * 0.6), blurRadius: 60, spreadRadius: 10),
                  ],
                ),
              );
            },
          ),
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.purple3.withOpacity(0.3), width: 1),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -2, color: AppColors.text),
                  children: [
                    TextSpan(text: 'GAME'),
                    TextSpan(text: 'ON', style: TextStyle(color: AppColors.purple2)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text('PLAY MORE. WAIT LESS. GAME ON.',
                  style: TextStyle(fontSize: 12, letterSpacing: 3, color: AppColors.muted)),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.08),
                  side: BorderSide(color: Colors.white.withOpacity(0.25)),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                ),
                child: const Text('ENTER THE WORLD', style: TextStyle(fontSize: 12, letterSpacing: 1, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
