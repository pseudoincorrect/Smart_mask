//  Sensor Management Service (Bluetooth Low Energy service)
//
//  Description:
//      Bluetooth (BLoc) part related to the SMS (sensor management service)
//      of the BLE device connected. handle the sensor data by storing them to
//      database (or other repositories)

import 'package:flutter_blue/flutter_blue.dart';
import 'package:mask/src/logic/database/models/sensor_model.dart';
import 'package:mask/src/logic/repositories/sensor_data_repo.dart';
import './smart_mask_services_const.dart' as servicesConst;

class SensorManagementService {
  SensorDataRepository _sensorDataRepository;
  final String sensorService = servicesConst.s["smartMaskService"]["UUID"];
  final String sensorCharactUUID =
      servicesConst.s["smartMaskService"]["characteristics"]["sensors"]["UUID"];

  SensorManagementService() {
    this._sensorDataRepository = SensorDataRepository();
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
    return sensorDatas;
  }
}
