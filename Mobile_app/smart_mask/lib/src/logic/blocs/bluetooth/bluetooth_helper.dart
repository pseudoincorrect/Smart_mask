import 'package:flutter_blue/flutter_blue.dart';

Future<bool> isDeviceAlreadyConnected(BluetoothDevice device) async {
  List<BluetoothDevice> connectedDevices = [];
  connectedDevices = await FlutterBlue.instance.connectedDevices;
  for (var dev in connectedDevices) {
    if (dev.id == device.id) return Future.value(true);
  }
  return Future.value(false);
}
