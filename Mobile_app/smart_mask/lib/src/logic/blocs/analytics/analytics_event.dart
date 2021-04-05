import 'package:equatable/equatable.dart';
import 'package:smart_mask/src/logic/database/models/sensor_model.dart';

///////////////////////////////////////////////////////////////////////////////

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object> get props => [];
}

///////////////////////////////////////////////////////////////////////////////

class DataRefreshAnalyticsEvent extends AnalyticsEvent {}

///////////////////////////////////////////////////////////////////////////////

class ZoomIncAnalyticsEvent extends AnalyticsEvent {}

///////////////////////////////////////////////////////////////////////////////

class ZoomDecAnalyticsEvent extends AnalyticsEvent {}

///////////////////////////////////////////////////////////////////////////////

class TimeInTicksAnalyticsEvent extends AnalyticsEvent {
  final int ticksIn1000;

  const TimeInTicksAnalyticsEvent({required this.ticksIn1000});

  @override
  List<Object> get props => [ticksIn1000];
}

///////////////////////////////////////////////////////////////////////////////

class FilterEnabledAnalyticsEvent extends AnalyticsEvent {
  final bool filterEnabled;

  const FilterEnabledAnalyticsEvent({required this.filterEnabled});

  @override
  List<Object> get props => [filterEnabled];
}

///////////////////////////////////////////////////////////////////////////////

class LowPassAnalyticsEvent extends AnalyticsEvent {
  final double lowPassValue;

  const LowPassAnalyticsEvent({required this.lowPassValue});

  @override
  List<Object> get props => [lowPassValue];
}

///////////////////////////////////////////////////////////////////////////////

class HighPassAnalyticsEvent extends AnalyticsEvent {
  final double highPassValue;

  const HighPassAnalyticsEvent({required this.highPassValue});

  @override
  List<Object> get props => [highPassValue];
}

///////////////////////////////////////////////////////////////////////////////

class SelectedSensorAnalyticsEvent extends AnalyticsEvent {
  final Sensor selectedSensor;

  const SelectedSensorAnalyticsEvent({required this.selectedSensor});

  @override
  List<Object> get props => [selectedSensor];
}
