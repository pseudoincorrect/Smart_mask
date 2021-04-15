import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_blue/flutter_blue.dart';
import 'package:smart_mask/src/logic/blocs/bloc.dart';
import 'package:smart_mask/src/ui/screens/bluetooth/ble_find_device_screen.dart';
import 'package:smart_mask/src/ui/screens/graphs_screen.dart';
import 'package:smart_mask/src/ui/screens/analytics_screen.dart';
import 'package:smart_mask/src/ui/screens/sensor_details_screen.dart';
import 'package:smart_mask/src/ui/screens/home_screen.dart';
import 'package:smart_mask/src/ui/theme/theme.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    FlutterBlue.instance.setLogLevel(LogLevel.error);

    return MultiBlocProvider(
      providers: [
        BlocProvider<BleBloc>(create: (context) => BleBloc()),
        BlocProvider<AnalyticsBloc>(create: (context) => AnalyticsBloc()),
        BlocProvider<SensorDataBloc>(create: (context) => SensorDataBloc()),
        BlocProvider<TransmissionBloc>(create: (context) => TransmissionBloc()),
      ],
      child: MaterialApp(
        title: "Smart Mask",
        theme: getTheme(),
        home: SplashScreen(),
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
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: choices.length,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: <Widget>[
              Image(
                image: new AssetImage("assets/icon/smart_mask_logo_3_75px.png"),
                width: 50,
                height: 50,
                color: null,
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
              ),
              Expanded(child: Container()),
              BlocBuilder<BleBloc, BleState>(
                buildWhen: (_, state) => state is BleStateSetConnected,
                builder: (context, state) {
                  if (state is BleStateSetConnected) {
                    if (state.connected)
                      return Text("Smart Mask Connected");
                    else
                      return Text("Smart Mask Disconnected");
                  }
                  return Text("Loading..");
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
