//  Sensor Details Screen
//
//  Description:
//      Management of the screen page to display sensors data
//      related to only one sensor (selectable)

import 'package:flutter/material.dart';
import 'package:mask/src/logic/blocs/sensor_data/sensor_data_bloc.dart';
import 'package:mask/src/logic/blocs/sensor_data/sensor_data_provider.dart';
import 'package:mask/src/ui/widgets/drop_button.dart';
import 'package:mask/src/ui/widgets/graph/sensor_graph.dart';
import 'package:mask/src/logic/database/models/sensor_model.dart';

const num graphsHeight = 300.0;
final List<String> sensors =
    Sensor.values.map((Sensor s) => sensorEnumToString(s)).toList();

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

  @override
  Widget build(BuildContext context) {
    sensorDataBloc = SensorDataProvider.of(context);

    return StreamBuilder(
        stream: sensorDataBloc.getSelectedSensorStream(),
        builder: (BuildContext context, AsyncSnapshot<Sensor> snapshot) {
          if (snapshot.hasError) return Text('Empty');
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Text('ConnectionNone');
            case ConnectionState.waiting:
              return Text('ConnectionWaiting');
            case ConnectionState.done:
              return Text('ConnectionState.done');
            case ConnectionState.active:
              return Column(
                children: <Widget>[
                  DropButton(
                    value: sensorEnumToString(snapshot.data),
                    onChanged: dropButtonOnChanged,
                    items: sensors,
                  ),
                  SizedBox(
                    height: graphsHeight,
                    child: SensorGraph(
                      sensorDataStream: sensorDataBloc.getStream(snapshot.data),
                      sensor: snapshot.data,
                      height: graphsHeight / (Sensor.values.length * 2),
                    ),
                  ),
                ],
              );
          }
          return Text('Problem');
        });
  }

  dropButtonOnChanged(String newSensor) {
    Sensor sensor = sensorStringToEnum(newSensor);
    sensorDataBloc.setSelectedSensor(sensor);
    print("newSensor = $newSensor");
  }
}
