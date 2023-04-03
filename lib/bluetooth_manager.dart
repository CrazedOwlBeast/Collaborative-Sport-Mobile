import 'dart:async';
import 'dart:convert';
import 'package:device_info/device_info.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';

class BluetoothManager {
  static final BluetoothManager _instance = BluetoothManager._();
  static BluetoothManager get instance => _instance;
  static final nearbyService = NearbyService();
  //map of connectioned devices
  //<String id, Device device>
  final Map<String, Device> connectedDevices = {};

  //streams
  StreamSubscription? dataSubscription;
  StreamSubscription? stateSubscription;

  //device data to broadcast
  final Map<int, Map<String, String>> _deviceData = {};

  //streamController for device data
  final StreamController<String>
    _deviceDataStreamController = StreamController.broadcast();

  Stream<String> get deviceDataStream => _deviceDataStreamController.stream;

  //Private Constructor
  BluetoothManager._() {
    dataSubscription = nearbyService.dataReceivedSubscription(callback: (data) {
      String receivedData = jsonEncode(data);
      print("dataReceivedSubscription: $receivedData");
      updateDeviceData(data['message']);
    });
  }

  //TODO: implement
  Future<void> disconnect(int id) async {

  }

  //unused, maybe implement later
  Future<bool> connectToDevice() async {
    try {
      return true;
    } catch(e) {
      //TODO: Log error
      return false;
    }
  }

  StreamSubscription? startStateSubscription() {
    stateSubscription?.cancel();
    stateSubscription =
        nearbyService.stateChangedSubscription(callback: (devicesList) {
          devicesList.forEach((element) {
            print(
                " deviceId: ${element.deviceId} | deviceName: ${element.deviceName} | state: ${element.state}");

            if (element.state == SessionState.connected && !connectedDevices.containsKey(element.deviceId)) {
              connectedDevices[element.deviceId] = element;
            }
            if (element.state == SessionState.notConnected && connectedDevices.containsKey(element.deviceId)) {
              connectedDevices.remove(element.deviceId);
            }
          });
        });
    return stateSubscription;
  }

  StreamSubscription? reconnectStateSubscription() {
    stateSubscription?.cancel();
    stateSubscription =
        nearbyService.stateChangedSubscription(callback: (devicesList) {
          devicesList.forEach((device) {
            print(
                " deviceId: ${device.deviceId} | deviceName: ${device.deviceName} | state: ${device.state}");

            if (BluetoothManager.instance.connectedDevices.containsKey(device.deviceId) && device.state == SessionState.notConnected) {
              //attempt to reconnect
              BluetoothManager.nearbyService.invitePeer(
                deviceID: device.deviceId,
                deviceName: device.deviceName,
              );
            }
          });
        });
    return stateSubscription;
  }

  Future<void> broadcastString(String str) async {
    for (String id in connectedDevices.keys) {
      nearbyService.sendMessage(id, str);
    }
  }

  Future<void> updateDeviceData(String str) async {
    _deviceDataStreamController.sink.add(str);
  }

}