import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:smart_mask/src/logic/blocs/sensor_data/sensor_data_bloc.dart';
import 'package:smart_mask/src/logic/blocs/sensor_data/sensor_data_provider.dart';
import 'package:smart_mask/src/logic/database/models/sensor_model.dart';

import 'package:smart_mask/src/logic/blocs/analytics/analytics_bloc.dart';
import 'package:smart_mask/src/logic/blocs/analytics/analytics_provider.dart';
import 'package:smart_mask/src/ui/widgets/graph/sensor_graph.dart';

///////////////////////////////////////////////////////////////////////////////

const num graphsHeight = 300.0;

class AnalyticsSensorGraph extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AnalyticsBloc bloc = AnalyticsProvider.of(context);

    return StreamBuilder(
      stream: bloc.getSelectedSensorStream(),
      builder: (BuildContext context, AsyncSnapshot<Sensor> snapshot) {
        if (snapshot.hasError) Text("ConnectionError");
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
          case ConnectionState.done:
            return Text("Sensor Selection not ready");
          case ConnectionState.active:
            // return Text("Soon, there will be a graph here"),
            return Container(
              child: SizedBox(
                height: graphsHeight,
                child: SensorGraph(
                  sensorDataStream: bloc.getSensorDataStream(),
                  sensor: snapshot.data,
                  height: graphsHeight / (Sensor.values.length * 2),
                ),
              ),
            );
        }
        return Container(color: Colors.red);
      },
    );
  }
}

///////////////////////////////////////////////////////////////////////////////

class SensorSelectAnalyticsDropButton extends StatelessWidget {
  const SensorSelectAnalyticsDropButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AnalyticsBloc bloc = AnalyticsProvider.of(context);
    final List<String> sensors =
        Sensor.values.map((Sensor s) => sensorEnumToString(s)).toList();

    return StreamBuilder(
      stream: bloc.getSelectedSensorStream(),
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
                bloc.setSelectedSensor(sensor);
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
  AnalyticsBloc bloc;

  @override
  void initState() {
    super.initState();
    _currentSliderValue = 0;
  }

  @override
  Widget build(BuildContext context) {
    bloc = AnalyticsProvider.of(context);
    return Container(
      margin: EdgeInsets.only(top: 10, left: 10, right: 10),
      child: Card(
        child: Container(
          child: Column(
            children: [
              zoomAndTitle(),
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
        bloc.setTime(value.toInt());
      },
      onChanged: (double x) {
        setState(() => _currentSliderValue = x);
      },
    );
  }

  Widget zoomInButton() {
    return ElevatedButton(
      onPressed: () => bloc.increaseZoomLevel(),
      child: Icon(Icons.zoom_in),
    );
  }

  Widget zoomOutButton() {
    return ElevatedButton(
      onPressed: () => bloc.decreaseZoomLevel(),
      child: Icon(Icons.zoom_out),
    );
  }
}

///////////////////////////////////////////////////////////////////////////////

class FilterSelect extends StatelessWidget {
  final double textInPutHeight = 40;

  @override
  Widget build(BuildContext context) {
    AnalyticsBloc bloc = AnalyticsProvider.of(context);

    return Container(
      margin: EdgeInsets.only(left: 10, right: 10),
      child: Card(
        child: Container(
          padding: EdgeInsets.all(10),
          height: textInPutHeight * 2.2,
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
                      child: filterCard(bloc, "Low Pass", 1000),
                    ),
                    Expanded(
                      child: filterCard(bloc, "High Pass", 0.2),
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

  Widget filterCard(AnalyticsBloc bloc, String text, double value) {
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

class DownloadButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AnalyticsBloc bloc = AnalyticsProvider.of(context);

    return Container(
      margin: EdgeInsets.only(top: 10, left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          dowloadButton(bloc.saveRawData, "Raw Data", Icons.save),
          SizedBox(width: 40),
          dowloadButton(bloc.saveProcessedData, "Filtered Data", Icons.save),
        ],
      ),
    );
  }

  Widget dowloadButton(void Function() onPress, String text, IconData icon) {
    return Container(
        width: 120,
        height: 90,
        child: ElevatedButton(
          onPressed: onPress,
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(text),
              SizedBox(height: 10),
              Icon(icon, size: 40),
            ],
          ),
        ));
  }
}

///////////////////////////////////////////////////////////////////////////////

class EnableMockDataCheckbox extends StatefulWidget {
  const EnableMockDataCheckbox({Key key}) : super(key: key);

  @override
  _EnableMockDataCheckboxState createState() => _EnableMockDataCheckboxState();
}

class _EnableMockDataCheckboxState extends State<EnableMockDataCheckbox> {
  bool _enable = false;

  void initState() {
    super.initState();
    () async {
      await Future.delayed(Duration.zero);
      SensorDataBloc sensorDataBloc = SensorDataProvider.of(context);
      setState(() {
        _enable = sensorDataBloc.isMockDataEnabled();
      });
    }();
  }

  @override
  Widget build(BuildContext context) {
    SensorDataBloc sensorDataBloc = SensorDataProvider.of(context);
    return Container(
      margin: EdgeInsets.only(left: 0, right: 80, top: 10),
      child: CheckboxListTile(
        title: const Text('Randomly Generated Sensor Data'),
        value: _enable,
        onChanged: (bool value) {
          sensorDataBloc.toggleMockData();
          setState(() {
            _enable = sensorDataBloc.isMockDataEnabled();
          });
        },
      ),
    );
  }
}
