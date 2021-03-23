//  Sensor Data Model
//
//  Description:
//      Main structure for dealing with sensor data in an
//      Organised way. We will find function to deal with
//      Sensor enum and SensorData class here

import 'package:smart_mask/src/logic/blocs/bluetooth/smart_mask_services_const.dart'
    as smsConst;

enum Sensor { sensor_1, sensor_2, sensor_3, sensor_4 }

Sensor sensorStringToEnum(String sensor) {
  switch (sensor) {
    case 'sensor_1':
      return Sensor.sensor_1;
      break;
    case 'sensor_2':
      return Sensor.sensor_2;
      break;
    case 'sensor_3':
      return Sensor.sensor_3;
      break;
    case 'sensor_4':
      return Sensor.sensor_4;
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

Sensor sensorFromBLEchararcteristicUUID(String uuid) {
  final Map<String, Map<String, String>> valuesChars =
      smsConst.S["sensorMeasurementService"]["characteristics"]["values"];

  final Map<String, Map<String, String>> controlChars =
      smsConst.S["sensorMeasurementService"]["characteristics"]["control"];

  if (uuid.toUpperCase() == valuesChars["sensor_1"]["UUID"])
    return Sensor.sensor_1;
  if (uuid.toUpperCase() == valuesChars["sensor_2"]["UUID"])
    return Sensor.sensor_2;
  if (uuid.toUpperCase() == valuesChars["sensor_3"]["UUID"])
    return Sensor.sensor_3;
  if (uuid.toUpperCase() == valuesChars["sensor_4"]["UUID"])
    return Sensor.sensor_4;

  if (uuid.toUpperCase() == controlChars["sensor_1"]["UUID"])
    return Sensor.sensor_1;
  if (uuid.toUpperCase() == controlChars["sensor_2"]["UUID"])
    return Sensor.sensor_2;
  if (uuid.toUpperCase() == controlChars["sensor_3"]["UUID"])
    return Sensor.sensor_3;
  if (uuid.toUpperCase() == controlChars["sensor_4"]["UUID"])
    return Sensor.sensor_4;

  return null;
}

class SensorData {
  int id;
  Sensor sensor;
  int timeStamp;
  int value;

  SensorData({this.id, this.sensor, this.timeStamp, this.value});

  factory SensorData.fromSensorAndValue(
      Sensor sensor, int value, int timeStamp) {
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
