//  Bluetooth Business Logic (BLoc) provider
//
//  Description:
//      Enable the bluetooth bloc to be accessible (provided)
//      throughout the app with contex.inherit..

import 'package:flutter/material.dart';
import 'package:smart_mask/src/logic/blocs/bluetooth/bluetooth_bloc.dart';

class BluetoothProvider extends InheritedWidget {
  final BluetoothBloc bloc;

  BluetoothProvider({Key? key, required Widget child, required this.bloc})
      : super(key: key, child: child);

  bool updateShouldNotify(_) => true;

  static BluetoothBloc of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<BluetoothProvider>()!.bloc;
  }
}
