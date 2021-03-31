import 'dart:async';

import 'package:smart_mask/src/logic/database/models/sensor_model.dart';
import 'dart:math';

import 'package:smart_mask/src/logic/repositories/sensor_data_repo.dart';

class SensorsMock {
  final _sensorDataRepo = SensorDataRepository();
  Map<Sensor, int> sensorMockData = Map();
  late Random rng;

  Duration addInterval = Duration(milliseconds: 200);
  Timer? mockTimer;

  SensorsMock() {
    rng = Random();
    for (var s in Sensor.values) {
      sensorMockData[s] = 0;
    }
  }

  addMockData() {
    for (var s in Sensor.values) {
      var rand = rng.nextInt(10);

      int sMockInt = sensorMockData[s] ?? 0;

      if (rng.nextBool())
        sMockInt += rand;
      else
        sMockInt -= rand;

      if (sMockInt < -3000) sMockInt = -3000;
      if (sMockInt > 3000) sMockInt = 3000;

      var sensorData = SensorData.fromSensorAndValue(
          s, sMockInt, DateTime.now().millisecondsSinceEpoch);

      _sensorDataRepo.insertSensorData(sensorData);

      sensorMockData[s] = sMockInt;
    }
  }

  bool isEnabled() {
    if (mockTimer == null || !mockTimer!.isActive) return false;
    return true;
  }

  enableMock() {
    if (mockTimer == null || !mockTimer!.isActive) {
      mockTimer = Timer.periodic(addInterval, (Timer t) => addMockData());
    }
  }

  disableMock() {
    if (mockTimer == null) return;
    if (mockTimer!.isActive) mockTimer!.cancel();
  }

  dispose() {
    mockTimer!.cancel();
  }
}
