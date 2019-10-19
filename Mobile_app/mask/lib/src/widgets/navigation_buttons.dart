import 'package:flutter/material.dart';
import 'package:mask/src/screens/home.dart';
import '../screens/bluetooth_devices_list.dart';
import '../screens/graphs.dart';

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
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => bluetoothDevicesList()),
    );
  }

  void graphButton(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => graphs()),
    );
  }

  void homeButton(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Home()),
    );
  }
}
