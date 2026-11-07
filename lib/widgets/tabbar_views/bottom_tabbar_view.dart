import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_water_reminder_app/blocs/history/history_bloc.dart';
import 'package:flutter_water_reminder_app/blocs/history/history_event.dart';
import 'package:flutter_water_reminder_app/blocs/tabbar/tabbar_cubit.dart';
import 'package:flutter_water_reminder_app/views/history_view.dart';
import 'package:flutter_water_reminder_app/views/home_view.dart';
import 'package:flutter_water_reminder_app/views/settings_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomTabbarView extends StatelessWidget {
  const BottomTabbarView({super.key});

  static const List<Widget> _screens = [
    HomeView(),
    HistoryView(),
    SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TabbarCubit(),
      child: const _BottomTabbarContent(),
    );
  }
}

class _BottomTabbarContent extends StatelessWidget {
  const _BottomTabbarContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TabbarCubit, int>(
      builder: (context, index) {
        return Scaffold(
          body: IndexedStack(index: index, children: BottomTabbarView._screens),
          bottomNavigationBar: NavigationBar(
            selectedIndex: index,
            onDestinationSelected: (index) {
              context.read<TabbarCubit>().select(index);
              if (index == 1) {
                context.read<HistoryBloc>().add(const HistoryRefreshed());
              }
            },
            destinations: const [
              NavigationDestination(
                icon: FaIcon(FontAwesomeIcons.house),
                label: 'Home',
              ),
              NavigationDestination(
                icon: FaIcon(FontAwesomeIcons.noteSticky),
                label: 'History',
              ),
              NavigationDestination(
                icon: FaIcon(FontAwesomeIcons.gear),
                label: 'Settings',
              ),
            ],
          ),
        );
      },
    );
  }
}
