import 'package:flutter/material.dart';

/// Simple global theme controller using ValueNotifier to avoid provider issues
class AppThemeController {
  AppThemeController._();

  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  static void toggle(bool isDark) {
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}