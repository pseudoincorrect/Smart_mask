//  Sensor Data Business Logic (BLoc) provider
//
//  Description:
//      Enable the Sensor Data bloc to be accessible (provided)
//      throughout the app with contex.inherit..

import 'package:flutter/material.dart';
import 'package:smart_mask/src/logic/blocs/analytics/analytics_bloc.dart';

class AnalyticsProvider extends InheritedWidget {
  final AnalyticsBloc bloc;

  AnalyticsProvider({Key? key, required Widget child, required this.bloc})
      : super(key: key, child: child);

  bool updateShouldNotify(_) => true;

  static AnalyticsBloc of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AnalyticsProvider>()!.bloc;
  }
}
