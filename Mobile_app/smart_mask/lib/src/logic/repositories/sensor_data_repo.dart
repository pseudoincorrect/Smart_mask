//  Sensor Data Repository
//
//  Description:
//      Class making the brige (interface) between function/classes dealing with
//      Sensor data (widget) and data repositories (Local Db, online Db, OS files, etc..)
//      provide a clean access to sensor data so that the caller need not to worry
//      about where the data come from (from which repository/data storage)

import 'package:smart_mask/src/logic/database/access_operations/sensor_data_access.dart';
import 'package:smart_mask/src/logic/models/sensor_model.dart';
import 'package:smart_mask/src/logic/models/time_interval.dart';

class SensorDataRepository {
  final sensorDataAccess = SensorDataAccess();

  Future<int> insertSensorData(SensorData sensorData) =>
      sensorDataAccess.createSensorData(sensorData);

  Future<int> deleteAllSensorData() => sensorDataAccess.deleteAllSensorData();

  Future<List<SensorData>> getSensorData(Sensor sensor,
          {required TimeIntervalMsEpoch interval}) =>
      sensorDataAccess.getSensorData(
        sensor,
        interval: interval,
      );

  Future<List<SensorData>> getAllSensorData(
          {required TimeIntervalMsEpoch interval}) =>
      sensorDataAccess.getAllSensorData(interval: interval);

  Future<SensorData?> getOldestSensorData(Sensor sensor) =>
      sensorDataAccess.getOldestSensorData(sensor);

  Future<SensorData?> getNewestSensorData(Sensor sensor) =>
      sensorDataAccess.getNewestSensorData(sensor);

  Future<SensorData?> getAnyOldestSensorData() =>
      sensorDataAccess.getAnyOldestSensorData();

  Future<SensorData?> getAnyNewestSensorData() =>
      sensorDataAccess.getAnyNewestSensorData();
}
