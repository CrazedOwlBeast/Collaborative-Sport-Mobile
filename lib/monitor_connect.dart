import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hello_world/app_logger.dart';
import 'ble_sensor_device.dart';
import 'package:collection/collection.dart';

class MonitorConnect extends StatefulWidget {
  final FlutterReactiveBle flutterReactiveBle;
  final List<BleSensorDevice> connectedDevices;
  final Function(List<BleSensorDevice>) callback;
  final LayerLink link;
  final OverlayEntry overlayEntry;
  final Offset offset;
  final double dialogWidth;
  final double dialogHeight;
  final AppLogger logger;

  const MonitorConnect({Key? key, required this.flutterReactiveBle,
    required this.callback, required this.connectedDevices, required this.link,
    required this.offset, required this.dialogWidth, required this.dialogHeight, required this.overlayEntry, required this.logger}) : super(key: key);


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
      widget.logger.loggerEvents.events.add(LoggerEvent(eventType: 11));
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
          debugPrint('Device found.');
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

  // TODO: ListView is scrolling into the Positioned elements.
  @override
  Widget build(BuildContext context) {
    return CompositedTransformFollower(
      offset: widget.offset,
      link: widget.link,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(45.0)),
        color: Colors.black,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
      SizedBox(
        width: widget.dialogWidth * 0.9,
        // height: widget.dialogHeight * 0.75,
        child:
        Column(
          children: [
            SizedBox(height: widget.dialogWidth * .12,),  // Margin for ListView
            Flexible(
              child: ListView(
                children: [
                  ...devices
                      .map(
                        (device) => ListTile(
                      title: Text(device.name,
                          style: GoogleFonts.openSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              height: 1.7,
                              color: Colors.white
                          )),
                      subtitle: Text("${device.id}\nRSSI: ${device.rssi}",
                          style: GoogleFonts.openSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              height: 1.7,
                              color: Colors.white
                          )),
                      leading: const Icon(Icons.bluetooth, color: Colors.white,),
                      tileColor: !isConnected(device.id) ?
                          Colors.white10 : Colors.green,
                      // minVerticalPadding: widget.dialogWidth * .03,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(45.0)),
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

                          if (device.serviceUuids.any((service) => service == HEART_RATE_SERVICE_UUID || service == Uuid.parse("0000180d-0000-1000-8000-00805f9b34fb"))) {
                            connectedSensor = BleSensorDevice(
                              type: 'HR',
                              flutterReactiveBle: flutterReactiveBle,
                              deviceId: device.id,
                              serviceId: HEART_RATE_SERVICE_UUID,
                              characteristicId: HEART_RATE_CHARACTERISTIC,
                            );
                            widget.connectedDevices.add(connectedSensor);

                            LoggerEvent loggerEvent = LoggerEvent(eventType: 12);
                            loggerEvent.bleDeviceName = 'heart rate monitor ${connectedSensor.deviceId}';
                            loggerEvent.processEvent();
                            widget.logger.loggerEvents.events.add(loggerEvent);
                          }
                          else if (device.serviceUuids.any((service) => service == CYCLING_POWER_SERVICE_UUID || service == Uuid.parse("00001818-0000-1000-8000-00805f9b34fb"))) {
                            connectedSensor = BleSensorDevice(
                              type: 'POWER',
                              flutterReactiveBle: flutterReactiveBle,
                              deviceId: device.id,
                              serviceId: CYCLING_POWER_SERVICE_UUID,
                              characteristicId: CYCLING_POWER_CHARACTERISTIC,
                            );
                            widget.connectedDevices.add(connectedSensor);

                            LoggerEvent loggerEvent = LoggerEvent(eventType: 12);
                            loggerEvent.bleDeviceName = 'power meter ${connectedSensor.deviceId}';
                            loggerEvent.processEvent();
                            widget.logger.loggerEvents.events.add(loggerEvent);
                          }

                        }
                        else {
                          _connection.cancel();
                          widget.connectedDevices.removeWhere((element) => element.deviceId == device.id);

                          LoggerEvent loggerEvent = LoggerEvent(eventType: 13);
                          loggerEvent.bleDeviceName = device.id;
                          loggerEvent.processEvent();
                          widget.logger.loggerEvents.events.add(loggerEvent);
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
      ),
          Container(
            height: widget.dialogHeight * 0.15,
            child: Stack(
              children: [
                Positioned(
                    width: widget.dialogWidth * .12,
                    height: widget.dialogWidth * .12,
                    top: widget.dialogWidth * .05,
                    right: widget.dialogWidth * .05,
                    child: FloatingActionButton(
                        mini: true,
                        backgroundColor: Colors.red,
                        onPressed: () {
                          widget.overlayEntry.remove();
                        },
                        child: Icon(Icons.clear_rounded, size: widget.dialogWidth * .11)
                    )),
                Positioned(
                  top: widget.dialogWidth * .05,
                  left: widget.dialogWidth * .15,
                  child: Text('Discovered Devices:',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.openSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 1.7,
                          color: Colors.white
                      )
                  ),
                )
              ],
            ),
          )

        ])
    ));
  }

  @override
  void dispose() {
    //widget.callback()
    scanSubscription?.cancel();
    super.dispose();
  }
}

