//  Sensor Details Screen
//
//  Description:
//      Management of the screen page to display sensors data
//      related to only one sensor (selectable)

import 'package:flutter/material.dart';
import 'package:smart_mask/src/logic/blocs/bluetooth/bluetooth_bloc.dart';
import 'package:smart_mask/src/logic/blocs/bluetooth/bluetooth_provider.dart';
import 'package:smart_mask/src/logic/blocs/sensor_data/sensor_data_bloc.dart';
import 'package:smart_mask/src/logic/blocs/sensor_data/sensor_data_provider.dart';
import 'package:smart_mask/src/ui/widgets/graph/sensor_graph.dart';
import 'package:smart_mask/src/logic/database/models/sensor_model.dart';
import 'package:smart_mask/src/ui/widgets/sensor_control_widgets.dart';

const num graphsHeight = 300.0;

class GraphDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SensorDataBloc sensorDataBloc = SensorDataProvider.of(context);
    BluetoothBloc bluetoothBloc = BluetoothProvider.of(context);

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
            return SingleChildScrollView(
                child: Column(
              children: <Widget>[
                SensorSelectDropButton(
                  sensor: snapshot.data,
                  changeSensorFunction: sensorDataBloc.setSelectedSensor,
                ),
                SizedBox(
                    height: graphsHeight,
                    child: SensorGraph(
                      sensorDataStream: sensorDataBloc.getStream(snapshot.data),
                      sensor: snapshot.data,
                      height: graphsHeight / (Sensor.values.length * 2),
                    )),
                SampleRateSlider(
                  sensor: snapshot.data,
                  initialValue:
                      bluetoothBloc.getSamplePeriod(snapshot.data).toDouble(),
                  setValuefunction: bluetoothBloc.setSamplePeriod,
                ),
                GainSlider(
                  sensor: snapshot.data,
                  initialGain: bluetoothBloc.getGain(snapshot.data),
                  setValuefunction: bluetoothBloc.setGain,
                ),
                EnableCheckbox(
                  sensor: snapshot.data,
                  initialEnable: bluetoothBloc.getEnable(snapshot.data),
                  setValuefunction: bluetoothBloc.setEnable,
                )
              ],
            ));
        }
        return Text('Problem');
      },
    );
  }
}
