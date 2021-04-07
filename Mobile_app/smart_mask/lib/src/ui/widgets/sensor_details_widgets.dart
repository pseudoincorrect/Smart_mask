//  Drop Button
//
//  Description:
//      Widget to control the sensor: Selection, Sample rate, Gain and Enable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_mask/src/logic/blocs/bloc.dart';
import 'package:smart_mask/src/logic/models/sensor_model.dart';
import 'package:smart_mask/src/logic/models/sensor_control_model.dart';
import 'package:smart_mask/src/ui/widgets/graph/sensor_graph.dart';

class SensorSelectDropButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<String> sensors =
        Sensor.values.map((Sensor s) => sensorEnumToString(s)).toList();

    return BlocBuilder<SensorDataBloc, SensorDataState>(
        buildWhen: (_, state) => state is SensorDataStateSelectedsensor,
        builder: (context, state) {
          if (state is SensorDataStateSelectedsensor) {
            return DropdownButton<String>(
              value: sensorEnumToString(state.sensor),
              icon: Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              onChanged: (String? newSensor) {
                Sensor? sensor = sensorStringToEnum(newSensor);
                if (sensor == null) return;
                BlocProvider.of<SensorDataBloc>(context)
                    .add(SensorDataEventSelectedSensor(sensor: sensor));
              },
              items: sensors.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value.toUpperCase()),
                );
              }).toList(),
            );
          }
          return Text("No Data");
        });
  }
}

///////////////////////////////////////////////////////////////////////////////

class BuildDetailGraph extends StatelessWidget {
  final double graphHeight;

  BuildDetailGraph({required this.graphHeight});

  @override
  Widget build(BuildContext context) {
    Sensor sensor = Sensor.sensor_1;
    return BlocBuilder<SensorDataBloc, SensorDataState>(
      buildWhen: (_, state) {
        if (state is SensorDataStateSelectedsensor) return true;
        if (state is SensorDataStateSensorData && sensor == state.sensor)
          return true;
        return false;
      },
      builder: (context, state) {
        if (state is SensorDataStateSelectedsensor) {
          sensor = state.sensor;
        }
        if (state is SensorDataStateSensorData && state.sensor == sensor) {
          return SensorGraph(state.data, graphHeight);
        }
        return EmptySensorGraph(graphHeight);
      },
    );
  }
}

///////////////////////////////////////////////////////////////////////////////

class SamplePeriodSlider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SensorDataBloc, SensorDataState>(
      buildWhen: (_, state) => state is SensorDataStateSelectedsensor,
      builder: (context, state) {
        if (state is SensorDataStateSelectedsensor) {
          return SamplePeriodSliderLvl1(sensor: state.sensor);
        }
        return Text("Loading..");
      },
    );
  }
}

class SamplePeriodSliderLvl1 extends StatelessWidget {
  final Sensor sensor;

  SamplePeriodSliderLvl1({required this.sensor});

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<BleBloc>(context)
        .add(BleEventRefreshWithSensor(sensor: sensor));
    return BlocBuilder<BleBloc, BleState>(
      buildWhen: (_, state) =>
          state is BleStateSetSamplePeriod && state.sensor == sensor,
      builder: (context, state) {
        if (state is BleStateSetSamplePeriod) {
          return Card(
            margin: EdgeInsets.only(left: 20, right: 20, top: 10),
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(children: [
                Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Text("Sample Period (ms) - Applied to ALL sensors")),
                Row(mainAxisSize: MainAxisSize.max, children: [
                  Text("${state.samplePeriod.toInt()} ms"),
                  Expanded(
                    child: SamplePeriodSliderLvl2(
                      sensor: sensor,
                      samplePeriodInit: state.samplePeriod.toDouble(),
                    ),
                  )
                ]),
              ]),
            ),
          );
        }
        return Text("Loading");
      },
    );
  }
}

class SamplePeriodSliderLvl2 extends StatefulWidget {
  final Sensor sensor;
  final double samplePeriodInit;

  const SamplePeriodSliderLvl2(
      {Key? key, required this.sensor, required this.samplePeriodInit})
      : super(key: key);

  @override
  _SamplePeriodSliderLvl2State createState() => _SamplePeriodSliderLvl2State();
}

class _SamplePeriodSliderLvl2State extends State<SamplePeriodSliderLvl2> {
  late double samplePeriod = widget.samplePeriodInit;

