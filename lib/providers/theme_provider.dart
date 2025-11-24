import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeColor {
  red(Colors.red, 'Red'),
  blue(Colors.blue, 'Blue'),
  green(Colors.green, 'Green'),
  purple(Colors.purple, 'Purple'),
  orange(Colors.orange, 'Orange'),
  teal(Colors.teal, 'Teal'),
  pink(Colors.pink, 'Pink'),
  indigo(Colors.indigo, 'Indigo');

  const AppThemeColor(this.color, this.label);
  final Color color;
  final String label;
}

class ThemeNotifier extends Notifier<AppThemeColor> {
  static const _key = 'theme_color';

  @override
  AppThemeColor build() {
    _loadTheme();
    return AppThemeColor.red; // default
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final colorName = prefs.getString(_key);
    if (colorName != null) {
      final theme = AppThemeColor.values.firstWhere(
        (t) => t.name == colorName,
        orElse: () => AppThemeColor.red,
      );
      state = theme;
    }
  }

  Future<void> setTheme(AppThemeColor theme) async {
    state = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, theme.name);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, AppThemeColor>(() {
  return ThemeNotifier();
});
