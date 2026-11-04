import 'package:equatable/equatable.dart';

enum AppThemeMode {
  system,
  light,
  dark;

  static AppThemeMode fromValue(String? value) {
    return AppThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => AppThemeMode.system,
    );
  }
}

enum WaterUnit {
  ml,
  oz;

  static WaterUnit fromValue(String? value) {
    return WaterUnit.values.firstWhere(
      (unit) => unit.name == value,
      orElse: () => WaterUnit.ml,
    );
  }
}

class AppSettings extends Equatable {
  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.languageCode = 'tr',
    this.waterUnit = WaterUnit.ml,
    this.notificationsEnabled = true,
  });

  final AppThemeMode themeMode;
  final String languageCode;
  final WaterUnit waterUnit;
  final bool notificationsEnabled;

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      themeMode: AppThemeMode.fromValue(map['themeMode'] as String?),
      languageCode: map['languageCode'] as String? ?? 'tr',
      waterUnit: WaterUnit.fromValue(map['waterUnit'] as String?),
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'themeMode': themeMode.name,
      'languageCode': languageCode,
      'waterUnit': waterUnit.name,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  AppSettings copyWith({
    AppThemeMode? themeMode,
    String? languageCode,
    WaterUnit? waterUnit,
    bool? notificationsEnabled,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
      waterUnit: waterUnit ?? this.waterUnit,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  @override
  List<Object?> get props => [
    themeMode,
    languageCode,
    waterUnit,
    notificationsEnabled,
  ];
}
