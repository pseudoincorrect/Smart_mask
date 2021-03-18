//  Bluetooth Low Energy Services constants
//
//  Description:
//      Used to store constants related to bluetooth LE service
//      services: sms (sensor management service)
//      data is stored in a hierarchical way

const dynamic s = {
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
  "genericAttributService": {
    "UUID": "00001801-0000-1000-8000-00805f9b34fb",
    "characteristics": {
      "serviceChanged": {"UUID": "00002aa6-0000-1000-8000-00805f9b34fb"},
    },
  },
  "sensorMeasurementService": {
    "UUID": "00001600-1212-efde-1523-785feabcd124",
    "characteristics": {
      "sensors_1_vals": {"UUID": "00001601-1212-efde-1523-785feabcd124"},
      "sensors_1_ctrl": {"UUID": "00001602-1212-efde-1523-785feabcd124"},
      "sensors_2_vals": {"UUID": "00001603-1212-efde-1523-785feabcd124"},
      "sensors_2_ctrl": {"UUID": "00001604-1212-efde-1523-785feabcd124"},
      "sensors_3_vals": {"UUID": "00001605-1212-efde-1523-785feabcd124"},
      "sensors_3_ctrl": {"UUID": "00001606-1212-efde-1523-785feabcd124"},
      "sensors_4_vals": {"UUID": "00001607-1212-efde-1523-785feabcd124"},
      "sensors_4_ctrl": {"UUID": "00001608-1212-efde-1523-785feabcd124"},
    },
  },
};
