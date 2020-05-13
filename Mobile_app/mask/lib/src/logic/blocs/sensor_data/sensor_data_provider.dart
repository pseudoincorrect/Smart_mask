//  Sensor Data Business Logic (BLoc) provider
//
//  Description:
//      Enable the Sensor Data bloc to be accessible (provided)
//      throughout the app with contex.inherit..

import 'package:flutter/material.dart';
import 'package:mask/src/logic/blocs/sensor_data/sensor_data_bloc.dart';

class SensorDataProvider extends InheritedWidget {
  final SensorDataBloc bloc;

  SensorDataProvider({Key key, Widget child, this.bloc})
      : super(key: key, child: child);

  bool updateShouldNotify(_) => true;

  static SensorDataBloc of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<SensorDataProvider>()
        .bloc;
  }
}
