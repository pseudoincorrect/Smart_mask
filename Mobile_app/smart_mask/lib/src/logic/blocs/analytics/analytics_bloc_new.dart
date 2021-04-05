import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:smart_mask/src/logic/blocs/analytics/Analytics_logic.dart';
import 'package:smart_mask/src/logic/blocs/bloc.dart';
import 'package:smart_mask/src/logic/database/models/sensor_model.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  late AnalyticsLogic _logic;

  AnalyticsBloc() : super(InitialAnalyticsState()) {
    _logic = AnalyticsLogic();
  }

  @override
  Stream<AnalyticsState> mapEventToState(AnalyticsEvent event) async* {
    if (event is DataRefreshAnalyticsEvent) {
      yield* _mapDataRefreshAnalyticsEvent();
    } else if (event is ZoomIncAnalyticsEvent) {
      yield* _mapZoomIncAnalyticsEvent();
    } else if (event is ZoomDecAnalyticsEvent) {
      yield* _mapZoomDecAnalyticsEvent();
    } else if (event is TimeInTicksAnalyticsEvent) {
      yield* _mapTimeInTicksAnalyticsEvent(event);
    } else if (event is FilterEnabledAnalyticsEvent) {
      yield* _mapFilterEnabledAnalyticsEvent(event);
    } else if (event is LowPassAnalyticsEvent) {
      yield* _mapLowPassAnalyticsEvent(event);
    } else if (event is HighPassAnalyticsEvent) {
      yield* _mapHighPassAnalyticsEvent(event);
    } else if (event is SelectedSensorAnalyticsEvent) {
      yield* _mapSelectedSensorAnalyticsEvent(event);
    }
  }

  Stream<AnalyticsState> _mapDataRefreshAnalyticsEvent() async* {
    await _logic.getLatestSensorData();
    yield* _refreshData();
  }

  Stream<AnalyticsState> _mapZoomIncAnalyticsEvent() async* {
    _logic.increaseZoomLevel();
    yield* _refreshData();
  }

  Stream<AnalyticsState> _mapZoomDecAnalyticsEvent() async* {
    _logic.decreaseZoomLevel();
    yield* _refreshData();
  }

  Stream<AnalyticsState> _mapTimeInTicksAnalyticsEvent(
      TimeInTicksAnalyticsEvent event) async* {
    _logic.setTimefromInt(event.ticksIn1000);
    yield* _refreshData();
    yield TimeInTicksAnalyticsState(ticksIn1000: event.ticksIn1000)
  }

  Stream<AnalyticsState> _mapFilterEnabledAnalyticsEvent(
      FilterEnabledAnalyticsEvent event) async* {
    _logic.setTransform(event.filterEnabled);
    yield* _refreshData();
    yield FilterEnabledAnalyticsState(isEnable: event.filterEnabled);
  }

  Stream<AnalyticsState> _mapLowPassAnalyticsEvent(
      LowPassAnalyticsEvent event) async* {
    _logic.setLowPassFilter(event.lowPassValue);
    yield* _refreshData();
    yield LowPassAnalyticsState(lowPassValue: event.lowPassValue);
  }

  Stream<AnalyticsState> _mapHighPassAnalyticsEvent(
      HighPassAnalyticsEvent event) async* {
    _logic.setHighPassFilter(event.highPassValue);
    yield* _refreshData();
    yield HighPassAnalyticsState(highPassValue: event.highPassValue);
  }

  Stream<AnalyticsState> _mapSelectedSensorAnalyticsEvent(
      SelectedSensorAnalyticsEvent event) async* {
    await _logic.setSelectedSensor(event.selectedSensor);
    yield* _refreshData();
  }

  ///////////////////////////////////////////////////////

  Stream<AnalyticsState> _refreshData() async* {
    List<SensorData> sensorData = _logic.refreshAnalytics();
    var state = SensorDataAnalyticsState(data: sensorData);
    yield state;
  }
}
