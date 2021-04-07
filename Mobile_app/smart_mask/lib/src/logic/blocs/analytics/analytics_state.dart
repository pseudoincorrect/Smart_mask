import 'package:equatable/equatable.dart';
import 'package:smart_mask/src/logic/models/sensor_model.dart';

///////////////////////////////////////////////////////////////////////////////

abstract class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object> get props => [];
}

///////////////////////////////////////////////////////////////////////////////

class AnalyticsStateInitial extends AnalyticsState {}

///////////////////////////////////////////////////////////////////////////////

class AnalyticsStateSensorData extends AnalyticsState {
  final List<SensorData> data;

  AnalyticsStateSensorData({required this.data});

  @override
  List<Object> get props => [data];
}

///////////////////////////////////////////////////////////////////////////////

class AnalyticsStateSelectedsensor extends AnalyticsState {
  final Sensor sensor;

  AnalyticsStateSelectedsensor({required this.sensor});

  @override
  List<Object> get props => [sensor];
}

///////////////////////////////////////////////////////////////////////////////

class AnalyticsStateLowPass extends AnalyticsState {
  final double lowPassValue;

  AnalyticsStateLowPass({required this.lowPassValue});

  @override
  List<Object> get props => [lowPassValue];
}

///////////////////////////////////////////////////////////////////////////////

class AnalyticsStateHighPass extends AnalyticsState {
  final double highPassValue;

  AnalyticsStateHighPass({required this.highPassValue});

  @override
  List<Object> get props => [highPassValue];
}

///////////////////////////////////////////////////////////////////////////////

class AnalyticsStateFilterEnabled extends AnalyticsState {
  final bool isEnable;

  AnalyticsStateFilterEnabled({required this.isEnable});

  @override
  List<Object> get props => [isEnable];
}

///////////////////////////////////////////////////////////////////////////////

class AnalyticsStateTimeInTicks extends AnalyticsState {
  final int ticksIn1000;

  AnalyticsStateTimeInTicks({required this.ticksIn1000});

  @override
  List<Object> get props => [ticksIn1000];
}

///////////////////////////////////////////////////////////////////////////////

class AnalyticsStateError extends AnalyticsState {
  AnalyticsStateError();
}
