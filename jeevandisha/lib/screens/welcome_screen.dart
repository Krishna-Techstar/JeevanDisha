import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Hero Area
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFE1F4F7),
                    Color(0xFFC8ECF1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Floating decoration circle 1
                  Positioned(
                    top: 54,
                    left: 32,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: JeevanColors.aqua.withValues(alpha: 0.20),
                      ),
                    ),
                  ),

                  // Floating decoration circle 2
                  Positioned(
                    top: 130,
                    right: 28,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: JeevanColors.aqua.withValues(alpha: 0.20),
                      ),
                    ),
                  ),

                  // Floating decoration circle 3
                  Positioned(
                    bottom: 48,
                    left: 44,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: JeevanColors.aqua.withValues(alpha: 0.20),
                      ),
                    ),
                  ),

                  // Centered large circle with multi-layered shadows
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFD0EEF2),
                            boxShadow: [
                              BoxShadow(
                                color: JeevanColors.aqua.withValues(alpha: 0.35),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.8),
                                blurRadius: 20,
                                spreadRadius: -5,
                              ),
                              BoxShadow(
                                color: JeevanColors.tealDark
                                    .withValues(alpha: 0.12),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            '🌸',
                            style: TextStyle(
                              fontSize: 90,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Content Section
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Heading "Your wellbeing journey starts here" 30px fontWeight 800 color tealDeep lineHeight 1.18
                const Text(
                  'Your wellbeing journey starts here',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: JeevanColors.tealDeep,
                    height: 1.18,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 10),

                // Subtitle: 14px color textSec fontWeight 500 lineHeight 1.6
                const Text(
                  'A structured 6-week program for nursing students — building resilience, study skills, and emotional strength.',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 14,
                    color: JeevanColors.textSec,
                    fontWeight: FontWeight.w500,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 28),

                // Full-width pill-shaped "Get Started →" button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => context.go('/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: JeevanColors.tealDark,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: const StadiumBorder(),
                    ),
                    child: const Text(
                      'Get Started →',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // "Already have an account? Sign in" TextButton
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text(
                      'Already have an account? Sign in',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: JeevanColors.textSec,
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
}
