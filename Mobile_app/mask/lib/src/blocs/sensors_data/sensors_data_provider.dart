import 'package:flutter/material.dart';
import './sensors_data_bloc.dart';

class SensorsDataProvider extends InheritedWidget {
  final SensorsDataBloc bloc;

  SensorsDataProvider({Key key, Widget child, this.bloc})
      : super(key: key, child: child);

  bool updateShouldNotify(_) => true;

  static SensorsDataBloc of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(SensorsDataProvider)
            as SensorsDataProvider)
        .bloc;
  }
}
