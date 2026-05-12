import 'package:flutter/material.dart';
import 'package:flutter_water_reminder_app/core/extensions/context_extensions.dart';
import 'package:flutter_water_reminder_app/widgets/gradient_widget.dart';

final main1 = [
  Colors.cyanAccent,
  Colors.yellowAccent,
  Colors.pinkAccent,
  Colors.cyanAccent,
  Colors.pinkAccent,
  Colors.yellowAccent,
];

final main2 = [
  Colors.cyanAccent,
  Colors.white,
  Colors.purpleAccent,
  Colors.cyanAccent,
  Colors.cyanAccent,
  Colors.white,
];

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: Container(
          color: Colors.deepPurple,
          child: Center(
            child: GradientWidget(
              gradient: LinearGradient(colors: main1),
              widget: Text(
                style: TextStyle(fontSize: 18),
                "Hello Dont Forget Drink To Water xD",
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fill,
            image: AssetImage("assets/home.png"),
          ),
        ),
      ),
    );
  }
}
