import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeColor {
  netflixRed(Color(0xFFE50914), 'Netflix Red'), // Netflix signature red
  blue(CupertinoColors.systemBlue, 'Blue'),
  green(CupertinoColors.systemGreen, 'Green'),
  purple(CupertinoColors.systemPurple, 'Purple'),
  orange(CupertinoColors.systemOrange, 'Orange'),
  teal(CupertinoColors.systemTeal, 'Teal'),
  pink(CupertinoColors.systemPink, 'Pink'),
  indigo(CupertinoColors.systemIndigo, 'Indigo');

  const AppThemeColor(this.color, this.label);
  final Color color;
  final String label;
}

class ThemeNotifier extends Notifier<Color> {
  static const _key = 'theme_color';

  @override
  Color build() {
    _loadTheme();
    return AppThemeColor.netflixRed.color; // default Netflix red
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final colorName = prefs.getString(_key);
    if (colorName != null) {
      final theme = AppThemeColor.values.firstWhere(
        (t) => t.name == colorName,
        orElse: () => AppThemeColor.netflixRed,
      );
      state = theme.color;
    }
  }

  Future<void> setTheme(AppThemeColor theme) async {
    state = theme.color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, theme.name);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, Color>(() {
  return ThemeNotifier();
});
