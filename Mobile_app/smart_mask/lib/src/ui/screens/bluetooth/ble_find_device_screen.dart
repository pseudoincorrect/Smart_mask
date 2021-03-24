import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:rxdart/rxdart.dart';
import 'package:smart_mask/src/logic/blocs/bluetooth/bluetooth_helper.dart';
import 'package:smart_mask/src/logic/blocs/bluetooth/bluetooth_provider.dart';
import 'file:///C:/Users/maxim/Documents/git/smart_mask/Mobile_app/smart_mask/lib/src/ui/screens/bluetooth/ble_device_screen.dart';
import 'package:smart_mask/src/ui/screens/bluetooth/ble_off_screen.dart';
import 'package:smart_mask/src/ui/widgets/bluetooth/scan_result_widgets.dart';

Widget bluetoothDevicesListScreen() {
  return StreamBuilder<BluetoothState>(
      stream: FlutterBlue.instance.state,
      initialData: BluetoothState.unknown,
      builder: (c, snapshot) {
        final state = snapshot.data;
        if (state == BluetoothState.on) {
          return FindDevicesScreen();
        }
        return BluetoothOffScreen(state: state);
      });
}

class FindDevicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bleblock = BluetoothProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Find Devices'),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            FlutterBlue.instance.startScan(timeout: Duration(seconds: 4)),
        // List of connected devices
        child: StreamBuilder<bool>(
          stream: bleblock.isConnectedStream,
          initialData: false,
          builder: (context, snapshot) {
            bool isConnected = snapshot.data;
            if (isConnected) {
              return connectedDevicesList(context);
            } else {
              return scannedDevicesList(context);
            }
          },
        ),
      ),
      floatingActionButton: scanFloatButton(),
    );
  }

  Widget connectedDevicesList(BuildContext context) {
    return StreamBuilder<List<BluetoothDevice>>(
      stream: MergeStream([
        Stream.fromFuture(FlutterBlue.instance.connectedDevices),
        Stream.periodic(Duration(seconds: 2))
            .asyncMap((_) => FlutterBlue.instance.connectedDevices),
      ]),
      initialData: [],
      builder: (context, snapshot) => Column(
        children: snapshot.data
            .map(
              (device) => ListTile(
                title: Text(device.name),
                subtitle: Text(device.id.toString()),
                trailing: StreamBuilder<BluetoothDeviceState>(
                  stream: device.state,
                  initialData: BluetoothDeviceState.disconnected,
                  builder: (context, snapshot) {
                    if (snapshot.data == BluetoothDeviceState.connected) {
                      return ElevatedButton(
                        child: Text('OPEN'),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DeviceScreen(device: device),
                          ),
                        ),
                      );
                    }
                    return Text(snapshot.data.toString());
                  },
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget scannedDevicesList(BuildContext context) {
    final bleblock = BluetoothProvider.of(context);
    return StreamBuilder<List<ScanResult>>(
      stream: FlutterBlue.instance.scanResults,
      initialData: [],
      builder: (context, snapshot) {
        return Column(
          children: snapshot.data
              .where((scanResults) => scanResults.device.name == "Smart_Mask")
              .toList()
              .map(
                (scanResults) => ScanResultTile(
                  result: scanResults,
                  onTap: () async {
                    // bool isConnected =
                    //     await isDeviceAlreadyConnected(scanResults.device);
                    // if (!isConnected)

                    await scanResults.device.connect();
                    bleblock.checkServiceUpdate(scanResults.device);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return DeviceScreen(device: scanResults.device);
                        },
                      ),
                    );
                  },
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget scanFloatButton() {
    return StreamBuilder<bool>(
      stream: FlutterBlue.instance.isScanning,
      initialData: false,
      builder: (context, snapshot) {
        if (snapshot.data) {
          return FloatingActionButton(
            child: Icon(Icons.stop),
            onPressed: () => FlutterBlue.instance.stopScan(),
            backgroundColor: Colors.red,
          );
        } else {
          return FloatingActionButton(
              child: Icon(Icons.search),
              onPressed: () => FlutterBlue.instance
                  .startScan(timeout: Duration(seconds: 4)));
        }
      },
    );
  }
}
