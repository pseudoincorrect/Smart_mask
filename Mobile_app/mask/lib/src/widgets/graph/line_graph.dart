// Copyright 2018 the Charts project authors. Please see the AUTHORS file
// for details.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/// Time series chart with line annotation example
///
/// The example future range annotation extends beyond the range of the series
/// data, demonstrating the effect of the [Charts.RangeAnnotation.extendAxis]
/// flag. This can be set to false to disable range extension.
///
/// Additional annotations may be added simply by adding additional
/// [Charts.RangeAnnotationSegment] items to the list.
// EXCLUDE_FROM_GALLERY_DOCS_START
import 'dart:math';

// EXCLUDE_FROM_GALLERY_DOCS_END
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

import '../../data_processing/sensors_data/time_series.dart';

class TimeSeriesLineAnnotationChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  TimeSeriesLineAnnotationChart(this.seriesList, {this.animate});

  @override
  Widget build(BuildContext context) {
    return new charts.TimeSeriesChart(seriesList, animate: animate);
  }

  /// Creates a [TimeSeriesChart] with sample data and no transition.
  factory TimeSeriesLineAnnotationChart.withSampleData(
      List<TimeSeriesSensor> timeSeries) {
    return new TimeSeriesLineAnnotationChart(
      _createSampleData(timeSeries),
      animate: false,
    );
  }

  /// Creates a [TimeSeriesChart] with random data and animated transitions.
  factory TimeSeriesLineAnnotationChart.withRandomData() {
    return new TimeSeriesLineAnnotationChart(
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
        id: 'Sales',
        domainFn: (TimeSeriesSensor sensor, _) => sensor.time,
        measureFn: (TimeSeriesSensor sensor, _) => sensor.value,
        data: data,
      )
    ];
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<TimeSeriesSensor, DateTime>> _createSampleData(
      List<TimeSeriesSensor> timeSeries) {
    return [
      new charts.Series<TimeSeriesSensor, DateTime>(
        id: 'Sales',
        domainFn: (TimeSeriesSensor sensor, _) => sensor.time,
        measureFn: (TimeSeriesSensor sensor, _) => sensor.value,
        data: timeSeries,
      )
    ];
  }
}
