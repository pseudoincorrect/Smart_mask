import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './screens/home.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: "Smart Mask",
      theme: getTheme(),
      home: Home(),
    );
  }

  ThemeData getTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.blue,
      accentColor: Colors.blueAccent,
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.blue,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5))),
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }

//  void preloadAssets(BuildContext context) {
//    precacheImage(AssetImage('assets/images/work_ready.jpg'), context);
//  }
}
