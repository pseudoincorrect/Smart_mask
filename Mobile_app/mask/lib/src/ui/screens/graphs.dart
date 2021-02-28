//  All Sensors Graph Screen
//
//  Description:
//      Management of the screen page to display all sensors data
//      on graphs.

// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:mask/src/logic/blocs/sensor_data/sensor_data_bloc.dart';
import 'package:mask/src/logic/blocs/sensor_data/sensor_data_provider.dart';
import 'package:mask/src/ui/screens/sensor_details.dart';
import 'package:mask/src/ui/widgets/graph/sensor_graph.dart';
import 'package:mask/src/logic/database/models/sensor_model.dart';

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
            Text(sensorEnumToString(sensor).toUpperCase()),
            Expanded(child: Container()),
            RaisedButton(
                onPressed: () => navigateSensorDetails(sensor),
                child: Text("Details"))
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

  void navigateSensorDetails(Sensor sensor) {
    sensorDataBloc.setSelectedSensor(sensor);
    DefaultTabController.of(context).animateTo(2);
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => GraphDetails()),
    // );
    // print("navigateSensorDetails");
  }
}
