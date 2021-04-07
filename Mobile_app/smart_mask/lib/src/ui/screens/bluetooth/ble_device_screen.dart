//  Bluetooth Devices List page
//
//  Description:
//      Display open (connected) device and enable device discovery to later
//      connect to a relevant bluetooth device

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_blue/flutter_blue.dart';
import 'package:smart_mask/src/logic/blocs/bloc.dart';
import 'package:smart_mask/src/ui/widgets/bluetooth/bluetooth_services.dart';

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
        actions: <Widget>[],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(height: 10),
            connectDisconnectButton(context),
            StreamBuilder<BluetoothDeviceState>(
              stream: device.state,
              initialData: BluetoothDeviceState.connecting,
              builder: (c, snapshot) => ListTile(
                leading: (snapshot.data == BluetoothDeviceState.connected)
                    ? Icon(Icons.bluetooth_connected)
                    : Icon(Icons.bluetooth_disabled),
                title: Text(
                    'Device is ${snapshot.data.toString().split('.')[1]}.'),
                subtitle: Text('${device.id}'),
                trailing: StreamBuilder<bool>(
                  stream: device.isDiscoveringServices,
                  initialData: false,
                  builder: (c, snapshot) => IndexedStack(
                    index: snapshot.data! ? 1 : 0,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.refresh),
                        onPressed: () => device.discoverServices(),
                      ),
                      IconButton(
                        icon: SizedBox(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.grey),
                          ),
                          width: 18.0,
                          height: 18.0,
                        ),
                        onPressed: null,
                      )
                    ],
                  ),
                ),
              ),
            ),
            StreamBuilder<int>(
              stream: device.mtu,
              initialData: 0,
              builder: (c, snapshot) => ListTile(
                title: Text('MTU Size'),
                subtitle: Text('${snapshot.data} bytes'),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => device.requestMtu(223),
                ),
              ),
            ),
            StreamBuilder<List<BluetoothService>>(
              stream: device.services,
              initialData: [],
              builder: (c, snapshot) {
                return Column(
                  children: _buildServiceTiles(snapshot.data!),
                );
              },
            ),
            ElevatedButton(
              child: Text("View Graphs"),
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
                // MaterialPageRoute(
                //   builder: (context) => MyApp(),
                // );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget connectDisconnectButton(BuildContext context) {
    var bleLogic = BlocProvider.of<BleBloc>(context).bleLogic;

    return StreamBuilder<BluetoothDeviceState>(
      stream: device.state,
      initialData: BluetoothDeviceState.connecting,
      builder: (c, snapshot) {
        VoidCallback onPressed;
        String text;
        switch (snapshot.data) {
          case BluetoothDeviceState.connected:
            onPressed = () {
              device.disconnect();
            };
            text = 'DISCONNECT';
            break;
          case BluetoothDeviceState.disconnected:
            onPressed = () async {
              await device.connect();
              bleLogic.checkServiceUpdate(device);
            };
            text = 'CONNECT';
            break;
          default:
            onPressed = () => null;
            text = snapshot.data.toString().substring(21).toUpperCase();
            break;
        }
        return ElevatedButton(
          onPressed: onPressed,
          child: Text(
            text,
          ),
        );
      },
    );
  }

  List<int> _getRandomBytes() {
    final math = Random();
    return [
      math.nextInt(255),
      math.nextInt(255),
      math.nextInt(255),
      math.nextInt(255)
    ];
  }

  List<Widget> _buildServiceTiles(List<BluetoothService> services) {
    return services
        .map(
          (s) => ServiceTile(
            service: s,
            characteristicTiles: s.characteristics
                .map(
                  (c) => CharacteristicTile(
                    characteristic: c,
                    onReadPressed: () => c.read(),
                    onWritePressed: () => c.write(_getRandomBytes()),
                    onNotificationPressed: () =>
                        c.setNotifyValue(!c.isNotifying),
                    descriptorTiles: c.descriptors
                        .map(
                          (d) => DescriptorTile(
                            descriptor: d,
                            onReadPressed: () => d.read(),
                            onWritePressed: () => d.write(_getRandomBytes()),
                          ),
                        )
                        .toList(),
                  ),
                )
                .toList(),
          ),
        )
        .toList();
  }
}
