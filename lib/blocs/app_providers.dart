import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_water_reminder_app/blocs/auth/auth_cubit.dart';
import 'package:flutter_water_reminder_app/blocs/auth/auth_service.dart';
import 'package:flutter_water_reminder_app/blocs/history/history_bloc.dart';
import 'package:flutter_water_reminder_app/blocs/history/history_event.dart';
import 'package:flutter_water_reminder_app/blocs/history/history_repository.dart';
import 'package:flutter_water_reminder_app/blocs/home/home_bloc.dart';
import 'package:flutter_water_reminder_app/blocs/home/home_event.dart';
import 'package:flutter_water_reminder_app/blocs/home/home_repository.dart';
import 'package:flutter_water_reminder_app/blocs/settings/settings_cubit.dart';
import 'package:flutter_water_reminder_app/blocs/settings/settings_repository.dart';
import 'package:flutter_water_reminder_app/core/bootstrap/app_bootstrap.dart';
import 'package:flutter_water_reminder_app/core/local_storage/water_local_store.dart';

class AppProviders extends StatelessWidget {
  const AppProviders({super.key, required this.bootstrap, required this.child});

  final AppBootstrap bootstrap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => WaterLocalStore()),
        RepositoryProvider(
          create: (context) =>
              HomeRepository(localStore: context.read<WaterLocalStore>()),
        ),
        RepositoryProvider(
          create: (context) =>
              HistoryRepository(localStore: context.read<WaterLocalStore>()),
        ),
        RepositoryProvider(create: (_) => SettingsRepository()),
        RepositoryProvider(create: (_) => AuthService()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                SettingsCubit(context.read<SettingsRepository>())..load(),
          ),
          BlocProvider(
            create: (context) =>
                AuthCubit(context.read<AuthService>(), bootstrap),
          ),
          BlocProvider(
            create: (context) =>
                HomeBloc(context.read<HomeRepository>(), bootstrap)
                  ..add(const HomeStarted()),
          ),
          BlocProvider(
            create: (context) =>
                HistoryBloc(context.read<HistoryRepository>(), bootstrap)
                  ..add(const HistoryStarted()),
          ),
        ],
        child: child,
      ),
    );
  }
}
