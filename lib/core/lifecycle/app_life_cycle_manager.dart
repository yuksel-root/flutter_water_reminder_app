import 'package:flutter/material.dart';

class AppLifeCycleManager extends StatefulWidget {
  const AppLifeCycleManager({super.key, required this.child});

  final Widget child;

  @override
  State<AppLifeCycleManager> createState() => _AppLifeCycleManagerState();
}

class _AppLifeCycleManagerState extends State<AppLifeCycleManager>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    debugPrint('LifeCycleState = $state');
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
