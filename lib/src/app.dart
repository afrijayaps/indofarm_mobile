import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'application/auth/auth_controller.dart';
import 'application/auth/auth_state.dart';
import 'application/theme/theme_controller.dart';
import 'core/theme/app_theme.dart';
import 'presentation/auth/login_screen.dart';
import 'presentation/common/home_screen.dart';
import 'presentation/common/splash_screen.dart';

class IndoFarmApp extends ConsumerWidget {
  const IndoFarmApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final selectedPreset = ref.watch(themeControllerProvider);
    final themeBundle = AppTheme.bundleFor(selectedPreset);

    return MaterialApp(
      title: 'IndoFarm',
      debugShowCheckedModeBanner: false,
      theme: themeBundle.theme,
      darkTheme: themeBundle.darkTheme,
      themeMode: themeBundle.mode,
      home: switch (authState.status) {
        AuthStatus.initializing => const SplashScreen(),
        AuthStatus.authenticated => const HomeScreen(),
        AuthStatus.unauthenticated => const LoginScreen(),
      },
    );
  }
}
