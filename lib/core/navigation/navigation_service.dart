import 'package:flutter/material.dart';

import 'i_navigation_service.dart';

class NavigationService implements INavigationService {
  static NavigationService? _instance;

  static NavigationService get instance {
    _instance ??= NavigationService._init();
    return _instance!;
  }

  NavigationService._init();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  bool _removeAllOldRoutes(Route<dynamic> route) => false;

  @override
  Future<void> navigateToPage({required String path, Object? data}) async {
    await navigatorKey.currentState?.pushNamed(path, arguments: data);
  }

  @override
  Future<void> navigateToPageClear({required String path, Object? data}) async {
    await navigatorKey.currentState?.pushNamedAndRemoveUntil(
      path,
      _removeAllOldRoutes,
      arguments: data,
    );
  }

  @override
  Future<void> navigatePop({Object? data}) async {
    navigatorKey.currentState?.pop(data);
  }
}
