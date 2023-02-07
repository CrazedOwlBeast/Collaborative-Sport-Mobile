import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
// import 'package:beacon_broadcast/beacon_broadcast.dart';
// import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  // Obtain FlutterBlue instance.
  final flutterReactiveBle = FlutterReactiveBle();

  // Start BeaconBroadcast instance.
  // BeaconBroadcast beaconBroadcast = BeaconBroadcast();

  //final FlutterBlePeripheral blePeripheral = FlutterBlePeripheral();
//
  //final AdvertiseData advertiseData = AdvertiseData(
  //  serviceUuid: 'bf27730d-860a-4e09-889c-2d8b6a9e0fe7',
  //  manufacturerId: 1234,
  //  manufacturerData: Uint8List.fromList([1, 2, 3, 4, 5, 6]),
  //);
  //final AdvertiseSettings advertiseSettings = AdvertiseSettings(
  //  advertiseMode: AdvertiseMode.advertiseModeBalanced,
  //  txPowerLevel: AdvertiseTxPower.advertiseTxPowerMedium,
  //  timeout: 3000,
  //);
  //final AdvertiseSetParameters advertiseSetParameters = AdvertiseSetParameters(
  //  txPowerLevel: txPowerMedium,
  //);
//
  //Future<void> _toggleAdvertise() async {
  //  if (await blePeripheral.isAdvertising) {
  //    await blePeripheral.stop();
  //  } else {
  //    await blePeripheral.start(advertiseData: advertiseData);
  //  }
  //}
//
  //Future<void> _toggleAdvertiseSet() async {
  //  if (await blePeripheral.isAdvertising) {
  //    await blePeripheral.stop();
  //  } else {
  //    await blePeripheral.start(
  //      advertiseData: advertiseData,
  //      advertiseSetParameters: advertiseSetParameters,
  //    );
  //  }
  //}

  Future<Map<Permission, PermissionStatus>> _getBluetoothPermissions() async {
    // Get permissions.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
    ].request();
    return statuses;
  }



  void _floatingActionButtonOnPressed() {
    // Get permissions.
    Future<Map<Permission,
        PermissionStatus>> statuses = _getBluetoothPermissions();

    // Start scanning
    StreamSubscription<DiscoveredDevice> bleScan = flutterReactiveBle
        .scanForDevices(withServices: [],
        scanMode: ScanMode.lowLatency).listen((device) {
      print(device.name);
    });

    showDialog(
      context: context,
      builder: (BuildContext context) =>
          SimpleDialog(
              title: const Text('Connect to a partner'),
              children: <Widget>[
                SimpleDialogOption(
                  onPressed: () {
                    bleScan.cancel();
                    Navigator.pop(context);
                  },
                  child: const Text('Stop scan'),
                ),
              ]
          ),
    );

    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      persistentFooterButtons:
      [FloatingActionButton(
        onPressed: _floatingActionButtonOnPressed,
        tooltip: 'Increment',
        child: const Icon(Icons.bluetooth),
      ),
      FloatingActionButton(
        onPressed: _floatingActionButtonOnPressed,
        tooltip: 'Increment',
        child: const Icon(Icons.play_arrow_sharp),
      )],// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
