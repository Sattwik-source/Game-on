import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

/// Clean card with subtle hover effect and shadow
class EnhancedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? accentColor;
  final EdgeInsets? padding;
  final double? width;
  final double? height;

  const EnhancedCard({
    super.key,
    required this.child,
    this.onTap,
    this.accentColor,
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
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: widget.width,
          height: widget.height,
          padding: widget.padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _hovered ? AppColors.surfaceHover : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hovered ? (widget.accentColor ?? AppColors.borderHover) : AppColors.border,
              width: 1,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
