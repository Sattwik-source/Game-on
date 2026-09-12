import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

/// Enhanced card with hover lift effect and glow
class EnhancedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? glowColor;
  final EdgeInsets? padding;
  final double? width;
  final double? height;

  const EnhancedCard({
    super.key,
    required this.child,
    this.onTap,
    this.glowColor,
    this.padding,
    this.width,
    this.height,
  });

  @override
  State<EnhancedCard> createState() => _EnhancedCardState();
}

class _EnhancedCardState extends State<EnhancedCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final glowColor = widget.glowColor ?? AppColors.primary;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        width: widget.width,
        height: widget.height,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding: widget.padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _hovered ? AppColors.surfaceHover : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _hovered ? glowColor : AppColors.border,
                width: _hovered ? 1.5 : 1,
              ),
              boxShadow: _hovered
                  ? [
                      BoxShadow(
                        color: glowColor.withOpacity(0.3),
                        blurRadius: 16,
                        spreadRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
