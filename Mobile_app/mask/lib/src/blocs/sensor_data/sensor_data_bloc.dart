//  Sensor Data Business Logic (BLoc) provider
//
//  Description:
//      Enable the access to sensor data (streams) through the app
//      Used by the widget to get automatically refreshed with
//      arriving sensor data (with update timers) and to do basic
//      opperation (insert, delete) on these data.

import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:mask/src/database/models/sensor_model.dart';
import 'package:mask/src/repositories/sensor_data_repo.dart';

class SensorDataBloc {
  final _sensorDataRepo = SensorDataRepository();
  Duration windowInterval = Duration(seconds: 10);
  Duration refreshInterval = Duration(seconds: 1);

  Map<Sensor, BehaviorSubject<List<SensorData>>> _sensorDataSubjects = Map();
  Map<Sensor, Stream<List<SensorData>>> _sensorDataStreams = Map();

  SensorDataBloc() {
    for (var i = 0; i < Sensor.values.length; i++) {
      _sensorDataSubjects[Sensor.values[i]] =
          BehaviorSubject<List<SensorData>>();

      _sensorDataStreams[Sensor.values[i]] =
          _sensorDataSubjects[Sensor.values[i]].stream;
    }

    setupTimers(refreshInterval);
  }

  getSensorData(Sensor sensor, {List<DateTime> interval}) async {
    _sensorDataSubjects[sensor].sink.add(await _sensorDataRepo.getSensorData(
          sensor,
          interval: interval,
        ));
  }

  Stream<List<SensorData>> getStream(Sensor sensor) {
    return _sensorDataStreams[sensor];
  }

  addSensorData(SensorData sensorData) async {
    await _sensorDataRepo.insertSensorData(sensorData);
  }

  deleteAllSensorData() async {
    await _sensorDataRepo.deleteAllSensorData();
  }

  setupTimers(Duration refreshInterval) {
    for (var index = 0; index < Sensor.values.length; index++) {
      Sensor sensor = Sensor.values[index];
      startTimeout(refreshInterval, sensor);
    }
  }

  startTimeout(Duration refreshInterval, Sensor sensor) {
    return new Timer.periodic(
        refreshInterval, (Timer t) => sensorRefreshTimeout(sensor));
  }

  void sensorRefreshTimeout(Sensor sensor) {
    this.getSensorData(sensor,
        interval: [DateTime.now().subtract(windowInterval), DateTime.now()]);
  }

  dispose() {
    for (var i = 0; i < Sensor.values.length; i++) {
      _sensorDataSubjects[Sensor.values[i]].close();
    }
  }
}