import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:smart_mask/src/logic/blocs/bluetooth/bluetooth_bloc.dart';
import 'package:smart_mask/src/logic/blocs/bluetooth/bluetooth_provider.dart';
import 'package:smart_mask/src/logic/blocs/sensor_data/sensor_data_bloc.dart';
import 'package:smart_mask/src/logic/blocs/sensor_data/sensor_data_provider.dart';
import 'package:smart_mask/src/ui/screens/bluetooth_devices_list.dart';
import 'package:smart_mask/src/ui/screens/graphs.dart';
import 'package:smart_mask/src/ui/screens/sensor_details.dart';
import 'package:smart_mask/src/ui/screens/home.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    FlutterBlue.instance.setLogLevel(LogLevel.error);

    final bluetoothBloc = BluetoothBloc();
    final sensorDataBloc = SensorDataBloc();

    return SensorDataProvider(
      bloc: sensorDataBloc,
      child: BluetoothProvider(
        bloc: bluetoothBloc,
        child: MaterialApp(
          title: "Smart Mask",
          theme: getTheme(),
          home: TabControl(),
        ),
      ),
    );
  }

  ThemeData getTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.blue,
      accentColor: Colors.blueAccent,
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.blue,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5))),
        textTheme: ButtonTextTheme.primary,
      ),
    );
  }
}

class TabControl extends StatefulWidget {
  TabControl({Key key}) : super(key: key);

  @override
  _TabControlState createState() => _TabControlState();
}

class _TabControlState extends State<TabControl> {
  BluetoothBloc bluetoothBloc;

  Widget build(BuildContext context) {
    bluetoothBloc = BluetoothProvider.of(context);
    return DefaultTabController(
      length: choices.length,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: <Widget>[
              const Text('Smart Mask'),
              Expanded(child: Container()),
              StreamBuilder<bool>(
                stream: bluetoothBloc.isConnected,
                initialData: false,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.data == true) {
                    return Text("Connected");
                  }
                  return Text("Disconnected");
                },
              ),
            ],
          ),
          bottom: TabBar(
            isScrollable: true,
            tabs: choices.map((Choice choice) {
              return Tab(
                text: choice.title,
                icon: Icon(choice.icon),
              );
            }).toList(),
          ),
        ),
        body: TabBarView(
          children: choices.map((Choice choice) {
            return choice.getWidget(context);
          }).toList(),
        ),
        floatingActionButton: connectButton(context),
      ),
    );
  }
}

FloatingActionButton connectButton(BuildContext context) {
  return FloatingActionButton(
    onPressed: () {
      print("connectButton Pressed");
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => bluetoothDevicesList()));
    },
    child: Icon(Icons.bluetooth),
  );
}

class Choice {
  const Choice({this.title, this.icon, this.widget});

  final String title;
  final IconData icon;
  final dynamic widget;

  Widget getWidget(BuildContext context) {
    return widget(context);
  }
}

List<Choice> choices = <Choice>[
  Choice(
    title: 'Home',
    icon: Icons.home,
    widget: (BuildContext context) => Home(),
  ),
  Choice(
    title: 'Graphs',
    icon: Icons.show_chart,
    widget: (BuildContext context) => Graph(),
  ),
  Choice(
    title: 'Details',
    icon: Icons.details,
    widget: (BuildContext context) => GraphDetails(),
  ),
];

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({Key key, this.choice}) : super(key: key);

  final Choice choice;

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.bodyText2;
    return Card(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(choice.icon, size: 128.0, color: textStyle.color),
            Text(choice.title, style: textStyle),
          ],
        ),
      ),
    );
  }
}
