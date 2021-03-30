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
  AnalyticsState _analyticsState = AnalyticsState();

  BehaviorSubject<Sensor> _selectedSensorSubject;
  BehaviorSubject<TimeInterval> _timeRangeSubject;
  BehaviorSubject<List<SensorData>> _sensorDataProcessedSubject;
  BehaviorSubject<bool> _analyticsRefresh;

  AnalyticsBloc() {
    _selectedSensorSubject = BehaviorSubject<Sensor>();
    _timeRangeSubject = BehaviorSubject<TimeInterval>();
    _sensorDataProcessedSubject = BehaviorSubject<List<SensorData>>();
    _analyticsRefresh = BehaviorSubject<bool>();
    _analyticsRefresh.stream.listen((event) => processAnalytics());
    setSelectedSensor(_selectedSensor);
  }

  processAnalytics() {
    print(_analyticsState.toString());
  }

  Future<TimeInterval> getAvailableInterval() async {
    var start = await _sensorDataRepo.getEarliestSensorData(_selectedSensor);
    var end = await _sensorDataRepo.getLatestSensorData(_selectedSensor);
    var startDate = DateTime.fromMillisecondsSinceEpoch(start.timeStamp);
    var endDate = DateTime.fromMillisecondsSinceEpoch(end.timeStamp);
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

  setTime(int value) {
    _analyticsState.time = value;
    triggerAnalyticsRefresh();
  }

  increaseZoomLevel() {
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
  DateTime start;
  DateTime end;

  TimeInterval(this.start, this.end);

  factory TimeInterval.fromMsSinceEpoch(RangeValues range) {
    DateTime dateStart =
        DateTime.fromMicrosecondsSinceEpoch(range.start.toInt());
    DateTime dateEnd = DateTime.fromMicrosecondsSinceEpoch(range.end.toInt());
    return TimeInterval(dateStart, dateEnd);
  }
}

class AnalyticsState {
  int _time;
  int _zoomLevel;
  double _lowPassFilter;
  double _highPassFilter;

  AnalyticsState() {
    _time = DateTime.now().millisecondsSinceEpoch;
    _zoomLevel = 0;
    _lowPassFilter = 100.0;
    _highPassFilter = 0.2;
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

  int get time => _time;

  set time(int value) {
    int nowMs = DateTime.now().millisecondsSinceEpoch;
    int nowMinus1monthMs =
        DateTime.now().subtract(Duration(days: 30)).millisecondsSinceEpoch;
    if (value > nowMs || value < nowMinus1monthMs) return;
    _time = value;
  }

  int get zoomLevel => _zoomLevel;

  set zoomLevel(int value) {
    if (value < 0 || value > 15) return;
    _zoomLevel = value;
  }

  @override
  String toString() {
    return "Analytics State ${DateTime.fromMillisecondsSinceEpoch(_time)}, "
        "Zoom level : $_zoomLevel, Low pass $_lowPassFilter, High pass $_highPassFilter";
  }
}
