import 'package:mask/src/database/models/sensor_data_model.dart';

abstract class SensorDataState {
  const SensorDataState();
}

class SensorDataLoading extends SensorDataState {}

class SensorDataLoaded extends SensorDataState {
  final List<SensorData> sensorData;
  const SensorDataLoaded([this.sensorData = const []]);
}

class SensorDataNotLoaded extends SensorDataState {}
