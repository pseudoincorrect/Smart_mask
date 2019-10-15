import 'package:flutter/material.dart';
import '../widgets/graph.dart';

Widget graphs() {
  return Scaffold(
    appBar: AppBar(
      title: const Text("graphs"),
    ),
    body: Center(
      child: TimeSeriesLineAnnotationChart.withRandomData(),
//        child: Text("first Graph"),
    ),
  );
}
