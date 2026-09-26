import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/module_model.dart';
import 'glass_card.dart';
import 'progress_ring.dart';

class ModuleCard extends StatelessWidget {
  const ModuleCard({
    super.key,
    required this.module,
    required this.onTap,
  });

  final ModuleModel module;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: JeevanColors.aqua.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              module.icon,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Module ${module.moduleNumber}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: JeevanColors.aqua,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  module.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: JeevanColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  module.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ProgressRing(
            percent: module.progress,
            label: '',
            size: 54,
            lineWidth: 5,
            progressColor: JeevanColors.aqua,
          ),
        ],
      ),
    );
  }
}
