import 'dart:async';
import 'dart:convert';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';

class BluetoothManager {
  static final BluetoothManager _instance = BluetoothManager._();
  static BluetoothManager get instance => _instance;
  static final nearbyService = NearbyService();

  // Map of connected devices
  final Map<String, Device> connectedDevices = {};

  // Streams
  StreamSubscription? dataSubscription;
  StreamSubscription? stateSubscription;

  // StreamController for device data
  final StreamController<String> _deviceDataStreamController = StreamController.broadcast();

  // Stream for data received from partners
  Stream<String> get deviceDataStream => _deviceDataStreamController.stream;

  // Private Constructor
  BluetoothManager._() {
    dataSubscription = nearbyService.dataReceivedSubscription(callback: (data) {
      String receivedData = jsonEncode(data);
      print("dataReceivedSubscription: $receivedData");
      updateDeviceData(data['message']);
    });
  }

  // Unused, maybe implement later
  Future<void> disconnect(int id) async {
    // Implement disconnect logic if needed
  }

  // Unused, maybe implement later
  Future<bool> connectToDevice() async {
    try {
      return true;
    } catch (e) {
      // TODO: Log error
      print("Error connecting to device: $e");
      return false;
    }
  }

  StreamSubscription? startStateSubscription() {
    // stateSubscription?.cancel();
    print("state change sub called");
    stateSubscription = nearbyService.stateChangedSubscription(callback: (devicesList) {
      print("<----- Devices ----->");
      print(devicesList.toString());
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

  // Sets the stateSubscription to detect unexpected disconnects and attempts to reconnect
  StreamSubscription? reconnectStateSubscription() {
    stateSubscription?.cancel();
    stateSubscription = nearbyService.stateChangedSubscription(callback: (devicesList) {
      devicesList.forEach((device) {
        print(
            " deviceId: ${device.deviceId} | deviceName: ${device.deviceName} | state: ${device.state}");

        if (connectedDevices.containsKey(device.deviceId) && device.state == SessionState.notConnected) {
          // Attempt to reconnect
          nearbyService.invitePeer(
            deviceID: device.deviceId,
            deviceName: device.deviceName,
          );
        }
      });
    });
    return stateSubscription;
  }

  // Sends string to all connected devices
  Future<void> broadcastString(String str) async {
    for (String id in connectedDevices.keys) {
      nearbyService.sendMessage(id, str);
    }
  }

  // Adds string to deviceDataStream
  Future<void> updateDeviceData(String str) async {
    _deviceDataStreamController.sink.add(str);
  }
}
