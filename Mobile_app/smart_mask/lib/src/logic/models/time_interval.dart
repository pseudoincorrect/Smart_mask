class TimeIntervalMsEpoch {
  /// oldest timestamp
  late int start;

  /// Newest timestamp
  late int end;

  TimeIntervalMsEpoch({required this.start, required this.end});

  factory TimeIntervalMsEpoch.fromTimeInterval(TimeInterval interval) {
    return TimeIntervalMsEpoch(
      start: interval.start.millisecondsSinceEpoch,
      end: interval.end.millisecondsSinceEpoch,
    );
  }
}

class TimeInterval {
  /// oldest DateTime
  late DateTime start;

  /// Newest DateTime
  late DateTime end;

  TimeInterval({required this.start, required this.end});

  factory TimeInterval.fromTimeIntervalMsEpoch(TimeIntervalMsEpoch interval) {
    return TimeInterval(
      start: DateTime.fromMillisecondsSinceEpoch(interval.start),
      end: DateTime.fromMillisecondsSinceEpoch(interval.end),
    );
  }
}
