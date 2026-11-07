import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_water_reminder_app/blocs/app_providers.dart';
import 'package:flutter_water_reminder_app/blocs/settings/settings_cubit.dart';
import 'package:flutter_water_reminder_app/blocs/settings/settings_state.dart';
import 'package:flutter_water_reminder_app/core/bootstrap/app_bootstrap.dart';
import 'package:flutter_water_reminder_app/core/lifecycle/app_life_cycle_manager.dart';
import 'package:flutter_water_reminder_app/core/navigation/navigation_route.dart';
import 'package:flutter_water_reminder_app/core/navigation/navigation_service.dart';
import 'package:flutter_water_reminder_app/models/app_settings.dart';
import 'package:flutter_water_reminder_app/widgets/tabbar_views/bottom_tabbar_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  unawaited(
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom],
    ),
  );
  unawaited(
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
  );

  final bootstrap = AppBootstrap();
  unawaited(bootstrap.initialize());

  runApp(MainApp(bootstrap: bootstrap));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.bootstrap});

  final AppBootstrap bootstrap;

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      bootstrap: bootstrap,
      child: AppLifeCycleManager(child: const _AppView()),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Water Reminder',
          theme: _buildTheme(Brightness.light),
          darkTheme: _buildTheme(Brightness.dark),
          themeMode: _themeMode(state.settings.themeMode),
          navigatorKey: NavigationService.instance.navigatorKey,
          onGenerateRoute: NavigationRoute.instance.generateRoute,
          home: const BottomTabbarView(),
        );
      },
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.blue,
      brightness: brightness,
    );
  }

  ThemeMode _themeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }
}
