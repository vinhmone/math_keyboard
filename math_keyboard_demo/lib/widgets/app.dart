import 'package:flutter/material.dart';
import 'package:math_keyboard_demo/data/strings.dart';
import 'package:math_keyboard_demo/widgets/scaffold.dart';

/// Demo application for `math_keyboard`.
class DemoApp extends StatefulWidget {
  /// Constructs a [DemoApp].
  const DemoApp({super.key});

  @override
  DemoAppState createState() => DemoAppState();
}

/// State for [DemoApp].
class DemoAppState extends State<DemoApp> {
  var _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        brightness: _darkMode ? Brightness.dark : Brightness.light,
      ),
      home: DemoScaffold(
        onToggleBrightness: () {
          setState(() {
            _darkMode = !_darkMode;
          });
        },
      ),
    );
  }
}
