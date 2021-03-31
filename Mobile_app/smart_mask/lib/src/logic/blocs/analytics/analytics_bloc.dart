//  Sensor Data Business Logic (BLoc) provider
//
//  Description:
//

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:smart_mask/src/logic/database/models/sensor_model.dart';
import 'package:smart_mask/src/logic/repositories/sensor_data_repo.dart';

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

    print("analytics state preparation");
    var interval = getAvailableInterval();
    interval.then((interval) {
      _analyticsState = AnalyticsState(interval);
      print("analytics state set");
    });
  }

  processAnalytics() {
    print(_analyticsState.toString());
  }

  Future<TimeInterval> getAvailableInterval() async {
    print("hey 1");
    var start = await _sensorDataRepo.getOldestSensorData(_selectedSensor);
    var end = await _sensorDataRepo.getNewestSensorData(_selectedSensor);
    if (start == null || end == null)
      return TimeInterval(DateTime.now(), DateTime.now());

    var startDate = DateTime.fromMillisecondsSinceEpoch(start.timeStamp);
    var endDate = DateTime.fromMillisecondsSinceEpoch(end.timeStamp);
    print("hey 2");
    return TimeInterval(startDate, endDate);
  }

  getSensorData(TimeInterval interval) async {
    List<SensorData> sensorData = await _sensorDataRepo.getSensorData(
      _selectedSensor,
      interval: [interval.start, interval.end],
    );
    _sensorDataProcessedSubject.sink.add(sensorData);
  }

  Stream<List<SensorData>> getSensorDataStream() {
    return _sensorDataProcessedSubject.stream;
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
    var ti = await getAvailableInterval();
    print("start interval ${ti.start}");
    print("end interval ${ti.end}");
    triggerAnalyticsRefresh();
  }

  increaseZoomLevel() {
    // _analyticsState.zoomLevel += 1;
    getAvailableInterval();
    // setTimefromInt(0);
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
  late TimeInterval _workTimeInterval;
  late DateTime _time;
  late int _zoomLevel;
  late double _lowPassFilter;
  late double _highPassFilter;

  AnalyticsState(TimeInterval workTi) {
    _zoomLevel = 0;
    _lowPassFilter = 100.0;
    _highPassFilter = 0.2;
    workTimeInterval = workTi;
    int startMs = workTi.start.millisecondsSinceEpoch;
    int endMs = workTi.end.millisecondsSinceEpoch;
    _time = DateTime.fromMillisecondsSinceEpoch((endMs - startMs) ~/ 2);
  }

  double get lowPassFilter => _lowPassFilter;

  set lowPassFilter(double value) {
    if (value < 0 || value <= _highPassFilter || value > 10000) return;
    _lowPassFilter = value;
  }

  double get highPassFilter => _highPassFilter;

  set highPassFilter(double value) {
    if (value < 0 || value >= _lowPassFilter || value > 10000) return;
    _highPassFilter = value;
  }

  DateTime get time => _time;

  set time(DateTime value) {
    if (value.isAfter(DateTime.now())) return;
    if (value.isBefore(DateTime.now().subtract(Duration(days: 30)))) return;
    _time = value;
  }

  int get zoomLevel => _zoomLevel;

  set zoomLevel(int value) {
    if (value < 0 || value > 15) return;
    _zoomLevel = value;
  }

  TimeInterval get workTimeInteral => _workTimeInterval;

  set workTimeInterval(TimeInterval ti) {
    var start = ti.start;
    var end = ti.end;
    if (ti.start.isBefore(ti.end.subtract(Duration(hours: 1))))
      start = ti.end.subtract(Duration(hours: 1));
    _workTimeInterval = TimeInterval(start, end);
  }

  @override
  String toString() {
    return "Analytics State $_time, "
        "Zoom level : $_zoomLevel, Low pass $_lowPassFilter, High pass $_highPassFilter";
  }
}
