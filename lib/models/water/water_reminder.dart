import 'package:equatable/equatable.dart';

enum ReminderMode {
  sound,
  vibration,
  silent;

  static ReminderMode fromValue(String? value) {
    return ReminderMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ReminderMode.sound,
    );
  }
}

class WaterReminder extends Equatable {
  const WaterReminder({
    this.id,
    required this.hour,
    required this.minute,
    required this.mode,
    required this.soundName,
    this.isEnabled = true,
  }) : assert(hour >= 0 && hour <= 23),
       assert(minute >= 0 && minute <= 59);

  final String? id;
  final int hour;
  final int minute;
  final ReminderMode mode;
  final String soundName;
  final bool isEnabled;

  String get timeLabel {
    final formattedHour = hour.toString().padLeft(2, '0');
    final formattedMinute = minute.toString().padLeft(2, '0');
    return '$formattedHour:$formattedMinute';
  }

  factory WaterReminder.fromMap(Map<String, dynamic> map, {String? id}) {
    return WaterReminder(
      id: id,
      hour: (map['hour'] as num).toInt(),
      minute: (map['minute'] as num).toInt(),
      mode: ReminderMode.fromValue(map['mode'] as String?),
      soundName: map['soundName'] as String? ?? '',
      isEnabled: map['isEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hour': hour,
      'minute': minute,
      'mode': mode.name,
      'soundName': soundName,
      'isEnabled': isEnabled,
    };
  }

  WaterReminder copyWith({
    String? id,
    int? hour,
    int? minute,
    ReminderMode? mode,
    String? soundName,
    bool? isEnabled,
  }) {
    return WaterReminder(
      id: id ?? this.id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      mode: mode ?? this.mode,
      soundName: soundName ?? this.soundName,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  @override
  List<Object?> get props => [id, hour, minute, mode, soundName, isEnabled];
}
