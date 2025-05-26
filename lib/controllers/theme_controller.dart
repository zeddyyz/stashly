import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/preferences_service.dart';

/// Controller to manage app theme
class ThemeController extends GetxController {
  final PreferencesService _preferencesService = Get.find<PreferencesService>();

  /// Observable theme mode
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();

    // Get theme mode from preferences
    themeMode.value = _preferencesService.themeMode.value;

    // Listen for changes in preferences
    _preferencesService.themeMode.listen((mode) {
      themeMode.value = mode;
      _updateTheme(mode);
    });
  }

  /// Change the app's theme mode
  Future<void> changeThemeMode(ThemeMode mode) async {
    await _preferencesService.saveThemeMode(mode);
    themeMode.value = mode;
    _updateTheme(mode);
  }

  /// Toggle between light and dark themes
  Future<void> toggleTheme() async {
    final newMode = themeMode.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;

    await changeThemeMode(newMode);
  }

  /// Update theme in GetX
  void _updateTheme(ThemeMode mode) {
    Get.changeThemeMode(mode);
  }

  /// Check if dark mode is active
  bool get isDarkMode =>
      themeMode.value == ThemeMode.dark ||
      (themeMode.value == ThemeMode.system &&
          WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark);
}
