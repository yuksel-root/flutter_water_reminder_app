import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_water_reminder_app/blocs/settings/settings_repository.dart';
import 'package:flutter_water_reminder_app/blocs/settings/settings_state.dart';
import 'package:flutter_water_reminder_app/models/app_settings.dart';
import 'package:flutter_water_reminder_app/models/water/water_reminder.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._repository) : super(const SettingsState());

  final SettingsRepository _repository;

  Future<void> load() async {
    emit(state.copyWith(status: SettingsStatus.loading, errorMessage: ''));

    try {
      final settings = await _repository.fetchSettings();
      final reminders = await _repository.fetchReminders();

      emit(
        state.copyWith(
          status: SettingsStatus.ready,
          settings: settings,
          reminders: reminders,
          errorMessage: '',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: SettingsStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) {
    return _saveSettings(state.settings.copyWith(themeMode: mode));
  }

  Future<void> setLanguageCode(String code) {
    return _saveSettings(state.settings.copyWith(languageCode: code));
  }

  Future<void> setWaterUnit(WaterUnit unit) {
    return _saveSettings(state.settings.copyWith(waterUnit: unit));
  }

  Future<void> setNotificationsEnabled(bool enabled) {
    return _saveSettings(
      state.settings.copyWith(notificationsEnabled: enabled),
    );
  }

  Future<void> saveReminder(WaterReminder reminder) async {
    final value = reminder.id == null
        ? reminder.copyWith(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
          )
        : reminder;

    final reminders = [...state.reminders];
    final index = reminders.indexWhere((item) => item.id == value.id);

    if (index == -1) {
      reminders.add(value);
    } else {
      reminders[index] = value;
    }

    reminders.sort(_compareReminders);
    await _saveReminders(reminders);
  }

  Future<void> deleteReminder(String id) async {
    final reminders = state.reminders
        .where((reminder) => reminder.id != id)
        .toList();
    await _saveReminders(reminders);
  }

  Future<void> toggleReminder(String id) async {
    final reminders = state.reminders
        .map(
          (reminder) => reminder.id == id
              ? reminder.copyWith(isEnabled: !reminder.isEnabled)
              : reminder,
        )
        .toList();
    await _saveReminders(reminders);
  }

  Future<void> _saveSettings(AppSettings settings) async {
    try {
      await _repository.saveSettings(settings);
      emit(
        state.copyWith(
          status: SettingsStatus.ready,
          settings: settings,
          errorMessage: '',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: SettingsStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _saveReminders(List<WaterReminder> reminders) async {
    try {
      await _repository.saveReminders(reminders);
      emit(
        state.copyWith(
          status: SettingsStatus.ready,
          reminders: reminders,
          errorMessage: '',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: SettingsStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  int _compareReminders(WaterReminder a, WaterReminder b) {
    final aMinutes = a.hour * 60 + a.minute;
    final bMinutes = b.hour * 60 + b.minute;
    return aMinutes.compareTo(bMinutes);
  }
}
