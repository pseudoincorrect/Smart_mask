import 'package:flutter/material.dart';

import 'package:mask/src/blocs/sensors_data/sensors_data_bloc.dart';
import 'package:mask/src/blocs/sensors_data/sensors_data_provider.dart';
import 'package:mask/src/widgets/graph/time_series.dart';
import 'package:mask/src/widgets/db_control_buttons.dart';
import 'package:mask/src/widgets/graph/line_graph.dart';
import 'package:mask/src/database/models/sensor_data_model.dart';
import 'package:mask/src/widgets/navigation_buttons.dart';

final num graphsHeight = 600.0;

Widget graphs() {
  return Scaffold(
    appBar: AppBar(
      title: const Text("graphs"),
    ),
    body: ListView(
      children: <Widget>[
        SizedBox(
          height: graphsHeight,
          child: RefreshingGraph(),
        ),
        NavigationButtons(),
        DbControlButtons(),
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
    sensorDataBloc.getSensorData();

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: Sensor.values.length,
      itemBuilder: (context, index) {
        return ListTile(
          subtitle: Text(Sensor.values[index].toString()),
          title: StreamBuilder(
            stream: sensorDataBloc.sensorData,
            builder: (BuildContext context,
                AsyncSnapshot<List<SensorData>> snapshot) {
              if (snapshot.hasError) return Text('Empty');
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return Text('ConnectionNone');
                case ConnectionState.waiting:
                  return Text('ConnectionWaiting');
                case ConnectionState.active:
                  return SizedBox(
                    height: graphsHeight / (Sensor.values.length + 0.5),
                    child: LineChart.withSampleData(
                      _parseSensorData(snapshot.data),
                    ),
                  );
                case ConnectionState.done:
                  return Text('ConnectionDone');
              }
              return null; // unreachable}, ),;
            },
          ),
        );
      },
    );
  }

//  @override
//  Widget build(BuildContext context) {
//    sensorDataBloc = SensorsDataProvider.of(context);
//    sensorDataBloc.getSensorData();
//    return StreamBuilder(
//      stream: sensorDataBloc.sensorData,
//      builder:
//          (BuildContext context, AsyncSnapshot<List<SensorData>> snapshot) {
//        if (snapshot.hasError) return Text('Empty');
//        switch (snapshot.connectionState) {
//          case ConnectionState.none:
//            return Text('ConnectionNone');
//          case ConnectionState.waiting:
//            return Text('ConnectionWaiting');
//          case ConnectionState.active:
//            return LineChart.withSampleData(_parseSensorData(snapshot.data));
//          case ConnectionState.done:
//            return Text('ConnectionDone');
//        }
//        return null; // unreachable}, ),;
//      },
//    );
//  }

  List<TimeSeriesSensor> _parseSensorData(List<SensorData> sensorData) {
    var timeSeries = List<TimeSeriesSensor>();
    for (var data in sensorData) {
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
