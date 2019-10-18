import 'package:mask/src/database/models/sensor_data_model.dart';
import 'package:mask/src/database/access_operations/sensor_data_access.dart';
import 'package:mask/src/widgets/graph/time_series.dart';

class SensorDataRepository {
  final sensorDataAccess = SensorDataAccess();

  Future insertSensorData(SensorData sensorData) =>
      sensorDataAccess.createSensorData(sensorData);

  Future deleteAllSensorData() => sensorDataAccess.deleteAllSensorData();

  Future getSensorData({List<Sensor> sensors, List<DateTime> interval}) =>
      sensorDataAccess.getSensorData(
        sensors: sensors,
        interval: interval,
      );
}
