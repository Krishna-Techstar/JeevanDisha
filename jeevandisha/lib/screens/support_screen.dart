import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../widgets/glass_card.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final body = SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
        children: [
          Text(
            'Support',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'You do not have to hold everything alone.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 22),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'In this moment',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'If you feel unsafe or in crisis, reach local emergency '
                  'services or a trusted person nearby. This app is a companion, '
                  'not emergency care.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GlassCard(
            onTap: () => context.push('/stress'),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: JeevanColors.success.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.spa_rounded, color: JeevanColors.tealDark),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1-minute stress reset',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Text(
                        'Guided box breathing',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: JeevanColors.textSec),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Talk to someone',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'A friend, mentor, counselor, or campus support office can '
                  'help when thoughts feel heavy. Asking is a strength.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gentle reminders',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 10),
                _Bullet('Rest is part of progress, not the opposite of it.'),
                _Bullet('One small step still moves the path forward.'),
                _Bullet('Comparison steals focus — your pace is enough.'),
              ],
            ),
          ),
        ],
      ),
    );

    if (embedded) return body;

    return JeevanBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Support')),
        body: body,
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('·  ', style: TextStyle(color: JeevanColors.tealDark)),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
