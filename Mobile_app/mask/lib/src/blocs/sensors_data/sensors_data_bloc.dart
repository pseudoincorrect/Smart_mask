import 'dart:async';
import 'package:mask/src/widgets/graph/time_series.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mask/src/database/models/sensor_data_model.dart';

import '../../repositories/sensor_data_repo.dart';

class SensorsDataBloc {
  final _sensorDataRepo = SensorDataRepository();
  final _sensorDataSubject = BehaviorSubject<List<SensorData>>();

  get sensorData => _sensorDataSubject.stream;

  getSensorData({List<Sensor> sensors, List<DateTime> interval}) async {
    _sensorDataSubject.sink.add(await _sensorDataRepo.getSensorData(
      sensors: sensors,
      interval: interval,
    ));
  }

  addSensorData(SensorData sensorData) async {
    await _sensorDataRepo.insertSensorData(sensorData);
    getSensorData();
  }

  deleteAllSensorData() async {
    await _sensorDataRepo.deleteAllSensorData();
    await getSensorData();
  }

  dispose() {
    _sensorDataSubject.close();
  }
}
