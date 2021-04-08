import 'dart:async';
import 'dart:typed_data';

// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_blue/flutter_blue.dart';

import 'package:smart_mask/src/logic/models/sensor_model.dart';
import 'package:smart_mask/src/logic/models/sensor_control_model.dart';
import 'package:smart_mask/src/logic/repositories/sensor_data_repo.dart';
import 'package:smart_mask/src/logic/blocs/bluetooth/smart_mask_services_const.dart'
    as smsConst;

final String sensorServiceUUID = smsConst.S["sensorMeasurementService"]["UUID"];

final Map<String, Map<String, String>> valuesChars =
    smsConst.S["sensorMeasurementService"]["characteristics"]["values"];

final Map<String, Map<String, String>> controlChars =
    smsConst.S["sensorMeasurementService"]["characteristics"]["control"];

class BleLogic {
  late Map<Sensor, SensorControl> _sensorControls;
  late SensorDataRepository _sensorDataRepository;
  late Sensor selectedSensor;

  BleLogic() {
    selectedSensor = Sensor.sensor_1;
    _sensorControls = Map();
    _sensorDataRepository = SensorDataRepository();

    for (var i in Sensor.values) {
      _sensorControls[i] = SensorControl(
        initGain: SensorGain.fifth,
        initSamplePeriodMs: 200,
        initEnable: true,
      );
    }
  }

  Future<bool> isConnected() async {
    var devices = await FlutterBlue.instance.connectedDevices;
    return devices.length > 0;
  }

  checkServiceUpdate(BluetoothDevice device) async {
    print("checkServiceUpdate ${device.name}");
    var services = await device.discoverServices();
    print(services);
    for (var s in services) {
      print(s.uuid);
      await updateCharacteristics(s.characteristics);
    }
  }

  updateCharacteristics(List<BluetoothCharacteristic> characteristics) async {
    for (var characteristic in characteristics) {
      var uuid = characteristic.uuid.toString().toUpperCase();

      dynamic uuids = [];
      valuesChars.forEach((key, value) {
        uuids.add(value["UUID"]);
      });

      if (uuids.contains(uuid)) {
        await setSensorReceive(characteristic);
        print("enabled characteristic ${characteristic.uuid}");
      }
    }
  }

  setSensorReceive(BluetoothCharacteristic characteristic) async {
    characteristic.value.listen((x) => onReceiveValue(x, characteristic));
    if (!characteristic.isNotifying) {
      await characteristic.setNotifyValue(true);
    }
  }

  onReceiveValue(List<int> values, BluetoothCharacteristic char) async {
    List<SensorData> sensorDatas;
    final String uuid = char.uuid.toString();
    final sensor = sensorFromBLEchararcteristicUUID(uuid)!;
    sensorDatas = await parseSensorValues(values, sensor);
    for (var sensorData in sensorDatas) {
      await _sensorDataRepository.insertSensorData(sensorData);
    }
  }

  Future<List<SensorData>> parseSensorValues(
      List<int> values, Sensor sensor) async {
    List<SensorData> sensorDatas = [];
    int timeNow = DateTime.now().millisecondsSinceEpoch;

    for (var i = 0, j = smsConst.SENSOR_VALS_PER_PACKET;
        i < values.length;
        i += 2, j--) {
      var buffer = Uint8List(2).buffer;
      var bdata = ByteData.view(buffer);
      bdata.setUint8(1, values[i]);
      bdata.setUint8(0, values[i + 1]);
      int value = bdata.getInt16(0);
      // Since we receive a list of value from one sensor, we need to assign
      // a different time stamp for each value
      int calcTime = timeNow - j * getSamplePeriod(sensor);
      // int calcTime = timeNow - j * smsConst.SAMPLE_PERIOD_MS;
      sensorDatas.add(SensorData.fromSensorAndValue(sensor, value, calcTime));
    }
    return sensorDatas;
  }

  SensorControl getSensorControl(Sensor sensor) => _sensorControls[sensor]!;

  int getSamplePeriod(Sensor sensor) {
    var ctrl = getSensorControl(sensor);
    return ctrl.samplePeriodMs;
  }

  setSamplePeriod(Sensor sensor, int newPeriodMs) async {
    var ctrl = getSensorControl(sensor);
    ctrl.samplePeriodMs = newPeriodMs;
    if (await isConnected()) setSensorCtrlBle(sensor);
  }

  SensorGain getGain(Sensor sensor) {
    var ctrl = getSensorControl(sensor);
    return ctrl.gain;
  }

  setGain(Sensor sensor, SensorGain newGain) async {
    SensorControl ctrl = getSensorControl(sensor);
    ctrl.gain = newGain;
    if (await isConnected()) setSensorCtrlBle(sensor);
  }

  bool getEnable(Sensor sensor) {
    var ctrl = getSensorControl(sensor);
    return ctrl.enable;
  }

  setEnable(Sensor sensor, bool newEnable) async {
    SensorControl ctrl = getSensorControl(sensor);
    ctrl.enable = newEnable;
    if (await isConnected()) setSensorCtrlBle(sensor);
  }

  Future<BluetoothCharacteristic?> getSensorCtrlChar(Sensor sensor) async {
    List<BluetoothDevice> devices = await FlutterBlue.instance.connectedDevices;
    BluetoothDevice device;
    if (devices[0].name.contains("Smart"))
      device = devices[0];
    else
      return null;
    List<BluetoothService> services = await device.services.first;
    BluetoothService smsService = services
        .where((s) => s.uuid.toString().toUpperCase() == sensorServiceUUID)
        .first;
    List<BluetoothCharacteristic> characteristics = smsService.characteristics;
    BluetoothCharacteristic ctrlChar = characteristics
        .where((c) =>
            c.uuid.toString().toUpperCase() ==
            controlChars[sensorEnumToString(sensor)]!["UUID"])
        .first;
    return ctrlChar;
  }

  setSensorCtrlBle(Sensor sensor) async {
    var ctrl = getSensorControl(sensor);
    var ctrlPacket = SensorControlPacket(ctrl);
    var char = await getSensorCtrlChar(sensor);
    if (char != null)
      await char.write(ctrlPacket.buffer, withoutResponse: false);
  }
}

class SensorControlPacket {
  List<int> buffer = [];

  SensorControlPacket(SensorControl sensorControl) {
    // uint32_t samplePeriodMs
    int byte;
    byte = sensorControl.samplePeriodMs & 0x000000FF;
    buffer.add(byte);
    byte = (sensorControl.samplePeriodMs & 0x0000FF00) >> 8;
    buffer.add(byte);
    byte = (sensorControl.samplePeriodMs & 0x00FF0000) >> 16;
    buffer.add(byte);
    byte = (sensorControl.samplePeriodMs & 0xFF000000) >> 24;
    buffer.add(byte);
    // uint8_t gain
    buffer.add(sensorControl.gain.index);
    // uint8_t enable
    buffer.add(sensorControl.enable ? 1 : 0);
  }
}