  @override
  void didUpdateWidget(dynamic oldWidget) {
    if (samplePeriod != widget.samplePeriodInit) {
      setState(() {
        samplePeriod = widget.samplePeriodInit;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: samplePeriod,
      min: 200,
      max: 1000,
      divisions: 99,
      onChangeEnd: (double value) {
        BlocProvider.of<BleBloc>(context).add(BleEventSetSamplePeriod(
            sensor: widget.sensor, samplePeriod: samplePeriod.toInt()));
      },
      onChanged: (double x) {
        setState(() => samplePeriod = x);
      },
    );
  }
}

///////////////////////////////////////////////////////////////////////////////

class GainSlider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SensorDataBloc, SensorDataState>(
      buildWhen: (_, state) => state is SensorDataStateSelectedsensor,
      builder: (context, state) {
        if (state is SensorDataStateSelectedsensor) {
          return GainSliderLvl1(sensor: state.sensor);
        }
        return Text("Loading..");
      },
    );
  }
}

class GainSliderLvl1 extends StatelessWidget {
  final Sensor sensor;

  GainSliderLvl1({required this.sensor});

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<BleBloc>(context)
        .add(BleEventRefreshWithSensor(sensor: sensor));
    return BlocBuilder<BleBloc, BleState>(
      buildWhen: (_, state) =>
          state is BleStateSetGain && state.sensor == sensor,
      builder: (context, state) {
        if (state is BleStateSetGain) {
          return Card(
            margin: EdgeInsets.only(left: 20, right: 20, top: 10),
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(children: [
                Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Text("Gain Applied to the selected sensor")),
                Row(mainAxisSize: MainAxisSize.max, children: [
                  Text("${sensorGainEnumToString(state.gain)}"),
                  Expanded(
                    child: GainSliderBleLvl2(
                      sensor: sensor,
                      initGainValue: state.gain,
                    ),
                  )
                ]),
              ]),
            ),
          );
        }
        return Text("Loading");
      },
    );
  }
}

class GainSliderBleLvl2 extends StatefulWidget {
  final Sensor sensor;
  final SensorGain initGainValue;

  const GainSliderBleLvl2(
      {Key? key, required this.sensor, required this.initGainValue})
      : super(key: key);

  @override
  _GainSliderBleLvl2State createState() => _GainSliderBleLvl2State();
}

class _GainSliderBleLvl2State extends State<GainSliderBleLvl2> {
  late SensorGain gainValue = widget.initGainValue;

  @override
  void didUpdateWidget(dynamic oldWidget) {
    if (gainValue != widget.initGainValue) {
      setState(() {
        gainValue = widget.initGainValue;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: gainValue.index.toDouble(),
      min: 0,
      max: SensorGain.values.length.toDouble() - 1,
      divisions: 99,
      onChangeEnd: (double value) {
        var bloc = BlocProvider.of<BleBloc>(context);
        var event = BleEventSetGain(
          sensor: widget.sensor,
          gain: SensorGain.values[value.toInt()],
        );
        bloc.add(event);
      },
      onChanged: (double x) {
        setState(() => gainValue = SensorGain.values[x.toInt()]);
      },
    );
  }
}

///////////////////////////////////////////////////////////////////////////////

class EnableCheckbox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SensorDataBloc, SensorDataState>(
      buildWhen: (_, state) => state is SensorDataStateSelectedsensor,
      builder: (context, state) {
        if (state is SensorDataStateSelectedsensor) {
          return EnableCheckboxLvl1(sensor: state.sensor);
        }
        return Text("Loading..");
      },
    );
  }
}

class EnableCheckboxLvl1 extends StatelessWidget {
  final Sensor sensor;

  const EnableCheckboxLvl1({Key? key, required this.sensor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<BleBloc>(context)
        .add(BleEventRefreshWithSensor(sensor: sensor));
    return BlocBuilder<BleBloc, BleState>(
      buildWhen: (_, state) =>
          state is BleStateSetEnable && state.sensor == sensor,
      builder: (context, state) {
        if (state is BleStateSetEnable) {
          return Container(
            margin: EdgeInsets.only(left: 10, right: 200, top: 10),
            child: CheckboxListTile(
              activeColor: Theme.of(context).accentColor,
              title: const Text('Enable Sensor'),
              value: state.enable,
              onChanged: (bool? value) {
                var bloc = BlocProvider.of<BleBloc>(context);
                var event = BleEventSetEnable(
                  sensor: sensor,
                  enable: value!,
                );
                bloc.add(event);
              },
            ),
          );
        }
        return Text("Loading..");
      },
    );
  }
}
