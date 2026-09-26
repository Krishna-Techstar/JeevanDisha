import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../services/api_service.dart';
import '../widgets/glass_card.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key, required this.activityId});

  final String activityId;

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  Map<String, dynamic>? _activity;
  final Map<String, dynamic> _responses = {};
  bool _loading = true;
  bool _submitting = false;
  int? _selectedOption;

  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _loadActivity();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _getController(String key, [String initialText = '']) {
    return _controllers.putIfAbsent(
      key,
      () => TextEditingController(text: initialText),
    );
  }

  Future<void> _loadActivity() async {
    setState(() {
      _loading = true;
    });

    try {
      final response = await ApiService.get('/activities/${widget.activityId}');
      if (!mounted) return;

      final data = response is Map<String, dynamic>
          ? response
          : Map<String, dynamic>.from(response as Map);
      final act = data['activity'] is Map
          ? Map<String, dynamic>.from(data['activity'] as Map)
          : data;

      setState(() {
        _activity = act;
        _loading = false;
      });

      // Call start endpoint in background
      try {
        await ApiService.post('/activities/${widget.activityId}/start', {});
      } catch (_) {}
    } catch (e) {
      if (!mounted) return;
      // Fallback demo activity if offline/error
      setState(() {
        _activity = _getDemoActivity(widget.activityId);
        _loading = false;
      });
    }
  }

  Future<void> _handleComplete() async {
    setState(() {
      _submitting = true;
    });

    try {
      await ApiService.post(
        '/activities/${widget.activityId}/complete',
        _responses,
      );
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _submitting = false;
    });
    context.pop();
  }

  int _getTypeStepIndex(String type) {
    switch (type.toLowerCase()) {
      case 'learn':
        return 0;
      case 'understand':
        return 1;
      case 'practice':
        return 2;
      case 'reflect':
        return 3;
      case 'apply':
        return 4;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = _activity?['type']?.toString() ?? 'learn';
    final currentStep = _getTypeStepIndex(type);
    final title = _activity?['title']?.toString() ?? 'Activity';

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
            child: Column(
              children: [
                // Top Navigation Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: JeevanColors.tealDeep,
                          size: 20,
                        ),
                        onPressed: () => context.pop(),
                      ),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: JeevanColors.tealDeep,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // 5-dot Step Indicator
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: _buildStepIndicator(currentStep),
                ),
                const SizedBox(height: 12),

                // Scrollable Content
                if (_loading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: JeevanColors.tealDark,
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      child: _buildTypeContent(type),
                    ),
                  ),

                // Bottom "Continue →" Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _handleComplete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: JeevanColors.tealDark,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Continue →',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
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

  Widget _buildStepIndicator(int currentStep) {
    const steps = ['Learn', 'Understand', 'Practice', 'Reflect', 'Apply'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(steps.length, (index) {
        final isDone = index < currentStep;
        final isCurrent = index == currentStep;

        final Color color = isDone
            ? JeevanColors.success
            : isCurrent
                ? JeevanColors.tealDark
                : JeevanColors.bgSec;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Column(
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color:
                                  JeevanColors.tealDark.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  steps[index],
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 10,
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                    color: isCurrent
                        ? JeevanColors.tealDark
                        : isDone
                            ? JeevanColors.success
                            : JeevanColors.textSec,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTypeContent(String type) {
    switch (type.toLowerCase()) {
      case 'learn':
        return _buildLearnContent();
      case 'understand':
        return _buildUnderstandContent();
      case 'practice':
        return _buildPracticeContent();
      case 'reflect':
        return _buildReflectContent();
      case 'apply':
        return _buildApplyContent();
      default:
        return _buildLearnContent();
    }
  }

  // TYPE "learn"
  Widget _buildLearnContent() {
    final learn = _activity?['learnContent'] is Map
        ? Map<String, dynamic>.from(_activity!['learnContent'] as Map)
        : <String, dynamic>{};

    final heading = learn['heading']?.toString() ??
        'Understanding Psychological Wellbeing';
    final body = learn['body']?.toString() ??
        'Psychological wellbeing in nursing is about emotional balance, self-compassion, and stress regulation during challenging shifts.';
    final keyIdea = learn['keyIdea']?.toString() ??
        'Acknowledging stress early prevents clinical burnout and protects patient care.';

    return GlassCard(
      padding: const EdgeInsets.all(22),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heading (20px bold)
          Text(
            heading,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: JeevanColors.textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 14),

          // Body (14px textSec)
          Text(
            body,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14,
              color: JeevanColors.textSec,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 22),

          // KeyIdeaBox Container (aqua-tinted with "💡 KEY IDEA" label)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: JeevanColors.aqua.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: JeevanColors.aqua.withValues(alpha: 0.45),
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      '💡 KEY IDEA',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: JeevanColors.tealDark,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  keyIdea,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: JeevanColors.tealDeep,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // TYPE "understand"
  Widget _buildUnderstandContent() {
    final understand = _activity?['understandContent'] is Map
        ? Map<String, dynamic>.from(_activity!['understandContent'] as Map)
        : <String, dynamic>{};

    final scenario = understand['scenario']?.toString() ??
        'During a busy ICU night shift, you notice severe fatigue and high anxiety regarding medication dispensing. What is the most adaptive response?';
    final optionsList = understand['options'] as List<dynamic>? ??
        [
          {
            'text':
                'Pause for a 60-second breathing reset and double-check with the head nurse.',
            'isCorrect': true,
          },
          {
            'text':
                'Ignore the fatigue and rush through to finish the round faster.',
            'isCorrect': false,
          },
        ];

    final explanation = understand['explanation']?.toString() ??
        'Taking a brief pause prevents error cascades and activates your parasympathetic nervous system.';

    return GlassCard(
      padding: const EdgeInsets.all(22),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Clinical Scenario',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: JeevanColors.tealDark,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            scenario,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: JeevanColors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          // Two tappable option cards
          for (int i = 0; i < optionsList.length; i++) ...[
            Builder(
              builder: (context) {
                final option = optionsList[i] is Map
                    ? Map<String, dynamic>.from(optionsList[i])
                    : {'text': optionsList[i].toString(), 'isCorrect': false};
                final isSelected = _selectedOption == i;
                final isCorrect = option['isCorrect'] == true;

                Color bg = Colors.white.withValues(alpha: 0.65);
                Color border = Colors.white.withValues(alpha: 0.9);
                Color textColor = JeevanColors.textPrimary;

                if (isSelected) {
                  if (isCorrect) {
                    bg = JeevanColors.success.withValues(alpha: 0.18);
                    border = JeevanColors.success;
                    textColor = const Color(0xFF1B5E20);
                  } else {
                    bg = Colors.red.withValues(alpha: 0.12);
                    border = Colors.redAccent;
                    textColor = const Color(0xFFB71C1C);
                  }
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedOption = i;
                        _responses['selectedOption'] = i;
                        _responses['isCorrect'] = isCorrect;
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: border, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? (isCorrect
                                      ? JeevanColors.success
                                      : Colors.redAccent)
                                  : JeevanColors.bgSec,
                            ),
                            alignment: Alignment.center,
                            child: isSelected
                                ? Icon(
                                    isCorrect ? Icons.check : Icons.close,
                                    color: Colors.white,
                                    size: 18,
                                  )
                                : Text(
                                    String.fromCharCode(65 + i),
                                    style: const TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: JeevanColors.tealDeep,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              option['text']?.toString() ?? '',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],

          // Explanation card shown after selection
          if (_selectedOption != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: JeevanColors.aqua.withValues(alpha: 0.6),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: JeevanColors.tealDark,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Explanation',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: JeevanColors.tealDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    explanation,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 13,
                      color: JeevanColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // TYPE "practice"
  Widget _buildPracticeContent() {
    final fields = _activity?['practiceFields'] as List<dynamic>? ??
        [
          {
            'label': 'What is currently causing you stress?',
            'placeholder': 'e.g., upcoming practical exam',
          },
          {
            'label': 'What is one thing within your control?',
            'placeholder': 'e.g., revising pharmacology flashcards today',
          },
          {
            'label': 'A supportive person you can reach out to',
            'placeholder': 'e.g., batch mentor or peer',
          },
        ];

    return GlassCard(
      padding: const EdgeInsets.all(22),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Practice Exercise',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: JeevanColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Fill in your reflections below:',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13,
              color: JeevanColors.textSec,
            ),
          ),
          const SizedBox(height: 18),
          for (final f in fields) ...[
            Builder(
              builder: (context) {
                final field = f is Map
                    ? Map<String, dynamic>.from(f)
                    : {'label': f.toString(), 'placeholder': 'Type here...'};
                final label = field['label']?.toString() ?? 'Field';
                final placeholder = field['placeholder']?.toString() ?? '';
                final ctrl = _getController(label);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: JeevanColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        child: TextField(
                          controller: ctrl,
                          onChanged: (val) {
                            _responses[label] = val;
                          },
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 14,
                            color: JeevanColors.textPrimary,
                          ),
                          maxLines: 2,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(14),
                            hintText: placeholder,
                            hintStyle: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 13,
                              color: JeevanColors.textSec,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  // TYPE "reflect"
  Widget _buildReflectContent() {
    final questions = _activity?['reflectionQuestions'] as List<dynamic>? ??
        [
          'How did you cope with clinical pressure today?',
          'What is one positive experience you had with a patient or mentor?',
        ];

    return GlassCard(
      padding: const EdgeInsets.all(22),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Self-Reflection',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: JeevanColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Take a quiet moment to reflect on your experiences:',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13,
              color: JeevanColors.textSec,
            ),
          ),
          const SizedBox(height: 18),
          for (final q in questions) ...[
            Builder(
              builder: (context) {
                final question = q.toString();
                final ctrl = _getController(question);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: JeevanColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        child: TextField(
                          controller: ctrl,
                          onChanged: (val) {
                            _responses[question] = val;
                          },
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 14,
                            color: JeevanColors.textPrimary,
                          ),
                          maxLines: 3,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(14),
                            hintText: 'Write your thoughts here…',
                            hintStyle: TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 13,
                              color: JeevanColors.textSec,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  // TYPE "apply"
  Widget _buildApplyContent() {
    final prompt = _activity?['applyPrompt']?.toString() ??
        'Write one concrete action you will implement on your next ward shift:';
    final ctrl = _getController('applyPrompt');

    return GlassCard(
      padding: const EdgeInsets.all(22),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Action Plan',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: JeevanColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            prompt,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: JeevanColors.textPrimary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
            ),
            child: TextField(
              controller: ctrl,
              onChanged: (val) {
                _responses['applyResponse'] = val;
              },
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                color: JeevanColors.textPrimary,
              ),
              maxLines: 5,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
                hintText: 'Write your specific action plan here…',
                hintStyle: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13,
                  color: JeevanColors.textSec,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getDemoActivity(String id) {
    return {
      'id': id,
      'title': 'The Stress Response in Clinical Practice',
      'type': 'learn',
      'order': 1,
      'estimatedMinutes': 5,
      'learnContent': {
        'heading': 'Stress as an Adaptive Signal',
        'body':
            'In clinical environments, stress is a natural biological response alerting you to critical situations. Recognizing bodily signs early protects your wellbeing.',
        'keyIdea':
            'Stress is not weakness — it is information your nervous system provides to guide mindful action.',
      },
    };
  }
}
