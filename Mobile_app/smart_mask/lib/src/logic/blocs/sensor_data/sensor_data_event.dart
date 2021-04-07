import 'package:equatable/equatable.dart';
import 'package:smart_mask/src/logic/models/sensor_model.dart';

///////////////////////////////////////////////////////////////////////////////

abstract class SensorDataEvent extends Equatable {
  const SensorDataEvent();

  @override
  List<Object> get props => [];
}

///////////////////////////////////////////////////////////////////////////////

class SensorDataEventRefresh extends SensorDataEvent {}

///////////////////////////////////////////////////////////////////////////////

class SensorDataEventDataRefresh extends SensorDataEvent {}

///////////////////////////////////////////////////////////////////////////////

class SensorDataEventSelectedSensor extends SensorDataEvent {
  final Sensor sensor;

  const SensorDataEventSelectedSensor({required this.sensor});

  @override
  List<Object> get props => [sensor];
}

///////////////////////////////////////////////////////////////////////////////

class SensorDataEventEnableMock extends SensorDataEvent {
  final bool enable;

  const SensorDataEventEnableMock({required this.enable});

  @override
  List<Object> get props => [enable];
}
