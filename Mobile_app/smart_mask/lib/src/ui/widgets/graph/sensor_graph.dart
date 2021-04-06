//  Sensor chart
//
//  Description:
//      widget used to create a line graph with provided sensor data

import 'package:flutter/material.dart';
import 'package:smart_mask/src/logic/database/models/sensor_model.dart';
import 'package:smart_mask/src/ui/widgets/graph/time_series.dart';
import 'package:smart_mask/src/ui/widgets/graph/line_graph.dart';

class EmptySensorGraph extends StatelessWidget {
  final double height;

  EmptySensorGraph(this.height);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: LineChart.withSampleData(
        parseSensorData([]),
      ),
    );
  }
}

class SensorGraph extends StatelessWidget {
  final List<SensorData> sensorData;
  final double height;

  SensorGraph(this.sensorData, this.height);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: LineChart.withSampleData(
        parseSensorData(sensorData),
      ),
    );
  }
}

List<TimeSeriesSensor> parseSensorData(List<SensorData> sensorData) {
  List<TimeSeriesSensor> timeSeries = [];

  for (var data in sensorData) {
    var dataPoint = TimeSeriesSensor(
        DateTime.fromMillisecondsSinceEpoch(data.timeStamp), data.value);
    timeSeries.add(dataPoint);
  }
  return timeSeries;
}
