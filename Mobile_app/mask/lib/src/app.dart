import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask/src/blocs/bluetooth/bluetooth_bloc.dart';
import 'package:mask/src/blocs/bluetooth/bluetooth_provider.dart';
import 'package:mask/src/blocs/sensor_data/sensor_data_bloc.dart';
import 'package:mask/src/blocs/sensor_data/sensor_data_provider.dart';
import './screens/home.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    final bluetoothBloc = BluetoothBloc();
    final sensorDataBloc = SensorDataBloc();

    return SensorDataProvider(
      bloc: sensorDataBloc,
      child: BluetoothProvider(
        bloc: bluetoothBloc,
        child: MaterialApp(
          title: "Smart Mask",
          theme: getTheme(),
          home: Home(),
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
