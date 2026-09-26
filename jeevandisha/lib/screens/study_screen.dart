import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/api_service.dart';
import '../widgets/glass_card.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  int _seconds = 1500; // 25 minutes
  bool _running = false;
  Timer? _timer;

  final TextEditingController _topicController = TextEditingController(
    text: 'Clinical Pharmacology Review',
  );
  final List<TextEditingController> _recallControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  String? _sessionId;
  bool _sessionStarted = false;
  bool _submitting = false;

  @override
  void dispose() {
    _timer?.cancel();
    _topicController.dispose();
    for (final c in _recallControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    if (_running) return;
    _timer?.cancel();
    setState(() {
      _running = true;
      _sessionStarted = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_seconds > 0) {
        setState(() {
          _seconds--;
        });
      }
      if (_seconds == 0) {
        timer.cancel();
        setState(() {
          _running = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session complete!'),
            backgroundColor: JeevanColors.tealDark,
          ),
        );
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _running = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _seconds = 1500;
      _sessionId = null;
      _sessionStarted = false;
    });
  }

  String _formatTime() {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _handleCompleteSession() async {
    final topic = _topicController.text.trim().isNotEmpty
        ? _topicController.text.trim()
        : 'Clinical Pharmacology Review';

    final p1 = _recallControllers[0].text.trim();
    final p2 = _recallControllers[1].text.trim();
    final p3 = _recallControllers[2].text.trim();

    final recallPoints = [
      p1.isNotEmpty ? p1 : 'Key takeaway 1',
      p2.isNotEmpty ? p2 : 'Key takeaway 2',
      p3.isNotEmpty ? p3 : 'Key takeaway 3',
    ];

    setState(() {
      _submitting = true;
    });

    try {
      // 1) Start session if not already started to get sessionId
      String? currentSessionId = _sessionId;
      if (currentSessionId == null) {
        final startRes = await ApiService.post('/study/start', {
          'topic': topic,
        });
        if (startRes is Map) {
          currentSessionId = (startRes['sessionId'] ??
                  startRes['id'] ??
                  startRes['session']?['id'] ??
                  startRes['session']?['_id'])
              ?.toString();
          _sessionId = currentSessionId;
          _sessionStarted = true;
        }
      }

      // 2) Complete session with recall points
      if (currentSessionId != null) {
        await ApiService.post('/study/$currentSessionId/complete', {
          'recallPoints': recallPoints,
        });
      } else {
        await ApiService.post('/study', {
          'topic': topic,
          'recallPoints': recallPoints,
          'status': 'completed',
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Study session completed successfully!'),
          backgroundColor: JeevanColors.tealDark,
          duration: Duration(seconds: 3),
        ),
      );

      _resetTimer();
      for (final c in _recallControllers) {
        c.clear();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved: ${e.toString().replaceAll('Exception: ', '')}'),
          backgroundColor: JeevanColors.tealDark,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

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

          // Main Layout
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top Hero Container
                _buildHeroContainer(),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Topic Input Card
                        _buildTopicCard(),
                        const SizedBox(height: 16),

                        // Active Recall Card
                        _buildRecallCard(),
                        const SizedBox(height: 20),

                        // Complete Session Button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed:
                                _submitting ? null : _handleCompleteSession,
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
                                    'Complete Session',
                                    style: TextStyle(
                                      fontFamily: 'Manrope',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ],
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

  // Top hero: Container gradient tealDark to 0A7A88
  Widget _buildHeroContainer() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            JeevanColors.tealDark,
            Color(0xFF0A7A88),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x33075B66),
            blurRadius: 20,
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
        children: [
          // "STUDY SESSION" label 13px white60
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'STUDY SESSION',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 13,
                  color: Colors.white60,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              if (_sessionStarted) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _running ? 'IN PROGRESS' : 'PAUSED',
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),

          // Timer display "${_formatTime()}" 60px fontWeight 800 white
          Text(
            _formatTime(),
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 60,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 4),

          // Topic text below
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _topicController,
            builder: (context, value, _) {
              final topic = value.text.trim().isNotEmpty
                  ? value.text.trim()
                  : 'Focus sprint (25 min)';
              return Text(
                topic,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              );
            },
          ),
          const SizedBox(height: 22),

          // Row of two buttons (Start/Pause & Reset)
          Row(
            children: [
              // Start/Pause button (white bg, tealDark text)
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _running ? _pauseTimer : _startTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: JeevanColors.tealDark,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      _running ? 'Pause' : 'Start',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Reset button (white20 bg, white text)
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _resetTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.20),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Reset',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Topic input card
  Widget _buildTopicCard() {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Session Topic',
            style: TextStyle(
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
              controller: _topicController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                color: JeevanColors.textPrimary,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                hintText: 'e.g., Pharmacology - Antibiotics',
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

  // Active Recall GlassCard with heading, 3 recall TextFields with numbered aqua circle labels
  Widget _buildRecallCard() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Active Recall',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: JeevanColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Write 3 key points after your timer ends:',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13,
              color: JeevanColors.textSec,
            ),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < 3; i++) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  // Numbered aqua circle label 1/2/3
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: JeevanColors.aqua.withValues(alpha: 0.35),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: JeevanColors.tealDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // TextField
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      child: TextField(
                        controller: _recallControllers[i],
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          color: JeevanColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          hintText: i == 0
                              ? 'First key concept learned'
                              : i == 1
                                  ? 'Second core point'
                                  : 'Clinical application or takeaway',
                          hintStyle: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 13,
                            color: JeevanColors.textSec,
                          ),
                        ),
                      ),
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
}
