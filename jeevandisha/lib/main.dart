import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants.dart';
import 'core/router.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: JeevanDishaApp()));
}

class JeevanDishaApp extends ConsumerWidget {
  const JeevanDishaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ensure auth bootstrap can run early for restore; splash also calls it.
    ref.watch(authProvider);
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: JeevanTheme.get(),
      routerConfig: router,
    );
  }
}
