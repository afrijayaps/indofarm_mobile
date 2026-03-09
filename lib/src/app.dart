import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'application/auth/auth_controller.dart';
import 'application/auth/auth_state.dart';
import 'presentation/auth/login_screen.dart';
import 'presentation/common/home_screen.dart';
import 'presentation/common/splash_screen.dart';

class IndoFarmApp extends ConsumerWidget {
  const IndoFarmApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final baseTextTheme = GoogleFonts.spaceGroteskTextTheme();

    return MaterialApp(
      title: 'IndoFarm',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFFFFB700),
          secondary: Color(0xFF4D3F1A),
          surface: Color(0xFFFFFFFF),
          onPrimary: Color(0xFF231D0F),
          onSurface: Color(0xFF181818),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F8F5),
        textTheme: baseTextTheme,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFFB700), width: 1.2),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFB700),
          secondary: Color(0xFFFFD166),
          surface: Color(0xFF2A2212),
          onPrimary: Color(0xFF231D0F),
          onSurface: Color(0xFFF2F2EE),
        ),
        scaffoldBackgroundColor: const Color(0xFF231D0F),
        textTheme: baseTextTheme.apply(bodyColor: const Color(0xFFF2F2EE)),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2A2212),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0x4DFFB700)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0x4DFFB700)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFFB700), width: 1.2),
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF2A2212),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      themeMode: ThemeMode.system,
      home: switch (authState.status) {
        AuthStatus.initializing => const SplashScreen(),
        AuthStatus.authenticated => const HomeScreen(),
        AuthStatus.unauthenticated => const LoginScreen(),
      },
    );
  }
}
