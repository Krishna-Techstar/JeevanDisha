import 'package:flutter/material.dart';

/// Design tokens — never hardcode colors outside this file.
class JeevanColors {
  JeevanColors._();

  static const bgMain = Color(0xFFE8F5F7);
  static const bgSec = Color(0xFFD6EFF2);
  static const aqua = Color(0xFF79C9D6);
  static const aquaLight = Color(0xFFA8DDE6);
  static const tealDark = Color(0xFF075B66);
  static const tealDeep = Color(0xFF064A53);
  static const success = Color(0xFF65BFA5);
  static const warning = Color(0xFFE9B86A);
  static const textPrimary = Color(0xFF123B40);
  static const textSec = Color(0xFF5E8690);
  static const glass = Color(0x99FFFFFF); // 60% white
  static const glassBorder = Color(0xB3FFFFFF); // 70% white
}

class JeevanTheme {
  JeevanTheme._();

  static ThemeData get() => ThemeData(
        useMaterial3: true,
        fontFamily: 'Manrope',
        scaffoldBackgroundColor: JeevanColors.bgMain,
        colorScheme: const ColorScheme.light(
          primary: JeevanColors.tealDark,
          onPrimary: Colors.white,
          secondary: JeevanColors.aqua,
          onSecondary: JeevanColors.tealDeep,
          surface: JeevanColors.bgMain,
          onSurface: JeevanColors.textPrimary,
          error: Color(0xFFD9534F),
          onError: Colors.white,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w800,
            color: JeevanColors.textPrimary,
            letterSpacing: -1.2,
          ),
          displayMedium: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            color: JeevanColors.textPrimary,
          ),
          headlineLarge: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            color: JeevanColors.textPrimary,
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            color: JeevanColors.textPrimary,
            fontSize: 28,
          ),
          headlineSmall: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            color: JeevanColors.textPrimary,
            fontSize: 22,
          ),
          titleLarge: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w600,
            color: JeevanColors.textPrimary,
            fontSize: 18,
          ),
          titleMedium: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w600,
            color: JeevanColors.textPrimary,
            fontSize: 16,
          ),
          titleSmall: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w600,
            color: JeevanColors.textPrimary,
            fontSize: 14,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w400,
            color: JeevanColors.textPrimary,
            height: 1.45,
            fontSize: 16,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w400,
            color: JeevanColors.textSec,
            height: 1.45,
            fontSize: 14,
          ),
          bodySmall: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w400,
            color: JeevanColors.textSec,
            fontSize: 12,
          ),
          labelLarge: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w600,
            color: JeevanColors.textPrimary,
            letterSpacing: 0.2,
          ),
          labelSmall: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w500,
            color: JeevanColors.textSec,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          foregroundColor: JeevanColors.textPrimary,
          titleTextStyle: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: JeevanColors.textPrimary,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: JeevanColors.glass,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: JeevanColors.aqua.withValues(alpha: 0.45),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: JeevanColors.aqua.withValues(alpha: 0.45),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: JeevanColors.tealDark,
              width: 1.6,
            ),
          ),
          hintStyle: const TextStyle(
            fontFamily: 'Manrope',
            color: JeevanColors.textSec,
          ),
          labelStyle: const TextStyle(
            fontFamily: 'Manrope',
            color: JeevanColors.textSec,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: JeevanColors.tealDark,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: JeevanColors.tealDark,
            textStyle: const TextStyle(
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: JeevanColors.glass,
          selectedColor: JeevanColors.tealDark,
          labelStyle: const TextStyle(fontFamily: 'Manrope'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
}

/// Soft gradient + translucent blobs so [GlassCard] blur has something to sample.
class Blob extends StatelessWidget {
  const Blob({
    super.key,
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}

/// App-wide atmospheric background: gradient + blobs (required for glass).
class JeevanBackground extends StatelessWidget {
  const JeevanBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  JeevanColors.bgMain,
                  JeevanColors.bgSec,
                  Color(0xFFEAF8F4),
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          top: -90,
          right: -50,
          child: Blob(
            size: 240,
            color: JeevanColors.aqua.withValues(alpha: 0.35),
          ),
        ),
        Positioned(
          bottom: 60,
          left: -70,
          child: Blob(
            size: 200,
            color: JeevanColors.success.withValues(alpha: 0.22),
          ),
        ),
        Positioned(
          top: 220,
          left: 40,
          child: Blob(
            size: 110,
            color: JeevanColors.warning.withValues(alpha: 0.16),
          ),
        ),
        Positioned(
          bottom: 220,
          right: -30,
          child: Blob(
            size: 140,
            color: JeevanColors.tealDark.withValues(alpha: 0.10),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

/// @Deprecated — use [JeevanBackground]
typedef AtmosphereBackground = JeevanBackground;
