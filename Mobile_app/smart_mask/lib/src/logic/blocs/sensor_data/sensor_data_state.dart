import 'package:equatable/equatable.dart';
import 'package:smart_mask/src/logic/models/sensor_model.dart';

///////////////////////////////////////////////////////////////////////////////

abstract class SensorDataState extends Equatable {
  const SensorDataState();

  @override
  List<Object> get props => [];
}

///////////////////////////////////////////////////////////////////////////////

class SensorDataStateInitial extends SensorDataState {}

///////////////////////////////////////////////////////////////////////////////

class SensorDataStateSelectedsensor extends SensorDataState {
  final Sensor sensor;

  SensorDataStateSelectedsensor({required this.sensor});

  @override
  List<Object> get props => [sensor];
}

///////////////////////////////////////////////////////////////////////////////

class SensorDataStateSensorData extends SensorDataState {
  final List<SensorData> data;
  final Sensor sensor;

  SensorDataStateSensorData({required this.sensor, required this.data});

  @override
  List<Object> get props => [sensor, data];
}

///////////////////////////////////////////////////////////////////////////////

class SensorDataStateEnableMock extends SensorDataState {
  final bool enable;

  const SensorDataStateEnableMock({required this.enable});

  @override
  List<Object> get props => [enable];
}
