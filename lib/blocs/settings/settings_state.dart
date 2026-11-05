import 'package:equatable/equatable.dart';
import 'package:flutter_water_reminder_app/models/app_settings.dart';
import 'package:flutter_water_reminder_app/models/water/water_reminder.dart';

enum SettingsStatus { initial, loading, ready, failure }

class SettingsState extends Equatable {
  const SettingsState({
    this.status = SettingsStatus.initial,
    this.settings = const AppSettings(),
    this.reminders = const [],
    this.errorMessage = '',
  });

  final SettingsStatus status;
  final AppSettings settings;
  final List<WaterReminder> reminders;
  final String errorMessage;

  SettingsState copyWith({
    SettingsStatus? status,
    AppSettings? settings,
    List<WaterReminder>? reminders,
    String? errorMessage,
  }) {
    return SettingsState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      reminders: reminders ?? this.reminders,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, settings, reminders, errorMessage];
}
