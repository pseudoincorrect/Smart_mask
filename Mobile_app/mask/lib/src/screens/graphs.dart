//  All Sensors Graph Screen
//
//  Description:
//      Management of the screen page to display all sensors data
//      on graphs.

import 'package:flutter/material.dart';
import 'package:mask/src/blocs/sensor_data/sensor_data_bloc.dart';
import 'package:mask/src/blocs/sensor_data/sensor_data_provider.dart';
import 'package:mask/src/screens/sensor_details.dart';
import 'package:mask/src/widgets/graph/sensor_graph.dart';
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
          subtitle: SensorGraph(
            sensorDataStream: sensorDataBloc.getStream(sensor),
            sensor: sensor,
            height: graphsHeight / (Sensor.values.length * 2),
          ),
        );
      },
    );
  }

  void navigateSensorDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GraphDetails()),
    );
    print("navigateSensorDetails");
  }
}
