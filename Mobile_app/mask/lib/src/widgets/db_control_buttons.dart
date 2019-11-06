//  Database Control Buttons
//
//  Description:
//      Mainly used to debug database
//      push button to insert random data in db,
//      Delete it, etc...

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mask/src/blocs/bluetooth/bluetooth_bloc.dart';
import 'package:mask/src/blocs/bluetooth/bluetooth_provider.dart';
import 'package:mask/src/blocs/sensor_data/sensor_data_bloc.dart';
import 'package:mask/src/blocs/sensor_data/sensor_data_provider.dart';
import 'package:mask/src/database/models/sensor_model.dart';

class DbControlButtons extends StatefulWidget {
  DbControlButtons({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DbControlButtonsState();
  }
}

class _DbControlButtonsState extends State<DbControlButtons> {
  SensorDataBloc sensorDataBloc;
  BluetoothBloc bluetoothBloc;

  @override
  Widget build(BuildContext context) {
    bluetoothBloc = BluetoothProvider.of(context);
    sensorDataBloc = SensorDataProvider.of(context);
    return Row(
      children: <Widget>[
        RaisedButton(
          onPressed: () => insertDataButton(context),
          child: Text("Insert Data"),
        ),
        RaisedButton(
          onPressed: () => deleteDataButton(context),
          child: Text("Delete Data"),
        ),
        // RaisedButton(
        //   onPressed: () => customQueryButton(context),
        //   child: Text("Custom Query"),
        // ),
      ],
    );
  }

  void insertDataButton(BuildContext context) {
    insertRandomData();
  }

  void insertRandomData() {
    var rng = Random();
    var id = rng.nextInt(1000000);
    var value = rng.nextInt(100);
    var timestamp = DateTime.now().millisecondsSinceEpoch;
    Sensor sensor;

    int rand = rng.nextInt(Sensor.values.length);
    sensor = Sensor.values[rand];

    SensorData sensorData = SensorData(
      value: value,
      id: id,
      sensor: sensor,
      timeStamp: timestamp,
    );

    sensorDataBloc.addSensorData(sensorData);
  }

  void deleteDataButton(BuildContext context) {
    sensorDataBloc.deleteAllSensorData();
  }

// void customQueryButton(BuildContext context) async {
//   await sensorDataBloc.getSensorData(Sensor.temperature, interval: [
//     DateTime.now().subtract(Duration(seconds: 10)),
//     DateTime.now()
//   ]);
// }

}
