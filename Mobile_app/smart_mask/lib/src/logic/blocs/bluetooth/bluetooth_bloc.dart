//  Ble Business logic (BLoc)
//
//  Description:
//      contain the bluetooth state management for the app
//      manage data stream (sensors, and notification)

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_mask/src/logic/blocs/bloc.dart';

import 'package:smart_mask/src/logic/blocs/bluetooth/bluetooth_logic.dart';
import 'package:smart_mask/src/logic/models/sensor_control_model.dart';

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
    } else if (event is BleEventSetSelectedSensor) {
      yield* _mapBleEventSetSelectedSensor(event);
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
    yield* refreshSensor();
    print("_mapBleEventRefresh");
  }

  Stream<BleState> _mapBleEventSetSelectedSensor(
      BleEventSetSelectedSensor event) async* {
    _logic.selectedSensor = event.sensor;
    yield* refreshSensor();
  }

  Stream<BleState> _mapBleEventSetSamplePeriod(
      BleEventSetSamplePeriod event) async* {
    await _logic.setSamplePeriod(_logic.selectedSensor, event.samplePeriod);
    yield BleStateSetSamplePeriod(
      samplePeriod: event.samplePeriod,
    );
  }

  Stream<BleState> _mapBleEventSetGain(BleEventSetGain event) async* {
    await _logic.setGain(_logic.selectedSensor, event.gain);
    yield BleStateSetGain(
      gain: event.gain,
    );
  }

  Stream<BleState> _mapBleEventSetEnable(BleEventSetEnable event) async* {
    await _logic.setEnable(_logic.selectedSensor, event.enable);
    yield BleStateSetEnable(
      enable: event.enable,
    );
  }

  Stream<BleState> _mapBleEventSetConnected(BleEventSetConnected event) async* {
    yield BleStateSetConnected(connected: event.connected);
  }

  /////////////////////////////////////////////////////////////////////////////

  Stream<BleState> refreshSensor() async* {
    print("refreshSensor");
    int samplePeriod = _logic.getSamplePeriod(_logic.selectedSensor);
    yield BleStateSetSamplePeriod(samplePeriod: samplePeriod);
    SensorGain gain = _logic.getGain(_logic.selectedSensor);
    yield BleStateSetGain(gain: gain);
    bool enable = _logic.getEnable(_logic.selectedSensor);
    yield BleStateSetEnable(enable: enable);
  }

  dispose() {
    connSub.cancel();
  }

  /////////////////////////////////////////////////////////////////////////////

  BleLogic get bleLogic => _logic;
}
