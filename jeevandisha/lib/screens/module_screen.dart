import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../providers/module_provider.dart';
import '../widgets/activity_card.dart';
import '../widgets/glass_card.dart';
import '../widgets/progress_ring.dart';

class ModuleScreen extends ConsumerWidget {
  const ModuleScreen({super.key, required this.moduleId});

  final String moduleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moduleAsync = ref.watch(moduleProvider(moduleId));

    return JeevanBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(),
        body: moduleAsync.when(
          data: (module) => ListView(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 28),
            children: [
              GlassCard(
                child: Row(
                  children: [
                    ProgressRing(
                      percent: module.progress,
                      label: 'Complete',
                      size: 72,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            module.title,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            module.description,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Activities',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              for (final a in module.activities) ...[
                ActivityCard(
                  activity: a,
                  onTap: () => context.push('/activities/${a.id}'),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
        ),
      ),
    );
  }
}
