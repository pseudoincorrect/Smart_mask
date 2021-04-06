import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_mask/src/logic/blocs/bloc.dart';
import 'package:smart_mask/src/logic/database/models/sensor_model.dart';
import 'package:smart_mask/src/ui/widgets/graph/sensor_graph.dart';

///////////////////////////////////////////////////////////////////////////////

const double graphsHeight = 300.0;

class AnalyticsGraph extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      buildWhen: (_, state) => state is AnalyticsStateSensorData,
      builder: (context, state) {
        if (state is AnalyticsStateSensorData) {
          return SensorGraph(state.data, graphsHeight);
        }
        return EmptySensorGraph(graphsHeight);
      },
    );
  }
}

///////////////////////////////////////////////////////////////////////////////

class SelectAndRefresh extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AnalyticsBloc bloc = BlocProvider.of<AnalyticsBloc>(context);

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
                onPressed: () => bloc.add(AnalyticsEventDataRefresh()),
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
    final List<String> sensors =
        Sensor.values.map((Sensor s) => sensorEnumToString(s)).toList();

    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      buildWhen: (_, state) => state is AnalyticsStateSelectedsensor,
      builder: (context, state) {
        if (state is AnalyticsStateSelectedsensor)
          return DropdownButton<String>(
            value: sensorEnumToString(state.sensor),
            icon: Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            onChanged: (String? newSensor) {
              Sensor sensor = sensorStringToEnum(newSensor!)!;
              BlocProvider.of<AnalyticsBloc>(context)
                  .add(AnalyticsEventSelectedSensor(sensor: sensor));
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
        return Text("Loading..");
      },
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
    bloc = BlocProvider.of<AnalyticsBloc>(context);
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
          bloc.add(AnalyticsEventTimeInTicks(ticksIn1000: x.toInt()));
          // bloc.setTimefromInt(x.toInt());
        },
      ),
    );
  }

  Widget zoomInButton() {
    return ElevatedButton(
      onPressed: () => bloc.add(AnalyticsEventZoomInc()),
      child: Icon(Icons.zoom_in),
    );
  }

  Widget zoomOutButton() {
    return ElevatedButton(
      onPressed: () => bloc.add(AnalyticsEventZoomDec()),
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
                      child: HighPassValue(textInPutHeight: textInPutHeight),
                    ),
                    Expanded(
                      child: LowPassValue(textInPutHeight: textInPutHeight),
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

class TransformEnableAndTitleState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      buildWhen: (_, s) => s is AnalyticsStateFilterEnabled,
      builder: (context, state) {
        if (state is AnalyticsStateFilterEnabled) {
          return Row(
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                child: Checkbox(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  activeColor: Theme.of(context).accentColor,
                  value: state.isEnable,
                  onChanged: (bool? value) {
                    BlocProvider.of<AnalyticsBloc>(context).add(
                      AnalyticsEventFilterEnabled(filterEnabled: value!),
                    );
                  },
                ),
              ),
              Container(alignment: Alignment.center, child: Text("Filters")),
              Spacer(),
            ],
          );
        }
        return Text("Loading..");
      },
    );
  }
}

class LowPassValue extends StatelessWidget {
  final double textInPutHeight;

  LowPassValue({required this.textInPutHeight});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      buildWhen: (_, s) => s is AnalyticsStateLowPass,
      builder: (context, state) {
        return Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 10),
              Text("Low"),
              SizedBox(width: 10),
              Container(
                height: textInPutHeight,
                width: 60,
                child: TextField(
                  onSubmitted: (String val) {
                    BlocProvider.of<AnalyticsBloc>(context).add(
                      AnalyticsEventLowPass(
                        lowPassValue: double.parse(val),
                      ),
                    );
                  },
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.only(
                      bottom: textInPutHeight / 4,
                    ),
                    hintText: state is AnalyticsStateLowPass
                        ? state.lowPassValue.toString()
                        : "Error",
                  ),
                ),
              ),
              SizedBox(width: 5),
              Text("Hz"),
              SizedBox(width: 10),
            ],
          ),
        );
      },
    );
  }
}

class HighPassValue extends StatelessWidget {
  final double textInPutHeight;

  HighPassValue({required this.textInPutHeight});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      buildWhen: (_, s) => s is AnalyticsStateHighPass,
      builder: (context, state) {
        return Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 10),
              Text("High"),
              SizedBox(width: 10),
              Container(
                height: textInPutHeight,
                width: 60,
                child: TextField(
                  onSubmitted: (String val) {
                    BlocProvider.of<AnalyticsBloc>(context).add(
                      AnalyticsEventHighPass(
                        highPassValue: double.parse(val),
                      ),
                    );
                  },
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.only(
                      bottom: textInPutHeight / 4,
                    ),
                    hintText: state is AnalyticsStateHighPass
                        ? state.highPassValue.toString()
                        : "Error",
                  ),
                ),
              ),
              SizedBox(width: 5),
              Text("Hz"),
              SizedBox(width: 10),
            ],
          ),
        );
      },
    );
  }
}

///////////////////////////////////////////////////////////////////////////////

class DownloadButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10, left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          dowloadButton(() {}, "Raw Data", Icons.save),
          SizedBox(width: 40),
          dowloadButton(() {}, "Filtered Data", Icons.save),
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

/////////////////////////////////////////////////////////////////////////////

class EnableMockDataCheckbox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SensorDataBloc, SensorDataState>(
      buildWhen: (_, state) => state is SensorDataStateEnableMock,
      builder: (context, state) {
        if (state is SensorDataStateEnableMock) {
          return Row(
            children: <Widget>[
              Padding(padding: EdgeInsets.only(left: 10)),
              Container(
                alignment: Alignment.centerLeft,
                child: Checkbox(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  activeColor: Theme.of(context).accentColor,
                  value: state.enable,
                  onChanged: (bool? value) {
                    BlocProvider.of<SensorDataBloc>(context)
                        .add(SensorDataEventEnableMock(enable: value!));
                  },
                ),
              ),
              Container(
                  alignment: Alignment.center, child: Text("Generate Data")),
              Spacer(),
            ],
          );
        }
        return Text("Loading..");
      },
    );
  }
}
