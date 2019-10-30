import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mask/src/blocs/sensor_data/sensor_data_bloc.dart';

import 'package:mask/src/blocs/sensor_data/sensor_data_provider.dart';
import 'package:mask/src/widgets/graph/time_series.dart';
import 'package:mask/src/widgets/db_control_buttons.dart';
import 'package:mask/src/widgets/graph/line_graph.dart';
import 'package:mask/src/database/models/sensor_model.dart';
import 'package:mask/src/widgets/navigation_buttons.dart';

final num graphsHeight = 450.0;
Duration windowInterval = Duration(seconds: 10);
Duration refreshInterval = Duration(seconds: 1);

Widget graphs() {
  return Scaffold(
    appBar: AppBar(
      title: const Text("graphs"),
    ),
    body: ListView(
      children: <Widget>[
        NavigationButtons(),
        SizedBox(
          height: graphsHeight,
          child: RefreshingGraph(),
        ),
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
  SensorDataBloc sensorDataBloc;
  List<Timer> graphUpdateTimers = List<Timer>();

  @override
  Widget build(BuildContext context) {
    sensorDataBloc = SensorDataProvider.of(context);

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: Sensor.values.length,
      itemBuilder: (context, index) {
        Sensor sensor = Sensor.values[index];
        graphUpdateTimers.add(startTimeout(refreshInterval, sensor));

        return ListTile(
          subtitle: Row(children: [
            Text(sensor.toString()),
            FlatButton(onPressed: navigateSensorDetails, child: Text("Details"))
          ]),
          title: StreamBuilder(
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
                    height: graphsHeight / (Sensor.values.length + 2),
                    child: LineChart.withSampleData(
                      _parseSensorData(snapshot.data, sensor),
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

  List<TimeSeriesSensor> _parseSensorData(
      List<SensorData> sensorData, Sensor sensor) {
    var timeSeries = List<TimeSeriesSensor>();

    List<SensorData> namedSensorData =
        sensorData.where((element) => element.sensorName == sensor).toList();

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

  startTimeout(Duration duration, Sensor sensor) {
    return new Timer.periodic(duration, (Timer t) => handleTimeout(sensor));
  }

  void handleTimeout(Sensor sensor) {
    sensorDataBloc.getSensorData(sensor,
        interval: [DateTime.now().subtract(windowInterval), DateTime.now()]);
  }

  void navigateSensorDetails() {
    print("navigateSensorDetails");
  }

  @override
  void dispose() {
    for (var t in graphUpdateTimers) {
      t?.cancel();
    }
    super.dispose();
  }
}
