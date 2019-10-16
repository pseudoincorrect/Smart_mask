import 'package:mask/src/database/models/sensor_data_model.dart';
import 'package:mask/src/database/access_operations/sensor_data_access.dart';

class SensorDataRepository {
  final sensorDataAccess = SensorDataAccess();

  Future insertSensorData(SensorData sensorData) =>
      sensorDataAccess.createSensorData(sensorData);

  Future getAllSensorData() => sensorDataAccess.getSensorData();

  Future deleteAllSensorData() => sensorDataAccess.deleteAllSensorData();
}
