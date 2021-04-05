import 'package:equatable/equatable.dart';
import 'package:smart_mask/src/logic/database/models/sensor_model.dart';

///////////////////////////////////////////////////////////////////////////////

abstract class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object> get props => [];
}

///////////////////////////////////////////////////////////////////////////////

class InitialAnalyticsState extends AnalyticsState {}

///////////////////////////////////////////////////////////////////////////////

class SensorDataAnalyticsState extends AnalyticsState {
  final List<SensorData> data;

  SensorDataAnalyticsState({required this.data});

  @override
  List<Object> get props => [data];
}

///////////////////////////////////////////////////////////////////////////////

class LowPassAnalyticsState extends AnalyticsState {
  final double lowPassValue;

  LowPassAnalyticsState({required this.lowPassValue});

  @override
  List<Object> get props => [lowPassValue];
}

///////////////////////////////////////////////////////////////////////////////

class HighPassAnalyticsState extends AnalyticsState {
  final double highPassValue;

  HighPassAnalyticsState({required this.highPassValue});

  @override
  List<Object> get props => [highPassValue];
}

///////////////////////////////////////////////////////////////////////////////

class FilterEnabledAnalyticsState extends AnalyticsState {
  final bool isEnable;

  FilterEnabledAnalyticsState({required this.isEnable});

  @override
  List<Object> get props => [isEnable];
}

///////////////////////////////////////////////////////////////////////////////

class TimeInTicksAnalyticsState extends AnalyticsState {
  final int ticksIn1000;

  TimeInTicksAnalyticsState({required this.ticksIn1000});

  @override
  List<Object> get props => [ticksIn1000];
}

///////////////////////////////////////////////////////////////////////////////

class ErrorAnalyticsState extends AnalyticsState {
  ErrorAnalyticsState();
}
