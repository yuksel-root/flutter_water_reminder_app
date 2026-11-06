import 'package:flutter/material.dart';
import 'package:flutter_water_reminder_app/core/constants/navigation_constants.dart';
import 'package:flutter_water_reminder_app/views/history_view.dart';
import 'package:flutter_water_reminder_app/views/settings_view.dart';
import 'package:flutter_water_reminder_app/widgets/tabbar_views/bottom_tabbar_view.dart';

class NavigationRoute {
  static final NavigationRoute _instance = NavigationRoute._init();

  static NavigationRoute get instance => _instance;

  NavigationRoute._init();

  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case NavigationConstants.homeView:
        return pageNavigate(const BottomTabbarView(), settings);

      case NavigationConstants.historyView:
        return pageNavigate(const HistoryView(), settings);

      case NavigationConstants.settingsView:
        return pageNavigate(const SettingsView(), settings);

      default:
        return MaterialPageRoute<dynamic>(
          builder: (context) => Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Route is not found')),
          ),
          settings: settings,
        );
    }
  }

  static MaterialPageRoute<dynamic> pageNavigate(
    Widget widget,
    RouteSettings settings,
  ) {
    return MaterialPageRoute<dynamic>(
      builder: (context) => widget,
      settings: settings,
    );
  }
}
