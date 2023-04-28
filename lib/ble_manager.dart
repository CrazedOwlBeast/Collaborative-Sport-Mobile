import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'ble_sensor_device.dart';

//Singleton class created to make BLE connections persistent throughout app
class BleManager {
  static final BleManager _instance = BleManager._();
  static BleManager get instance => _instance;
  static final flutterReactiveBle = FlutterReactiveBle();

  final List<BleSensorDevice> connectedSensors = <BleSensorDevice>[];
  BleManager._() {

  }
}