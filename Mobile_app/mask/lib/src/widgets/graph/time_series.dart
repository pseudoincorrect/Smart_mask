/// Sample time series data type.
class TimeSeriesSensor {
  final DateTime time;
  final int value;

  TimeSeriesSensor(this.time, this.value);

  @override
  String toString() {
    return 'time = ${this.time}, value = ${this.value}';
  }
}

