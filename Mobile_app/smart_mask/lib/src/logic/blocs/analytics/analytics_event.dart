import 'package:equatable/equatable.dart';
import 'package:smart_mask/src/logic/database/models/sensor_model.dart';

///////////////////////////////////////////////////////////////////////////////

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object> get props => [];
}

///////////////////////////////////////////////////////////////////////////////

class AnalyticsEventRefresh extends AnalyticsEvent {}

///////////////////////////////////////////////////////////////////////////////

class AnalyticsEventDataRefresh extends AnalyticsEvent {}

///////////////////////////////////////////////////////////////////////////////

class AnalyticsEventZoomInc extends AnalyticsEvent {}

///////////////////////////////////////////////////////////////////////////////

class AnalyticsEventZoomDec extends AnalyticsEvent {}

///////////////////////////////////////////////////////////////////////////////

class AnalyticsEventTimeInTicks extends AnalyticsEvent {
  final int ticksIn1000;

  const AnalyticsEventTimeInTicks({required this.ticksIn1000});

  @override
  List<Object> get props => [ticksIn1000];
}

///////////////////////////////////////////////////////////////////////////////

class AnalyticsEventFilterEnabled extends AnalyticsEvent {
  final bool filterEnabled;

  const AnalyticsEventFilterEnabled({required this.filterEnabled});

  @override
  List<Object> get props => [filterEnabled];
}

///////////////////////////////////////////////////////////////////////////////

class AnalyticsEventLowPass extends AnalyticsEvent {
  final double lowPassValue;

  const AnalyticsEventLowPass({required this.lowPassValue});

  @override
  List<Object> get props => [lowPassValue];
}

///////////////////////////////////////////////////////////////////////////////

class AnalyticsEventHighPass extends AnalyticsEvent {
  final double highPassValue;

  const AnalyticsEventHighPass({required this.highPassValue});

  @override
  List<Object> get props => [highPassValue];
}

///////////////////////////////////////////////////////////////////////////////

class AnalyticsEventSelectedSensor extends AnalyticsEvent {
  final Sensor sensor;

  const AnalyticsEventSelectedSensor({required this.sensor});

  @override
  List<Object> get props => [sensor];
}
