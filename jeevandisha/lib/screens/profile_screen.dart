import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/loading_state.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  UserModel? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    final user = await AuthService.fetchUserProfile();
    if (!mounted) return;
    setState(() {
      _user = user;
      _loading = false;
    });
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Log Out',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w800,
            color: JeevanColors.tealDeep,
          ),
        ),
        content: const Text(
          'Are you sure you want to log out of JeevanDisha?',
          style: TextStyle(
            fontFamily: 'Manrope',
            color: JeevanColors.textSec,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(authProvider.notifier).logout();
      if (!mounted) return;
      context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _user ?? ref.watch(authProvider).user;
    if (_loading && user == null) {
      return const Scaffold(
        backgroundColor: JeevanColors.bgMain,
        body: LoadingState(message: 'Loading profile...'),
      );
    }
    final userName = user?.name.isNotEmpty == true ? user!.name : 'Nursing Student';
    final userEmail = user?.email.isNotEmpty == true ? user!.email : 'student@college.edu';
    final initial = userName.trim().isNotEmpty ? userName.trim()[0].toUpperCase() : 'S';

    return Scaffold(
      backgroundColor: JeevanColors.bgMain,
      body: Stack(
        children: [
          // Background atmospheric blur blobs
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

          // Main Scrollable Body
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Navigation Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white),
                            boxShadow: [
                              BoxShadow(
                                color: JeevanColors.tealDark.withValues(alpha: 0.08),
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
                      const Text(
                        'User Profile',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: JeevanColors.tealDeep,
                        ),
                      ),
                      const SizedBox(width: 42), // balancer
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Avatar & Identity Card
                  GlassCard(
                    padding: const EdgeInsets.all(22),
                    borderRadius: 24,
                    child: Row(
                      children: [
                        // Avatar Circle
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                JeevanColors.tealDark,
                                Color(0xFF0E8896),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: JeevanColors.tealDark.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            initial,
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 18),

                        // Name and Email
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: JeevanColors.tealDeep,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                userEmail,
                                style: const TextStyle(
                                  fontFamily: 'Manrope',
                                  fontSize: 13,
                                  color: JeevanColors.textSec,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: JeevanColors.aqua.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Week ${user?.currentWeek ?? 1} · Module ${user?.currentModule ?? 1}',
                                  style: const TextStyle(
                                    fontFamily: 'Manrope',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: JeevanColors.tealDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Academic Information Card
                  const Text(
                    'ACADEMIC DETAILS',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: JeevanColors.textSec,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 10),

                  GlassCard(
                    padding: const EdgeInsets.all(18),
                    borderRadius: 22,
                    child: Column(
                      children: [
                        _buildInfoRow(
                          icon: Icons.badge_outlined,
                          label: 'PRN / Roll No',
                          value: user?.prn.isNotEmpty == true ? user!.prn : 'Not specified',
                        ),
                        const Divider(height: 20, color: Color(0x1F075B66)),
                        _buildInfoRow(
                          icon: Icons.school_outlined,
                          label: 'Class & Division',
                          value: '${user?.className.isNotEmpty == true ? user!.className : "Nursing"} ${user?.division.isNotEmpty == true ? "Div ${user!.division}" : ""}',
                        ),
                        const Divider(height: 20, color: Color(0x1F075B66)),
                        _buildInfoRow(
                          icon: Icons.local_hospital_outlined,
                          label: 'Department',
                          value: user?.department.isNotEmpty == true ? user!.department : 'Nursing Education & Clinical Practice',
                        ),
                        if (user?.specialization.isNotEmpty == true) ...[
                          const Divider(height: 20, color: Color(0x1F075B66)),
                          _buildInfoRow(
                            icon: Icons.star_border_rounded,
                            label: 'Specialization',
                            value: user!.specialization,
                          ),
                        ],
                        if (user?.institutionName.isNotEmpty == true) ...[
                          const Divider(height: 20, color: Color(0x1F075B66)),
                          _buildInfoRow(
                            icon: Icons.account_balance_outlined,
                            label: 'Institution',
                            value: user!.institutionName,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Settings / Program Card
                  const Text(
                    'PROGRAM & SUPPORT',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: JeevanColors.textSec,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 10),

                  GlassCard(
                    padding: const EdgeInsets.all(18),
                    borderRadius: 22,
                    child: Column(
                      children: [
                        _buildActionRow(
                          icon: Icons.support_agent_rounded,
                          title: 'Emergency & Counselor Helpline',
                          onTap: () => context.push('/support'),
                        ),
                        const Divider(height: 20, color: Color(0x1F075B66)),
                        _buildActionRow(
                          icon: Icons.spa_outlined,
                          title: 'Stress Reset Toolkit',
                          onTap: () => context.push('/stress'),
                        ),
                        const Divider(height: 20, color: Color(0x1F075B66)),
                        _buildActionRow(
                          icon: Icons.info_outline_rounded,
                          title: 'About JEEVANDISHA (v1.0.0)',
                          onTap: () {
                            showAboutDialog(
                              context: context,
                              applicationName: 'JEEVANDISHA',
                              applicationVersion: '1.0.0',
                              applicationLegalese: 'Psychological wellbeing and study resilience companion for nursing students.',
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _handleLogout,
                      icon: const Icon(Icons.logout_rounded, size: 20),
                      label: const Text(
                        'Log Out',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
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

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: JeevanColors.tealDark, size: 20),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: JeevanColors.textSec,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: JeevanColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: JeevanColors.tealDark, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: JeevanColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: JeevanColors.textSec,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
