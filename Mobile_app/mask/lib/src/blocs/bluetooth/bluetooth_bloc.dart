import 'package:flutter_blue/flutter_blue.dart';
import 'package:mask/src/repositories/sensor_data_repo.dart';
import 'package:rxdart/rxdart.dart';
import './smart_mask_services_const.dart' as servicesConst;

final String sensorService = servicesConst.s["smartMaskService"]["UUID"];
final String sensorCharactUUID =
    servicesConst.s["smartMaskService"]["characteristics"]["sensors"]["UUID"];

class BluetoothBloc {
  Stream<BluetoothState> _bluetoothState;
  BluetoothDevice _device;
  SensorDataRepository _sensorDataRepository;

  BluetoothBloc() {
    init();
    _sensorDataRepository = SensorDataRepository();
    _bluetoothState = FlutterBlue.instance.state;
  }

  Stream<BluetoothState> get bluetoothStateStream {
    return _bluetoothState;
  }

  void init() {
    print("init bluetooth bloc");
  }

  void printDevice() {
    print("${this._device?.name.toString()}");
  }

  connectDevice(BluetoothDevice device) async {
    this._device = device;
    this._device.services.listen(onUpdateServices);
//    this._device.discoverServices();
  }

  disconnectDevice() {
    print("disconnectDevice");
    this._device = null;
  }

  onUpdateServices(List<BluetoothService> services) {
    for (var service in services) {
//      print("service: ${service.uuid.toString()}");
      updateCharacteristics(service.characteristics);
    }
  }

  updateCharacteristics(List<BluetoothCharacteristic> characteristics) {
    for (var characteristic in characteristics) {
//      print("characteristic: ${characteristic.uuid.toString()}");
      if (characteristic.uuid.toString() == sensorCharactUUID) {
        setSensorReceive(characteristic);
      }
    }
  }

  setSensorReceive(BluetoothCharacteristic characteristic) {
    print("sensor chararcteristic ${characteristic.uuid.toString()}");
    characteristic.value.listen(onReceiveValue);
    characteristic.setNotifyValue(true);
  }

  onReceiveValue(List<int> values) {
    parseSensorValues(values);
  }

  List<int> parseSensorValues(List<int> values) {
    var newValues = List<int>();
    print("values: " + values.toString());

    return values;
  }

  dispose() {}
}
