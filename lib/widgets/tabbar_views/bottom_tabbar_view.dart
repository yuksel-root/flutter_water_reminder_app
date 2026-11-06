import 'package:flutter/material.dart';
import 'package:flutter_water_reminder_app/views/history_view.dart';
import 'package:flutter_water_reminder_app/views/home_view.dart';
import 'package:flutter_water_reminder_app/views/settings_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomTabbarView extends StatefulWidget {
  const BottomTabbarView({super.key});

  @override
  State<BottomTabbarView> createState() => _BottomTabbarViewState();
}

class _BottomTabbarViewState extends State<BottomTabbarView> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    HomeView(),
    HistoryView(),
    SettingsView(),
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTap,
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
  }
}
