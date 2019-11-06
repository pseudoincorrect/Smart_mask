//  Time Serie data type class
//
//  Description:
//      Class used to define a time sere data (a dot in line chart)
//      this data type is used by the graph widget to create line chart
//      with a list of TimeSerieSensor data

class TimeSeriesSensor {
  final DateTime time;
  final int value;

  TimeSeriesSensor(this.time, this.value);

  @override
  String toString() {
    return 'time = ${this.time}, value = ${this.value}';
  }
}
