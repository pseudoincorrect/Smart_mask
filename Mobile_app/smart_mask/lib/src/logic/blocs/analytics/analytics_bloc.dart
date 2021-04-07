import 'package:bloc/bloc.dart';
import 'package:smart_mask/src/logic/blocs/analytics/analytics_logic.dart';
import 'package:smart_mask/src/logic/blocs/bloc.dart';
import 'package:smart_mask/src/logic/models/sensor_model.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  late AnalyticsLogic _logic;

  AnalyticsBloc() : super(AnalyticsStateInitial()) {
    _logic = AnalyticsLogic();
    this.add(AnalyticsEventRefresh());
  }

  @override
  Stream<AnalyticsState> mapEventToState(event) async* {
    if (event is AnalyticsEventRefresh) {
      yield* _mapAnalyticsEventRefresh();
    } else if (event is AnalyticsEventDataRefresh) {
      yield* _mapAnalyticsEventDataRefresh();
    } else if (event is AnalyticsEventZoomInc) {
      yield* _mapAnalyticsEventZoomInc();
    } else if (event is AnalyticsEventZoomDec) {
      yield* _mapAnalyticsEventZoomDec();
    } else if (event is AnalyticsEventTimeInTicks) {
      yield* _mapAnalyticsEventTimeInTicks(event);
    } else if (event is AnalyticsEventFilterEnabled) {
      yield* _mapAnalyticsEventFilterEnabled(event);
    } else if (event is AnalyticsEventLowPass) {
      yield* _mapAnalyticsEventLowPass(event);
    } else if (event is AnalyticsEventHighPass) {
      yield* _mapAnalyticsEventHighPass(event);
    } else if (event is AnalyticsEventSelectedSensor) {
      yield* _mapAnalyticsEventSelectedSensor(event);
    }
  }

  Stream<AnalyticsState> _mapAnalyticsEventRefresh() async* {
    this.add(AnalyticsEventSelectedSensor(sensor: _logic.selectedSensor));
    this.add(AnalyticsEventFilterEnabled(filterEnabled: _logic.filterEnabled));
    this.add(AnalyticsEventLowPass(lowPassValue: _logic.lowPassFilter));
    this.add(AnalyticsEventHighPass(highPassValue: _logic.highPassFilter));
  }

  Stream<AnalyticsState> _mapAnalyticsEventDataRefresh() async* {
    await _logic.getLatestSensorData();
    yield* _refreshData();
  }

  Stream<AnalyticsState> _mapAnalyticsEventZoomInc() async* {
    _logic.increaseZoomLevel();
    yield* _refreshData();
  }

  Stream<AnalyticsState> _mapAnalyticsEventZoomDec() async* {
    _logic.decreaseZoomLevel();
    yield* _refreshData();
  }

  Stream<AnalyticsState> _mapAnalyticsEventTimeInTicks(
      AnalyticsEventTimeInTicks event) async* {
    _logic.setTimefromInt(event.ticksIn1000);
    yield* _refreshData();
    yield AnalyticsStateTimeInTicks(ticksIn1000: event.ticksIn1000);
  }

  Stream<AnalyticsState> _mapAnalyticsEventFilterEnabled(
      AnalyticsEventFilterEnabled event) async* {
    _logic.setTransform(event.filterEnabled);
    yield* _refreshData();
    yield AnalyticsStateFilterEnabled(isEnable: event.filterEnabled);
  }

  Stream<AnalyticsState> _mapAnalyticsEventLowPass(
      AnalyticsEventLowPass event) async* {
    _logic.setLowPassFilter(event.lowPassValue);
    yield* _refreshData();
    yield AnalyticsStateLowPass(lowPassValue: event.lowPassValue);
  }

  Stream<AnalyticsState> _mapAnalyticsEventHighPass(
      AnalyticsEventHighPass event) async* {
    _logic.setHighPassFilter(event.highPassValue);
    yield* _refreshData();
    yield AnalyticsStateHighPass(highPassValue: event.highPassValue);
  }

  Stream<AnalyticsState> _mapAnalyticsEventSelectedSensor(
      AnalyticsEventSelectedSensor event) async* {
    await _logic.setSelectedSensor(event.sensor);
    yield* _refreshData();
    yield AnalyticsStateSelectedsensor(sensor: event.sensor);
  }

  ///////////////////////////////////////////////////////

  Stream<AnalyticsState> _refreshData() async* {
    List<SensorData> sensorData = _logic.refreshAnalytics();
    var state = AnalyticsStateSensorData(data: sensorData);
    yield state;
  }
}
