import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mask/src/blocs/sensors_data/sensors_data_provider.dart';
import 'package:mask/src/database/models/sensor_data_model.dart';

import '../screens/bluetooth_devices_list.dart';
import '../screens/graphs.dart';
import '../blocs/sensors_data/sensors_data_bloc.dart';

class TestButtons extends StatefulWidget {
  TestButtons({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TestButtonsState();
  }
}

class _TestButtonsState extends State<TestButtons> {
  SensorsDataBloc sensorDataBloc;

  @override
  Widget build(BuildContext context) {
    sensorDataBloc = SensorsDataProvider.of(context);

    return Column(
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
          onPressed: () => insertDataButton(context),
          child: Text("Insert Data"),
        ),
        FlatButton(
          onPressed: () => refreshDataButton(context),
          child: Text("Display Data"),
        ),
        FlatButton(
          onPressed: () => deleteDataButton(context),
          child: Text("Delete Data"),
        ),
        StreamBuilder<List<SensorData>>(
          stream: sensorDataBloc.sensorData, // a Stream<int> or null
          builder:
              (BuildContext context, AsyncSnapshot<List<SensorData>> snapshot) {
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Text('Select lot');
              case ConnectionState.waiting:
                return Text('Press Refresh...');
              case ConnectionState.active:
                return Text('\$${snapshot.data}');
              case ConnectionState.done:
                return Text('\$${snapshot.data} (closed)');
            }
            return null; // unreachable
          },
        )
      ],
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

  void insertDataButton(BuildContext context) {
    insertRandomData();
    print("generate random data");
  }

  void refreshDataButton(BuildContext context) async {
    print("display data");
    List<SensorData> dataArray;
    await sensorDataBloc.getAllSensorData();
  }

  void insertRandomData() {
    var rng = Random();
    var id = rng.nextInt(1000);
    var value = rng.nextInt(100);
    var timestamp = DateTime.now().millisecondsSinceEpoch;
    String sensorName = 'Temperature';
    SensorData sensorData = SensorData(
      value: value,
      id: id,
      sensorName: sensorName,
      timeStamp: timestamp,
    );
    sensorDataBloc.addSensorData(sensorData);
    print(sensorData.toString());
  }

  void deleteDataButton(BuildContext context) {
    sensorDataBloc.deleteAllSensorData();
    print("generate random data");
  }
}
