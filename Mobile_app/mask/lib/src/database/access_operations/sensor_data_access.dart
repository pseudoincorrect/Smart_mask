import 'dart:async';
import 'package:mask/src/database/database.dart';
import 'package:mask/src/database/models/sensor_data_model.dart';
import 'package:mask/src/widgets/graph/time_series.dart';

class SensorDataAccess {
  final dbProvider = DatabaseProvider.dbProvider;

  Future<int> createSensorData(SensorData sensorData) async {
    final db = await dbProvider.database;
//    print(sensorData.toDatabaseJson().toString());
    var result = db.insert(sensorDataTABLE, sensorData.toDatabaseJson());
    return result;
  }

  Future<List<SensorData>> getSensorData(Sensor sensor,
      {List<DateTime> interval}) async {
    final db = await dbProvider.database;
    List<Map<String, dynamic>> result;
    String query =
        'SELECT * FROM $sensorDataTABLE WHERE sensorName = \'${sensor.toString()}\'';

    if (interval != null) {
      query += ' AND ';
      final int dateLowMs = interval[0].millisecondsSinceEpoch;
      final int dateHighMs = interval[1].millisecondsSinceEpoch;
      query += ' timeStamp > $dateLowMs AND timeStamp < $dateHighMs';
    }

    result = await db.rawQuery(query);

    List<SensorData> sensorData =
        result.map((item) => SensorData.fromDatabaseJson(item)).toList();
    return sensorData;
  }

  Future<int> deleteAllSensorData() async {
    final db = await dbProvider.database;
    var result = await db.rawDelete('DELETE FROM $sensorDataTABLE');
    return result;
  }

  Future<int> deleteSensorDataOlderThan(DateTime date) async {
    final db = await dbProvider.database;
    final int dateMs = date.millisecondsSinceEpoch;
    var result = await db
        .rawDelete('DELETE FROM $sensorDataTABLE WHERE timeStamp < $dateMs');
    return result;
  }
}
