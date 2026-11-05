import 'dart:convert';

import 'package:flutter_water_reminder_app/core/local_storage/local_storage_manager.dart';
import 'package:flutter_water_reminder_app/models/app_settings.dart';
import 'package:flutter_water_reminder_app/models/water/water_reminder.dart';

class SettingsRepository {
  SettingsRepository({LocalStorageManager? storage})
    : _storage = storage ?? LocalStorageManager.instance;

  final LocalStorageManager _storage;

  static const String _settingsKey = 'app_settings';
  static const String _remindersKey = 'water_reminders';

  Future<AppSettings> fetchSettings() async {
    final value = await _storage.getString(_settingsKey);
    if (value == null || value.isEmpty) {
      return const AppSettings();
    }

    try {
      return AppSettings.fromMap(jsonDecode(value) as Map<String, dynamic>);
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _storage.setString(_settingsKey, jsonEncode(settings.toMap()));
  }

  Future<List<WaterReminder>> fetchReminders() async {
    final value = await _storage.getString(_remindersKey);
    if (value == null || value.isEmpty) {
      return [];
    }

    try {
      final items = jsonDecode(value) as List<dynamic>;
      return items
          .map((item) => WaterReminder.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveReminders(List<WaterReminder> reminders) async {
    final items = reminders.map((reminder) => reminder.toMap()).toList();
    await _storage.setString(_remindersKey, jsonEncode(items));
  }
}
