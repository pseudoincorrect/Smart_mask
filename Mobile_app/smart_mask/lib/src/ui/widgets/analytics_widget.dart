import 'package:flutter/material.dart';
import 'package:smart_mask/src/logic/database/models/sensor_model.dart';

import 'package:smart_mask/src/logic/blocs/analytics/analytics_bloc.dart';
import 'package:smart_mask/src/logic/blocs/analytics/analytics_provider.dart';

///////////////////////////////////////////////////////////////////////////////

class SensorSelectAnalyticsDropButton extends StatelessWidget {
  const SensorSelectAnalyticsDropButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AnalyticsBloc sensorDataBloc = AnalyticsProvider.of(context);
    final List<String> sensors =
        Sensor.values.map((Sensor s) => sensorEnumToString(s)).toList();

    return StreamBuilder(
      stream: sensorDataBloc.getSelectedSensorStream(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) return Text("error");
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Text("ConnectionNone");
          case ConnectionState.waiting:
            return Text("ConnectionWaiting");
          case ConnectionState.done:
            return Text("ConnectionDone");
          case ConnectionState.active:
            return DropdownButton<String>(
              value: sensorEnumToString(snapshot.data),
              icon: Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              onChanged: (String newSensor) {
                Sensor sensor = sensorStringToEnum(newSensor);
                sensorDataBloc.setSelectedSensor(sensor);
              },
              items: sensors.map<DropdownMenuItem<String>>(
                (String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.toUpperCase()),
                  );
                },
              ).toList(),
            );
        }
        return null; // unreachable
      },
    );
  }
}

///////////////////////////////////////////////////////////////////////////////

class IntervalSlider extends StatefulWidget {
  const IntervalSlider({Key key}) : super(key: key);

  @override
  _IntervalSliderState createState() => _IntervalSliderState();
}

class _IntervalSliderState extends State<IntervalSlider> {
  double _currentSliderValue;
  double _zoomLevel;
  AnalyticsBloc sensorDataBloc;

  // @override
  // void didUpdateWidget(dynamic oldWidget) {
  //   if (_currentSliderValue != widget.initialValue) {
  //     setState(() {
  //       _currentSliderValue = widget.initialValue;
  //     });
  //   }
  //   super.didUpdateWidget(oldWidget);
  // }

  @override
  void initState() {
    super.initState();
    _currentSliderValue = 0;
    _zoomLevel = 0;
  }

  @override
  Widget build(BuildContext context) {
    sensorDataBloc = AnalyticsProvider.of(context);
    return Card(
      margin: EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            flex: 8,
            child: Column(
              children: [
                Container(child: Text("Navigate Your Data")),
                Container(
                  padding: EdgeInsets.only(top: 10),
                  child: timeSlider(),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                zoomInButton(),
                zoomOutButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget timeSlider() {
    return Slider(
      value: _currentSliderValue,
      min: 0,
      max: 1000,
      divisions: 99,
      onChangeEnd: (double value) {
        sensorDataBloc.setTime(value.toInt());
      },
      onChanged: (double x) {
        setState(() => _currentSliderValue = x);
      },
    );
  }

  Widget zoomInButton() {
    return ElevatedButton(
      onPressed: () => sensorDataBloc.increaseZoomLevel(),
      child: Text("+"),
    );
  }

  Widget zoomOutButton() {
    return ElevatedButton(
      onPressed: () => sensorDataBloc.decreaseZoomLevel(),
      child: Text("-"),
    );
  }
}

///////////////////////////////////////////////////////////////////////////////
