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
    "UUID": "00001800-0000-1000-8000-00805F9B34FB",
    "characteristics": {
      "deviceName": {"UUID": "00002A00-0000-1000-8000-00805F9B34FB"},
      "appearance": {"UUID": "00002A01-0000-1000-8000-00805F9B34FB"},
      "peripheralPreferredConnectionParameters": {
        "UUID": "00002A04-0000-1000-8000-00805F9B34FB"
      },
    },
  },
  "genericAttributeService": {
    "UUID": "00001801-0000-1000-8000-00805F9B34FB",
    "characteristics": {
      "serviceChanged": {"UUID": "00002AA6-0000-1000-8000-00805F9B34FB"},
    },
  },
  "sensorMeasurementService": {
    "UUID": "00000000-1212-EFDE-1523-785FEABCD124",
    "characteristics": {
      "values": {
        "sensor_1": {"UUID": "00000001-1212-EFDE-1523-785FEABCD124"},
        "sensor_2": {"UUID": "00000003-1212-EFDE-1523-785FEABCD124"},
        "sensor_3": {"UUID": "00000005-1212-EFDE-1523-785FEABCD124"},
        "sensor_4": {"UUID": "00000007-1212-EFDE-1523-785FEABCD124"},
      },
      "control": {
        "sensor_1": {"UUID": "00000002-1212-EFDE-1523-785FEABCD124"},
        "sensor_2": {"UUID": "00000004-1212-EFDE-1523-785FEABCD124"},
        "sensor_3": {"UUID": "00000006-1212-EFDE-1523-785FEABCD124"},
        "sensor_4": {"UUID": "00000008-1212-EFDE-1523-785FEABCD124"},
      }
    },
  },
};
