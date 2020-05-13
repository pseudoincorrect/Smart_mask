//  Sensor Data Model
//
//  Description:
//      Main structure for dealing with sensor data in an
//      Organised way. We will find function to deal with
//      Sensor enum and SensorData class here

enum Sensor { temperature, humidity, acetone, respiration }

Sensor sensorStringToEnum(String sensor) {
  switch (sensor) {
    case 'temperature':
      return Sensor.temperature;
      break;
    case 'humidity':
      return Sensor.humidity;
      break;
    case 'acetone':
      return Sensor.acetone;
      break;
    case 'respiration':
      return Sensor.respiration;
      break;
    default:
      {
        return null;
      }
  }
}

String sensorEnumToString(Sensor sensor) {
  return sensor.toString().replaceFirst("Sensor.", "");
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
        "sensor": sensorEnumToString(this.sensor),
        "timeStamp": this.timeStamp,
        "value": this.value,
      };

  @override
  String toString() {
    return 'id = ${this.id}, sensor = ${sensorEnumToString(this.sensor)}, timeStamp = ${this.timeStamp}, value = ${this.value}';
  }
}
