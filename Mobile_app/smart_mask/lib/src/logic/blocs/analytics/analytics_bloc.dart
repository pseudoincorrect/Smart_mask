//  Sensor Data Analytic Business Logic (BLoc) provider
//
//  Description:
//    BLoc to navigate and filter sensor data

import 'dart:async';
import 'dart:math';

// ignore: import_of_legacy_library_into_null_safe
import 'package:iirjdart/butterworth.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:rxdart/rxdart.dart';
import 'package:smart_mask/src/logic/database/models/sensor_model.dart';
import 'package:smart_mask/src/logic/repositories/sensor_data_repo.dart';

const MAX_TIME_TICKS = 1000;
const MAX_ZOOM = 10;

class AnalyticsBloc {
  final _sensorDataRepo = SensorDataRepository();
  Sensor _selectedSensor = Sensor.sensor_1;
  late AnalyticsState _analyticsState;

  late BehaviorSubject<List<SensorData>> _sensorDataSubject;
  late bool _transform;

  AnalyticsBloc() {
    _sensorDataSubject = BehaviorSubject<List<SensorData>>();
    setSelectedSensor(_selectedSensor);
    _transform = false;
    _analyticsState = AnalyticsState();
    _analyticsState.lowPassFilter = 0.5;
    _analyticsState.highPassFilter = 0.01;
  }

  Future<TimeInterval> getAvailableInterval() async {
    final start = await _sensorDataRepo.getOldestSensorData(_selectedSensor);
    final end = await _sensorDataRepo.getNewestSensorData(_selectedSensor);
    if (start == null || end == null) {
      var now = DateTime.now().millisecondsSinceEpoch;
      return TimeInterval(now, now);
    }
    return TimeInterval(start.timeStamp, end.timeStamp);
  }

  List<SensorData> getDataWindow() {
    final leftMs = _analyticsState._timeWindow.start;
    final rightMs = _analyticsState._timeWindow.end;
    List<SensorData> winList = [];
    if (_transform) {
      winList = _analyticsState.dataProcessed
          .where((d) => d.timeStamp >= leftMs && d.timeStamp <= rightMs)
          .toList();
    } else {
      winList = _analyticsState.dataRaw
          .where((d) => d.timeStamp >= leftMs && d.timeStamp <= rightMs)
          .toList();
    }
    return winList;
  }

  refreshAnalytics() async {
    calculateTimeWindow();
    _sensorDataSubject.sink.add(getDataWindow());
  }

  processTransformAndRefreshAnalytics() async {
    calculateTransform();
    refreshAnalytics();
  }

  calculateTransform() async {
    Butterworth butterworth = Butterworth();
    int order = 2;
    double sampleRate = 1 / (200 / 1000);
    double leftFreq = _analyticsState.highPassFilter;
    double rightFreq = _analyticsState.lowPassFilter;
    double centerFreq = (rightFreq - leftFreq) / 2;
    double widthFreq = rightFreq - leftFreq;

    butterworth.bandPass(order, sampleRate, centerFreq, widthFreq);
    double val;
    SensorData sensorData;
    _analyticsState.dataProcessed.clear();

    for (var s in _analyticsState.dataRaw) {
      val = butterworth.filter(s.value.toDouble());
      sensorData = SensorData.fromSensorAndValue(
          _selectedSensor, val.toInt(), s.timeStamp);
      _analyticsState.dataProcessed.add(sensorData);
    }
  }

  Future<List<SensorData>> getSensorData(TimeInterval interval) async {
    final start = DateTime.fromMillisecondsSinceEpoch(interval.start);
    final end = DateTime.fromMillisecondsSinceEpoch(interval.end);
    List<SensorData> sensorData = await _sensorDataRepo.getSensorData(
      _selectedSensor,
      interval: [start, end],
    );
    return sensorData;
  }

  Stream<List<SensorData>> getSensorDataStream() {
    return _sensorDataSubject.stream;
  }

