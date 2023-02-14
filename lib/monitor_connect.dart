import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'ble_sensor_device.dart';

class MonitorConnect extends StatefulWidget {
  final FlutterReactiveBle flutterReactiveBle;
  final Function(BleSensorDevice) callback;
  const MonitorConnect({Key? key, required this.flutterReactiveBle, required this.callback}) : super(key: key);

  @override
  State<MonitorConnect> createState() => _MonitorConnectState();
}

class _MonitorConnectState extends State<MonitorConnect> {
  //const _MonitorConnectState({required })
  final Uuid HEART_RATE_SERVICE_UUID = Uuid.parse('180d');
  final Uuid HEART_RATE_CHARACTERISTIC = Uuid.parse('2a37');
  //final flutterReactiveBle = FlutterReactiveBle();
  late final flutterReactiveBle;
  List<DiscoveredDevice> devices = <DiscoveredDevice>[];
  StreamSubscription? scanSubscription;
  //List<BleSensorDevice> connectedDevices = <BleSensorDevice>[];

  @override
  void initState() {
    super.initState();
    flutterReactiveBle = widget.flutterReactiveBle;
    //scan for sensors
    debugPrint('Begin scan');
    if (flutterReactiveBle.status == BleStatus.ready) {
      //scanSubscription?.cancel();
      scanSubscription = flutterReactiveBle.scanForDevices(withServices: [HEART_RATE_SERVICE_UUID]).listen((device) {
        final knownDeviceIndex = devices.indexWhere((d) => d.id == device.id);
        if (knownDeviceIndex >= 0) {
          devices[knownDeviceIndex] = device;
        } else {
          devices.add(device);
        }
      }, onError: (Object e) {
        debugPrint('Error scanning for heart rate sensor: $e');
      });
    }
    else {
      debugPrint('Error: BLE status not ready');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan for devices'),
      ),
      body: Column(
        children: [
          Flexible(
            child: ListView(
              children: [
                ListTile(
                  title: Text('Discovered Devices:'),
                ),
                ...devices
                    .map(
                      (device) => ListTile(
                    title: Text(device.name),
                    subtitle: Text("${device.id}\nRSSI: ${device.rssi}"),
                    leading: const Icon(Icons.bluetooth),
                    onTap: () async {
                      //connnect
                      flutterReactiveBle.connectToDevice(
                        id: device.id,
                        servicesWithCharacteristicsToDiscover: {HEART_RATE_SERVICE_UUID: [HEART_RATE_CHARACTERISTIC]},
                      ).listen((update) {
                        debugPrint('Connection state update: ${update.connectionState}');
                      });
                      BleSensorDevice connnectedSensor = BleSensorDevice(type: 'HR', flutterReactiveBle: flutterReactiveBle, deviceId: device.id,);
                      //connectedDevices.add(connnectedSensor);
                      widget.callback(connnectedSensor);
                    },
                  ),
                )
                    .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    //widget.callback()
    scanSubscription?.cancel();
    super.dispose();
  }
}

