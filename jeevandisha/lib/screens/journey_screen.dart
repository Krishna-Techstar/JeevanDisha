import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../services/api_service.dart';
import '../widgets/error_state.dart';
import '../widgets/glass_card.dart';
import '../widgets/loading_state.dart';

class JourneyScreen extends StatefulWidget {
  const JourneyScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends State<JourneyScreen> {
  List<dynamic> _modules = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadModules();
  }

  Future<void> _loadModules() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await ApiService.get('/modules');
      if (!mounted) return;

      List<dynamic> list;
      if (response is List) {
        list = response;
      } else if (response is Map && response['modules'] is List) {
        list = response['modules'] as List;
      } else {
        list = [];
      }

      setState(() {
        _modules = list.isNotEmpty ? list : _defaultModules;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
        _modules = _defaultModules;
      });
    }
  }

  static const List<Map<String, dynamic>> _defaultModules = [
    {
      '_id': '67b38df9a888c016e789a001',
      'moduleNumber': 1,
      'title': 'Understanding Psychological Wellbeing',
      'description': 'Foundations of mental health in nursing',
      'icon': '🌱',
      'progress': 1.0,
      'activities': [1, 2, 3, 4, 5],
    },
    {
      '_id': '67b38df9a888c016e789a002',
      'moduleNumber': 2,
      'title': 'Stress & Emotional Management',
      'description': 'Mindfulness, coping and emotion regulation',
      'icon': '🧘',
      'progress': 0.6,
      'activities': [1, 2, 3, 4, 5],
    },
    {
      '_id': '67b38df9a888c016e789a003',
      'moduleNumber': 3,
      'title': 'Self-care, Sleep & Resilience',
      'description': 'Physical wellbeing, night shift routines',
      'icon': '🌙',
      'progress': 0.0,
      'activities': [1, 2, 3, 4, 5],
    },
    {
      '_id': '67b38df9a888c016e789a004',
      'moduleNumber': 4,
      'title': 'Time Management & Study Skills',
      'description': 'Clinical balancing and active study techniques',
      'icon': '📚',
      'progress': 0.0,
      'activities': [1, 2, 3, 4, 5],
    },
    {
      '_id': '67b38df9a888c016e789a005',
      'moduleNumber': 5,
      'title': 'Clinical & Examination Stress',
      'description': 'Managing clinical rounds and exam anxiety',
      'icon': '🏥',
      'progress': 0.0,
      'activities': [1, 2, 3, 4, 5],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JeevanColors.bgMain,
      body: Stack(
        children: [
          // Atmospheric background blobs
          Positioned(
            top: -40,
            right: -50,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: JeevanColors.aqua.withValues(alpha: 0.35),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: -50,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: JeevanColors.aquaLight.withValues(alpha: 0.35),
                ),
              ),
            ),
          ),
          Positioned(
            top: 320,
            right: -40,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: JeevanColors.aqua.withValues(alpha: 0.35),
                ),
              ),
            ),
          ),

          // Main Layout
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Your Journey 🌱',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: JeevanColors.tealDeep,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '5 modules · 6 weeks',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          color: JeevanColors.textSec,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                if (_loading)
                  const Expanded(
                    child: LoadingState(message: 'Loading modules...'),
                  )
                else if (_error != null && _modules.isEmpty)
                  Expanded(
                    child: ErrorState(
                      message: _error!,
                      onRetry: _loadModules,
                    ),
                  )
                else
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadModules,
                      color: JeevanColors.tealDark,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                        itemCount: _modules.length,
                        itemBuilder: (context, index) {
                          final module = _modules[index] is Map<String, dynamic>
                              ? _modules[index] as Map<String, dynamic>
                              : Map<String, dynamic>.from(
                                  _modules[index] as Map,
                                );

                          return _buildModuleCard(module, index);
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(Map<String, dynamic> module, int index) {
    final moduleNumber = module['moduleNumber'] ?? (index + 1);
    final title = module['title']?.toString() ?? 'Module $moduleNumber';
    final icon = module['icon']?.toString() ?? '🌱';
    final moduleId = module['_id'] ?? module['id'] ?? '$moduleNumber';

    final activities = module['activities'] as List<dynamic>? ?? [];
    final totalActivities = activities.isNotEmpty ? activities.length : 5;

    int completedCount = 0;
    if (activities.isNotEmpty && activities.first is Map) {
      completedCount = activities.where((a) {
        if (a is Map) {
          return a['completed'] == true || a['status'] == 'completed';
        }
        return false;
      }).length;
    } else if (module['progress'] != null) {
      final progressNum = (module['progress'] as num).toDouble();
      completedCount = (progressNum * totalActivities).round();
    }

    final double progressRatio = totalActivities > 0
        ? (completedCount / totalActivities).clamp(0.0, 1.0)
        : 0.0;
    final bool isCompleted =
        completedCount >= totalActivities && totalActivities > 0;
    final bool isInProgress =
        completedCount > 0 && completedCount < totalActivities;

    // Number container colors:
    // Green if completed, aqua if current/in progress, bgSec if locked
    final Color numberBg;
    final Color numberTextColor;
    if (isCompleted) {
      numberBg = JeevanColors.success;
      numberTextColor = Colors.white;
    } else if (isInProgress || index == 0) {
      numberBg = JeevanColors.aqua;
      numberTextColor = JeevanColors.tealDeep;
    } else {
      numberBg = JeevanColors.bgSec;
      numberTextColor = JeevanColors.textSec;
    }

    // Status text: "✅ Completed 5/5", "🔵 In progress · 3/5 done", "⏳ Not started"
    final String statusText;
    final Color statusColor;
    if (isCompleted) {
      statusText = '✅ Completed $completedCount/$totalActivities';
      statusColor = const Color(0xFF2E7D32);
    } else if (isInProgress) {
      statusText = '🔵 In progress · $completedCount/$totalActivities done';
      statusColor = JeevanColors.tealDark;
    } else {
      statusText = '⏳ Not started';
      statusColor = JeevanColors.textSec;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: GlassCard(
        onTap: () => context.go('/module/$moduleId'),
        padding: const EdgeInsets.all(18),
        borderRadius: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Module number container (44x44, borderRadius 14)
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: numberBg,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: (isCompleted || isInProgress)
                        ? [
                            BoxShadow(
                              color: numberBg.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$moduleNumber',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: numberTextColor,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Module title & status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: JeevanColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Icon emoji
                Text(
                  icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ],
            ),

            // If in progress show LinearProgressIndicator
            if (isInProgress) ...[
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progressRatio,
                  minHeight: 6,
                  backgroundColor: JeevanColors.bgSec,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    JeevanColors.tealDark,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
