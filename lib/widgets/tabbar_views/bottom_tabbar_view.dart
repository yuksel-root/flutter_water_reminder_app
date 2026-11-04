import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_water_reminder_app/core/constants/navigation_constants.dart';
import 'package:flutter_water_reminder_app/core/navigation/navigation_service.dart';
import 'package:flutter_water_reminder_app/views/home_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomTabbarView extends StatefulWidget {
  const BottomTabbarView({super.key});

  @override
  State<BottomTabbarView> createState() => _BottomTabbarViewState();
}

class _BottomTabbarViewState extends State<BottomTabbarView> {
  final NavigationService _navigation = NavigationService.instance;

  int _currentIndex = 0;

  static const List<Widget> _screens = [HomeView(), HomeView(), HomeView()];

  void _onTap(int index) {
    if (index == 3) {
      unawaited(
        _navigation.navigateToPage(path: NavigationConstants.settingsView),
      );
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue,
        currentIndex: _currentIndex,
        onTap: _onTap,
        selectedItemColor: Colors.grey,
        unselectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.house),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.noteSticky),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.gamepad),
            label: 'Mini Game',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.gear),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
