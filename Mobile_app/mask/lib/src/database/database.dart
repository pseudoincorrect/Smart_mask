import 'dart:async';
import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

final sensorDataTABLE = 'SensorData';

class DatabaseProvider {
  static final DatabaseProvider dbProvider = DatabaseProvider();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await createDatabase();
    return _database;
  }

  createDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'SensorData.db');

    // await deleteDatabase(path);
    // print("database deleted");

    var database = await openDatabase(path, version: 1, onCreate: initDb);
    print("database created");

    return database;
  }

  void initDb(Database database, int version) async {
    await database.execute(''' 
    CREATE TABLE $sensorDataTABLE (
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        sensor TEXT NOT NULL, 
        timeStamp INT NOT NULL,
        value INT NOT NULL
    ) 
    ''');
  }
}
