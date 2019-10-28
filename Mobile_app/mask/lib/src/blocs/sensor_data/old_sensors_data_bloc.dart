import 'package:mask/src/widgets/graph/time_series.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mask/src/database/models/sensor_data_model.dart';

import '../../repositories/sensor_data_repo.dart';

class SensorDataBloc {
  final _sensorDataRepo = SensorDataRepository();

  Map<Sensor, BehaviorSubject<List<SensorData>>> _SensorDataSubjects = Map();
  Map<Sensor, Stream<List<SensorData>>> _SensorDataStreams = Map();

  SensorDataBloc() {
    for (var i = 0; i < Sensor.values.length; i++) {
      _SensorDataSubjects[Sensor.values[i]] =
          BehaviorSubject<List<SensorData>>();
      _SensorDataStreams[Sensor.values[i]] =
          _SensorDataSubjects[Sensor.values[i]].stream;
    }
  }

  getSensorData(Sensor sensor, {List<DateTime> interval}) async {
    _SensorDataSubjects[sensor].sink.add(await _sensorDataRepo.getSensorData(
          sensor,
          interval: interval,
        ));
  }

  Stream<List<SensorData>> getStream(Sensor sensor) {
    return _SensorDataStreams[sensor];
  }

  addSensorData(SensorData sensorData) async {
    await _sensorDataRepo.insertSensorData(sensorData);
  }

  deleteAllSensorData() async {
    await _sensorDataRepo.deleteAllSensorData();
  }

  dispose() {
    for (var i = 0; i < Sensor.values.length; i++) {
      _SensorDataSubjects[Sensor.values[i]].close();
    }
  }
}
