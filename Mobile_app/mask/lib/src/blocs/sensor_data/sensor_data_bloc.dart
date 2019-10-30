import 'package:rxdart/rxdart.dart';
import 'package:mask/src/database/models/sensor_model.dart';

import 'package:mask/src/repositories/sensor_data_repo.dart';

class SensorDataBloc {
  final _sensorDataRepo = SensorDataRepository();

  Map<Sensor, BehaviorSubject<List<SensorData>>> _sensorDataSubjects = Map();
  Map<Sensor, Stream<List<SensorData>>> _sensorDataStreams = Map();

  SensorDataBloc() {
    for (var i = 0; i < Sensor.values.length; i++) {
      _sensorDataSubjects[Sensor.values[i]] =
          BehaviorSubject<List<SensorData>>();

      _sensorDataStreams[Sensor.values[i]] =
          _sensorDataSubjects[Sensor.values[i]].stream;
    }
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

  dispose() {
    for (var i = 0; i < Sensor.values.length; i++) {
      _sensorDataSubjects[Sensor.values[i]].close();
    }
  }
}
