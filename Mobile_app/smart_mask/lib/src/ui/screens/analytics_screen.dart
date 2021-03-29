import 'package:flutter/material.dart';
import 'package:smart_mask/src/ui/widgets/analytics_widget.dart';
import 'package:smart_mask/src/ui/widgets/graph/sensor_graph.dart';
import 'package:smart_mask/src/logic/database/models/sensor_model.dart';
import 'package:smart_mask/src/ui/widgets/sensor_control_widgets.dart';

const num graphsHeight = 300.0;

class AnalyticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SensorSelectAnalyticsDropButton(),
              SizedBox(
                height: graphsHeight,
                child: Text("Soon, there will be a graph here"),
                // child: SensorGraph(
                //   sensorDataStream: analyticsBloc.getSensorDataStream(),
                //   sensor: snapshot.data,
                //   height: graphsHeight / (Sensor.values.length * 2),
                // ),
              ),
              IntervalSlider(),
            ],
          ),
        ),
      ),
    );
  }
}

// class AnalyticsView extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     AnalyticsBloc analyticsBloc = AnalyticsProvider.of(context);
//     return StreamBuilder(
//       stream: analyticsBloc.getSelectedSensorStream(),
//       builder: (BuildContext context, AsyncSnapshot<Sensor> snapshot) {
//         if (snapshot.hasError) return Text('Error');
//         switch (snapshot.connectionState) {
//           case ConnectionState.active:
//             return SingleChildScrollView(
//                 child: Column(
//               children: <Widget>[
//                 SensorSelectAnalyticsDropButton(
//                   sensor: snapshot.data,
//                   changeSensorFunction: analyticsBloc.setSelectedSensor,
//                 ),
//                 SizedBox(
//                   height: graphsHeight,
//                   // child: Text("Soon, there will be a graph here"),
//                   child: SensorGraph(
//                     sensorDataStream: analyticsBloc.getSensorDataStream(),
//                     sensor: snapshot.data,
//                     height: graphsHeight / (Sensor.values.length * 2),
//                   ),
//                 ),
//                 IntervalSlider(),
//               ],
//             ));
//         }
//         return Text('Data not ready');
//       },
//     );
//   }
// }
