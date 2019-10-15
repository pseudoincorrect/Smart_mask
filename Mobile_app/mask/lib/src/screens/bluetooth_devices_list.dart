import 'package:flutter/material.dart';

Widget bluetoothDevicesList() {
  return Scaffold(
    appBar: AppBar(
      title: const Text("graphs"),
    ),
    body: Column(
      children: <Widget>[
        Text("Device 1"),
        Text("Device 2"),
        Text("Device 3"),
      ],
    ),
  );
}
