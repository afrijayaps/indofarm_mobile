import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indofarm_mobile/src/application/auth/auth_controller.dart';
import 'package:indofarm_mobile/src/application/auth/auth_state.dart';
import 'package:indofarm_mobile/src/presentation/auth/login_screen.dart';

class _FakeAuthController extends StateNotifier<AuthState>
    implements AuthController {
  _FakeAuthController() : super(const AuthState.unauthenticated());

  bool shouldFail = false;
  int loginCalls = 0;
  String? lastEmail;
  String? lastPassword;

  @override
  Future<void> bootstrap() async {}

  @override
  Future<void> login({required String email, required String password}) async {
    loginCalls += 1;
    lastEmail = email;
    lastPassword = password;
    state = const AuthState.initializing();
    if (shouldFail) {
      state = const AuthState.unauthenticated(error: 'Kredensial salah');
    }
  }

  @override
  Future<void> logout() async {}
}

void main() {
  testWidgets('login screen sends phone credentials to controller', (
    tester,
  ) async {
    final fakeAuth = _FakeAuthController();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authControllerProvider.overrideWith((ref) => fakeAuth)],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), '082212345678');
    await tester.enterText(find.byType(TextFormField).at(1), 'rahasia123');
    await tester.tap(find.text('Masuk'));
    await tester.pump();

    expect(fakeAuth.lastEmail, '+6282212345678');
    expect(fakeAuth.lastPassword, 'rahasia123');
  });

  testWidgets('login locks for 30 seconds after 5 failed attempts', (
    tester,
  ) async {
    final fakeAuth = _FakeAuthController()..shouldFail = true;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authControllerProvider.overrideWith((ref) => fakeAuth)],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), '82212345678');
    await tester.enterText(find.byType(TextFormField).at(1), 'salahpass');

    for (var i = 0; i < 5; i++) {
      await tester.tap(find.text('Masuk'));
      await tester.pump();
    }

    expect(fakeAuth.loginCalls, 5);
    expect(find.text('Tunggu 30 dtk'), findsOneWidget);
    expect(
      find.text('Terlalu banyak percobaan. Coba lagi dalam 30 detik.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Tunggu 30 dtk'));
    await tester.pump();
    expect(fakeAuth.loginCalls, 5);

    await tester.pump(const Duration(seconds: 31));
    await tester.pump();

    expect(find.text('Masuk'), findsOneWidget);
    final loginButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Masuk'),
    );
    expect(loginButton.onPressed, isNotNull);
  });
}
