import 'package:flutter/material.dart';

class AppLifeCycleManager extends StatefulWidget {
  final Widget child;
  const AppLifeCycleManager({Key? key, required this.child}) : super(key: key);

  @override
  State<AppLifeCycleManager> createState() => _AppLifeCycleManagerState();
}

class _AppLifeCycleManagerState extends State<AppLifeCycleManager>
    with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.detached:
        print('LifeCycleState = $state');
        break;
      case AppLifecycleState.inactive:
        print('LifeCycleState = $state');

        break;
      case AppLifecycleState.paused:
        print('LifeCycleState = $state');

        break;
      case AppLifecycleState.resumed:
        print('LifeCycleState = $state');

        break;

      default:
    }
  }
}
