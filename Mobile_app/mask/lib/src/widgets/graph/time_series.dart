/// Sample time series data type.
class TimeSeriesSensor {
  final DateTime time;
  final int value;

  TimeSeriesSensor(this.time, this.value);

  @override
  String toString() {
    return 'time = ${this.time}, value = ${this.value}';
  }
}

enum Sensor { temperature, humidity, acetone }

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
    default:
      {
        return null;
      }
  }
}
