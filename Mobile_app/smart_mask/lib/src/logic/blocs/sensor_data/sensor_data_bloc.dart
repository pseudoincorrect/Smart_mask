import 'package:bloc/bloc.dart';
import 'package:smart_mask/src/logic/blocs/bloc.dart';

import 'dart:async';

import 'package:smart_mask/src/logic/blocs/sensor_data/sensor_mock.dart';
import 'package:smart_mask/src/logic/database/models/sensor_model.dart';
import 'package:smart_mask/src/logic/repositories/sensor_data_repo.dart';

class SensorDataBloc extends Bloc<SensorDataEvent, SensorDataState> {
  Duration windowInterval = Duration(seconds: 20);
  Duration refreshInterval = Duration(seconds: 1);
  late SensorDataLogic _logic;
  late Timer refreshSub;

  SensorDataBloc() : super(SensorDataStateInitial()) {
    _logic = SensorDataLogic();
    this.add(SensorDataEventDataRefresh());
    refreshSub = startRefreshTimers(refreshInterval);
  }

  @override
  Future<void> close() async {
    refreshSub.cancel();
    super.close();
  }

  /////////////////////////////////////////////////////////////////////////////

  @override
  Stream<SensorDataState> mapEventToState(event) async* {
    if (event is SensorDataEventRefresh) {
      yield* _mapSensorDataEventRefresh();
    } else if (event is SensorDataEventDataRefresh) {
      yield* _mapSensorDataEventDataRefresh();
    } else if (event is SensorDataEventSelectedSensor) {
      yield* _mapSensorDataEventSelectedSensor(event);
    } else if (event is SensorDataEventEnableMock) {
      yield* _mapSensorDataEventEnableMock(event);
    }
  }

  Stream<SensorDataState> _mapSensorDataEventRefresh() async* {
    this.add(SensorDataEventSelectedSensor(sensor: _logic.selectedSensor));
    this.add(SensorDataEventEnableMock(enable: _logic.sensorsMock.isEnabled()));
    this.add(SensorDataEventDataRefresh());
  }

  Stream<SensorDataState> _mapSensorDataEventDataRefresh() async* {
    for (var sensor in Sensor.values) {
      var interval = [DateTime.now().subtract(windowInterval), DateTime.now()];
      var data = await _logic.getSensorData(sensor, interval: interval);
      yield SensorDataStateSensorData(sensor: sensor, data: data);
    }
  }

  Stream<SensorDataState> _mapSensorDataEventSelectedSensor(
      SensorDataEventSelectedSensor event) async* {
    _logic.selectedSensor = event.sensor;
    yield SensorDataStateSelectedsensor(sensor: _logic.selectedSensor);
  }

  Stream<SensorDataState> _mapSensorDataEventEnableMock(
      SensorDataEventEnableMock event) async* {
    if (event.enable) {
      _logic.enableMockData();
    } else {
      _logic.disableMockData();
    }
    yield SensorDataStateEnableMock(enable: event.enable);
  }

  /////////////////////////////////////////////////////////////////////////////

  Timer startRefreshTimers(Duration refreshInterval) {
    return Timer.periodic(refreshInterval, (Timer t) {
      this.add(SensorDataEventDataRefresh());
    });
  }

  Sensor get selectedSensor => _logic.selectedSensor;
}

/////////////////////////////////////////////////////////////////////////////

class SensorDataLogic {
  late SensorDataRepository _sensorDataRepo;
  late Sensor selectedSensor;
  late SensorsMock sensorsMock;

  SensorDataLogic() {
    _sensorDataRepo = SensorDataRepository();
    selectedSensor = Sensor.sensor_1;
    sensorsMock = SensorsMock();
  }

  Future<List<SensorData>> getSensorData(Sensor sensor,
      {required List<DateTime> interval}) async {
    return await _sensorDataRepo.getSensorData(sensor, interval: interval);
  }

  bool isMockDataEnabled() {
    return sensorsMock.isEnabled();
  }

  void enableMockData() {
    if (!sensorsMock.isEnabled()) sensorsMock.enableMock();
  }

  void disableMockData() {
    if (sensorsMock.isEnabled()) sensorsMock.disableMock();
  }
}
