import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_water_reminder_app/blocs/history/history_bloc.dart';
import 'package:flutter_water_reminder_app/blocs/history/history_event.dart';
import 'package:flutter_water_reminder_app/blocs/history/history_repository.dart';
import 'package:flutter_water_reminder_app/blocs/home/home_bloc.dart';
import 'package:flutter_water_reminder_app/blocs/home/home_event.dart';
import 'package:flutter_water_reminder_app/blocs/home/home_repository.dart';
import 'package:flutter_water_reminder_app/blocs/settings/settings_cubit.dart';
import 'package:flutter_water_reminder_app/blocs/settings/settings_repository.dart';
import 'package:flutter_water_reminder_app/blocs/settings/settings_state.dart';
import 'package:flutter_water_reminder_app/core/lifecycle/app_life_cycle_manager.dart';
import 'package:flutter_water_reminder_app/core/navigation/navigation_route.dart';
import 'package:flutter_water_reminder_app/core/navigation/navigation_service.dart';
import 'package:flutter_water_reminder_app/firebase_options.dart';
import 'package:flutter_water_reminder_app/models/app_settings.dart';
import 'package:flutter_water_reminder_app/widgets/tabbar_views/bottom_tabbar_view.dart';

Future<void> main() async {
  await _init();
  runApp(const MainApp());
}

Future<void> _init() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.bottom],
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await _initFirebase();
}

Future<void> _initFirebase() async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      await auth.signInAnonymously();
    }
  } catch (error, stackTrace) {
    debugPrint('Firebase initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => SettingsCubit(SettingsRepository())..load(),
        ),
        BlocProvider(
          create: (_) => HomeBloc(HomeRepository())..add(const HomeStarted()),
        ),
        BlocProvider(
          create: (_) =>
              HistoryBloc(HistoryRepository())..add(const HistoryStarted()),
        ),
      ],
      child: const AppLifeCycleManager(child: _AppView()),
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
