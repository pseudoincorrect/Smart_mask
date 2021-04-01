//  Sensor Data Business Logic (BLoc) provider
//
//  Description:
//

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

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

  late BehaviorSubject<Sensor> _selectedSensorSubject;
  late BehaviorSubject<TimeInterval> _timeRangeSubject;
  late BehaviorSubject<List<SensorData>> _sensorDataProcessedSubject;
  late BehaviorSubject<bool> _analyticsRefresh;

  AnalyticsBloc() {
    _selectedSensorSubject = BehaviorSubject<Sensor>();
    _timeRangeSubject = BehaviorSubject<TimeInterval>();
    _sensorDataProcessedSubject = BehaviorSubject<List<SensorData>>();
    _analyticsRefresh = BehaviorSubject<bool>();
    _analyticsRefresh.stream.listen((event) => processAnalytics());
    setSelectedSensor(_selectedSensor);
    _analyticsState = AnalyticsState();
  }

  Future<TimeInterval> getAvailableInterval() async {
    final start = await _sensorDataRepo.getOldestSensorData(_selectedSensor);
    final end = await _sensorDataRepo.getNewestSensorData(_selectedSensor);
    if (start == null || end == null)
      return TimeInterval(DateTime.now(), DateTime.now());

    final startDate = DateTime.fromMillisecondsSinceEpoch(start.timeStamp);
    final endDate = DateTime.fromMillisecondsSinceEpoch(end.timeStamp);
    return TimeInterval(startDate, endDate);
  }

  List<SensorData> getDataWindow() {
    final leftMs = _analyticsState._timeWindow.start.millisecondsSinceEpoch;
    final rightMs = _analyticsState._timeWindow.end.millisecondsSinceEpoch;
    final winList = _analyticsState.dataRaw
        .where((d) => d.timeStamp >= leftMs && d.timeStamp <= rightMs)
        .toList();
    return winList;
  }

  processAnalytics() async {
    calculateTimeWindow();
    _sensorDataProcessedSubject.sink.add(getDataWindow());
    // _sensorDataProcessedSubject.sink.add(_analyticsState.dataRaw);
  }

  Future<List<SensorData>> getSensorData(TimeInterval interval) async {
    List<SensorData> sensorData = await _sensorDataRepo.getSensorData(
      _selectedSensor,
      interval: [interval.start, interval.end],
    );
    return sensorData;
  }

  Stream<List<SensorData>> getSensorDataStream() {
    return _sensorDataProcessedSubject.stream;
  }

  void calculateTimeWindow() {
    final startMs =
        _analyticsState.workTimeInterval.start.millisecondsSinceEpoch;
    final endMs = _analyticsState.workTimeInterval.end.millisecondsSinceEpoch;
    final posInTicks = _analyticsState.timePosInTicks;

    final centerMs =
        startMs + (posInTicks * (endMs - startMs) ~/ MAX_TIME_TICKS);

    final zoomDelta = (endMs - startMs) ~/ pow(2, _analyticsState.zoomLevel);
    var windowLeftMs = centerMs - zoomDelta;
    windowLeftMs = windowLeftMs > startMs ? windowLeftMs : startMs;
    var windowRightMs = centerMs + zoomDelta;
    windowRightMs = windowRightMs < endMs ? windowRightMs : endMs;

    _analyticsState._timeWindow.start =
        DateTime.fromMillisecondsSinceEpoch(windowLeftMs);
    _analyticsState._timeWindow.end =
        DateTime.fromMillisecondsSinceEpoch(windowRightMs);

    _analyticsState.timeWindow = TimeInterval(
        DateTime.fromMillisecondsSinceEpoch(windowLeftMs),
        DateTime.fromMillisecondsSinceEpoch(windowRightMs));

    print(
        "time windows : ${_analyticsState._timeWindow.start.minute}:${_analyticsState._timeWindow.start.second}"
        " to ${_analyticsState._timeWindow.end.minute}:${_analyticsState._timeWindow.end.second}");
  }

  void refreshSensorData() async {
    final ti = await getAvailableInterval();
    _analyticsState.dataRaw = await getSensorData(ti);
    _analyticsState.workTimeInterval = ti;
    _analyticsState.resetWorkInterval();
    triggerAnalyticsRefresh();
  }

  Stream<TimeInterval> get timeRangeStream => _timeRangeSubject.stream;

  set timeRange(TimeInterval interval) {
    _timeRangeSubject.add(interval);
    getSensorData(interval);
  }

  void setSelectedSensor(Sensor sensor) {
    _selectedSensorSubject.add(sensor);
  }

  Stream<Sensor> getSelectedSensorStream() {
    return _selectedSensorSubject.stream;
  }

  Stream<bool> getAnalyticsRefreshStream() {
    return _analyticsRefresh.stream;
  }

  triggerAnalyticsRefresh() {
    _analyticsRefresh.add(true);
  }

  setLowPassFilter(double value) {
    _analyticsState.lowPassFilter = value;
    triggerAnalyticsRefresh();
  }

  setHighPassFilter(double value) {
    _analyticsState.highPassFilter = value;
    triggerAnalyticsRefresh();
  }

  setTimefromInt(int value) async {
    _analyticsState.timePosInTicks = value;
    triggerAnalyticsRefresh();
  }

  increaseZoomLevel() async {
    _analyticsState.zoomLevel += 1;
    triggerAnalyticsRefresh();
  }

  decreaseZoomLevel() {
    _analyticsState.zoomLevel -= 1;
    triggerAnalyticsRefresh();
  }

  saveProcessedData() {
    print("saveProcessedData");
  }

  saveRawData() {
    print("saveRawData");
  }

  dispose() {
    _sensorDataProcessedSubject.close();
    _selectedSensorSubject.close();
    _timeRangeSubject.close();
  }
}

class TimeInterval {
  late DateTime start;
  late DateTime end;

  TimeInterval(this.start, this.end);

  factory TimeInterval.fromMsSinceEpoch(RangeValues range) {
    DateTime dateStart =
        DateTime.fromMillisecondsSinceEpoch(range.start.toInt());
    DateTime dateEnd = DateTime.fromMillisecondsSinceEpoch(range.end.toInt());
    return TimeInterval(dateStart, dateEnd);
  }
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
    _workTimeInterval = TimeInterval(DateTime.now(), DateTime.now());
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
    if (ti.start.isBefore(ti.end.subtract(Duration(hours: 1))))
      start = ti.end.subtract(Duration(hours: 1));

    _workTimeInterval = TimeInterval(start, end);
  }

  TimeInterval get timeWindow => _timeWindow;

  set timeWindow(TimeInterval interval) {
    final startMs = interval.start.millisecondsSinceEpoch;
    final endMs = interval.end.millisecondsSinceEpoch;
    final wStartMs = _workTimeInterval.start.millisecondsSinceEpoch;
    final wEndMs = _workTimeInterval.end.millisecondsSinceEpoch;

    if (startMs >= wStartMs && endMs <= wEndMs) _timeWindow = interval;
  }

  resetWorkInterval() {
    _timeWindow = _workTimeInterval;
    _zoomLevel = 0;
    _timePosInTicks = MAX_TIME_TICKS;
  }
}
