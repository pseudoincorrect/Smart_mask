import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:mask/src/database/models/sensor_data_model.dart';

import '../../repositories/sensor_data_repo.dart';

class SensorsDataBloc {
  final _sensorDataRepo = SensorDataRepository();
  final _sensorDataSubject = BehaviorSubject<List<SensorData>>();

  get sensorData => _sensorDataSubject.stream;

  getAllSensorData() async {
    _sensorDataSubject.sink.add(await _sensorDataRepo.getAllSensorData());
  }

  addSensorData(SensorData sensorData) async {
    await _sensorDataRepo.insertSensorData(sensorData);
    getAllSensorData();
  }

  deleteAllSensorData() async {
    await _sensorDataRepo.deleteAllSensorData();
  }

  dispose() {
    _sensorDataSubject.close();
  }
}
