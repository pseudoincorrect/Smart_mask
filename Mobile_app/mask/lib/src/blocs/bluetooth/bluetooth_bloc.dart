//  Bluetooth Business logic (BLoc)
//
//  Description:
//      contain the bluetooth state management for the app
//      manage data stream (sensors, and notification)

import 'package:flutter_blue/flutter_blue.dart';
import 'package:mask/src/database/models/sensor_model.dart';
import 'package:mask/src/repositories/sensor_data_repo.dart';
import './smart_mask_services_const.dart' as servicesConst;

final String sensorService = servicesConst.s["smartMaskService"]["UUID"];
final String sensorCharactUUID =
    servicesConst.s["smartMaskService"]["characteristics"]["sensors"]["UUID"];

class BluetoothBloc {
  Stream<BluetoothState> _bluetoothState;
  SensorDataRepository _sensorDataRepository;
  Stream<bool> _isConnected;

  BluetoothBloc() {
    _sensorDataRepository = SensorDataRepository();
    _bluetoothState = FlutterBlue.instance.state;
    _isConnected =
        Stream.periodic(Duration(seconds: 2)).asyncMap((_) => checkConnected());
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

  onUpdateServices(List<BluetoothService> services) {
    for (var service in services) {
      print("service: ${service.uuid.toString()}");
      updateCharacteristics(service.characteristics);
    }
  }

  updateCharacteristics(List<BluetoothCharacteristic> characteristics) {
    for (var characteristic in characteristics) {
      print("characteristic: ${characteristic.uuid.toString()}");
      if (characteristic.uuid.toString() == sensorCharactUUID) {
        setSensorReceive(characteristic);
      }
    }
  }

  setSensorReceive(BluetoothCharacteristic characteristic) {
    print("sensor chararcteristic ${characteristic.uuid.toString()}");
    characteristic.value.listen(onReceiveValue);
    if (!characteristic.isNotifying) characteristic.setNotifyValue(true);
  }

  onReceiveValue(List<int> values) async {
    var sensorDatas = List<SensorData>();
    parseSensorValues(values, sensorDatas);
    for (var sensorData in sensorDatas) {
      await _sensorDataRepository.insertSensorData(sensorData);
    }
  }

  List<SensorData> parseSensorValues(
      List<int> values, List<SensorData> sensorDatas) {
    for (var i = 0, j = 0; i < values.length; i += 2, j++) {
      int value = values[i] + (values[i + 1] << 8);
      sensorDatas.add(SensorData.fromSensorAndValue(Sensor.values[j], value));
    }
    print("sensor data added");
    return sensorDatas;
  }

  dispose() {}
}
