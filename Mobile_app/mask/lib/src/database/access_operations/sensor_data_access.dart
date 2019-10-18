import 'dart:async';
import 'package:mask/src/database/database.dart';
import 'package:mask/src/database/models/sensor_data_model.dart';

class SensorDataAccess {
  final dbProvider = DatabaseProvider.dbProvider;

  Future<int> createSensorData(SensorData sensorData) async {
    final db = await dbProvider.database;
    var result = db.insert(sensorDataTABLE, sensorData.toDatabaseJson());
    return result;
  }

  Future<List<SensorData>> getSensorData() async {
    final db = await dbProvider.database;

//    print("DB DUMP");
//    print(await db.rawQuery("SELECT * from $sensorDataTABLE"));

    List<Map<String, dynamic>> result;
    result = await db.rawQuery('SELECT * FROM $sensorDataTABLE');

    List<SensorData> sensorData =
        result.map((item) => SensorData.fromDatabaseJson(item)).toList();
    return sensorData;
  }

  Future<int> deleteAllSensorData() async {
    final db = await dbProvider.database;
    var result = await db.rawDelete("DELETE FROM $sensorDataTABLE");
    return result;
  }
}
