import 'package:mask/src/widgets/graph/time_series.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mask/src/database/models/sensor_data_model.dart';

import '../../repositories/sensor_data_repo.dart';

class SensorsDataBloc {
  final _sensorDataRepo = SensorDataRepository();

  Map<Sensor, BehaviorSubject<List<SensorData>>> _sensorsDataSubjects = Map();
  Map<Sensor, Stream<List<SensorData>>> _sensorsDataStreams = Map();

  SensorsDataBloc() {
    for (var i = 0; i < Sensor.values.length; i++) {
      _sensorsDataSubjects[Sensor.values[i]] =
          BehaviorSubject<List<SensorData>>();
      _sensorsDataStreams[Sensor.values[i]] =
          _sensorsDataSubjects[Sensor.values[i]].stream;
    }
  }

  getSensorData(Sensor sensor, {List<DateTime> interval}) async {
    _sensorsDataSubjects[sensor].sink.add(await _sensorDataRepo.getSensorData(
          sensor,
          interval: interval,
        ));
  }

  Stream<List<SensorData>> getStream(Sensor sensor){
    return _sensorsDataStreams[sensor];
  }

  addSensorData(SensorData sensorData) async {
    await _sensorDataRepo.insertSensorData(sensorData);
  }

  deleteAllSensorData() async {
    await _sensorDataRepo.deleteAllSensorData();
  }

  dispose() {
    for (var i = 0; i < Sensor.values.length; i++) {
      _sensorsDataSubjects[Sensor.values[i]].close();
    }
  }
}
