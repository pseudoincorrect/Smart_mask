import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mask/src/blocs/sensors_data/sensors_data_provider.dart';
import 'package:mask/src/database/models/sensor_data_model.dart';
import 'package:mask/src/widgets/graph/time_series.dart';
import '../blocs/sensors_data/sensors_data_bloc.dart';

class DbControlButtons extends StatefulWidget {
  DbControlButtons({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DbControlButtonsState();
  }
}

class _DbControlButtonsState extends State<DbControlButtons> {
  SensorsDataBloc sensorDataBloc;

  @override
  Widget build(BuildContext context) {
    sensorDataBloc = SensorsDataProvider.of(context);

    return Column(
      children: <Widget>[
        FlatButton(
          onPressed: () => insertDataButton(context),
          child: Text("Insert Data"),
        ),
        FlatButton(
          onPressed: () => deleteDataButton(context),
          child: Text("Delete Data"),
        ),
//        FlatButton(
//          onPressed: () => customQueryButton(context),
//          child: Text("Custom Query"),
//        ),
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
    Sensor sensorName;

    int rand = rng.nextInt(3);
    sensorName = rand == 0
        ? Sensor.temperature
        : rand == 1 ? Sensor.humidity : Sensor.acetone;

    SensorData sensorData = SensorData(
      value: value,
      id: id,
      sensorName: sensorName,
      timeStamp: timestamp,
    );

    sensorDataBloc.addSensorData(sensorData);
  }

  void deleteDataButton(BuildContext context) {
    sensorDataBloc.deleteAllSensorData();
  }

//  void customQueryButton(BuildContext context) async {
//    await sensorDataBloc.getSensorData(Sensor.temperature, interval: [
//      DateTime.now().subtract(Duration(seconds: 10)),
//      DateTime.now()
//    ]);
//  }
}
