import 'dart:async';
import 'dart:io';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hello_world/active_workout.dart';
import 'home_screen.dart';

// Not used yet
class PartnerConnect extends StatefulWidget {
  const PartnerConnect({super.key});

  @override
  State<PartnerConnect> createState() => _PartnerConnectState();
}

// TODO: Android uses MAC for connections, iOS uses UUID...
class _PartnerConnectState extends State<PartnerConnect> {
  // Obtain FlutterReactiveBle instance for this screen // TODO: Entire app?
  final flutterReactiveBle = FlutterReactiveBle();

  final List<String> foundPartnersUUIDs = [];
  // Map of UUIDS:MACS
  final foundDevicesUUIDs = {};
  final List<ElevatedButton> partnerButtonsList = [];

  @override
  void initState() {
    super.initState();
    scanBLE(); // TODO
  }

  // TODO: StreamBuilder?
  StreamSubscription<DiscoveredDevice> scanBLE() {
    // MAC is used to connect but is random, need to scan for UUID
    // A special UUID is advertised while app is running, allowing users to
    // find others using the app to connect to.
    // A List<String> is used to keep track of UUIDs found during scan
    // Start scanning
    // Iterates for each device found.
    StreamSubscription<DiscoveredDevice> bleScan = flutterReactiveBle
        .scanForDevices(withServices: [],
        scanMode: ScanMode.lowLatency).listen((device) {
      // Ignore device if already seen during this scan.
      bool newUUID = true;
      for (String UUID in foundDevicesUUIDs.keys) {
        if (UUID == device.serviceUuids.toString()) {
          newUUID = false;
          break;
        }
      }
      if (newUUID == true) {
        // Add device to list of found devices to prevent it from being displayed multiple times.
        foundDevicesUUIDs[device.serviceUuids.toString()] = device.id; // MAC is device.id
        foundPartnersUUIDs.add(device.serviceUuids.toString());
        if (device.serviceUuids.toString().startsWith("[48454c4c")) {
          setState(() {
            _updateButtonList(device.serviceUuids.toString());
          });
        }
        // TODO: Make UUIDs meaningful. (App identifier and name?)
        // Check for app identifier to differentiate between partners and other devices.
        if (device.serviceUuids.toString() ==
            "[48454c4c-4f57-4f52-4c44-2d4852313034]") {
          //foundPartnersUUIDs.add(device.serviceUuids.toString());
          // Device info string printed to terminal for testing.
          print("Partner found!\n"
              "Name: ${device.name}\n"
              "ID: ${device.id}\n"
              "Manufacturer Data: ${device.manufacturerData}\n"
              "RSSI: ${device.rssi}\n"
              "Service Data: ${device.serviceData}\n"
              "Service UUIDs: ${device.serviceUuids}\n\n");
        }
      }
      print("BLE device found in scan.");
      print(foundPartnersUUIDs);
    }); // End of BLE listener.

    return bleScan;
  }

  // Function to add buttons when device is found
  List<Widget> _updateButtonList(String newUUID) {
    if (partnerButtonsList.length >= 2) {
      partnerButtonsList.removeLast();
    }
    ElevatedButton newButton = ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Color.fromRGBO(90, 90, 90, 0.5)),
        minimumSize: MaterialStateProperty.all<Size>(const Size(300, 60)),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          )
        )
      ),
      onPressed: () {
        _partnerConnect(newUUID);
      },
      child: Wrap(
        spacing: 90,
        alignment: WrapAlignment.spaceEvenly,
        children: [
          // const Icon(Icons.directions_walk_outlined, size: 50,),
          // Spacer(),
          Text(newUUID, style: GoogleFonts.openSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.2
          )),
        ],
      )
    );
    partnerButtonsList.add(newButton);
    return partnerButtonsList;
  }

  _partnerConnect(String uUID) {
    //String partnerID = "";
    //if (Platform.isAndroid) {
    //  partnerID = foundDevicesUUIDs[uUID];
    //}
    //else if (Platform.isIOS) {
    //  partnerID = uUID;
    //}
    //flutterReactiveBle.connectToDevice(
    //    id: partnerID
    //);

  }

    // Build Button widgets for dialog.
    //st<TextButton> partnersButtonList = [];
    //r (String UUID in foundPartnersUUIDs) {
    //TextButton newButton = TextButton(
    //  style: ButtonStyle(
    //      backgroundColor: MaterialStateProperty.all(
    //          Color.fromRGBO(90, 90, 90, 0.5)),
    //      minimumSize: MaterialStateProperty.all<Size>(const Size(300, 60)),
    //      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    //          RoundedRectangleBorder(
    //            borderRadius: BorderRadius.circular(15.0),
    //          )
    //      )
    //  ),
    //  onPressed: () {
    //    //TODO Connect to partner.
    //  },
    //  child: Wrap(
    //    spacing: 90,
    //    alignment: WrapAlignment.spaceEvenly,
    //    children: [
    //      const Icon(Icons.directions_walk_outlined, size: 50,),
    //      // Spacer(),
    //      Text(UUID, style: GoogleFonts.openSans(
    //          fontSize: 8,
    //          fontWeight: FontWeight.w600,
    //          height: 1
    //      )),
    //    ],
    //  ),
    //);

      // Add button to List
      //partnersButtonList.add(newButton);
    //}

    // Add red X. // TODO make sure this works
    // partnerDialogWidgets.add(Container(
    //   width: double.infinity,
    //   height: 600,
    //   alignment: Alignment.bottomCenter,
    //   decoration: BoxDecoration(
    //       borderRadius: BorderRadius.circular(45),
    //       color: Colors.black),
    //   padding: EdgeInsets.fromLTRB(10, 0, 20, 70),
    // ));
    // partnerDialogWidgets.add(Positioned(
    //     width: 30,
    //     height: 30,
    //     top: 15,
    //     right: 15,
    //     child: FloatingActionButton(
    //         mini: true,
    //         backgroundColor: Colors.red,
    //         onPressed: () {
    //           // continueCallBack();
    //           bleScan.cancel();
    //         },
    //         child: Icon(Icons.clear)
    //     )
    // ));

    // Build dialog.
    // https://api.flutter.dev/flutter/material/showDialog.html

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [Padding(
            padding: const EdgeInsets.fromLTRB(0, 50, 0, 100),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  children: partnerButtonsList.map((e) {
                    return Container(
                      child: e,
                    );
                  }
                ).toList(),
              )]
            ),
          )]

        )
      )

    );
  }
}

