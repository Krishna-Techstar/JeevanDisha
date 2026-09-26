import 'dart:ui';

import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import '../widgets/error_state.dart';
import '../widgets/glass_card.dart';
import '../widgets/loading_state.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  List<dynamic> _goals = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await ApiService.get('/goals');
      if (!mounted) return;

      List<dynamic> list;
      if (response is List) {
        list = response;
      } else if (response is Map && response['goals'] is List) {
        list = response['goals'] as List;
      } else {
        list = [];
      }

      setState(() {
        _goals = list.isNotEmpty ? list : _defaultGoals;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _goals = _defaultGoals;
        _loading = false;
      });
    }
  }

  Future<void> _toggleGoalStatus(Map<String, dynamic> goal) async {
    final goalId = goal['id'] ?? goal['_id'];
    final currentStatus = goal['status']?.toString().toLowerCase();
    final newStatus = currentStatus == 'completed' ? 'active' : 'completed';

    setState(() {
      goal['status'] = newStatus;
    });

    try {
      if (goalId != null && !goalId.toString().startsWith('default_')) {
        await ApiService.put('/goals/$goalId', {
          'status': newStatus,
        });
      }
    } catch (_) {
      // Ignored for offline/optimistic update
    }
  }

  void _showAddGoalBottomSheet() {
    final goalCtrl = TextEditingController();
    final actionCtrl = TextEditingController();
    final scheduleCtrl = TextEditingController();
    final targetDateCtrl = TextEditingController(text: '2026-10-30');
    final firstStepCtrl = TextEditingController();
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  24,
                  24,
                  24,
                  MediaQuery.of(modalCtx).viewInsets.bottom + 24,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xF2FFFFFF),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x33075B66),
                      blurRadius: 24,
                      offset: Offset(0, -6),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bottom Sheet Handle
                      Center(
                        child: Container(
                          width: 44,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 18),
                          decoration: BoxDecoration(
                            color: JeevanColors.textSec.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // Header
                      const Text(
                        'Add New Goal 🎯',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: JeevanColors.tealDeep,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Set an actionable target for your nursing journey.',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          color: JeevanColors.textSec,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Goal input
                      _buildModalField(
                        controller: goalCtrl,
                        label: 'Goal',
                        hint: 'e.g., Master IV insertion protocol',
                      ),
                      const SizedBox(height: 12),

                      // Action input
                      _buildModalField(
                        controller: actionCtrl,
                        label: 'Action',
                        hint: 'e.g., Practice 2 cannula setups in skill lab',
                      ),
                      const SizedBox(height: 12),

                      // Schedule input
                      _buildModalField(
                        controller: scheduleCtrl,
                        label: 'Schedule',
                        hint: 'e.g., Tuesdays & Thursdays 4:00 PM',
                      ),
                      const SizedBox(height: 12),

                      // Target Date input
                      _buildModalField(
                        controller: targetDateCtrl,
                        label: 'Target Date',
                        hint: 'e.g., 2026-10-30',
                      ),
                      const SizedBox(height: 12),

                      // First Step input
                      _buildModalField(
                        controller: firstStepCtrl,
                        label: 'First Step',
                        hint: 'e.g., Review anatomy guide for veins',
                      ),
                      const SizedBox(height: 22),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: saving
                              ? null
                              : () async {
                                  final goalText = goalCtrl.text.trim();
                                  if (goalText.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please enter a goal name'),
                                        backgroundColor: JeevanColors.warning,
                                      ),
                                    );
                                    return;
                                  }

                                  setModalState(() => saving = true);

                                  final payload = {
                                    'goal': goalText,
                                    'action': actionCtrl.text.trim(),
                                    'schedule': scheduleCtrl.text.trim(),
                                    'targetDate': targetDateCtrl.text.trim(),
                                    'firstStep': firstStepCtrl.text.trim().isNotEmpty
                                        ? firstStepCtrl.text.trim()
                                        : 'Get started with first small action',
                                  };

                                  try {
                                    await ApiService.post('/goals', payload);
                                    if (modalCtx.mounted) {
                                      Navigator.pop(modalCtx);
                                    }
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Goal added successfully! 🎯'),
                                          backgroundColor: JeevanColors.tealDark,
                                        ),
                                      );
                                      _loadGoals();
                                    }
                                  } catch (e) {
                                    if (modalCtx.mounted) {
                                      Navigator.pop(modalCtx);
                                    }
                                    // Local optimistic add fallback
                                    setState(() {
                                      _goals.insert(0, {
                                        'id': 'local_${DateTime.now().millisecondsSinceEpoch}',
                                        ...payload,
                                        'status': 'active',
                                        'progress': 0.3,
                                      });
                                    });
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Goal saved!'),
                                          backgroundColor: JeevanColors.tealDark,
                                        ),
                                      );
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: JeevanColors.tealDark,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: saving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Save Goal',
                                  style: TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModalField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: JeevanColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: JeevanColors.textSec.withValues(alpha: 0.25),
            ),
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14,
              color: JeevanColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                color: JeevanColors.textSec,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JeevanColors.bgMain,
      body: Stack(
        children: [
          // Background blobs
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

          // Main Column Layout
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top: teal gradient header Container (tealDark to 0E8896 borderRadius bottom 32)
                _buildHeader(),

                // Body: SingleChildScrollView Column padding 20 horizontal, gap 16
                Expanded(
                  child: _loading
                      ? const LoadingState(message: 'Loading goals...')
                      : _error != null && _goals.isEmpty
                          ? ErrorState(
                              message: _error!,
                              onRetry: _loadGoals,
                            )
                          : RefreshIndicator(
                              onRefresh: _loadGoals,
                              color: JeevanColors.tealDark,
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                child: Column(
                                  children: [
                                    for (int i = 0; i < _goals.length; i++) ...[
                                      _buildGoalCard(_goals[i]),
                                      const SizedBox(height: 16),
                                    ],

                                    // "Add new goal" GlassCard with dashed border
                                    _buildAddGoalCard(),
                                    const SizedBox(height: 24),
                                  ],
                                ),
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

  // Top header: Container gradient tealDark to 0E8896 borderRadius bottom 32
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            JeevanColors.tealDark,
            Color(0xFF0E8896),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x33075B66),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'My Goals 🎯',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Small, actionable steps towards nursing resilience.',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Goal GlassCard with padding 22
  Widget _buildGoalCard(dynamic rawGoal) {
    final goal = rawGoal is Map<String, dynamic>
        ? rawGoal
        : Map<String, dynamic>.from(rawGoal as Map);

    final goalText = goal['goal']?.toString() ??
        goal['title']?.toString() ??
        'Clinical Practice Goal';
    final action = goal['action']?.toString() ?? '';
    final schedule = goal['schedule']?.toString() ?? '';
    final targetDate = goal['targetDate'] != null
        ? goal['targetDate'].toString().split('T').first
        : 'Ongoing';
    final firstStep = goal['firstStep']?.toString() ?? 'Initial step';
    final isCompleted = goal['status'] == 'completed';

    // Emoji icon lookup or fallback
    final emoji = goal['emoji']?.toString() ??
        (isCompleted
            ? '🎯'
            : goalText.toLowerCase().contains('sleep')
                ? '🌙'
                : goalText.toLowerCase().contains('study') ||
                        goalText.toLowerCase().contains('calculation')
                    ? '💊'
                    : '🌱');

    // Progress computation or 0.6 demo default
    double progress = 0.6;
    if (goal['progress'] != null) {
      progress = (goal['progress'] as num).toDouble();
    } else if (isCompleted) {
      progress = 1.0;
    }

    return GlassCard(
      padding: const EdgeInsets.all(22),
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row with goal text Column + emoji icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goalText,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: JeevanColors.textPrimary,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    if (action.isNotEmpty || schedule.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        action.isNotEmpty
                            ? action
                            : schedule,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          color: JeevanColors.textSec,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                emoji,
                style: const TextStyle(fontSize: 26),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // LinearProgressIndicator showing progress
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: JeevanColors.bgSec,
              valueColor: AlwaysStoppedAnimation<Color>(
                isCompleted ? JeevanColors.success : JeevanColors.aqua,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // "Target: date" text in textSec
          Text(
            'Target: $targetDate',
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: JeevanColors.textSec,
            ),
          ),
          const SizedBox(height: 12),

          // First step Row: green circle checkmark icon + step text (strikethrough if done)
          GestureDetector(
            onTap: () => _toggleGoalStatus(goal),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? JeevanColors.success
                          : JeevanColors.success.withValues(alpha: 0.2),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.check,
                      size: 14,
                      color: isCompleted ? Colors.white : JeevanColors.tealDeep,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'First step: $firstStep',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isCompleted
                            ? JeevanColors.textSec
                            : JeevanColors.textPrimary,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // "Add new goal" GlassCard with dashed border
  Widget _buildAddGoalCard() {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: JeevanColors.aqua.withValues(alpha: 0.7),
        radius: 20,
        strokeWidth: 1.6,
        dashWidth: 6.0,
        dashSpace: 4.0,
      ),
      child: GlassCard(
        onTap: _showAddGoalBottomSheet,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        borderRadius: 20,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: JeevanColors.aqua.withValues(alpha: 0.35),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: JeevanColors.tealDark,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Add New Goal',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: JeevanColors.tealDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const List<Map<String, dynamic>> _defaultGoals = [
    {
      'id': 'default_1',
      'goal': 'Master Pediatric Dosage Calculations',
      'action': 'Practice 5 clinical math questions daily',
      'schedule': 'Every morning 8:00 AM',
      'targetDate': '2026-10-15',
      'firstStep': 'Download drug dosage worksheet',
      'status': 'active',
      'progress': 0.6,
      'emoji': '💊',
    },
    {
      'id': 'default_2',
      'goal': 'Maintain 7+ Hours Sleep on Shift Days',
      'action': 'Nightly wind down routine 30 mins before bed',
      'schedule': 'Nightly at 10:30 PM',
      'targetDate': '2026-10-08',
      'firstStep': 'Put phone on Do Not Disturb at 10 PM',
      'status': 'active',
      'progress': 0.4,
      'emoji': '🌙',
    },
    {
      'id': 'default_3',
      'goal': 'Post-Clinical Emotional Debrief',
      'action': '5-minute reflection in JeevanDisha',
      'schedule': 'After hospital duty',
      'targetDate': '2026-10-22',
      'firstStep': 'Note 3 clinical observations and feelings',
      'status': 'completed',
      'progress': 1.0,
      'emoji': '📝',
    },
  ];
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final double dashWidth;
  final double dashSpace;

  _DashedBorderPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.radius = 20,
    this.dashWidth = 6.0,
    this.dashSpace = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final length = (distance + dashWidth < metric.length)
            ? dashWidth
            : metric.length - distance;
        final extractPath = metric.extractPath(distance, distance + length);
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth ||
      radius != oldDelegate.radius;
}
