import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';

class ThemeStorage {
  static const _presetKey = 'app_theme_preset';

  Future<AppThemePreset> read() async {
    final prefs = await SharedPreferences.getInstance();
    final rawValue = prefs.getString(_presetKey);
    for (final preset in AppThemePreset.values) {
      if (preset.name == rawValue) {
        return preset;
      }
    }
    return AppTheme.defaultPreset;
  }

  Future<void> write(AppThemePreset preset) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_presetKey, preset.name);
  }
}
