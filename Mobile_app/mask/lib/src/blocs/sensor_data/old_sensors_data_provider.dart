import 'package:flutter/material.dart';
import './old_sensors_data_bloc.dart';

class SensorDataProvider extends InheritedWidget {
  final SensorDataBloc bloc;

  SensorDataProvider({Key key, Widget child, this.bloc})
      : super(key: key, child: child);

  bool updateShouldNotify(_) => true;

  static SensorDataBloc of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(SensorDataProvider)
            as SensorDataProvider)
        .bloc;
  }
}
