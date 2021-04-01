import 'package:flutter/material.dart';
import 'package:smart_mask/src/ui/widgets/analytics_widget.dart';

class AnalyticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SelectAndRefresh(),
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
