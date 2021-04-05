//  Transmission Logic (BLoc) provider
//
//  Description:
//      Enable the transmission bloc to be accessible (provided)
//      throughout the app with contex.inherit..

import 'package:flutter/material.dart';
import 'package:smart_mask/src/logic/blocs/transmission/transmission_bloc.dart';

class TransmissionProvider extends InheritedWidget {
  final TransmissionBloc bloc;

  TransmissionProvider({Key? key, required Widget child, required this.bloc})
      : super(key: key, child: child);

  bool updateShouldNotify(_) => true;

  static TransmissionBloc of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<TransmissionProvider>()!
        .bloc;
  }
}
