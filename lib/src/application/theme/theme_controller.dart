import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../providers.dart';

class ThemeController extends StateNotifier<AppThemePreset> {
  ThemeController(this._ref) : super(AppTheme.defaultPreset) {
    _restore();
  }

  final Ref _ref;
  bool _hasLocalSelection = false;

  Future<void> _restore() async {
    final restoredPreset = await _ref.read(themeStorageProvider).read();
    if (_hasLocalSelection || !mounted) {
      return;
    }
    state = restoredPreset;
  }

  Future<void> selectPreset(AppThemePreset preset) async {
    if (state == preset) {
      return;
    }

    _hasLocalSelection = true;
    state = preset;
    await _ref.read(themeStorageProvider).write(preset);
  }
}

final themeControllerProvider =
    StateNotifierProvider<ThemeController, AppThemePreset>(
      (ref) => ThemeController(ref),
    );
