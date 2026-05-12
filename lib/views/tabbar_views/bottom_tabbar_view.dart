import 'package:flutter/material.dart';
import 'package:flutter_water_reminder_app/core/constants/gradient_colors.dart';
import 'package:flutter_water_reminder_app/core/constants/navigation_constants.dart';
import 'package:flutter_water_reminder_app/core/navigation/navigation_service.dart';
import 'package:flutter_water_reminder_app/views/home_view.dart';
import 'package:flutter_water_reminder_app/views/tabbar_views/tabbar_view.dart';
import 'package:flutter_water_reminder_app/widgets/gradient_widget.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class BottomTabbarView extends StatefulWidget {
  const BottomTabbarView({super.key});

  @override
  State<BottomTabbarView> createState() => _BottomTabbarViewState();
}

class _BottomTabbarViewState extends State<BottomTabbarView> {
  final NavigationService navigation = NavigationService.instance;
  int currentIndex = 0;

  final List<Widget> screens = const [
    HomeView(),
    HomeView(),
    HomeView(),
    HomeView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue,
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 3) {
            navigation.navigateToPage(path: NavigationConstants.settingsView);
            return;
          }

          setState(() {
            currentIndex = index;
          });
        },
        selectedItemColor: Colors.grey,
        unselectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.house),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.bolt),
            label: "Attack",
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.shield),
            label: "Defense",
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.gear),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
