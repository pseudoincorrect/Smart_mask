//  Sensor Data Transmission Logic (BLoc)
//
//  Description:
//    BLoc to manage data transmission either through internet or through
//    download to file system

import 'dart:async';
import 'dart:io';

// ignore: import_of_legacy_library_into_null_safe
import 'package:csv/csv.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_mask/src/logic/blocs/bloc.dart';
import 'package:smart_mask/src/logic/models/sensor_model.dart';
import 'package:smart_mask/src/logic/models/time_interval.dart';
import 'package:smart_mask/src/logic/repositories/sensor_data_repo.dart';

class TransmissionBloc extends Bloc<TransmissionEvent, TransmissionState> {
  late TransmissionLogic _logic;

  TransmissionBloc() : super(TransmissionStateInitial()) {
    _logic = TransmissionLogic();
  }

  @override
  Stream<TransmissionState> mapEventToState(event) async* {
    if (event is TransmissionEventRefresh) {
      yield* _mapTransmissionEventRefresh();
    } else if (event is TransmissionEventSaveRawData) {
      yield* _mapTransmissionEventSaveRawData();
    }
  }

  Stream<TransmissionState> _mapTransmissionEventRefresh() async* {}

  Stream<TransmissionState> _mapTransmissionEventSaveRawData() async* {
    await _logic.saveRawData();
    yield TransmissionStateSuccess();
  }
}

class TransmissionLogic {
  late SensorDataRepository _sensorDataRepo;

  TransmissionLogic() {
    _sensorDataRepo = SensorDataRepository();
  }

  Future<List<SensorData>> getAllData() async {
    var intervalInHour = Duration(hours: 1);

    var latest = await _sensorDataRepo.getAnyNewestSensorData();
    if (latest == null) return [];

    var endTime = latest.timeStamp;
    var startTime = DateTime.fromMillisecondsSinceEpoch(endTime)
        .subtract(intervalInHour)
        .millisecondsSinceEpoch;
    var interval = TimeIntervalMsEpoch(start: startTime, end: endTime);
    return await _sensorDataRepo.getAllSensorData(interval: interval);
  }

  Future<void> saveRawData() async {
    var timeStart = DateTime.now();
    var sensorData = await getAllData();

    List<List<dynamic>> dataList = [];
    for (var d in sensorData) {
      dataList.add([
        sensorEnumToString(d.sensor),
        d.timeStamp,
        d.value,
      ]);
    }

    final res = const ListToCsvConverter().convert(dataList);

    var status = await Permission.storage.status;
    print("status $status");
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    String path = await ExtStorage.getExternalStoragePublicDirectory(
        ExtStorage.DIRECTORY_DOWNLOADS);

    print(path);

    File file = File('$path/sensor_data.csv');

    await file.writeAsString(res);

    var timeEnd = DateTime.now();

    var elapsed = timeEnd.difference(timeStart).inMilliseconds;

    print("timeStart : $timeStart");
    print("Elapsed   : $elapsed ms");

    return Future.delayed(Duration.zero);
  }
}
