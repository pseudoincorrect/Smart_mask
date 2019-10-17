import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask/src/blocs/sensors_data/sensors_data_bloc.dart';
import 'package:mask/src/blocs/sensors_data/sensors_data_provider.dart';
import './screens/home.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    final sensorDataBloc = SensorsDataBloc();

    return SensorsDataProvider(
      bloc: sensorDataBloc,
      child: MaterialApp(
        title: "Smart Mask",
        theme: getTheme(),
        home: Scaffold(
          appBar: AppBar(
            title: Text("Smart Mask title"),
          ),
          body: Center(child: Home()),
        ),
      ),
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
