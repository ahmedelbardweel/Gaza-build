import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../shared/services/local_storage_service.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const String _storageKey = 'app_theme_mode';

  ThemeCubit() : super(_loadInitialTheme());

  static ThemeMode _loadInitialTheme() {
    final savedMode = LocalStorageService.instance.getString(_storageKey);
    switch (savedMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    String modeString;
    switch (mode) {
      case ThemeMode.light:
        modeString = 'light';
        break;
      case ThemeMode.dark:
        modeString = 'dark';
        break;
      case ThemeMode.system:
        modeString = 'system';
        break;
    }

    await LocalStorageService.instance.setString(_storageKey, modeString);
    emit(mode);
  }

  Future<void> toggleTheme(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }
}
