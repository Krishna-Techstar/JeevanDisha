import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _prn = TextEditingController();
  final _phone = TextEditingController();
  final _className = TextEditingController();
  final _division = TextEditingController();
  final _department = TextEditingController();
  final _specialization = TextEditingController();
  final _institution = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _prn.dispose();
    _phone.dispose();
    _className.dispose();
    _division.dispose();
    _department.dispose();
    _specialization.dispose();
    _institution.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final ok = await ref.read(authProvider.notifier).register(
          name: _name.text.trim(),
          email: _email.text.trim(),
          password: _password.text,
          prn: _prn.text.trim(),
          phone: _phone.text.trim(),
          className: _className.text.trim(),
          division: _division.text.trim(),
          department: _department.text.trim(),
          specialization: _specialization.text.trim(),
          institutionName: _institution.text.trim(),
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) {
      context.go('/home');
    } else {
      final err = ref.read(authProvider).error ?? 'Registration failed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return JeevanBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create account',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your college details help personalize the journey.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Enter email';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _prn,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'PRN',
                      hintText: 'Unique college PRN',
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Enter PRN' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Phone (optional)'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _className,
                          decoration: const InputDecoration(
                            labelText: 'Class',
                            hintText: 'SE',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _division,
                          decoration: const InputDecoration(
                            labelText: 'Division',
                            hintText: 'A',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _department,
                    decoration: const InputDecoration(
                      labelText: 'Department',
                      hintText: 'Computer Science & Engineering',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _specialization,
                    decoration: const InputDecoration(
                      labelText: 'Specialization',
                      hintText: 'AI & ML',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _institution,
                    decoration: const InputDecoration(
                      labelText: 'Institution',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.length < 4) {
                        return 'Password must be at least 4 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Create account'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () => context.pushReplacement('/login'),
                      child: const Text('Already have an account? Sign in'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
