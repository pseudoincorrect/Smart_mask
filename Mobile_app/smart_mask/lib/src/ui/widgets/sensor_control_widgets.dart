//  Drop Button
//
//  Description:
//      Widget to control the sensor: Selection, Sample rate, Gain and Enable

import 'package:flutter/material.dart';
import 'package:smart_mask/src/logic/database/models/sensor_model.dart';
import 'package:smart_mask/src/logic/database/models/sensor_control_model.dart';

class SensorSelectDropButton extends StatelessWidget {
  final Sensor sensor;
  final void Function(Sensor) changeSensorFunction;

  const SensorSelectDropButton({Key key, this.sensor, this.changeSensorFunction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> sensors =
        Sensor.values.map((Sensor s) => sensorEnumToString(s)).toList();
    return DropdownButton<String>(
      value: sensorEnumToString(sensor),
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      onChanged: onChanged,
      items: sensors.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value.toUpperCase()),
        );
      }).toList(),
    );
  }

  onChanged(String newSensor) {
    Sensor sensor = sensorStringToEnum(newSensor);
    changeSensorFunction(sensor);
  }
}

///////////////////////////////////////////////////////////////////////////////

class SampleRateSlider extends StatefulWidget {
  final Sensor sensor;
  final double initialValue;
  final void Function(Sensor, int) setValuefunction;

  const SampleRateSlider(
      {Key key, this.sensor, this.initialValue, this.setValuefunction})
      : super(key: key);

  @override
  _SampleRateSliderState createState() => _SampleRateSliderState();
}

class _SampleRateSliderState extends State<SampleRateSlider> {
  double _currentSliderValue;

  @override
  void didUpdateWidget(dynamic oldWidget) {
    if (_currentSliderValue != widget.initialValue) {
      setState(() {
        _currentSliderValue = widget.initialValue;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
    _currentSliderValue = widget.initialValue;
    print("initState ${sensorEnumToString(widget.sensor)}");
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.only(left: 20, right: 20, top: 10),
        child: Container(
            padding: EdgeInsets.all(10),
            child: Column(children: [
              Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Text("Sample Period (ms) - Applied to ALL sensors")),
              Row(mainAxisSize: MainAxisSize.max, children: [
                Text("${_currentSliderValue.toInt()}"),
                Expanded(child: sampleRateSlider())
              ]),
            ])));
  }

  Widget sampleRateSlider() {
    return Slider(
      value: _currentSliderValue,
      min: 200,
      max: 1000,
      divisions: 99,
      onChangeEnd: (double value) =>
          widget.setValuefunction(widget.sensor, value.toInt()),
      onChanged: (double x) {
        setState(() => _currentSliderValue = x);
      },
    );
  }
}

///////////////////////////////////////////////////////////////////////////////

class GainSlider extends StatefulWidget {
  final Sensor sensor;
  final SensorGain initialGain;
  final void Function(Sensor, SensorGain) setValuefunction;

  const GainSlider(
      {Key key, this.sensor, this.initialGain, this.setValuefunction})
      : super(key: key);

  @override
  _GainSliderState createState() => _GainSliderState();
}

class _GainSliderState extends State<GainSlider> {
  SensorGain _sensorGain;

  @override
  void initState() {
    super.initState();
    _sensorGain = widget.initialGain;
  }

  @override
  void didUpdateWidget(dynamic oldWidget) {
    if (_sensorGain != widget.initialGain) {
      setState(() {
        _sensorGain = widget.initialGain;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.only(left: 20, right: 20, top: 10),
        child: Container(
            padding: EdgeInsets.all(10),
            child: Column(children: [
              Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Text("Gain - For this sensor only")),
              Row(mainAxisSize: MainAxisSize.max, children: [
                Text("${sensorGainEnumToString(_sensorGain)}"),
                Expanded(child: gainSlider())
              ]),
            ])));
  }

  Widget gainSlider() {
    return Slider(
      value: _sensorGain.index.toDouble(),
      min: 0,
      max: SensorGain.values.length.toDouble() - 1,
      divisions: 99,
      onChangeEnd: (double value) => widget.setValuefunction(
        widget.sensor,
        SensorGain.values[value.toInt()],
      ),
      onChanged: (double x) {
        setState(() => _sensorGain = SensorGain.values[x.toInt()]);
      },
    );
  }
}

///////////////////////////////////////////////////////////////////////////////

class EnableCheckbox extends StatefulWidget {
  final Sensor sensor;
  final bool initialEnable;
  final void Function(Sensor, bool) setValuefunction;

  const EnableCheckbox(
      {Key key, this.sensor, this.initialEnable, this.setValuefunction})
      : super(key: key);

  @override
  _EnableCheckboxState createState() => _EnableCheckboxState();
}

class _EnableCheckboxState extends State<EnableCheckbox> {
  bool _enable;

  @override
  void initState() {
    super.initState();
    _enable = widget.initialEnable;
  }

  @override
  void didUpdateWidget(dynamic oldWidget) {
    if (_enable != widget.initialEnable) {
      setState(() {
        _enable = widget.initialEnable;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 200, top: 10),
      // margin: EdgeInsets.all(10),
      child: CheckboxListTile(
        title: const Text('Enable Sensor'),
        value: _enable,
        onChanged: (bool value) {
          setState(() {
            _enable = !_enable;
            widget.setValuefunction(widget.sensor, _enable);
          });
        },
      ),
    );
  }
}
