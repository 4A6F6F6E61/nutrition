import 'package:flutter/cupertino.dart';

class AppTheme {
  const AppTheme._();
  static const primaryColor = Color(0xFFE50914);
  static const backgroundColor = Color(0xFF000000);
  static const borderColor = Color(0xFF333333);
  static const textPrimary = Color(0xFFFEFEFE);
  static const textSecondary = Color(0xFFB3B3B3);
  static const buttonPrimary = Color(0xFFFEFEFE);
  static const buttonSecondary = Color(0xFF333333);
  static const tabBarInactive = Color(0xAA848484);
  static const tabBarActive = Color(0xFFFFFFFF);
  static const textFieldBackground = Color(0xFF323232);
  static const textFieldText = Color(0xFFC2C2C2);
  static const sheetBackground = Color(0xFF161616);
  static const cardBackground = sheetBackground;
  static const sheetActionForeground = Color(0xFFFFFFFF);
  static const sheetActionBackground = Color(0xFF232323);
}

CupertinoThemeData generateTheme({Color themeColor = AppTheme.primaryColor}) {
  return CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: themeColor,
    primaryContrastingColor: CupertinoColors.white,
    scaffoldBackgroundColor: AppTheme.backgroundColor,
    // barBackgroundColor: const Color(0xFF141414),
    textTheme: const CupertinoTextThemeData(
      primaryColor: AppTheme.textPrimary,
      tabLabelTextStyle: TextStyle(
        fontFamily: '.SF Pro Text',
        fontSize: 10,
        letterSpacing: -0.24,
        color: AppTheme.textPrimary,
      ),
      textStyle: TextStyle(
        fontFamily: '.SF Pro Text',
        fontSize: 17,
        letterSpacing: -0.41,
        color: AppTheme.textPrimary,
      ),

      navTitleTextStyle: TextStyle(
        fontFamily: '.SF Pro Display',
        fontSize: 34,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.37,
        color: CupertinoColors.activeGreen,
      ),
      navLargeTitleTextStyle: TextStyle(
        fontFamily: '.SF Pro Display',
        fontSize: 34,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.37,
        color: AppTheme.textPrimary,
      ),
    ),
  );
}
