import 'package:bloc/bloc.dart';
import 'package:mask/src/widgets/graph/time_series.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mask/src/database/models/sensor_data_model.dart';
import '../../repositories/sensor_data_repo.dart';
import './sensor_data_state.dart';
import "./sensor_data_event.dart";

class SensorDataBloc2 extends Bloc<SensorDataEvent, SensorDataState> {
  final _sensorDataRepo = SensorDataRepository();

  SensorDataBloc2();

  @override
  SensorDataState get initialState => SensorDataLoading();

  @override
  Stream<SensorDataState> mapEventToState(SensorDataEvent event) async* {
    if (event is AddSensorData) {
      yield* _mapAddSensorDataToState();
    } else if (event is DeleteAllSensorData) {
      yield* _mapDeleteAllSensorDataToState();
    }
  }

  Stream<SensorDataState> _mapAddSensorDataToState() async* {}

  Stream<SensorDataState> _mapDeleteAllSensorDataToState() async* {}
}
