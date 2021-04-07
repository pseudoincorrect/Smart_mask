import 'package:equatable/equatable.dart';
import 'package:smart_mask/src/logic/database/models/sensor_control_model.dart';
import 'package:smart_mask/src/logic/database/models/sensor_model.dart';

///////////////////////////////////////////////////////////////////////////////

abstract class BleEvent extends Equatable {
  const BleEvent();

  @override
  List<Object> get props => [];
}

///////////////////////////////////////////////////////////////////////////////

class BleEventRefresh extends BleEvent {}

///////////////////////////////////////////////////////////////////////////////

class BleEventRefreshWithSensor extends BleEvent {
  final Sensor sensor;

  BleEventRefreshWithSensor({required this.sensor});

  @override
  List<Object> get props => [sensor];
}

///////////////////////////////////////////////////////////////////////////////

class BleEventSetSamplePeriod extends BleEvent {
  final int samplePeriod;
  final Sensor sensor;

  BleEventSetSamplePeriod({required this.sensor, required this.samplePeriod});

  @override
  List<Object> get props => [sensor, samplePeriod];
}

///////////////////////////////////////////////////////////////////////////////

class BleEventSetGain extends BleEvent {
  final SensorGain gain;
  final Sensor sensor;

  BleEventSetGain({required this.sensor, required this.gain});

  @override
  List<Object> get props => [sensor, gain];
}

///////////////////////////////////////////////////////////////////////////////

class BleEventSetEnable extends BleEvent {
  final bool enable;
  final Sensor sensor;

  BleEventSetEnable({required this.sensor, required this.enable});

  @override
  List<Object> get props => [sensor, enable];
}

///////////////////////////////////////////////////////////////////////////////

class BleEventSetConnected extends BleEvent {
  final bool connected;

  BleEventSetConnected({required this.connected});

  @override
  List<Object> get props => [connected];
}