  void calculateTimeWindow() {
    final startMs = _analyticsState.workTimeInterval.start;
    final endMs = _analyticsState.workTimeInterval.end;
    final posInTicks = _analyticsState.timePosInTicks;

    final centerMs =
        startMs + (posInTicks * (endMs - startMs) ~/ MAX_TIME_TICKS);

    final zoomDelta = (endMs - startMs) ~/ pow(2, _analyticsState.zoomLevel);
    var windowLeftMs = centerMs - zoomDelta;
    windowLeftMs = windowLeftMs > startMs ? windowLeftMs : startMs;
    var windowRightMs = centerMs + zoomDelta;
    windowRightMs = windowRightMs < endMs ? windowRightMs : endMs;

    _analyticsState.timeWindow = TimeInterval(windowLeftMs, windowRightMs);
  }

  void changeSensor() async {
    final ti = await getAvailableInterval();
    _analyticsState.dataRaw = await getSensorData(ti);
    processTransformAndRefreshAnalytics();
  }

  void refreshSensorData() async {
    final ti = await getAvailableInterval();
    _analyticsState.dataRaw = await getSensorData(ti);
    _analyticsState.workTimeInterval = ti;
    _analyticsState.resetWorkInterval();
    if (_transform)
      processTransformAndRefreshAnalytics();
    else
      refreshAnalytics();
  }

  get selectedSensor => _selectedSensor;

  void setSelectedSensor(Sensor sensor) {
    _selectedSensor = sensor;
    changeSensor();
  }

  toggleTransform() {
    _transform = !_transform;
    processTransformAndRefreshAnalytics();
  }

  bool isTransformEnabled() {
    return _transform;
  }

  double get lowPassFilter => _analyticsState.lowPassFilter;

  setLowPassFilter(double value) {
    _analyticsState.lowPassFilter = value;
    processTransformAndRefreshAnalytics();
  }

  double get highPassFilter => _analyticsState.highPassFilter;

  setHighPassFilter(double value) {
    _analyticsState.highPassFilter = value;
    processTransformAndRefreshAnalytics();
  }

  setTimefromInt(int value) async {
    _analyticsState.timePosInTicks = value;
    refreshAnalytics();
  }

  increaseZoomLevel() async {
    _analyticsState.zoomLevel += 1;
    refreshAnalytics();
  }

  decreaseZoomLevel() {
    _analyticsState.zoomLevel -= 1;
    refreshAnalytics();
  }

  saveProcessedData() {
    print("saveProcessedData");
  }

  saveRawData() {
    print("saveRawData");
  }

  dispose() {
    _sensorDataSubject.close();
  }
}

class TimeInterval {
  late int start;
  late int end;

  TimeInterval(this.start, this.end);

// factory TimeInterval.fromMsSinceEpoch(RangeValues range) {
//   DateTime dateStart =
//       DateTime.fromMillisecondsSinceEpoch(range.start.toInt());
//   DateTime dateEnd = DateTime.fromMillisecondsSinceEpoch(range.end.toInt());
//   return TimeInterval(dateStart, dateEnd);
// }
}

class AnalyticsState {
  late List<SensorData> dataRaw;
  late List<SensorData> dataProcessed;
  late TimeInterval _workTimeInterval;
  late TimeInterval _timeWindow;
  late int _timePosInTicks;
  late int _zoomLevel;
  late double _lowPassFilter;
  late double _highPassFilter;

  AnalyticsState() {
    dataRaw = [];
    dataProcessed = [];
    _lowPassFilter = 100.0;
    _highPassFilter = 0.2;
    _workTimeInterval = TimeInterval(
      DateTime.now().millisecondsSinceEpoch,
      DateTime.now().millisecondsSinceEpoch,
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

  TimeInterval get workTimeInterval => _workTimeInterval;

  set workTimeInterval(TimeInterval ti) {
    var start = ti.start;
    var end = ti.end;
    // start is max one hour before end

    if (ti.start < (ti.end - Duration(hours: 1).inMilliseconds))
      start = ti.end - Duration(hours: 1).inMilliseconds;

    _workTimeInterval = TimeInterval(start, end);
  }

  TimeInterval get timeWindow => _timeWindow;

  set timeWindow(TimeInterval interval) {
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
