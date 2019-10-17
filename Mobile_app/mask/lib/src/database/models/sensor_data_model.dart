class SensorData {
  int id;
  String sensorName;
  int timeStamp;
  int value;

  SensorData({this.id, this.sensorName, this.timeStamp, this.value});

  factory SensorData.fromDatabaseJson(Map<String, dynamic> data) => SensorData(
      id: data['id'],
      sensorName: data['sensorName'],
      timeStamp: data['timeStamp'],
      value: data['value']);

  Map<String, dynamic> toDatabaseJson() => {
        "id": this.id,
        "sensorName": this.sensorName,
        "timeStamp": this.timeStamp,
        "value": this.value,
      };

  @override
  String toString() {
    // TODO: implement toString
    return 'id = ${this.id}, sensorName = ${this.sensorName}, timeStamp = ${this.timeStamp}, value = ${this.value}';
  }
}
