//  All Sensors Graph Screen
//
//  Description:
//      Management of the screen page to display all sensors data
//      on graphs.

// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:smart_mask/src/logic/blocs/sensor_data/sensor_data_bloc.dart';
import 'package:smart_mask/src/logic/blocs/sensor_data/sensor_data_provider.dart';
import 'package:smart_mask/src/ui/screens/sensor_details_screen.dart';
import 'package:smart_mask/src/ui/widgets/graph/sensor_graph.dart';
import 'package:smart_mask/src/logic/database/models/sensor_model.dart';

const num graphsHeight = 800.0;

class GraphsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SensorDataBloc sensorDataBloc = SensorDataProvider.of(context);
    return SingleChildScrollView(
        child: Column(
      children: <Widget>[
        SizedBox(
          height: graphsHeight,
          child: ListView.builder(
            itemCount: Sensor.values.length,
            itemBuilder: (context, index) {
              Sensor sensor = Sensor.values[index];
              return ListTile(
                title: Row(children: [
                  Text(sensorEnumToString(sensor).toUpperCase()),
                  Expanded(child: Container()),
                  ElevatedButton(
                    onPressed: () {
                      sensorDataBloc.setSelectedSensor(sensor);
                      DefaultTabController.of(context).animateTo(2);
                    },
                    child: Text("Details"),
                  ),
                ]),
                subtitle: SensorGraph(
                  sensorDataStream: sensorDataBloc.getStream(sensor),
                  sensor: sensor,
                  height: graphsHeight / (Sensor.values.length * 2),
                ),
              );
            },
          ),
        ),
      ],
    ));
  }
}
