import 'package:flutter/material.dart';
import 'package:flutter_water_reminder_app/core/navigation/navigation_service.dart';
import 'package:flutter_water_reminder_app/views/home_view.dart';

class SettingsTabbarView extends StatefulWidget {
  const SettingsTabbarView({super.key});

  @override
  State<SettingsTabbarView> createState() => _ExamTabbarViewState();
}

class _ExamTabbarViewState extends State<SettingsTabbarView>
    with TickerProviderStateMixin {
  late TabController tabController;

  final NavigationService navigation = NavigationService.instance;
  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: 1,
      child: Builder(
        builder: (BuildContext context) {
          final TabController tabController = DefaultTabController.of(context);
          tabController.addListener(() {
            if (!tabController.indexIsChanging) {
              FocusScope.of(context).unfocus();
            }
          });
          return Scaffold(
            body: const TabBarView(
              children: [HomeView(), HomeView(), HomeView()],
            ),
          );
        },
      ),
    );
  }
}
