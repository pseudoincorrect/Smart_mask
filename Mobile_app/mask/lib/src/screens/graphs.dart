import 'package:flutter/material.dart';

import 'package:mask/src/blocs/sensors_data/sensors_data_bloc.dart';
import 'package:mask/src/blocs/sensors_data/sensors_data_provider.dart';
import 'package:mask/src/data_processing/sensors_data/time_series.dart';
import 'package:mask/src/widgets/db_control_buttons.dart';
import 'package:mask/src/widgets/graph/line_graph.dart';
import 'package:mask/src/database/models/sensor_data_model.dart';

Widget graphs() {
  return Scaffold(
    appBar: AppBar(
      title: const Text("graphs"),
    ),
    body: ListView(
      children: <Widget>[
        SizedBox(
          height: 200.0,
          child: LineChart.withRandomData(),
        ),
        SizedBox(
          height: 200.0,
          child: RefreshingGraph(),
        ),
        TestButtons(),
      ],
    ),
  );
}

class RefreshingGraph extends StatefulWidget {
  @override
  _RefreshingGraphState createState() => _RefreshingGraphState();
}

class _RefreshingGraphState extends State<RefreshingGraph> {
  SensorsDataBloc sensorDataBloc;

  @override
  Widget build(BuildContext context) {
    sensorDataBloc = SensorsDataProvider.of(context);
    return StreamBuilder(
        stream: sensorDataBloc.sensorData,
        builder:
            (BuildContext context, AsyncSnapshot<List<SensorData>> snapshot) {
          if (snapshot.hasError) return Text('Empty');
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Text('ConnectionNone');
            case ConnectionState.waiting:
              return Text('ConnectionWaiting');
            case ConnectionState.active:
//              _parseSensorData(snapshot.data);
//              return LineChart.withRandomData();
              return LineChart.withSampleData(_parseSensorData(snapshot.data));
            case ConnectionState.done:
              return Text('ConnectionDone');
          }
          return null; // unreachable}, ),;
        });
  }

  List<TimeSeriesSensor> _parseSensorData(List<SensorData> sensorData) {
    var timeSeries = List<TimeSeriesSensor>();
    for (var data in sensorData) {
      print("millisec : " +
          DateTime.fromMillisecondsSinceEpoch(data.timeStamp).toString());
      var dataPoint = TimeSeriesSensor(
          DateTime.fromMillisecondsSinceEpoch(data.timeStamp), data.value);
      if (dataPoint != null) {
        timeSeries.add(dataPoint);
      }
//      print(dataPoint.toString());
    }
    timeSeries.sort((a, b) => (a.time.compareTo(b.time)));
    return timeSeries;
  }
}
