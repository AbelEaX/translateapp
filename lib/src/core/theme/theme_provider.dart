import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themePrefKey = 'theme_preference';
  final SharedPreferences _prefs;

  ThemeMode _themeMode;

  ThemeProvider(this._prefs) : _themeMode = ThemeMode.system {
    _loadThemePreference();
  }

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      // It's tricky to get system brightness here without context,
      // but usually the UI relies on `themeMode` and MaterialApp handles it.
      // For toggle UI consistency, we'll try to guess or just return false.
      // A better approach relies on `MediaQuery.of(context).platformBrightness`.
      return false;
    }
    return _themeMode == ThemeMode.dark;
  }

  void _loadThemePreference() {
    final String? themeStr = _prefs.getString(_themePrefKey);
    if (themeStr != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.name == themeStr,
        orElse: () => ThemeMode.system,
      );
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    await _prefs.setString(_themePrefKey, mode.name);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light || _themeMode == ThemeMode.system) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }
}
