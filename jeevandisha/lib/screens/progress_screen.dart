import 'dart:ui';

import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import '../widgets/error_state.dart';
import '../widgets/glass_card.dart';
import '../widgets/loading_state.dart';
import '../widgets/progress_ring.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  Map<String, dynamic>? _progress;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProgress();
  }

  Future<void> _fetchProgress() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await ApiService.get('/progress');
      if (!mounted) return;

      if (response is Map<String, dynamic>) {
        setState(() {
          _progress = response;
          _loading = false;
        });
      } else if (response is Map) {
        setState(() {
          _progress = Map<String, dynamic>.from(response);
          _loading = false;
        });
      } else {
        setState(() {
          _progress = _defaultProgress;
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _progress = _defaultProgress;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final progressData = _progress ?? _defaultProgress;
    final nestedProgress =
        progressData['progress'] is Map ? progressData['progress'] as Map : null;

    final int currentWeek = (progressData['currentWeek'] ??
            nestedProgress?['currentWeek'] ??
            2) as int;
    final int completedActivities = (progressData['completedActivities'] ??
            nestedProgress?['activitiesCompleted'] ??
            8) as int;
    final int totalActivities = (progressData['totalActivities'] ??
            nestedProgress?['activitiesTotal'] ??
            25) as int;
    final int completedGoals = (progressData['completedGoals'] ??
            nestedProgress?['goalsCompleted'] ??
            3) as int;
    final int totalGoals =
        (progressData['totalGoals'] ?? nestedProgress?['goalsTotal'] ?? 5) as int;
    final int totalCheckIns = (progressData['totalCheckIns'] ??
            nestedProgress?['totalCheckIns'] ??
            7) as int;
    final int completedStudySessions =
        (progressData['completedStudySessions'] ?? 5) as int;

    // Percent ratios
    final double activityRatio = totalActivities > 0
        ? (completedActivities / totalActivities).clamp(0.0, 1.0)
        : 0.0;
    final double goalsRatio = totalGoals > 0
        ? (completedGoals / totalGoals).clamp(0.0, 1.0)
        : (completedGoals / 5.0).clamp(0.0, 1.0);
    final double checkInRatio = (totalCheckIns / 14.0).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: JeevanColors.bgMain,
      body: Stack(
        children: [
          // Ambient background blobs
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
                // Top Header Container: gradient 0xFF064A53 to tealDark, borderRadius bottom 32, padding 52 top 24 sides 32 bottom
                _buildHeader(
                  currentWeek: currentWeek,
                  activityRatio: activityRatio,
                  goalsRatio: goalsRatio,
                  checkInRatio: checkInRatio,
                ),

                // Body content
                Expanded(
                  child: _loading
                      ? const LoadingState(message: 'Loading progress...')
                      : _error != null && _progress == null
                          ? ErrorState(
                              message: _error!,
                              onRetry: _fetchProgress,
                            )
                          : RefreshIndicator(
                              onRefresh: _fetchProgress,
                              color: JeevanColors.tealDark,
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 2x2 Stat Grid using GridView.count
                                GridView.count(
                                  crossAxisCount: 2,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 1.35,
                                  children: [
                                    _buildStatCard(
                                      emoji: '⏱️',
                                      number: '$completedStudySessions',
                                      label: 'Study Sessions',
                                    ),
                                    _buildStatCard(
                                      emoji: '🌱',
                                      number: '$completedActivities',
                                      label: 'Wellbeing Activities',
                                    ),
                                    _buildStatCard(
                                      emoji: '🎯',
                                      number: '$completedGoals',
                                      label: 'Goals Completed',
                                    ),
                                    _buildStatCard(
                                      emoji: '💡',
                                      number: '$totalCheckIns',
                                      label: 'Reflections Saved',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Wide GlassCard showing overall activity progress bar
                                GlassCard(
                                  padding: const EdgeInsets.all(20),
                                  borderRadius: 22,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Activity Completion',
                                            style: TextStyle(
                                              fontFamily: 'Manrope',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: JeevanColors.textPrimary,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: JeevanColors.tealDark
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              '${(activityRatio * 100).round()}%',
                                              style: const TextStyle(
                                                fontFamily: 'Manrope',
                                                fontSize: 13,
                                                fontWeight: FontWeight.w800,
                                                color: JeevanColors.tealDark,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: LinearProgressIndicator(
                                          value: activityRatio,
                                          minHeight: 10,
                                          backgroundColor: JeevanColors.bgSec,
                                          valueColor:
                                              const AlwaysStoppedAnimation<Color>(
                                            JeevanColors.tealDark,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '$completedActivities of $totalActivities activities done',
                                            style: const TextStyle(
                                              fontFamily: 'Manrope',
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: JeevanColors.textSec,
                                            ),
                                          ),
                                          Text(
                                            '${totalActivities - completedActivities} remaining',
                                            style: const TextStyle(
                                              fontFamily: 'Manrope',
                                              fontSize: 12,
                                              color: JeevanColors.textSec,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 18),

                                // Bottom note: "Progress reflects activity completion, not a wellbeing score."
                                const Center(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      'Progress reflects activity completion, not a wellbeing score.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Manrope',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: JeevanColors.textSec,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
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

  // Top header Container gradient Color(0xFF064A53) to tealDark, borderRadius bottom 32, padding 52 top 24 sides 32 bottom
  Widget _buildHeader({
    required int currentWeek,
    required double activityRatio,
    required double goalsRatio,
    required double checkInRatio,
  }) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF064A53),
            JeevanColors.tealDark,
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
            color: Color(0x33064A53),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.only(
        top: 52,
        left: 24,
        right: 24,
        bottom: 32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title & Week Chip Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // "Your Progress" 24px bold white
              const Text(
                'Your Progress',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),

              // Week chip: Container borderRadius 50 padding 6 14 background white18 — "🗓 Week X of 6" in 12px white85
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  '🗓 Week $currentWeek of 6',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Row of 3 ProgressRings
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Activities (completed/total as double, color aqua)
              ProgressRing(
                percent: activityRatio,
                label: 'Activities',
              ),

              // Goals (completedGoals, color success)
              ProgressRing(
                percent: goalsRatio,
                label: 'Goals',
                progressColor: JeevanColors.success,
              ),

              // Check-ins (totalCheckIns/14 as double, color warning)
              ProgressRing(
                percent: checkInRatio,
                label: 'Check-ins',
                progressColor: JeevanColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String emoji,
    required String number,
    required String label,
  }) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 22),
              ),
              Text(
                number,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: JeevanColors.tealDeep,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: JeevanColors.textSec,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  static const Map<String, dynamic> _defaultProgress = {
    'completedActivities': 8,
    'totalActivities': 25,
    'completedStudySessions': 5,
    'completedGoals': 3,
    'totalGoals': 5,
    'totalCheckIns': 7,
    'currentWeek': 2,
    'currentModule': 2,
  };
}
