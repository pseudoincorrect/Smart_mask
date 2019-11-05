import 'package:flutter/material.dart';
import 'package:mask/src/blocs/sensor_data/sensor_data_bloc.dart';
import 'package:mask/src/blocs/sensor_data/sensor_data_provider.dart';
import 'package:mask/src/widgets/graph/sensor_graph.dart';
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
