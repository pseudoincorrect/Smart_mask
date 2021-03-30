import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
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
    return Container(
      margin: EdgeInsets.only(top: 10, left: 10, right: 10),
      child: Card(
        child: Container(
          child: Column(
            children: [
              zoomAndTitle(),
              SizedBox(height: 10),
              timeSlider(),
            ],
          ),
        ),
      ),
    );
  }

  Widget zoomAndTitle() {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              child: zoomOutButton(),
              alignment: Alignment.centerLeft,
            ),
          ),
          Expanded(
            child: Container(
              child: Text("Navigate Your Data"),
              alignment: Alignment.center,
            ),
          ),
          Expanded(
            child: Container(
              child: zoomInButton(),
              alignment: Alignment.centerRight,
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
      child: Icon(Icons.zoom_in),
    );
  }

  Widget zoomOutButton() {
    return ElevatedButton(
      onPressed: () => sensorDataBloc.decreaseZoomLevel(),
      child: Icon(Icons.zoom_out),
    );
  }
}

///////////////////////////////////////////////////////////////////////////////

class FilterSelect extends StatelessWidget {
  final double textInPutHeight = 40;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Card(
        child: Container(
          padding: EdgeInsets.all(10),
          height: textInPutHeight * 2.5,
          child: Column(
            children: <Widget>[
              Expanded(flex: 1, child: Text("Filters")),
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      child: filterCard("Low Pass", 1000),
                    ),
                    Expanded(
                      child: filterCard("High Pass", 0.2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget filterCard(String text, double value) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 10),
          Text("$text:"),
          SizedBox(width: 10),
          Container(
            height: textInPutHeight,
            width: 60,
            child: TextField(
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.only(
                  bottom: textInPutHeight / 2,
                ),
                hintText: value.toString(),
              ),
            ),
          ),
          SizedBox(width: 5),
          Text("Hz"),
          SizedBox(width: 10),
        ],
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////////////////
