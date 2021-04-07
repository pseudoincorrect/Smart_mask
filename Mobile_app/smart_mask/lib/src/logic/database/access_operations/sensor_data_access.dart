//  Sensor Data Database Access
//
//  Description:
//      Enable the access to sensor data database for
//      the usual Insert, delete, etc..

import 'dart:async';
import 'package:smart_mask/src/logic/database/database.dart';
import 'package:smart_mask/src/logic/models/sensor_model.dart';
import 'package:smart_mask/src/logic/models/time_interval.dart';

class SensorDataAccess {
  final dbProvider = DatabaseProvider.dbProvider;

  Future<int> createSensorData(SensorData sensorData) async {
    final db = await dbProvider.database;
    var result = db.insert(sensorDataTABLE, sensorData.toDatabaseJson());
    return result;
  }

  Future<SensorData?> getOldestSensorData(Sensor sensor) async {
    final db = await dbProvider.database;
    List<Map<String, dynamic>> result;
    String query =
        'SELECT * FROM $sensorDataTABLE WHERE sensor = \'${sensorEnumToString(sensor)}\' ORDER BY ID ASC LIMIT 1';

    result = await db.rawQuery(query);

    List<SensorData> sensorData =
        result.map((item) => SensorData.fromDatabaseJson(item)).toList();
    if (sensorData.isNotEmpty) return sensorData[0];
    return null;
  }

  Future<SensorData?> getNewestSensorData(Sensor sensor) async {
    final db = await dbProvider.database;
    List<Map<String, dynamic>> result;
    String query =
        'SELECT * FROM $sensorDataTABLE WHERE sensor = \'${sensorEnumToString(sensor)}\' ORDER BY ID DESC LIMIT 1';

    result = await db.rawQuery(query);

    List<SensorData> sensorData =
        result.map((item) => SensorData.fromDatabaseJson(item)).toList();
    if (sensorData.isNotEmpty) return sensorData[0];
    return null;
  }

  Future<SensorData?> getAnyOldestSensorData() async {
    final db = await dbProvider.database;
    List<Map<String, dynamic>> result;
    String query = 'SELECT * FROM $sensorDataTABLE ORDER BY ID ASC LIMIT 1';

    result = await db.rawQuery(query);

    List<SensorData> sensorData =
        result.map((item) => SensorData.fromDatabaseJson(item)).toList();
    if (sensorData.isNotEmpty) return sensorData[0];
    return null;
  }

  Future<SensorData?> getAnyNewestSensorData() async {
    final db = await dbProvider.database;
    List<Map<String, dynamic>> result;
    String query = 'SELECT * FROM $sensorDataTABLE ORDER BY ID DESC LIMIT 1';

    result = await db.rawQuery(query);

    List<SensorData> sensorData =
        result.map((item) => SensorData.fromDatabaseJson(item)).toList();
    if (sensorData.isNotEmpty) return sensorData[0];
    return null;
  }

  Future<List<SensorData>> getSensorData(Sensor sensor,
      {required TimeIntervalMsEpoch interval}) async {
    final db = await dbProvider.database;
    List<Map<String, dynamic>> result;
    String query =
        'SELECT * FROM $sensorDataTABLE WHERE sensor = \'${sensorEnumToString(sensor)}\'';

    query += ' AND ';
    final int dateLowMs = interval.start;
    final int dateHighMs = interval.end;
    query += ' timeStamp > $dateLowMs AND timeStamp < $dateHighMs';

    result = await db.rawQuery(query);

    List<SensorData> sensorData =
        result.map((item) => SensorData.fromDatabaseJson(item)).toList();
    return sensorData;
  }

  Future<List<SensorData>> getAllSensorData(
      {required TimeIntervalMsEpoch interval}) async {
    final db = await dbProvider.database;
    List<Map<String, dynamic>> result;
    String query = 'SELECT * FROM $sensorDataTABLE WHERE ';

    final int dateLowMs = interval.start;
    final int dateHighMs = interval.end;
    query += ' timeStamp > $dateLowMs AND timeStamp < $dateHighMs';

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
