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

bool validateSensorSampleRate(int value) {
  if (value < 100) return false;
  if (value > 1000) return false;
  return true;
}

class SensorControl {
  SensorGain gain;
  int samplePeriod;

  SensorControl({this.gain, this.samplePeriod});
}
