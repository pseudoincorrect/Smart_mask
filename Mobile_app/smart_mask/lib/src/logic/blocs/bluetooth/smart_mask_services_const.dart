//  Bluetooth Low Energy Services constants
//
//  Description:
//      Used to store constants related to bluetooth LE service
//      services: sms (sensor management service)
//      data is stored in a hierarchical way

const SENSOR_VALS_PER_PACKET = 10;

const SAMPLE_PERIOD_MS = 250;

const dynamic S = {
  "genericAccessService": {
    "UUID": "00001800-0000-1000-8000-00805f9b34fb",
    "characteristics": {
      "deviceName": {"UUID": "00002a00-0000-1000-8000-00805f9b34fb"},
      "appearance": {"UUID": "00002a01-0000-1000-8000-00805f9b34fb"},
      "peripheralPreferredConnectionParameters": {
        "UUID": "00002a04-0000-1000-8000-00805f9b34fb"
      },
    },
  },
  "genericAttributeService": {
    "UUID": "00001801-0000-1000-8000-00805f9b34fb",
    "characteristics": {
      "serviceChanged": {"UUID": "00002aa6-0000-1000-8000-00805f9b34fb"},
    },
  },
  "sensorMeasurementService": {
    "UUID": "00001600-1212-efde-1523-785feabcd124",
    "characteristics": {
      "values": {
        "sensors_1": {"UUID": "00000001-1212-efde-1523-785feabcd124"},
        "sensors_2": {"UUID": "00000003-1212-efde-1523-785feabcd124"},
        "sensors_3": {"UUID": "00000005-1212-efde-1523-785feabcd124"},
        "sensors_4": {"UUID": "00000007-1212-efde-1523-785feabcd124"},
      },
      "control": {
        "sensors_1": {"UUID": "00000002-1212-efde-1523-785feabcd124"},
        "sensors_2": {"UUID": "00000004-1212-efde-1523-785feabcd124"},
        "sensors_3": {"UUID": "00000006-1212-efde-1523-785feabcd124"},
        "sensors_4": {"UUID": "00000008-1212-efde-1523-785feabcd124"},
      }
    },
  },
};
