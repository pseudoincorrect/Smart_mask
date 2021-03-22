import 'package:flutter/material.dart';
import 'package:smart_mask/src/logic/database/models/sensor_model.dart';
import 'package:smart_mask/src/logic/database/models/sensor_control_model.dart';

class SampleRateSlider extends StatefulWidget {
  final double initialValue;
  final void Function(int) setValuefunction;

  const SampleRateSlider({Key key, this.initialValue, this.setValuefunction})
      : super(key: key);

  @override
  _SampleRateSliderState createState() => _SampleRateSliderState();
}

class _SampleRateSliderState extends State<SampleRateSlider> {
  double _currentSliderValue;

  @override
  void initState() {
    super.initState();
    _currentSliderValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.all(20),
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
      min: 100,
      max: 1000,
      divisions: 99,
      onChangeEnd: (double value) => widget.setValuefunction(value.toInt()),
      onChanged: (double x) {
        setState(() => _currentSliderValue = x);
      },
    );
  }
}

///////////////////////////////////////////////////////////////////////////////

class GainSlider extends StatefulWidget {
  final SensorGain initialGain;
  final void Function(SensorGain) setValuefunction;

  const GainSlider({Key key, this.initialGain, this.setValuefunction})
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
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.all(20),
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
      onChangeEnd: (double value) {
        print("value ${value.round().toString()}");
      },
      onChanged: (double x) {
        setState(() => _sensorGain = SensorGain.values[x.toInt()]);
      },
    );
  }
}
