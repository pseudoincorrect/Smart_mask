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
  Sensor sensor;
  int timeStamp;
  int value;

  SensorData({this.id, this.sensor, this.timeStamp, this.value});

  factory SensorData.fromSensorAndValue(Sensor sensor, int value) {
    int timeStamp = DateTime.now().millisecondsSinceEpoch;
    int id = 0;
    return SensorData(
      id: id,
      sensor: sensor,
      timeStamp: timeStamp,
      value: value,
    );
  }

  factory SensorData.fromDatabaseJson(Map<String, dynamic> data) => SensorData(
      id: data['id'],
      sensor: sensorStringToEnum(data['sensor']),
      timeStamp: data['timeStamp'],
      value: data['value']);

  Map<String, dynamic> toDatabaseJson() => {
        "sensor": this.sensor.toString(),
        "timeStamp": this.timeStamp,
        "value": this.value,
      };

  @override
  String toString() {
    return 'id = ${this.id}, sensor = ${this.sensor.toString()}, timeStamp = ${this.timeStamp}, value = ${this.value}';
  }
}
