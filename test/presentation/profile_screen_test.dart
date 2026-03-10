import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indofarm_mobile/src/application/auth/auth_controller.dart';
import 'package:indofarm_mobile/src/application/auth/auth_state.dart';
import 'package:indofarm_mobile/src/application/theme/theme_controller.dart';
import 'package:indofarm_mobile/src/core/theme/app_theme.dart';
import 'package:indofarm_mobile/src/domain/models/app_user.dart';
import 'package:indofarm_mobile/src/domain/models/auth_session.dart';
import 'package:indofarm_mobile/src/presentation/profile/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAuthController extends StateNotifier<AuthState>
    implements AuthController {
  _FakeAuthController(AuthState state) : super(state);

  @override
  Future<void> bootstrap() async {}

  @override
  Future<void> login({required String email, required String password}) async {}

  @override
  Future<void> logout() async {}
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('profile screen lets user switch theme preset', (tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final fakeAuth = _FakeAuthController(
      AuthState.authenticated(
        AuthSession(
          token: 'token',
          tokenType: 'Bearer',
          user: const AppUser(
            id: 7,
            name: 'Budi',
            email: 'budi@indofarm.test',
            role: 'owner',
          ),
        ),
      ),
    );

    final container = ProviderContainer(
      overrides: [authControllerProvider.overrideWith((ref) => fakeAuth)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.dynamicDarkTheme,
          home: const Scaffold(body: ProfileScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Gold Dark'), findsOneWidget);
    expect(find.text('Gold Light'), findsOneWidget);
    expect(find.text('Google Clean'), findsOneWidget);
    expect(container.read(themeControllerProvider), AppThemePreset.goldDark);

    await tester.tap(find.text('Google Clean'));
    await tester.pumpAndSettle();

    expect(container.read(themeControllerProvider), AppThemePreset.googleClean);

    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getString('app_theme_preset'),
      AppThemePreset.googleClean.name,
    );
  });
}
