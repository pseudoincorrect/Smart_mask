//  Sensor Data Repository
//
//  Description:
//      Class making the brige (interface) between function/classes dealing with
//      Sensor data (widget) and data repositories (Local Db, online Db, OS files, etc..)
//      provide a clean access to sensor data so that the caller need not to worry
//      about where the data come from (from which repository/data storage)

import 'package:mask/src/logic/database/models/sensor_model.dart';
import 'package:mask/src/logic/database/access_operations/sensor_data_access.dart';

class SensorDataRepository {
  final sensorDataAccess = SensorDataAccess();

  Future insertSensorData(SensorData sensorData) =>
      sensorDataAccess.createSensorData(sensorData);

  Future deleteAllSensorData() => sensorDataAccess.deleteAllSensorData();

  Future getSensorData(Sensor sensor, {List<DateTime> interval}) =>
      sensorDataAccess.getSensorData(
        sensor,
        interval: interval,
      );
}
