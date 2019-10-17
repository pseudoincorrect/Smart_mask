import 'package:mask/src/database/models/sensor_data_model.dart';
import 'package:mask/src/database/access_operations/sensor_data_access.dart';

class SensorDataRepository {
  final sensorDataAccess = SensorDataAccess();

  Future insertSensorData(SensorData sensorData) =>
      sensorDataAccess.createSensorData(sensorData);

  // TODO: implement get sensor per sensor per interval
  Future getAllSensorData() => sensorDataAccess.getSensorData();

  // TODO: implement delete before timestamp
  Future deleteAllSensorData() => sensorDataAccess.deleteAllSensorData();
}
