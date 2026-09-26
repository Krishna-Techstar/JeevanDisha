import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/error_state.dart';
import '../widgets/glass_card.dart';
import '../widgets/loading_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _dashboardData;
  bool _loading = true;
  String? _errorMessage;
  String? _selectedFeeling;

  String _cachedUserName = 'Student';

  @override
  void initState() {
    super.initState();
    _initUserAndDashboard();
  }

  Future<void> _initUserAndDashboard() async {
    final cached = await AuthService.getCurrentUser();
    if (cached != null && cached.name.isNotEmpty && mounted) {
      setState(() {
        _cachedUserName = cached.name;
      });
    }
    await _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.get('/dashboard');
      if (!mounted) return;
      final data = response is Map<String, dynamic>
          ? response
          : Map<String, dynamic>.from(response as Map);
      setState(() {
        _dashboardData = data;
        _loading = false;
        final user = data['user'] as Map<String, dynamic>?;
        if (user != null && user['name'] != null) {
          _cachedUserName = user['name'].toString();
        }
        final checkIn = data['todayCheckIn'] as Map<String, dynamic>?;
        if (checkIn != null && checkIn['feeling'] != null) {
          _selectedFeeling = checkIn['feeling'].toString();
        }
      });
    } catch (e) {
      if (!mounted) return;
      final cached = await AuthService.getCurrentUser();
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
        if (cached != null && cached.name.isNotEmpty) {
          _cachedUserName = cached.name;
        }
        // Fallback placeholder data with real user name
        _dashboardData = {
          'user': {
            'name': _cachedUserName,
            'currentWeek': cached?.currentWeek ?? 1,
            'currentModule': cached?.currentModule ?? 1,
          },
          'currentModule': {
            'title': 'Understanding Psychological Wellbeing',
            'icon': '🌱',
            'description': 'Foundations of mental health in nursing',
          },
          'todayActivity': {
            'title': 'The Stress Response in Clinical Practice',
            'type': 'learn',
            'estimatedMinutes': 5,
          },
          'todayGoal': {
            'goal': 'Complete clinical reflection journal',
            'firstStep': 'Write 3 key points after ward duty',
          },
          'progress': {
            'completedActivities': 3,
            'totalActivities': 25,
            'completedStudySessions': 2,
            'completedGoals': 1,
          },
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JeevanColors.bgMain,
      body: Stack(
        children: [
          // Background blobs (same as login screen)
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

          // Main content
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                if (_loading)
                  const Expanded(
                    child: LoadingState(message: 'Loading dashboard...'),
                  )
                else if (_errorMessage != null && _dashboardData == null)
                  Expanded(
                    child: ErrorState(
                      message: _errorMessage!,
                      onRetry: _loadDashboard,
                    ),
                  )
                else ...[
                  // 1) Teal Gradient Header
                  _buildHeader(),

                  // 2) Scrollable GlassCards
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadDashboard,
                      color: JeevanColors.tealDark,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Today's Journey Card
                            _buildJourneyCard(),
                            const SizedBox(height: 16),

                            // Two Activity Cards in a Row (Breathing + Study)
                            _buildActivityRow(),
                            const SizedBox(height: 16),

                            // Goal Card
                            _buildGoalCard(),
                            const SizedBox(height: 16),

                            // Feeling Check-in Row
                            _buildFeelingCheckIn(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 1) Teal Gradient Header
  Widget _buildHeader() {
    final user = _dashboardData?['user'] as Map<String, dynamic>?;
    final userName = (user?['name'] as String?)?.trim().isNotEmpty == true
        ? user!['name'] as String
        : _cachedUserName;
    final currentWeek = user?['currentWeek'] ?? 1;

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
            color: Color(0x26075B66),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Good Morning,',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$userName 👋',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Week $currentWeek of 6',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No new notifications'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                  GestureDetector(
                    onTap: () => context.push('/profile'),
                    child: Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.2),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Date Strip
          _buildDateStrip(),
        ],
      ),
    );
  }

  // Date Strip (7 days with today highlighted)
  Widget _buildDateStrip() {
    final now = DateTime.now();
    final currentWeekday = now.weekday; // 1 = Mon, 7 = Sun
    final monday = now.subtract(Duration(days: currentWeekday - 1));

    final days = List.generate(7, (i) => monday.add(Duration(days: i)));
    const dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final date = days[index];
        final isToday = date.day == now.day &&
            date.month == now.month &&
            date.year == now.year;

        return Container(
          width: 38,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color:
                isToday ? Colors.white : Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(19),
            boxShadow: isToday
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Text(
                dayNames[index],
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isToday ? JeevanColors.tealDark : Colors.white70,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${date.day}',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13,
                  fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                  color: isToday ? JeevanColors.tealDark : Colors.white,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // Today's Journey Card
  Widget _buildJourneyCard() {
    final currentModule =
        _dashboardData?['currentModule'] as Map<String, dynamic>?;
    final progress = _dashboardData?['progress'] as Map<String, dynamic>?;
    final todayActivity =
        _dashboardData?['todayActivity'] as Map<String, dynamic>?;

    final completed = (progress?['completedActivities'] as num?)?.toInt() ?? 0;
    final total = (progress?['totalActivities'] as num?)?.toInt() ?? 25;
    final percent = total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;

    final moduleTitle = currentModule?['title'] as String? ??
        'Understanding Psychological Wellbeing';
    final moduleIcon = currentModule?['icon'] as String? ?? '🌱';

    return GlassCard(
      onTap: () {
        final modId = currentModule?['id'];
        if (modId != null) {
          context.push('/modules/$modId');
        } else {
          context.push('/journey');
        }
      },
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: JeevanColors.aqua.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(moduleIcon, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "TODAY'S JOURNEY",
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: JeevanColors.tealDark,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      moduleTitle,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: JeevanColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: JeevanColors.textSec,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$completed of $total activities complete',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12,
                  color: JeevanColors.textSec,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(percent * 100).round()}%',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: JeevanColors.tealDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              backgroundColor: JeevanColors.bgSec,
              valueColor: const AlwaysStoppedAnimation<Color>(
                JeevanColors.tealDark,
              ),
            ),
          ),
          if (todayActivity != null) ...[
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () {
                final actId = todayActivity['id'];
                if (actId != null) {
                  context.push('/activities/$actId');
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.play_circle_fill,
                      color: JeevanColors.tealDark,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Next: ${todayActivity['title'] ?? 'Activity'}',
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: JeevanColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${todayActivity['estimatedMinutes'] ?? 5} min',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 11,
                        color: JeevanColors.textSec,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Two Activity Cards in a Row (Breathing + Study)
  Widget _buildActivityRow() {
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            onTap: () => context.push('/stress'),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: JeevanColors.success.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('🧘', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Breathe & Calm',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: JeevanColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '3-min relaxation',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    color: JeevanColors.textSec,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: GlassCard(
            onTap: () => context.push('/study'),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: JeevanColors.warning.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Text('📖', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Focus Study',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: JeevanColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Active recall',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 12,
                    color: JeevanColors.textSec,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Goal Card
  Widget _buildGoalCard() {
    final todayGoal = _dashboardData?['todayGoal'] as Map<String, dynamic>?;
    final hasGoal =
        todayGoal != null && (todayGoal['goal'] as String?)?.isNotEmpty == true;

    return GlassCard(
      onTap: () => context.push('/goals'),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: JeevanColors.aquaLight.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: const Text('🎯', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'WEEKLY GOAL',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: JeevanColors.tealDark,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasGoal
                      ? (todayGoal['goal'] as String)
                      : 'Set your clinical focus goal',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: JeevanColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (hasGoal &&
                    (todayGoal['firstStep'] as String?)?.isNotEmpty ==
                        true) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Next: ${todayGoal['firstStep']}',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      color: JeevanColors.textSec,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: JeevanColors.textSec,
          ),
        ],
      ),
    );
  }

  // Feeling Check-in Row
  Widget _buildFeelingCheckIn() {
    const feelingIcons = {
      'Calm': '😌',
      'Hopeful': '✨',
      'Tired': '😴',
      'Anxious': '😰',
      'Focused': '🎯',
      'Overwhelmed': '🌊',
    };

    return GlassCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How are you feeling today?',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: JeevanColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: AppConstants.feelingLabels.map((label) {
                final isSelected = _selectedFeeling == label;
                final icon = feelingIcons[label] ?? '🌱';

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () async {
                      setState(() => _selectedFeeling = label);
                      try {
                        await ApiService.post('/checkins', {'feeling': label});
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Checked in: $label $icon'),
                            duration: const Duration(seconds: 2),
                            backgroundColor: JeevanColors.tealDark,
                          ),
                        );
                      } catch (_) {}
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? JeevanColors.tealDark
                            : Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? JeevanColors.tealDark
                              : Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(icon, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            label,
                            style: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : JeevanColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compatibility alias for router
typedef HomeBody = HomeScreen;
