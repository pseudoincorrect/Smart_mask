import 'package:flutter/material.dart';
import 'package:mask/src/blocs/sensor_data/sensor_data_bloc.dart';
import 'package:mask/src/blocs/sensor_data/sensor_data_provider.dart';
import 'package:mask/src/widgets/graph/time_series.dart';
import 'package:mask/src/widgets/graph/line_graph.dart';
import 'package:mask/src/database/models/sensor_model.dart';

const num graphsHeight = 200.0;

class GraphDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RefreshingGraph();
  }
}

class RefreshingGraph extends StatefulWidget {
  @override
  _RefreshingGraphState createState() => _RefreshingGraphState();
}

class _RefreshingGraphState extends State<RefreshingGraph> {
  SensorDataBloc sensorDataBloc;
  Sensor sensor;

  @override
  Widget build(BuildContext context) {
    sensorDataBloc = SensorDataProvider.of(context);
    Sensor sensor = Sensor.temperature;

    return Column(
      children: <Widget>[
        Text('selected Sensor'),
        dropbut(),
        SizedBox(
          height: graphsHeight,
          child: StreamBuilder(
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
                    height: 90.0,
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
        ),
      ],
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

  String dropdownValue = 'One';
  Widget dropbut() {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: dropbutOnChanged,
      items: <String>['One', 'Two', 'Free', 'Four']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  dropbutOnChanged(String newValue) {
    setState(() {
      dropdownValue = newValue;
    });
  }
}
