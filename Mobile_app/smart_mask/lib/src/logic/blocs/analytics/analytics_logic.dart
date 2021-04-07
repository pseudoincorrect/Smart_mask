import 'dart:math';

// ignore: import_of_legacy_library_into_null_safe
import 'package:iirjdart/butterworth.dart';
import 'package:smart_mask/src/logic/models/sensor_model.dart';
import 'package:smart_mask/src/logic/models/time_interval.dart';
import 'package:smart_mask/src/logic/repositories/sensor_data_repo.dart';

const MAX_TIME_TICKS = 1000;
const MAX_ZOOM = 10;

class AnalyticsLogic {
  late AnalyticsLogicState _state;
  late SensorDataRepository _sensorDataRepo;
  late Sensor _selectedSensor;
  late bool _transform;

  AnalyticsLogic() {
    _sensorDataRepo = SensorDataRepository();
    _state = AnalyticsLogicState();
    _state.lowPassFilter = 0.01;
    _state.highPassFilter = 0;
    _transform = false;
    _selectedSensor = Sensor.sensor_1;
  }

  Future<List<SensorData>> getSensorData(TimeIntervalMsEpoch interval) async {
    List<SensorData> sensorData = await _sensorDataRepo.getSensorData(
      _selectedSensor,
      interval: interval,
    );
    return sensorData;
  }

  Future<TimeIntervalMsEpoch> getAvailableInterval() async {
    final start = await _sensorDataRepo.getOldestSensorData(_selectedSensor);
    final end = await _sensorDataRepo.getNewestSensorData(_selectedSensor);
    if (start == null || end == null) {
      var now = DateTime.now().millisecondsSinceEpoch;
      return TimeIntervalMsEpoch(start: now, end: now);
    }
    return TimeIntervalMsEpoch(start: start.timeStamp, end: end.timeStamp);
  }

  Future<void> getLatestSensorData() async {
    final ti = await getAvailableInterval();
    _state.dataRaw = await getSensorData(ti);
    _state.workTimeInterval = ti;
    _state.resetWorkInterval();
  }

  List<SensorData> refreshAnalytics() {
    if (_transform) _calculateTransform();
    calculateTimeWindow();
    return _getDataWindow();
  }

  _calculateTransform() {
    Butterworth butterworth = Butterworth();
    int order = 2;
    double sampleRate = 1 / (200 / 1000);
    double leftFreq = _state.highPassFilter;
    double rightFreq = _state.lowPassFilter;
    double centerFreq = (rightFreq - leftFreq) / 2;
    double widthFreq = rightFreq - leftFreq;

    butterworth.bandPass(order, sampleRate, centerFreq, widthFreq);
    double val;
    SensorData sensorData;
    _state.dataProcessed.clear();

    for (var s in _state.dataRaw) {
      val = butterworth.filter(s.value.toDouble());
      sensorData = SensorData.fromSensorAndValue(
          _selectedSensor, val.toInt(), s.timeStamp);
      _state.dataProcessed.add(sensorData);
    }
  }

  void calculateTimeWindow() {
    final startMs = _state.workTimeInterval.start;
    final endMs = _state.workTimeInterval.end;
    final posInTicks = _state.timePosInTicks;

    final centerMs =
        startMs + (posInTicks * (endMs - startMs) ~/ MAX_TIME_TICKS);

    final zoomDelta = (endMs - startMs) ~/ pow(2, _state.zoomLevel);
    var windowLeftMs = centerMs - zoomDelta;
    windowLeftMs = windowLeftMs > startMs ? windowLeftMs : startMs;
    var windowRightMs = centerMs + zoomDelta;
    windowRightMs = windowRightMs < endMs ? windowRightMs : endMs;

    _state.timeWindow =
        TimeIntervalMsEpoch(start: windowLeftMs, end: windowRightMs);
  }

