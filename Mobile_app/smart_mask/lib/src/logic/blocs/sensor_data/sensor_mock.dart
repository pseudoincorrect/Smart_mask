import 'dart:async';

import 'package:smart_mask/src/logic/database/models/sensor_model.dart';
import 'dart:math';

import 'package:smart_mask/src/logic/repositories/sensor_data_repo.dart';

class SensorsMock {
  final _sensorDataRepo = SensorDataRepository();
  Map<Sensor, int> sensorMockData = Map();
  Random rng;

  Duration addInterval = Duration(milliseconds: 200);
  Timer mockTimer;

  SensorsMock() {
    rng = Random();
    for (var s in Sensor.values) {
      sensorMockData[s] = 0;
    }
  }

  addMockData() {
    for (var s in Sensor.values) {
      var rand = rng.nextInt(10);

      if (rng.nextBool())
        sensorMockData[s] += rand;
      else
        sensorMockData[s] -= rand;

      if (sensorMockData[s] < -3000) sensorMockData[s] = -3000;
      if (sensorMockData[s] > 3000) sensorMockData[s] = 3000;

      var sensorData = SensorData.fromSensorAndValue(
          s, sensorMockData[s], DateTime.now().millisecondsSinceEpoch);

      _sensorDataRepo.insertSensorData(sensorData);
    }
  }

  bool isEnabled() {
    if (mockTimer == null || !mockTimer.isActive) return false;
    return true;
  }

  enableMock() {
    if (mockTimer == null || !mockTimer.isActive) {
      mockTimer = Timer.periodic(addInterval, (Timer t) => addMockData());
    }
  }

  disableMock() {
    if (mockTimer == null) return;
    if (mockTimer.isActive) mockTimer.cancel();
  }

  dispose() {
    mockTimer.cancel();
  }
}
