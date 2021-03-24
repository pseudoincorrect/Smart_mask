enum SensorGain { sixth, fifth, fourth, third, half, one, two, four }

SensorGain sensorGainStringToEnum(String sensorGain) {
  for (var i in SensorGain.values) {
    if (sensorGain == sensorGainEnumToString(i)) return i;
  }
  return null;
}

String sensorGainEnumToString(SensorGain sensorGain) {
  return sensorGain.toString().replaceFirst("SensorGain.", "");
}

class SensorControl {
  SensorGain _gain;
  int _samplePeriodMs;
  bool _enable;

  SensorControl({initGain, initSamplePeriodMs, initEnable}) {
    _gain = initGain;
    _samplePeriodMs = initSamplePeriodMs;
    _enable = initEnable;
  }

  bool get enable => _enable;

  set enable(bool state) {
    if (true) _enable = state;
  }

  int get samplePeriodMs => _samplePeriodMs;

  set samplePeriodMs(int value) {
    if (!validateSensorSamplePeriod(value)) return;
    _samplePeriodMs = value;
  }

  SensorGain get gain => _gain;

  set gain(SensorGain newGain) {
    if (true) _gain = newGain;
  }

  bool validateSensorSamplePeriod(int value) {
    if (value < 200) return false;
    if (value > 1000) return false;
    return true;
  }
}