  List<SensorData> _getDataWindow() {
    final leftMs = _state._timeWindow.start;
    final rightMs = _state._timeWindow.end;
    List<SensorData> winList = [];
    if (_transform) {
      winList = _state.dataProcessed
          .where((d) => d.timeStamp >= leftMs && d.timeStamp <= rightMs)
          .toList();
    } else {
      winList = _state.dataRaw
          .where((d) => d.timeStamp >= leftMs && d.timeStamp <= rightMs)
          .toList();
    }
    return winList;
  }

  Future<void> _changeSensor() async {
    final ti = await getAvailableInterval();
    _state.dataRaw = await getSensorData(ti);
  }

  Sensor get selectedSensor => _selectedSensor;

  Future<void> setSelectedSensor(Sensor sensor) async {
    _selectedSensor = sensor;
    await _changeSensor();
  }

  // toggleTransform() {
  //   _transform = !_transform;
  // }

  bool get filterEnabled => _transform;

  setTransform(bool value) {
    _transform = value;
  }

  // bool isTransformEnabled() {
  //   return _transform;
  // }

  double get lowPassFilter => _state.lowPassFilter;

  setLowPassFilter(double value) {
    _state.lowPassFilter = value;
  }

  double get highPassFilter => _state.highPassFilter;

  setHighPassFilter(double value) {
    _state.highPassFilter = value;
  }

  setTimefromInt(int value) {
    _state.timePosInTicks = value;
  }

  increaseZoomLevel() async {
    _state.zoomLevel += 1;
  }

  decreaseZoomLevel() {
    _state.zoomLevel -= 1;
  }
}

class AnalyticsLogicState {
  late List<SensorData> dataRaw;
  late List<SensorData> dataProcessed;
  late TimeIntervalMsEpoch _workTimeInterval;
  late TimeIntervalMsEpoch _timeWindow;
  late int _timePosInTicks;
  late int _zoomLevel;
  late double _lowPassFilter;
  late double _highPassFilter;

  AnalyticsLogicState() {
    dataRaw = [];
    dataProcessed = [];
    _lowPassFilter = 100.0;
    _highPassFilter = 0.2;
    _workTimeInterval = TimeIntervalMsEpoch(
      start: DateTime.now().millisecondsSinceEpoch,
      end: DateTime.now().millisecondsSinceEpoch,
    );
    resetWorkInterval();
  }

  double get lowPassFilter => _lowPassFilter;

  set lowPassFilter(double value) {
    if (value > 0 || value > _highPassFilter || value < 10000)
      _lowPassFilter = value;
  }

  double get highPassFilter => _highPassFilter;

  set highPassFilter(double value) {
    if (value > 0 || value < _lowPassFilter || value < 10000)
      _highPassFilter = value;
  }

  int get zoomLevel => _zoomLevel;

  set zoomLevel(int value) {
    if (value > 0 && value < MAX_ZOOM) _zoomLevel = value;
  }

  int get timePosInTicks => _timePosInTicks;

  set timePosInTicks(int value) {
    if (value > 0 && value <= MAX_TIME_TICKS) _timePosInTicks = value;
  }

  TimeIntervalMsEpoch get workTimeInterval => _workTimeInterval;

  set workTimeInterval(TimeIntervalMsEpoch ti) {
    var start = ti.start;
    var end = ti.end;
    // start is max one hour before end

    if (ti.start < (ti.end - Duration(hours: 1).inMilliseconds))
      start = ti.end - Duration(hours: 1).inMilliseconds;

    _workTimeInterval = TimeIntervalMsEpoch(start: start, end: end);
  }

  TimeIntervalMsEpoch get timeWindow => _timeWindow;

  set timeWindow(TimeIntervalMsEpoch interval) {
    final startMs = interval.start;
    final endMs = interval.end;
    final wStartMs = _workTimeInterval.start;
    final wEndMs = _workTimeInterval.end;

    if (startMs >= wStartMs && endMs <= wEndMs) _timeWindow = interval;
  }

  resetWorkInterval() {
    _timeWindow = _workTimeInterval;
    _zoomLevel = 0;
    _timePosInTicks = MAX_TIME_TICKS;
  }
}
