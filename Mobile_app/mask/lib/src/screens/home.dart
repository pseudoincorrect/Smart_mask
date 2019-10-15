import 'package:flutter/material.dart';
import './bluetooth_devices_list.dart';
import './graphs.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("graphs"),
      ),
      body: Column(
        children: <Widget>[
          Text("connected"),
          FlatButton(
            onPressed: () => connectButton(context),
            child: Text("Connect"),
          ),
          FlatButton(
            onPressed: () => graphButton(context),
            child: Text("Graphs"),
          )
        ],
      ),
    );
  }

  void connectButton(BuildContext context) {
    print("Go to Connect screen");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => bluetoothDevicesList()),
    );
  }

  void graphButton(BuildContext context) {
    print("Go to Graphs screen");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => graphs()),
    );
  }
}
