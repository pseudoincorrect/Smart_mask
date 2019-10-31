enum Sensor { temperature, humidity, acetone, respiration }

Sensor sensorStringToEnum(String sensor) {
  switch (sensor) {
    case 'Sensor.temperature':
      return Sensor.temperature;
      break;
    case 'Sensor.humidity':
      return Sensor.humidity;
      break;
    case 'Sensor.acetone':
      return Sensor.acetone;
      break;
    case 'Sensor.respiration':
      return Sensor.respiration;
      break;
    default:
      {
        return null;
      }
  }
}

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
