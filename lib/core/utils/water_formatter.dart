import 'package:flutter_water_reminder_app/models/app_settings.dart';

String formatWaterAmount(num milliliters, WaterUnit unit) {
  if (unit == WaterUnit.oz) {
    final ounces = milliliters / 29.5735;
    return '${ounces.toStringAsFixed(1)} oz';
  }

  return '${milliliters.round()} ml';
}
