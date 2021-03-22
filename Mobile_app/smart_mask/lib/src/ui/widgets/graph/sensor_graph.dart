//  Sensor chart
//
//  Description:
//      widget used to create a line graph with provided sensor data

import 'package:flutter/material.dart';
import 'package:smart_mask/src/logic/database/models/sensor_model.dart';
import 'package:smart_mask/src/ui/widgets/graph/time_series.dart';
import 'package:smart_mask/src/ui/widgets/graph/line_graph.dart';

class SensorGraph extends StatefulWidget {
  final Stream<List<SensorData>> sensorDataStream;
  final Sensor sensor;
  final num height;

  SensorGraph({Key key, this.sensorDataStream, this.sensor, this.height})
      : super(key: key);

  @override
  _SensorGraphState createState() => _SensorGraphState();
}

class _SensorGraphState extends State<SensorGraph> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.sensorDataStream,
      builder:
          (BuildContext context, AsyncSnapshot<List<SensorData>> snapshot) {
        if (snapshot.hasError) return Text('Empty');
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Text('ConnectionNone');
          case ConnectionState.waiting:
            return Text('ConnectionWaiting');
          case ConnectionState.active:
            return SizedBox(
              height: widget.height,
              child: LineChart.withSampleData(
                _parseSensorData(snapshot.data, widget.sensor),
              ),
            );
          case ConnectionState.done:
            return Text('ConnectionDone');
        }
        return Text('Problem');
      },
    );
  }

  List<TimeSeriesSensor> _parseSensorData(
      List<SensorData> sensorData, Sensor sensor) {
    List<TimeSeriesSensor> timeSeries = [];

    List<SensorData> namedSensorData =
        sensorData.where((element) => element.sensor == sensor).toList();

    for (var data in namedSensorData) {
      var dataPoint = TimeSeriesSensor(
          DateTime.fromMillisecondsSinceEpoch(data.timeStamp), data.value);
      if (dataPoint != null) {
        timeSeries.add(dataPoint);
      }
    }
    timeSeries.sort((a, b) => (a.time.compareTo(b.time)));
    return timeSeries;
  }
}
