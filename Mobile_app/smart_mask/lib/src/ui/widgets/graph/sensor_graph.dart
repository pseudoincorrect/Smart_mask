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
  final double height;

  SensorGraph({Key? key, required this.sensorDataStream, required this.height})
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
          case ConnectionState.waiting:
          case ConnectionState.done:
            return _buildEmptyGraph();
          case ConnectionState.active:
            return _buildSensorGraph(snapshot.data!);
        }
      },
    );
  }

  Widget _buildEmptyGraph() {
    return SizedBox(
      height: widget.height,
      child: LineChart.withSampleData(
        _parseSensorData([]),
      ),
    );
  }

  Widget _buildSensorGraph(List<SensorData> sensorData) {
    return SizedBox(
      height: widget.height,
      child: LineChart.withSampleData(
        _parseSensorData(sensorData),
      ),
    );
  }

  List<TimeSeriesSensor> _parseSensorData(List<SensorData> sensorData) {
    List<TimeSeriesSensor> timeSeries = [];

    for (var data in sensorData) {
      var dataPoint = TimeSeriesSensor(
          DateTime.fromMillisecondsSinceEpoch(data.timeStamp), data.value);
      timeSeries.add(dataPoint);
    }
    return timeSeries;
  }
}