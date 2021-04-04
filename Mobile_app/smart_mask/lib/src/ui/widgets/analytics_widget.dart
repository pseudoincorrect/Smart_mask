import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:smart_mask/src/logic/blocs/sensor_data/sensor_data_bloc.dart';
import 'package:smart_mask/src/logic/blocs/sensor_data/sensor_data_provider.dart';
import 'package:smart_mask/src/logic/database/models/sensor_model.dart';

import 'package:smart_mask/src/logic/blocs/analytics/analytics_bloc.dart';
import 'package:smart_mask/src/logic/blocs/analytics/analytics_provider.dart';
import 'package:smart_mask/src/ui/widgets/graph/sensor_graph.dart';

///////////////////////////////////////////////////////////////////////////////

const double graphsHeight = 300.0;

class AnalyticsSensorGraph extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AnalyticsBloc bloc = AnalyticsProvider.of(context);
    return SensorGraph(
      sensorDataStream: bloc.getSensorDataStream(),
      height: graphsHeight,
    );
  }
}

///////////////////////////////////////////////////////////////////////////////

class SelectAndRefresh extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AnalyticsBloc bloc = AnalyticsProvider.of(context);

    return Row(
      children: [
        Expanded(
            flex: 1,
            child: SizedBox(
              width: 10,
            )),
        Expanded(
          flex: 1,
          child: SensorSelectAnalyticsDropButton(),
        ),
        Expanded(
          flex: 1,
          child: Row(
            children: [
              Spacer(),
              ElevatedButton(
                child: Icon(Icons.refresh),
                onPressed: bloc.refreshSensorData,
              ),
              SizedBox(width: 10)
            ],
          ),
        ),
      ],
    );
  }
}

///////////////////////////////////////////////////////////////////////////////

class SensorSelectAnalyticsDropButton extends StatelessWidget {
  const SensorSelectAnalyticsDropButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AnalyticsBloc bloc = AnalyticsProvider.of(context);
    Sensor sensor = bloc.selectedSensor;
    final List<String> sensors =
        Sensor.values.map((Sensor s) => sensorEnumToString(s)).toList();

    return DropdownButton<String>(
      value: sensorEnumToString(sensor),
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      onChanged: (String? newSensor) {
        Sensor sensor = sensorStringToEnum(newSensor!)!;
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
}

///////////////////////////////////////////////////////////////////////////////

class IntervalSlider extends StatefulWidget {
  const IntervalSlider({Key? key}) : super(key: key);

  @override
  _IntervalSliderState createState() => _IntervalSliderState();
}

class _IntervalSliderState extends State<IntervalSlider> {
  late double _currentSliderValue;
  late AnalyticsBloc bloc;

  @override
  void initState() {
    super.initState();
    _currentSliderValue = 500;
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
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        inactiveTrackColor: Theme.of(context).accentColor,
        activeTrackColor: Theme.of(context).accentColor,
        trackShape: RectangularSliderTrackShape(),
      ),
      child: Slider(
        value: _currentSliderValue,
        min: 0,
        max: 1000,
        divisions: 99,
        onChanged: (double x) {
          setState(() => _currentSliderValue = x);
          bloc.setTimefromInt(x.toInt());
        },
      ),
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
              Expanded(
                flex: 3,
                child: TransformEnableAndTitleState(),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      child: FilterCard(textInPutHeight, false),
                    ),
                    Expanded(
                      child: FilterCard(textInPutHeight, true),
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
}

class TransformEnableAndTitleState extends StatefulWidget {
  @override
  _TransformEnableAndTitleState createState() =>
      _TransformEnableAndTitleState();
}

class _TransformEnableAndTitleState
    extends State<TransformEnableAndTitleState> {
  AnalyticsBloc? bloc;
  bool _enable = true;

  @override
  void initState() {
    super.initState();
    () async {
      await Future.delayed(Duration.zero);
      bloc = AnalyticsProvider.of(context);
      setState(() {
        _enable = bloc!.isTransformEnabled();
      });
    }();
  }

  @override
  Widget build(BuildContext context) {
    bloc = AnalyticsProvider.of(context);
    return Row(
      children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          child: Checkbox(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            activeColor: Theme.of(context).accentColor,
            value: _enable,
            onChanged: (bool? value) {
              bloc!.toggleTransform();
              setState(() {
                _enable = bloc!.isTransformEnabled();
              });
            },
          ),
        ),
        Container(alignment: Alignment.center, child: Text("Filters")),
        Spacer(),
      ],
    );
  }
}

class FilterCard extends StatelessWidget {
  final double textInPutHeight;
  final bool isHighPass;

  FilterCard(this.textInPutHeight, this.isHighPass);

  @override
  Widget build(BuildContext context) {
    double value;
    String label;
    AnalyticsBloc bloc = AnalyticsProvider.of(context);
    Function(String val) editFilter;

    if (isHighPass) {
      value = bloc.highPassFilter;
      label = "High pass";
      editFilter = (String val) => bloc.setHighPassFilter(double.parse(val));
    } else {
      value = bloc.lowPassFilter;
      label = "Low pass";
      editFilter = (String val) => bloc.setLowPassFilter(double.parse(val));
    }
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 10),
          Text(label),
          SizedBox(width: 10),
          Container(
            height: textInPutHeight,
            width: 60,
            child: TextField(
              onSubmitted: editFilter,
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
          child: Column(
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
  const EnableMockDataCheckbox({Key? key}) : super(key: key);

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
        activeColor: Theme.of(context).accentColor,
        title: const Text('Randomly Generated Sensor Data'),
        value: _enable,
        onChanged: (bool? value) {
          sensorDataBloc.toggleMockData();
          setState(() {
            _enable = sensorDataBloc.isMockDataEnabled();
          });
        },
      ),
    );
  }
}
