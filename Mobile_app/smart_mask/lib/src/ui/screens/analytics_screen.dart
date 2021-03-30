import 'package:flutter/material.dart';
import 'package:smart_mask/src/ui/widgets/analytics_widget.dart';
import 'package:smart_mask/src/ui/widgets/graph/sensor_graph.dart';
import 'package:smart_mask/src/logic/database/models/sensor_model.dart';
import 'package:smart_mask/src/ui/widgets/sensor_control_widgets.dart';

class AnalyticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SensorSelectAnalyticsDropButton(),
              AnalyticsSensorGraph(),
              IntervalSlider(),
              FilterSelect(),
              DownloadButtons(),
              EnableMockDataCheckbox(),
            ],
          ),
        ),
      ),
    );
  }
}
