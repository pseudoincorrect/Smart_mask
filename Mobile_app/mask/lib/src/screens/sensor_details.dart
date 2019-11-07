//  Sensor Details Screen
//
//  Description:
//      Management of the screen page to display sensors data
//      related to only one sensor (selectable)

import 'package:flutter/material.dart';
import 'package:mask/src/blocs/sensor_data/sensor_data_bloc.dart';
import 'package:mask/src/blocs/sensor_data/sensor_data_provider.dart';
import 'package:mask/src/widgets/drop_button.dart';
import 'package:mask/src/widgets/graph/sensor_graph.dart';
import 'package:mask/src/database/models/sensor_model.dart';

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
  Sensor sensor = Sensor.temperature;
  String dropdownValue = sensors[0];

  @override
  Widget build(BuildContext context) {
    sensorDataBloc = SensorDataProvider.of(context);

    return Column(
      children: <Widget>[
        DropButton(
            value: dropdownValue,
            onChanged: dropButtonOnChanged,
            items: sensors),
        SizedBox(
          height: graphsHeight,
          child: SensorGraph(
            sensorDataStream: sensorDataBloc.getStream(sensor),
            sensor: sensor,
            height: graphsHeight / (Sensor.values.length * 2),
          ),
        ),
      ],
    );
  }

  void navigateSensorDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GraphDetails()),
    );
    print("navigateSensorDetails");
  }

  dropButtonOnChanged(String newSensor) {
    setState(() {
      dropdownValue = newSensor;
      this.sensor = sensorStringToEnum(newSensor);
    });
  }
}
