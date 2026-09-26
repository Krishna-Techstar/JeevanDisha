import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final loggedIn = await AuthService.isLoggedIn();
    if (!mounted) return;

    if (loggedIn) {
      context.go('/home');
    } else {
      context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF075B66),
              Color(0xFF0A8090),
              Color(0xFF79C9D6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '🌱',
                style: TextStyle(fontSize: 60),
              ),
              SizedBox(height: 16),
              Text(
                'JEEVANDISHA',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Understand Yourself. Manage Challenges.',
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 48),
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
