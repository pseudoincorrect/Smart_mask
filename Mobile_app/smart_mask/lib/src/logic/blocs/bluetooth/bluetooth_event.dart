import 'package:equatable/equatable.dart';
import 'package:smart_mask/src/logic/models/sensor_control_model.dart';
import 'package:smart_mask/src/logic/models/sensor_model.dart';

///////////////////////////////////////////////////////////////////////////////

abstract class BleEvent extends Equatable {
  const BleEvent();

  @override
  List<Object> get props => [];
}

///////////////////////////////////////////////////////////////////////////////

class BleEventRefresh extends BleEvent {}

///////////////////////////////////////////////////////////////////////////////

class BleEventSetSelectedSensor extends BleEvent {
  final Sensor sensor;

  BleEventSetSelectedSensor({required this.sensor});

  @override
  List<Object> get props => [sensor];
}

///////////////////////////////////////////////////////////////////////////////

class BleEventSetSamplePeriod extends BleEvent {
  final int samplePeriod;

  BleEventSetSamplePeriod({required this.samplePeriod});

  @override
  List<Object> get props => [samplePeriod];
}

///////////////////////////////////////////////////////////////////////////////

class BleEventSetGain extends BleEvent {
  final SensorGain gain;

  BleEventSetGain({required this.gain});

  @override
  List<Object> get props => [gain];
}

///////////////////////////////////////////////////////////////////////////////

class BleEventSetEnable extends BleEvent {
  final bool enable;

  BleEventSetEnable({required this.enable});

  @override
  List<Object> get props => [enable];
}

///////////////////////////////////////////////////////////////////////////////

class BleEventSetConnected extends BleEvent {
  final bool connected;

  BleEventSetConnected({required this.connected});

  @override
  List<Object> get props => [connected];
}
