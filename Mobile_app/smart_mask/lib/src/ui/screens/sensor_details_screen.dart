//  Sensor Details Screen
//
//  Description:
//      Management of the screen page to display sensors data
//      related to only one sensor (selectable)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_mask/src/logic/blocs/bloc.dart';
import 'package:smart_mask/src/logic/blocs/bluetooth/bluetooth_bloc.dart';
import 'package:smart_mask/src/logic/blocs/bluetooth/bluetooth_provider.dart';
import 'package:smart_mask/src/logic/database/models/sensor_model.dart';
import 'package:smart_mask/src/ui/widgets/sensor_details_widgets.dart';

class GraphDetailsScreen extends StatelessWidget {
  final double graphsHeight = 300.0;

  @override
  Widget build(BuildContext context) {
    // BluetoothBloc bluetoothBloc = BluetoothProvider.of(context);
    BlocProvider.of<AnalyticsBloc>(context).add(AnalyticsEventRefresh());
    BlocProvider.of<SensorDataBloc>(context).add(SensorDataEventRefresh());

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          SensorSelectDropButton(),
          SizedBox(
            height: graphsHeight,
            child: BuildDetailGraph(
              // sensor: sensorDataBloc.getStream(sensor),
              graphHeight: graphsHeight / (Sensor.values.length * 2),
            ),
          ),
          // SampleRateSlider(
          //   sensor: sensor,
          //   initialValue: bluetoothBloc.getSamplePeriod(sensor).toDouble(),
          //   setValuefunction: bluetoothBloc.setSamplePeriod,
          // ),
          // GainSlider(
          //   sensor: sensor,
          //   initialGain: bluetoothBloc.getGain(sensor),
          //   setValuefunction: bluetoothBloc.setGain,
          // ),
          // EnableCheckbox(
          //   sensor: sensor,
          //   initialEnable: bluetoothBloc.getEnable(sensor),
          //   setValuefunction: bluetoothBloc.setEnable,
          // )
        ],
      ),
    );
  }
}
