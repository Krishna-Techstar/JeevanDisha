import 'package:flutter/material.dart';

import '../core/theme.dart';

class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.message = 'Loading...'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: JeevanColors.aqua,
            strokeWidth: 3,
          ),
          const SizedBox(height: 14),
          Text(
            message,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: JeevanColors.textSec,
            ),
          ),
        ],
      ),
    );
  }
}
