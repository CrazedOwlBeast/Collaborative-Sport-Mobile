import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleSensorDevice {

  final Uuid HEART_RATE_SERVICE_UUID = Uuid.parse('180d');
  final Uuid HEART_RATE_CHARACTERISTIC = Uuid.parse('2a37');
  String deviceId;

  final String type;
  final FlutterReactiveBle flutterReactiveBle;


  BleSensorDevice({required this.type, required this.flutterReactiveBle, required this.deviceId});



  Future<void> connect() async {

  }


}