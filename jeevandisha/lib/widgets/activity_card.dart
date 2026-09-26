import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/activity_model.dart';
import 'glass_card.dart';

class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    required this.activity,
    required this.onTap,
  });

  final ActivityModel activity;
  final VoidCallback onTap;

  IconData get _icon {
    switch (activity.type) {
      case 'learn':
        return Icons.menu_book_rounded;
      case 'understand':
        return Icons.lightbulb_outline_rounded;
      case 'practice':
        return Icons.edit_note_rounded;
      case 'reflect':
        return Icons.psychology_alt_rounded;
      case 'apply':
        return Icons.bolt_rounded;
      default:
        return Icons.play_circle_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: activity.completed
                  ? JeevanColors.success.withValues(alpha: 0.25)
                  : JeevanColors.aqua.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              activity.completed ? Icons.check_rounded : _icon,
              color: activity.completed ? JeevanColors.success : JeevanColors.tealDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: JeevanColors.textPrimary,
                        decoration: activity.completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${activity.durationMinutes} min · ${activity.type}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: JeevanColors.textSec),
        ],
      ),
    );
  }
}
