import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../core/theme.dart';

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.percent,
    required this.label,
    this.progressColor = JeevanColors.aqua,
    this.backgroundColor = const Color(0x26FFFFFF),
    this.size = 72.0,
    this.lineWidth = 6.0,
  });

  final double percent;
  final String label;
  final Color progressColor;
  final Color backgroundColor;
  final double size;
  final double lineWidth;

  @override
  Widget build(BuildContext context) {
    final clampedPercent = percent.clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularPercentIndicator(
          percent: clampedPercent,
          radius: size / 2,
          lineWidth: lineWidth,
          animation: true,
          animationDuration: 1000,
          backgroundColor: backgroundColor,
          progressColor: progressColor,
          circularStrokeCap: CircularStrokeCap.round,
          center: Text(
            '${(clampedPercent * 100).toInt()}%',
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xB3FFFFFF),
          ),
        ),
      ],
    );
  }
}
