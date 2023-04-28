import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

//Class to store information of BLE devices
class BleSensorDevice {

  final String deviceId;
  final String type;
  final FlutterReactiveBle flutterReactiveBle;
  final serviceId;
  final characteristicId;

  BleSensorDevice({
    required this.type,
    required this.flutterReactiveBle,
    required this.deviceId,
    required this.serviceId,
    required this.characteristicId
  });

}