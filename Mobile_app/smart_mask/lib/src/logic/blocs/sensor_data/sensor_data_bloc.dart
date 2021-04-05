//  Sensor Data Business Logic (BLoc) provider
//
//  Description:
//      Enable the access to sensor data (streams) through the app
//      Used by the widget to get automatically refreshed with
//      arriving sensor data (with update timers) and to do basic
//      opperation (insert, delete) on these data.

import 'dart:async';

// ignore: import_of_legacy_library_into_null_safe
import 'package:rxdart/rxdart.dart';
import 'package:smart_mask/src/logic/blocs/sensor_data/sensor_mock.dart';
import 'package:smart_mask/src/logic/database/models/sensor_model.dart';
import 'package:smart_mask/src/logic/repositories/sensor_data_repo.dart';

class SensorDataBloc {
  final _sensorDataRepo = SensorDataRepository();
  Sensor _selectedSensor = Sensor.sensor_1;
  bool mockDataEnabled = false;
  Duration windowInterval = Duration(seconds: 10);
  Duration refreshInterval = Duration(seconds: 1);
  late SensorsMock sensorsMock;

  late BehaviorSubject<Sensor> _selectedSensorSubject;
  late Map<Sensor, BehaviorSubject<List<SensorData>>> _sensorDataSubjects =
      Map();
  late Map<Sensor, Stream<List<SensorData>>> _sensorDataStreams = Map();

  SensorDataBloc() {
    for (var i = 0; i < Sensor.values.length; i++) {
      _sensorDataSubjects[Sensor.values[i]] =
          BehaviorSubject<List<SensorData>>();

      _sensorDataStreams[Sensor.values[i]] =
          _sensorDataSubjects[Sensor.values[i]]!.stream;
    }

    _selectedSensorSubject = BehaviorSubject<Sensor>();
    setSelectedSensor(_selectedSensor);

    // delay for the database to set-up
    Future.delayed(Duration(seconds: 2), () => setupTimers(refreshInterval));

    sensorsMock = SensorsMock();
  }

  getSensorData(Sensor sensor, {required List<DateTime> interval}) async {
    _sensorDataSubjects[sensor]!.sink.add(await _sensorDataRepo.getSensorData(
          sensor,
          interval: interval,
        ));
  }

  Stream<List<SensorData>> getStream(Sensor sensor) {
    return _sensorDataStreams[sensor]!;
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
    return Timer.periodic(
        refreshInterval, (Timer t) => sensorRefreshTimeout(sensor));
  }

  void sensorRefreshTimeout(Sensor sensor) {
    this.getSensorData(sensor,
        interval: [DateTime.now().subtract(windowInterval), DateTime.now()]);
  }

  void setSelectedSensor(Sensor sensor) {
    _selectedSensorSubject.add(sensor);
  }

  Stream<Sensor> getSelectedSensorStream() {
    return _selectedSensorSubject.stream;
  }

  bool isMockDataEnabled() {
    return sensorsMock.isEnabled();
  }

  void toggleMockData() {
    if (sensorsMock.isEnabled())
      sensorsMock.disableMock();
    else
      sensorsMock.enableMock();
  }

  dispose() {
    for (var i = 0; i < Sensor.values.length; i++) {
      _sensorDataSubjects[Sensor.values[i]]!.close();
    }
  }
}