import 'package:mask/src/database/models/sensor_data_model.dart';

abstract class SensorDataEvent {
  const SensorDataEvent();
}

class AddSensorData extends SensorDataEvent {
  final SensorData sensorData;

  const AddSensorData(this.sensorData);

  @override
  String toString() {
    return 'Add Sensor Data: ${this.sensorData.toString()}';
  }
}

class DeleteAllSensorData extends SensorDataEvent {
  @override
  String toString() {
    return 'Delete All Sensor Data';
  }
}
