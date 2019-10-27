import 'package:flutter/material.dart';
import './bluetooth_bloc.dart';

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
