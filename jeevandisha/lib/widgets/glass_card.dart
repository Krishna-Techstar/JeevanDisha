import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double borderRadius;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 24,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: JeevanColors.glass, // Color(0x99FFFFFF)
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: JeevanColors.glassBorder, // Color(0xB3FFFFFF)
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: JeevanColors.tealDark.withValues(alpha: 0.08),
                  blurRadius: 32,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
