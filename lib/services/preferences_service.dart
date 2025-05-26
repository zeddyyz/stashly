import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:prf/prf.dart';

/// Service to handle app preferences and settings
class PreferencesService extends GetxService {
  final Logger _logger = Logger();

  // Define preferences using Prf API
  final themeModePrf = Prf.enumerated<ThemeMode>(
    'theme_mode',
    values: ThemeMode.values,
    defaultValue: ThemeMode.system,
  );

  final isPremiumPrf = Prf<bool>('is_premium', defaultValue: false);
  final lastSyncPrf = Prf<DateTime>('last_sync');

  // Observable preferences
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;
  final RxBool isPremium = false.obs;
  final Rx<DateTime?> lastSync = Rx<DateTime?>(null);

  /// Initialize preferences service
  Future<PreferencesService> init() async {
    _logger.i('PreferencesService initialized');

    // Load saved preferences
    await loadPreferences();

    return this;
  }

  /// Load all preferences from storage
  Future<void> loadPreferences() async {
    try {
      themeMode.value = await themeModePrf.get() ?? ThemeMode.system;
      isPremium.value = await isPremiumPrf.get() ?? false;
      lastSync.value = await lastSyncPrf.get();

      _logger.i(
        'Loaded preferences: themeMode=${themeMode.value}, isPremium=${isPremium.value}, lastSync=${lastSync.value}',
      );
    } catch (e) {
      _logger.e('Error loading preferences: $e');
    }
  }

  /// Save theme mode to preferences
  Future<void> saveThemeMode(ThemeMode mode) async {
    try {
      await themeModePrf.set(mode);
      themeMode.value = mode;
      _logger.i('Theme mode saved: $mode');
    } catch (e) {
      _logger.e('Error saving theme mode: $e');
    }
  }

  /// Save premium status to preferences
  Future<void> savePremiumStatus(bool status) async {
    try {
      await isPremiumPrf.set(status);
      isPremium.value = status;
      _logger.i('Premium status saved: $status');
    } catch (e) {
      _logger.e('Error saving premium status: $e');
    }
  }

  /// Save last sync timestamp to preferences
  Future<void> saveLastSync(DateTime timestamp) async {
    try {
      await lastSyncPrf.set(timestamp);
      lastSync.value = timestamp;
      _logger.i('Last sync saved: $timestamp');
    } catch (e) {
      _logger.e('Error saving last sync: $e');
    }
  }

  /// Reset all preferences to default values
  Future<void> resetPreferences() async {
    try {
      await themeModePrf.remove();
      await isPremiumPrf.remove();
      await lastSyncPrf.remove();

      themeMode.value = ThemeMode.system;
      isPremium.value = false;
      lastSync.value = null;

      _logger.i('All preferences reset to defaults');
    } catch (e) {
      _logger.e('Error resetting preferences: $e');
    }
  }
}
