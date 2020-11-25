//  Database Control Buttons
//
//  Description:
//      Mainly used to debug page Navigation
//      push button to insert to change pages

import 'package:flutter/material.dart';
// import 'package:mask/src/ui/screens/home.dart';
// import 'package:mask/src/ui/screens/bluetooth_devices_list.dart';
// import 'package:mask/src/ui/screens/graphs.dart';

class NavigationButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        FlatButton(
          onPressed: () => connectButton(context),
          child: Text("Connect"),
        ),
        FlatButton(
          onPressed: () => graphButton(context),
          child: Text("Graphs"),
        ),
        FlatButton(
          onPressed: () => homeButton(context),
          child: Text("Home"),
        ),
      ],
    );
  }

  void connectButton(BuildContext context) {
//    Navigator.push(
//      context,
//      MaterialPageRoute(builder: (context) => bluetoothDevicesList()),
//    );
  }

  void graphButton(BuildContext context) {
//    Navigator.push(
//      context,
//      MaterialPageRoute(builder: (context) => graphs()),
//    );
  }

  void homeButton(BuildContext context) {
//    Navigator.push(
//      context,
//      MaterialPageRoute(builder: (context) => Home()),
//    );
  }
}