import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'cloud_backup_service.dart';
import 'premium_access_service.dart';

class PremiumSyncService {
  static const String _autoSyncEnabledKey = 'premium_auto_sync_enabled';
  static const String _lastSyncKey = 'premium_last_sync_timestamp';

  static Timer? _autoSyncTimer;

  static Future<bool> isAutoSyncEnabled() async {
    if (!await PremiumAccessService.isPremium()) return false;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoSyncEnabledKey) ?? false;
  }

  static Future<void> setAutoSyncEnabled(bool enabled) async {
    if (!await PremiumAccessService.isPremium()) {
      stopAutoSyncTimer();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoSyncEnabledKey, enabled);

    if (enabled) {
      startAutoSyncTimer();
    } else {
      stopAutoSyncTimer();
    }
  }

  static Future<DateTime?> getLastSyncTimestamp() async {
    if (!await PremiumAccessService.isPremium()) return null;
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_lastSyncKey);
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  static Future<bool> syncNow() async {
    if (!await PremiumAccessService.isPremium()) return false;

    final user = await CloudBackupService.signIn();
    if (user == null) return false;

    final success = await CloudBackupService.backupData();
    if (success) {
      final now = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastSyncKey, now.toIso8601String());
    }

    return success;
  }

  static Future<bool> restoreNow() async {
    if (!await PremiumAccessService.isPremium()) return false;

    final user = await CloudBackupService.signIn();
    if (user == null) return false;

    return CloudBackupService.restoreData();
  }

  static Future<void> runStartupSyncIfEnabled() async {
    if (!await PremiumAccessService.isPremium()) return;
    if (!await isAutoSyncEnabled()) return;
    await syncNow();
    startAutoSyncTimer();
  }

  static void startAutoSyncTimer({
    Duration interval = const Duration(minutes: 20),
  }) {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = Timer.periodic(interval, (_) {
      syncNow();
    });
  }

  static void stopAutoSyncTimer() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
  }
}
