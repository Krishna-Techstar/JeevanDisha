import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../services/auth_service.dart';
import '../widgets/glass_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _error = 'Please enter both email and password';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await AuthService.login(email, password);
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Base background color
          Container(
            width: double.infinity,
            height: double.infinity,
            color: JeevanColors.bgMain,
          ),

          // Three positioned blurred circular blob containers
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

          // Foreground
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back arrow to "/welcome"
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: JeevanColors.tealDeep,
                      size: 26,
                    ),
                    onPressed: () => context.go('/welcome'),
                  ),
                  const SizedBox(height: 24),

                  // Heading
                  const Text(
                    'Welcome back 👋',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: JeevanColors.tealDeep,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  const Text(
                    'Sign in to continue',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 16,
                      color: JeevanColors.textSec,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Email input in GlassCard
                  GlassCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    borderRadius: 18,
                    child: TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        color: JeevanColors.textPrimary,
                        fontSize: 15,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        hintText: 'Email address',
                        hintStyle: TextStyle(
                          fontFamily: 'Manrope',
                          color: JeevanColors.textSec,
                          fontSize: 15,
                        ),
                        icon: Icon(
                          Icons.email_outlined,
                          color: JeevanColors.tealDark,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password input in GlassCard
                  GlassCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    borderRadius: 18,
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        color: JeevanColors.textPrimary,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        hintText: 'Password',
                        hintStyle: const TextStyle(
                          fontFamily: 'Manrope',
                          color: JeevanColors.textSec,
                          fontSize: 15,
                        ),
                        icon: const Icon(
                          Icons.lock_outline,
                          color: JeevanColors.tealDark,
                          size: 22,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: JeevanColors.textSec,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Error message
                  if (_error != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 16),
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],

                  // Elevated Button "Sign In"
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: JeevanColors.tealDark,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Sign In',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // TextButton below
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/register'),
                      child: const Text(
                        "Don't have an account? Create one",
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: JeevanColors.tealDark,
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
    );
  }
}
