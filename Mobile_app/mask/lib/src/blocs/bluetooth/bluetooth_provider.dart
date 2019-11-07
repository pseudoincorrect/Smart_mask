//  Bluetooth Business Logic (BLoc) provider
//
//  Description:
//      Enable the bluetooth bloc to be accessible (provided)
//      throughout the app with contex.inherit..

import 'package:flutter/material.dart';
import 'package:mask/src/blocs/bluetooth/bluetooth_bloc.dart';

class BluetoothProvider extends InheritedWidget {
  final BluetoothBloc bloc;

  BluetoothProvider({Key key, Widget child, this.bloc})
      : super(key: key, child: child);

  bool updateShouldNotify(_) => true;

  static BluetoothBloc of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(BluetoothProvider)
            as BluetoothProvider)
        .bloc;
  }
}