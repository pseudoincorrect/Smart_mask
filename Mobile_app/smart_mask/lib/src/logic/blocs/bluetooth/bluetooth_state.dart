import 'package:equatable/equatable.dart';
import 'package:smart_mask/src/logic/models/sensor_control_model.dart';
import 'package:smart_mask/src/logic/models/sensor_model.dart';

///////////////////////////////////////////////////////////////////////////////

abstract class BleState extends Equatable {
  const BleState();

  @override
  List<Object> get props => [];
}

///////////////////////////////////////////////////////////////////////////////

class BleStateInitial extends BleState {}

///////////////////////////////////////////////////////////////////////////////

class BleStateSetSelectedSensor extends BleState {
  final Sensor sensor;

  BleStateSetSelectedSensor({required this.sensor});

  @override
  List<Object> get props => [sensor];
}
///////////////////////////////////////////////////////////////////////////////

class BleStateSetSamplePeriod extends BleState {
  final int samplePeriod;

  BleStateSetSamplePeriod({required this.samplePeriod});

  @override
  List<Object> get props => [samplePeriod];
}

///////////////////////////////////////////////////////////////////////////////

class BleStateSetGain extends BleState {
  final SensorGain gain;

  BleStateSetGain({required this.gain});

  @override
  List<Object> get props => [gain];
}

///////////////////////////////////////////////////////////////////////////////

class BleStateSetEnable extends BleState {
  final bool enable;

  BleStateSetEnable({required this.enable});

  @override
  List<Object> get props => [enable];
}

///////////////////////////////////////////////////////////////////////////////

class BleStateSetConnected extends BleState {
  final bool connected;

  BleStateSetConnected({required this.connected});

  @override
  List<Object> get props => [connected];
}
