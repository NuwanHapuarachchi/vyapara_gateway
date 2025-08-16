import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/widgets/animated_navigation_bars.dart';

/// Provider for managing navigation bar type preference
final navigationBarTypeProvider =
    NotifierProvider<NavigationBarTypeNotifier, NavigationBarType>(() {
      return NavigationBarTypeNotifier();
    });

class NavigationBarTypeNotifier extends Notifier<NavigationBarType> {
  @override
  NavigationBarType build() {
    _loadPreference();
    return NavigationBarType.fluidGlass;
  }

  static const String _prefsKey = 'navigation_bar_type';

  Future<void> _loadPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final typeIndex =
          prefs.getInt(_prefsKey) ?? NavigationBarType.fluidGlass.index;

      if (typeIndex >= 0 && typeIndex < NavigationBarType.values.length) {
        state = NavigationBarType.values[typeIndex];
      }
    } catch (e) {
      // If loading fails, keep default
      print('Failed to load navigation preference: $e');
    }
  }

  Future<void> setNavigationType(NavigationBarType type) async {
    state = type;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsKey, type.index);
  }

  String getNavigationTypeName() {
    switch (state) {
      case NavigationBarType.neumorphic:
        return 'Classic Neumorphic';
      case NavigationBarType.fluidGlass:
        return 'iOS Fluid Glass';
      case NavigationBarType.bubble:
        return 'Bubble Animation';
    }
  }

  String getNavigationTypeDescription() {
    switch (state) {
      case NavigationBarType.neumorphic:
        return 'Clean neumorphic design with subtle shadows';
      case NavigationBarType.fluidGlass:
        return 'Modern iOS-style floating glass effect';
      case NavigationBarType.bubble:
        return 'Playful liquid bubble animations';
    }
  }
}
