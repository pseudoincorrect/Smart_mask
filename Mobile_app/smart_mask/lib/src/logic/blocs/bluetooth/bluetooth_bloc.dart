//  Bluetooth Business logic (BLoc)
//
//  Description:
//      contain the bluetooth state management for the app
//      manage data stream (sensors, and notification)

import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_blue/flutter_blue.dart';
import 'package:smart_mask/src/logic/database/models/sensor_model.dart';
import 'package:smart_mask/src/logic/database/models/sensor_control_model.dart';
import 'package:smart_mask/src/logic/repositories/sensor_data_repo.dart';
import 'package:smart_mask/src/logic/blocs/bluetooth/smart_mask_services_const.dart'
    as smsConst;

final String sensorService = smsConst.S["sensorMeasurementService"]["UUID"];

final Map<String, Map<String, String>> valuesChars =
    smsConst.S["sensorMeasurementService"]["characteristics"]["values"];

final Map<String, Map<String, String>> controlChars =
    smsConst.S["sensorMeasurementService"]["characteristics"]["control"];

class BluetoothBloc {
  int _sampleRateValue;
  SensorGain _gainValue;

  // Map<Sensor, SensorControl> _sensorControls;
  Stream<BluetoothState> _bluetoothState;
  SensorDataRepository _sensorDataRepository;
  Stream<bool> _isConnected;

  BluetoothBloc() {
    _sensorDataRepository = SensorDataRepository();
    _bluetoothState = FlutterBlue.instance.state;
    _isConnected =
        Stream.periodic(Duration(seconds: 2)).asyncMap((_) => checkConnected());
    _sampleRateValue = 200;
    _gainValue = SensorGain.one;
  }

  Future<bool> checkConnected() async {
    List<BluetoothDevice> devices = await FlutterBlue.instance.connectedDevices;
    if (devices.length > 0) {
      return Future.value(true);
    }
    return Future.value(false);
  }

  Stream<BluetoothState> get bluetoothStateStream {
    return _bluetoothState;
  }

  listenDevice(BluetoothDevice device) async {
    if (!await checkConnected()) {
      device.services.listen(onUpdateServices);
    }
  }

  Stream<bool> get isConnected {
    return _isConnected;
  }

  onUpdateServices(List<BluetoothService> services) async {
    for (var service in services) {
      updateCharacteristics(service.characteristics);
    }
  }

  updateCharacteristics(List<BluetoothCharacteristic> characteristics) async {
    for (var characteristic in characteristics) {
      var uuid = characteristic.uuid.toString();

      dynamic uuids = [];
      valuesChars.forEach((key, value) {
        uuids.add(value["UUID"]);
      });

      if (uuids.contains(uuid)) {
        await setSensorReceive(characteristic);
      }
    }
  }

  setSensorReceive(BluetoothCharacteristic characteristic) async {
    characteristic.value.listen((x) => onReceiveValue(x, characteristic));
    if (!characteristic.isNotifying) {
      await characteristic.setNotifyValue(true);
      print(characteristic.isNotifying);
    }
  }

  onReceiveValue(List<int> values, BluetoothCharacteristic char) async {
    List<SensorData> sensorDatas;
    final String uuid = char.uuid.toString();
    final sensor = sensorFromBLEchararcteristicUUID(uuid);
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
      var buffer = new Uint8List(2).buffer;
      var bdata = new ByteData.view(buffer);
      bdata.setUint8(1, values[i]);
      bdata.setUint8(0, values[i + 1]);
      int value = bdata.getInt16(0);
      // Since we receive a list of value from one sensor, we need to assign
      // a different time stamp for each value
      int calcTime = timeNow - j * smsConst.SAMPLE_PERIOD_MS;
      sensorDatas.add(SensorData.fromSensorAndValue(sensor, value, calcTime));
    }
    return sensorDatas;
  }

  setSampleRateValue(int newValue) {
    if (!validateSensorSampleRate(newValue)) return null;
    _sampleRateValue = newValue.round();
  }

  int getSampleRateValue() => _sampleRateValue;

  setgainValue(SensorGain newValue) => _gainValue = newValue;

  SensorGain getgainValue() => _gainValue;

  dispose() {}
}
