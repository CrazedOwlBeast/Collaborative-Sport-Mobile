import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'ble_sensor_device.dart';
import 'package:collection/collection.dart';

class MonitorConnect extends StatefulWidget {
  final FlutterReactiveBle flutterReactiveBle;
  final List<BleSensorDevice> connectedDevices;
  final Function(List<BleSensorDevice>) callback;
  const MonitorConnect({Key? key, required this.flutterReactiveBle, required this.callback, required this.connectedDevices}) : super(key: key);

  @override
  State<MonitorConnect> createState() => _MonitorConnectState();
}

class _MonitorConnectState extends State<MonitorConnect> {
  final Uuid HEART_RATE_SERVICE_UUID = Uuid.parse('180d');
  final Uuid HEART_RATE_CHARACTERISTIC = Uuid.parse('2a37');
  final Uuid CYCLING_POWER_SERVICE_UUID = Uuid.parse('1818');
  final Uuid CYCLING_POWER_CHARACTERISTIC = Uuid.parse('2a63');

  late final flutterReactiveBle;
  List<DiscoveredDevice> devices = <DiscoveredDevice>[];
  StreamSubscription? scanSubscription;
  late StreamSubscription<ConnectionStateUpdate> _connection;
  //List<BleSensorDevice> connectedDevices = <BleSensorDevice>[];
  Color _colorTile = Colors.white;

  @override
  void initState() {
    super.initState();
    flutterReactiveBle = widget.flutterReactiveBle;
    //scan for sensors
    debugPrint('Begin scan');
    if (flutterReactiveBle.status == BleStatus.ready) {
      //scanSubscription?.cancel();
      scanSubscription = flutterReactiveBle.scanForDevices(
          withServices: [HEART_RATE_SERVICE_UUID, CYCLING_POWER_SERVICE_UUID]).listen((device) {
        final knownDeviceIndex = devices.indexWhere((d) => d.id == device.id);
        if (knownDeviceIndex >= 0) {
          devices[knownDeviceIndex] = device;
        } else {
          setState(() {
            devices.add(device);
          });
        }
      }, onError: (Object e) {
        debugPrint('Error scanning for heart rate sensor: $e');
      });
    }
    else {
      debugPrint('Error: BLE status not ready');
    }
    for (BleSensorDevice d in widget.connectedDevices) {
      debugPrint("Device id: ${d.deviceId}");
    }

  }

  bool isConnected(String id) {
    bool result = widget.connectedDevices.firstWhereOrNull((element) => element.deviceId==id) != null;
    if (result) {
      debugPrint("True somehow");
    }
    else {
      debugPrint("False");
    }
    return result;
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
                    tileColor: !isConnected(device.id) ?
                        Colors.white : Colors.green,
                    onTap: () async {
                      //connect
                      BleSensorDevice connectedSensor;
                      if (!isConnected(device.id)) {
                        _connection = flutterReactiveBle.connectToDevice(
                          id: device.id,
                          servicesWithCharacteristicsToDiscover: {
                            HEART_RATE_SERVICE_UUID: [HEART_RATE_CHARACTERISTIC],
                            CYCLING_POWER_SERVICE_UUID: [CYCLING_POWER_CHARACTERISTIC],
                          },
                        ).listen((update) {
                          debugPrint('Connection state update: ${update
                              .connectionState}');
                        });

                        if (device.serviceUuids.any((service) => service == HEART_RATE_SERVICE_UUID)) {
                          connectedSensor = BleSensorDevice(
                            type: 'HR',
                            flutterReactiveBle: flutterReactiveBle,
                            deviceId: device.id,
                            serviceId: HEART_RATE_SERVICE_UUID,
                            characteristicId: HEART_RATE_CHARACTERISTIC,
                          );
                        }
                        else {
                          connectedSensor = BleSensorDevice(
                            type: 'POWER',
                            flutterReactiveBle: flutterReactiveBle,
                            deviceId: device.id,
                            serviceId: CYCLING_POWER_SERVICE_UUID,
                            characteristicId: CYCLING_POWER_CHARACTERISTIC,
                          );
                        }
                        widget.connectedDevices.add(connectedSensor);
                      }
                      else {
                        _connection.cancel();
                        widget.connectedDevices.removeWhere((element) => element.deviceId == device.id);
                      }
                      setState(() {
                        _colorTile = _colorTile == Colors.white ? Colors.green : Colors.white;
                      });
                      widget.callback(widget.connectedDevices);
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

