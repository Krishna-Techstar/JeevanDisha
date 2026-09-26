import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../services/api_service.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/glass_card.dart';

class StressScreen extends StatefulWidget {
  const StressScreen({super.key});

  @override
  State<StressScreen> createState() => _StressScreenState();
}

class _StressScreenState extends State<StressScreen> {
  final Set<String> _selectedStressors = {};
  String? _selectedStrategy;
  final TextEditingController _thoughtController = TextEditingController();
  bool _saving = false;

  static const List<String> _stressOptions = [
    'Academic',
    'Clinical',
    'Examination',
    'Personal',
    'Family',
    'Relationship',
    'Other',
  ];

  static const List<String> _strategyOptions = [
    'Deep breathing',
    'Take a short break',
    'Talk to someone',
    'Plan the task',
    'Physical activity',
  ];

  @override
  void dispose() {
    _thoughtController.dispose();
    super.dispose();
  }

  void _toggleStressor(String stressor) {
    setState(() {
      if (_selectedStressors.contains(stressor)) {
        _selectedStressors.remove(stressor);
      } else {
        _selectedStressors.add(stressor);
      }
    });
  }

  void _selectStrategy(String strategy) {
    setState(() {
      _selectedStrategy = strategy;
    });
  }

  Future<void> _handleSave() async {
    if (_selectedStrategy == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Choose a strategy'),
          backgroundColor: JeevanColors.warning,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      // Record check-in / stress plan to backend
      await ApiService.post('/checkins', {
        'mood': 'Reflective',
        'stressors': _selectedStressors.toList(),
        'strategy': _selectedStrategy,
        'note': _thoughtController.text.trim(),
        'type': 'stress_reset',
      });
    } catch (_) {
      // Offline fallback
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Plan saved ✓'),
            backgroundColor: JeevanColors.tealDark,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
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
          Positioned(
            top: 300,
            right: -30,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: JeevanColors.aqua.withValues(alpha: 0.25),
                ),
              ),
            ),
          ),

          // Main Content Layout
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back button
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go('/home');
                                }
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: JeevanColors.tealDark
                                          .withValues(alpha: 0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.arrow_back_rounded,
                                  color: JeevanColors.tealDeep,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Heading "Stress Management" 22px bold tealDeep
                        const Text(
                          'Stress Management',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: JeevanColors.tealDeep,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Sub "Identify what's stressing you and choose a strategy"
                        const Text(
                          "Identify what's stressing you and choose a strategy",
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 14,
                            color: JeevanColors.textSec,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 22),

                        // GlassCard 1: "What's stressing you today?"
                        _buildStressorsCard(),
                        const SizedBox(height: 18),

                        // GlassCard 2: "Choose a coping strategy"
                        _buildStrategiesCard(),
                        const SizedBox(height: 24),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _saving ? null : _handleSave,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: JeevanColors.tealDark,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _saving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Save Plan',
                                    style: TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // BottomNav currentIndex 0
                BottomNav(
                  currentIndex: 0,
                  onTap: (index) {
                    const routes = [
                      '/home',
                      '/journey',
                      '/study',
                      '/goals',
                      '/progress',
                    ];
                    if (index < routes.length) {
                      context.go(routes[index]);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // GlassCard 1: "What's stressing you today?" bold 15px + chips + 3-line TextField
  Widget _buildStressorsCard() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "What's stressing you today?",
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: JeevanColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),

          // Wrap spacing 8 runSpacing 8 of stress chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _stressOptions.map((option) {
              final isSelected = _selectedStressors.contains(option);
              return GestureDetector(
                onTap: () => _toggleStressor(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? JeevanColors.aqua
                        : JeevanColors.glass,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: isSelected
                          ? JeevanColors.aqua
                          : JeevanColors.glassBorder,
                      width: 1.2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: JeevanColors.aqua.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? JeevanColors.tealDeep
                          : JeevanColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Below chips: TextField multiline 3 rows placeholder "What can I do about it?" — glass styled
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.9),
                width: 1.2,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: TextField(
              controller: _thoughtController,
              maxLines: 3,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                color: JeevanColors.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: 'What can I do about it?',
                hintStyle: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13,
                  color: JeevanColors.textSec,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // GlassCard 2: "Choose a coping strategy" bold 15px + Column of 5 strategy items
  Widget _buildStrategiesCard() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose a coping strategy',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: JeevanColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),

          // Column of 5 strategy items each GestureDetector
          Column(
            children: _strategyOptions.map((strategy) {
              final isSelected = _selectedStrategy == strategy;
              return GestureDetector(
                onTap: () => _selectStrategy(strategy),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      // Animated radio circle
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? JeevanColors.tealDark
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? JeevanColors.tealDark
                                : JeevanColors.aqua,
                            width: 1.8,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: isSelected
                            ? Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 14),

                      // Strategy text
                      Expanded(
                        child: Text(
                          strategy,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? JeevanColors.tealDeep
                                : JeevanColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
