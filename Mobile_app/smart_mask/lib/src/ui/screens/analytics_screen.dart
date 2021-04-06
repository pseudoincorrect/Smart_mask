import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_mask/src/logic/blocs/bloc.dart';
import 'package:smart_mask/src/ui/widgets/analytics_widget.dart';

class AnalyticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    BlocProvider.of<AnalyticsBloc>(context).add(AnalyticsEventRefresh());
    BlocProvider.of<SensorDataBloc>(context).add(SensorDataEventRefresh());

    return SingleChildScrollView(
      child: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SelectAndRefresh(),
              AnalyticsGraph(),
              IntervalSlider(),
              FilterSelect(),
              EnableMockDataCheckbox(),
              DownloadButtons(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
