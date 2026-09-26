import 'package:flutter/material.dart';

import '../core/theme.dart';

class FeelingChip extends StatelessWidget {
  const FeelingChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: selected ? 1.04 : 1,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        selectedColor: JeevanColors.tealDark,
        backgroundColor: JeevanColors.glass,
        labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: selected ? Colors.white : JeevanColors.textPrimary,
            ),
        side: BorderSide(
          color: selected
              ? JeevanColors.tealDark
              : JeevanColors.success.withValues(alpha: 0.35),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      ),
    );
  }
}
