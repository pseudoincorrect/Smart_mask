import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mask/src/blocs/sensor_data/sensor_data_bloc.dart';
import 'package:mask/src/blocs/sensor_data/sensor_data_provider.dart';
import 'package:mask/src/screens/sensor_details.dart';
import 'package:mask/src/widgets/graph/time_series.dart';
import 'package:mask/src/widgets/graph/line_graph.dart';
import 'package:mask/src/database/models/sensor_model.dart';

const num graphsHeight = 600.0;

class Graph extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: graphsHeight,
          child: RefreshingGraphs(),
        ),
      ],
    );
  }
}

class RefreshingGraphs extends StatefulWidget {
  @override
  _RefreshingGraphsState createState() => _RefreshingGraphsState();
}

class _RefreshingGraphsState extends State<RefreshingGraphs> {
  SensorDataBloc sensorDataBloc;

  @override
  Widget build(BuildContext context) {
    sensorDataBloc = SensorDataProvider.of(context);

    return ListView.builder(
      itemCount: Sensor.values.length,
      itemBuilder: (context, index) {
        Sensor sensor = Sensor.values[index];

        return ListTile(
          title: Row(children: [
            Text(sensor.toString().replaceFirst('Sensor.', '').toUpperCase()),
            Expanded(child: Container()),
            RaisedButton(
                onPressed: navigateSensorDetails, child: Text("Details"))
          ]),
          subtitle: StreamBuilder(
            stream: sensorDataBloc.getStream(sensor),
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
                    height: graphsHeight / (Sensor.values.length * 2),
                    child: LineChart.withSampleData(
                      _parseSensorData(snapshot.data, sensor),
                    ),
                  );
                case ConnectionState.done:
                  return Text('ConnectionDone');
              }
              return Text('Problem');
            },
          ),
        );
      },
    );
  }

  List<TimeSeriesSensor> _parseSensorData(
      List<SensorData> sensorData, Sensor sensor) {
    var timeSeries = List<TimeSeriesSensor>();

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

  void navigateSensorDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GraphDetails()),
    );
    print("navigateSensorDetails");
  }
}
