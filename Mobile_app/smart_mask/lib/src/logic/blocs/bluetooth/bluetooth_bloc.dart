//  Ble Business logic (BLoc)
//
//  Description:
//      contain the bluetooth state management for the app
//      manage data stream (sensors, and notification)

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_mask/src/logic/blocs/bloc.dart';
import 'package:smart_mask/src/logic/blocs/bluetooth/bluetooth_event.dart';

import 'package:smart_mask/src/logic/blocs/bluetooth/bluetooth_logic.dart';
import 'package:smart_mask/src/logic/database/models/sensor_control_model.dart';
import 'package:smart_mask/src/logic/database/models/sensor_model.dart';

class BleBloc extends Bloc<BleEvent, BleState> {
  late BleLogic _logic;
  late Timer connSub;

  BleBloc() : super(BleStateInitial()) {
    _logic = BleLogic();

    connSub = Timer.periodic(
      Duration(seconds: 2),
      (Timer t) async =>
          add(BleEventSetConnected(connected: await _logic.isConnected())),
    );
  }

  @override
  Stream<BleState> mapEventToState(event) async* {
    if (event is BleEventRefresh) {
      yield* _mapBleEventRefresh();
    } else if (event is BleEventRefreshWithSensor) {
      yield* _mapBleEventRefreshWithSensor(event);
    } else if (event is BleEventSetSamplePeriod) {
      yield* _mapBleEventSetSamplePeriod(event);
    } else if (event is BleEventSetGain) {
      yield* _mapBleEventSetGain(event);
    } else if (event is BleEventSetEnable) {
      yield* _mapBleEventSetEnable(event);
    } else if (event is BleEventSetConnected) {
      yield* _mapBleEventSetConnected(event);
    }
  }

  Stream<BleState> _mapBleEventRefresh() async* {
    for (var sensor in Sensor.values) {
      int samplePeriod = _logic.getSamplePeriod(sensor);
      add(BleEventSetSamplePeriod(sensor: sensor, samplePeriod: samplePeriod));
      SensorGain gain = _logic.getGain(sensor);
      add(BleEventSetGain(sensor: sensor, gain: gain));
      bool enable = _logic.getEnable(sensor);
      add(BleEventSetEnable(sensor: sensor, enable: enable));
    }
  }

  Stream<BleState> _mapBleEventRefreshWithSensor(
      BleEventRefreshWithSensor event) async* {
    Sensor sensor = event.sensor;
    int samplePeriod = _logic.getSamplePeriod(sensor);
    add(BleEventSetSamplePeriod(sensor: sensor, samplePeriod: samplePeriod));
    SensorGain gain = _logic.getGain(sensor);
    add(BleEventSetGain(sensor: sensor, gain: gain));
    bool enable = _logic.getEnable(sensor);
    add(BleEventSetEnable(sensor: sensor, enable: enable));
  }

  Stream<BleState> _mapBleEventSetSamplePeriod(
      BleEventSetSamplePeriod event) async* {
    await _logic.setSamplePeriod(event.sensor, event.samplePeriod);
    yield BleStateSetSamplePeriod(
      sensor: event.sensor,
      samplePeriod: event.samplePeriod,
    );
  }

  Stream<BleState> _mapBleEventSetGain(BleEventSetGain event) async* {
    await _logic.setGain(event.sensor, event.gain);
    yield BleStateSetGain(
      sensor: event.sensor,
      gain: event.gain,
    );
  }

  Stream<BleState> _mapBleEventSetEnable(BleEventSetEnable event) async* {
    await _logic.setEnable(event.sensor, event.enable);
    yield BleStateSetEnable(
      sensor: event.sensor,
      enable: event.enable,
    );
  }

  Stream<BleState> _mapBleEventSetConnected(BleEventSetConnected event) async* {
    yield BleStateSetConnected(connected: event.connected);
  }

  dispose() {
    connSub.cancel();
  }

  /////////////////////////////////////////////////////////////////////////////

  BleLogic get bleLogic => _logic;
}
