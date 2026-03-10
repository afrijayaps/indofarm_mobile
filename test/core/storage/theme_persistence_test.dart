import 'package:flutter_test/flutter_test.dart';
import 'package:indofarm_mobile/src/core/storage/session_storage.dart';
import 'package:indofarm_mobile/src/core/storage/theme_storage.dart';
import 'package:indofarm_mobile/src/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Theme persistence', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('uses Gold Light as default preset', () async {
      final themeStorage = ThemeStorage();

      final preset = await themeStorage.read();

      expect(preset, AppThemePreset.goldLight);
    });

    test('logout session clear does not remove saved theme preset', () async {
      SharedPreferences.setMockInitialValues({
        'auth_session': '{"token":"abc"}',
        'app_theme_preset': AppThemePreset.googleJoy.name,
      });
      final sessionStorage = SessionStorage();
      final prefs = await SharedPreferences.getInstance();

      await sessionStorage.clear();

      expect(prefs.getString('auth_session'), isNull);
      expect(
        prefs.getString('app_theme_preset'),
        AppThemePreset.googleJoy.name,
      );
    });
  });
}
