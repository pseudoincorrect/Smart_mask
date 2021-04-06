//  All Sensors Graph Screen
//
//  Description:
//      Management of the screen page to display all sensors data
//      on graphs.

// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_mask/src/logic/blocs/bloc.dart';
import 'package:smart_mask/src/ui/widgets/graph/sensor_graph.dart';
import 'package:smart_mask/src/logic/database/models/sensor_model.dart';

const double graphsHeight = 800.0;

class GraphsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                        BlocProvider.of<SensorDataBloc>(context)
                            .add(SensorDataEventSelectedSensor(sensor: sensor));
                        DefaultTabController.of(context)!.animateTo(2);
                      },
                      child: Text("Details"),
                    ),
                  ]),
                  subtitle: BuildGraph(
                    sensor: sensor,
                    graphHeight: graphsHeight / (Sensor.values.length * 2),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class BuildGraph extends StatelessWidget {
  final Sensor sensor;
  final double graphHeight;

  BuildGraph({required this.sensor, required this.graphHeight});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SensorDataBloc, SensorDataState>(
      buildWhen: (_, state) {
        return (state is SensorDataStateSensorData &&
            state.sensor == this.sensor);
      },
      builder: (context, state) {
        if (state is SensorDataStateSensorData) {
          return SensorGraph(state.data, graphHeight);
        }
        return EmptySensorGraph(graphHeight);
      },
    );
  }
}
