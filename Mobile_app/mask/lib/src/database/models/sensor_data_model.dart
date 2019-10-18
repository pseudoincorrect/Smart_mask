import 'package:mask/src/widgets/graph/time_series.dart';

class SensorData {
  int id;
  Sensor sensorName;
  int timeStamp;
  int value;

  SensorData({this.id, this.sensorName, this.timeStamp, this.value});

  factory SensorData.fromDatabaseJson(Map<String, dynamic> data) => SensorData(
      id: data['id'],
      sensorName: sensorStringToEnum(data['sensorName']),
      timeStamp: data['timeStamp'],
      value: data['value']);

  Map<String, dynamic> toDatabaseJson() => {
        "id": this.id,
        "sensorName": this.sensorName.toString(),
        "timeStamp": this.timeStamp,
        "value": this.value,
      };

  @override
  String toString() {
    return 'id = ${this.id}, sensorName = ${this.sensorName.toString()}, timeStamp = ${this.timeStamp}, value = ${this.value}';
  }
}
