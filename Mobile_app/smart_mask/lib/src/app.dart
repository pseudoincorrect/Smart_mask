import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_blue/flutter_blue.dart';
import 'package:smart_mask/src/logic/blocs/bloc.dart';
import 'package:smart_mask/src/logic/blocs/bluetooth/bluetooth_bloc.dart';
import 'package:smart_mask/src/logic/blocs/bluetooth/bluetooth_provider.dart';
import 'package:smart_mask/src/logic/blocs/sensor_data/sensor_data_bloc.dart';
import 'package:smart_mask/src/logic/blocs/sensor_data/sensor_data_provider.dart';
import 'package:smart_mask/src/ui/screens/bluetooth/ble_find_device_screen.dart';
import 'package:smart_mask/src/ui/screens/graphs_screen.dart';
import 'package:smart_mask/src/ui/screens/analytics_screen.dart';
import 'package:smart_mask/src/ui/screens/sensor_details_screen.dart';
import 'package:smart_mask/src/ui/screens/home_screen.dart';

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
    // final analyticsBloc = AnalyticsBloc();

    return SensorDataProvider(
      bloc: sensorDataBloc,
      child: BluetoothProvider(
        bloc: bluetoothBloc,
        child: BlocProvider(
          create: (context) => AnalyticsBloc(),
          child: MaterialApp(
            title: "Smart Mask",
            theme: getTheme(),
            home: SplashScreen(),
          ),
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

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TabControl();
  }
}

class TabControl extends StatefulWidget {
  TabControl({Key? key}) : super(key: key);

  @override
  _TabControlState createState() => _TabControlState();
}

class _TabControlState extends State<TabControl> {
  BluetoothBloc? bluetoothBloc;

  Widget build(BuildContext context) {
    bluetoothBloc = BluetoothProvider.of(context);
    return DefaultTabController(
      length: choices.length,
      initialIndex: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: <Widget>[
              const Text(
                'Smart Mask',
                style: TextStyle(fontSize: 30),
              ),
              Expanded(child: Container()),
              StreamBuilder<bool>(
                stream: bluetoothBloc!.isConnectedStream,
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
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => bluetoothDevicesListScreen()));
    },
    child: Icon(Icons.bluetooth),
  );
}

class Choice {
  const Choice({required this.title, required this.icon, this.widget});

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
    widget: (BuildContext context) => HomeScreen(),
  ),
  Choice(
    title: 'Graphs',
    icon: Icons.show_chart,
    widget: (BuildContext context) => GraphsScreen(),
  ),
  Choice(
    title: 'Details',
    icon: Icons.zoom_in,
    widget: (BuildContext context) => GraphDetailsScreen(),
  ),
  Choice(
    title: 'Analytics',
    icon: Icons.analytics_outlined,
    widget: (BuildContext context) => AnalyticsScreen(),
  ),
];
