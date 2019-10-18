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
                return Text('${snapshot.data}');
              case ConnectionState.done:
                return Text('${snapshot.data} (closed)');
            }
            return null; // unreachable
          },
        )
      ],
    );
  }

  void insertDataButton(BuildContext context) {
    insertRandomData();
    print("generate random data");
  }

  void refreshDataButton(BuildContext context) async {
    print("display data");
    List<SensorData> dataArray;
    await sensorDataBloc.getSensorData();
  }

  void insertRandomData() {
    var rng = Random();
    var id = rng.nextInt(1000);
    var value = rng.nextInt(100);
    var timestamp = DateTime.now().millisecondsSinceEpoch;
    Sensor sensorName;

    switch (rng.nextInt(2)) {
      case 0:
        sensorName = Sensor.temperature;
        break;
      case 1:
        sensorName = Sensor.humidity;
        break;
      case 2:
        sensorName = Sensor.acetone;
        break;
      default:
        return;
    }

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
