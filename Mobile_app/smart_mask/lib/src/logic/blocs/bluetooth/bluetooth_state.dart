import 'package:equatable/equatable.dart';
import 'package:smart_mask/src/logic/database/models/sensor_control_model.dart';
import 'package:smart_mask/src/logic/database/models/sensor_model.dart';

///////////////////////////////////////////////////////////////////////////////

abstract class BleState extends Equatable {
  const BleState();

  @override
  List<Object> get props => [];
}

///////////////////////////////////////////////////////////////////////////////

class BleStateInitial extends BleState {}

///////////////////////////////////////////////////////////////////////////////

class BleStateSetSamplePeriod extends BleState {
  final int samplePeriod;
  final Sensor sensor;

  BleStateSetSamplePeriod({required this.sensor, required this.samplePeriod});

  @override
  List<Object> get props => [sensor, samplePeriod];
}

///////////////////////////////////////////////////////////////////////////////

class BleStateSetGain extends BleState {
  final SensorGain gain;
  final Sensor sensor;

  BleStateSetGain({required this.sensor, required this.gain});

  @override
  List<Object> get props => [sensor, gain];
}

///////////////////////////////////////////////////////////////////////////////

class BleStateSetEnable extends BleState {
  final bool enable;
  final Sensor sensor;

  BleStateSetEnable({required this.sensor, required this.enable});

  @override
  List<Object> get props => [sensor, enable];
}

///////////////////////////////////////////////////////////////////////////////

class BleStateSetConnected extends BleState {
  final bool connected;

  BleStateSetConnected({required this.connected});

  @override
  List<Object> get props => [connected];
}
