import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_water_reminder_app/core/navigation/navigation_route.dart';
import 'package:flutter_water_reminder_app/core/navigation/navigation_service.dart';
import 'package:flutter_water_reminder_app/core/lifecycle/app_life_cycle_manager.dart';
import 'package:flutter_water_reminder_app/widgets/tabbar_views/bottom_tabbar_view.dart';

Future<void> main() async {
  await _init();
}

Future<void> _init() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.bottom],
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppLifeCycleManager(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateRoute: NavigationRoute.instance.generateRoute,
        navigatorKey: NavigationService.instance.navigatorKey,
        home: const BottomTabbarView(),
      ),
    );
  }
}
