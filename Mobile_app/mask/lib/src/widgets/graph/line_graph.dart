import 'dart:math';

// EXCLUDE_FROM_GALLERY_DOCS_END
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

import '../../data_processing/sensors_data/time_series.dart';

class LineChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  LineChart(this.seriesList, {this.animate});

  @override
  Widget build(BuildContext context) {
    return new charts.TimeSeriesChart(
      seriesList,
      animate: animate,
      dateTimeFactory: const charts.LocalDateTimeFactory(),
    );
  }

  /// Creates a [TimeSeriesChart] with sample data and no transition.
  factory LineChart.withSampleData(List<TimeSeriesSensor> timeSeries) {
    return new LineChart(
      _createSampleData(timeSeries),
      animate: false,
    );
  }

  /// Creates a [TimeSeriesChart] with random data and animated transitions.
  factory LineChart.withRandomData() {
    return new LineChart(
      _createRandomData(),
      animate: true,
    );
  }

  /// Create random data.
  static List<charts.Series<TimeSeriesSensor, DateTime>> _createRandomData() {
    final random = new Random();

    final data = [
      new TimeSeriesSensor(new DateTime(2017, 9, 19), random.nextInt(100)),
      new TimeSeriesSensor(new DateTime(2017, 9, 26), random.nextInt(100)),
      new TimeSeriesSensor(new DateTime(2017, 10, 3), random.nextInt(100)),
      new TimeSeriesSensor(new DateTime(2017, 10, 10), random.nextInt(100)),
    ];

    return [
      new charts.Series<TimeSeriesSensor, DateTime>(
        id: 'sensorValues',
        domainFn: (TimeSeriesSensor sensor, _) => sensor.time,
        measureFn: (TimeSeriesSensor sensor, _) => sensor.value,
        data: data,
      )
    ];
  }

  /// Create one series with provided data.
  static List<charts.Series<TimeSeriesSensor, DateTime>> _createSampleData(
      List<TimeSeriesSensor> timeSeries) {
    return [
      new charts.Series<TimeSeriesSensor, DateTime>(
        id: 'sensorValues',
        domainFn: (TimeSeriesSensor sensor, _) => sensor.time,
        measureFn: (TimeSeriesSensor sensor, _) => sensor.value,
        data: timeSeries,
      )
    ];
  }
}
