//  Line graph
//
//  Description:
//      Class mainly dealing with chart_flutter library
//      in order to display a line graph for temporal data

import 'dart:math';

// ignore: import_of_legacy_library_into_null_safe
import 'package:charts_flutter/flutter.dart' as charts;

import 'package:flutter/material.dart';
import 'time_series.dart';

class LineChart extends StatelessWidget {
  final List<charts.Series<dynamic, DateTime>> seriesList;
  final bool animate;

  LineChart(this.seriesList, {required this.animate});

  @override
  Widget build(BuildContext context) {
    return charts.TimeSeriesChart(
      seriesList,
      animate: animate,
      dateTimeFactory: const charts.LocalDateTimeFactory(),
    );
  }

  /// Creates a [TimeSeriesChart] with sample data and no transition.
  factory LineChart.withSampleData(List<TimeSeriesSensor> timeSeries) {
    return LineChart(
      _createSampleData(timeSeries),
      animate: false,
    );
  }

  /// Creates a [TimeSeriesChart] with random data and animated transitions.
  factory LineChart.withRandomData() {
    return LineChart(
      _createRandomData(),
      animate: true,
    );
  }

  /// Create random data.
  static List<charts.Series<TimeSeriesSensor, DateTime>> _createRandomData() {
    final random = Random();

    final data = [
      TimeSeriesSensor(DateTime(2017, 9, 19), random.nextInt(100)),
      TimeSeriesSensor(DateTime(2017, 9, 26), random.nextInt(100)),
      TimeSeriesSensor(DateTime(2017, 10, 3), random.nextInt(100)),
      TimeSeriesSensor(DateTime(2017, 10, 10), random.nextInt(100)),
    ];

    return [
      charts.Series<TimeSeriesSensor, DateTime>(
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
      charts.Series<TimeSeriesSensor, DateTime>(
        id: 'sensorValues',
        domainFn: (TimeSeriesSensor sensor, _) => sensor.time,
        measureFn: (TimeSeriesSensor sensor, _) => sensor.value,
        data: timeSeries,
      )
    ];
  }
}
