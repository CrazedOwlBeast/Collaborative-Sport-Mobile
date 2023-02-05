import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:beacon_broadcast/beacon_broadcast.dart';

class PopupDialog extends StatelessWidget {

  VoidCallback continueCallBack;
  String buttonType;
  final FlutterReactiveBle bluetooth;

  PopupDialog(this.continueCallBack, this.buttonType, this.bluetooth, {super.key});

  @override
  Widget build(BuildContext context) {
  bool _hasBeenPressed = false;

    if(buttonType == "exerciseType")
    {
      return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.fromLTRB(30, 30, 30, 450),
          child: Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              Container(
                width: double.infinity,
                height: 600,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(45),
                  color: Colors.black,
                ),
                padding: EdgeInsets.fromLTRB(10, 0, 20, 70),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(height: 20),
                    Text("Select exercise type:", style: GoogleFonts.openSans(color: Colors.white, fontSize: 20)),
                    ElevatedButton(
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
                          //TODO Set exercise type to walking
                        },
                        child: Wrap(
                          spacing: 90,
                          alignment: WrapAlignment.spaceEvenly,
                          children: [
                            const Icon(Icons.directions_walk_outlined, size: 50,),
                            // Spacer(),
                            Text('Walking', style: GoogleFonts.openSans(
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                              height: 1.7
                            )),
                          ],
                        )
                    ),
                    ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Color.fromRGBO(90, 90, 90, 0.5)) ,
                            minimumSize: MaterialStateProperty.all<Size>(const Size(300, 60)),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                )
                            )
                        ),
                        onPressed: () {
                          //TODO Set exercise type to running
                        },
                        child: Wrap(
                          spacing: 90,
                          alignment: WrapAlignment.spaceEvenly,
                          children: [
                            const Icon(Icons.directions_run_outlined, size: 50,),
                            Text('Running', style: GoogleFonts.openSans(
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                                height: 1.7
                            )),
                          ],
                        )
                    ),
                    ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Color.fromRGBO(90, 90, 90, 0.5)) ,
                            minimumSize: MaterialStateProperty.all<Size>(const Size(300, 60)),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                )
                            )
                        ),
                        onPressed: () {

                          //TODO Set exercise type to cycling
                        },
                        child: Wrap(
                          spacing: 100,
                          alignment: WrapAlignment.spaceEvenly,
                          children: [
                            const Icon(Icons.directions_bike_outlined, size: 50,),
                            Text('Cycling', style: GoogleFonts.openSans(
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                                height: 1.7
                            )),
                          ],
                        )
                    ),
                  ],
                ),
              ),
              Positioned(
                width: 30,
                  height: 30,
                  top: 15,
                  right: 15,
                  child: FloatingActionButton(
                      mini: true,
                      backgroundColor: Colors.red,
                      onPressed: () {
                        continueCallBack();
                      },
                      child: Icon(Icons.clear)
                  ))
            ],
          )
      );
    }

    if(buttonType == "connectMonitors")
    {
      // TODO: add buttons dynamically for every device found, no need to have all this code, but just here now for temp reasons
      return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.fromLTRB(30, 30, 30, 450),
          child: Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              Container(
                width: double.infinity,
                height: 600,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(45),
                  color: Colors.black,
                ),
                padding: EdgeInsets.fromLTRB(10, 0, 20, 70),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(height: 20),
                    Text("Select Monitors:", style: GoogleFonts.openSans(color: Colors.white, fontSize: 20)),
                    ElevatedButton(
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
                          //TODO Set exercise type to walking
                        },
                        child: Wrap(
                          spacing: 90,
                          alignment: WrapAlignment.spaceEvenly,
                          children: [
                            const Icon(Icons.monitor_heart_outlined, size: 50,),
                            // Spacer(),
                            Text('Garmin Dual 3', style: GoogleFonts.openSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                height: 1.7
                            )),
                          ],
                        )
                    ),
                  ],
                ),
              ),
              Positioned(
                  width: 30,
                  height: 30,
                  top: 15,
                  right: 15,
                  child: FloatingActionButton(
                      mini: true,
                      backgroundColor: Colors.red,
                      onPressed: () {
                        continueCallBack();
                      },
                      child: Icon(Icons.clear)
                  ))
            ],
          )
      );
    }

    // TODO: Display partners found in BLE scan and let user connect to them
    // TODO: Add buttons dynamically for every partner found in scan
    // TODO: Stop scanning if dialog is cancelled (not using red x)
    // TODO: Check if Bluetooth is on
    if(buttonType == "connectPartners")
    {
      // Start advertising
      BeaconBroadcast beaconBroadcast = BeaconBroadcast();
      beaconBroadcast
          .setUUID('48454C4C4F574F524C442D4852313034')  // 32 base-16 characters
          .setMajorId(1)
          .setMinorId(100)
          .setTransmissionPower(-59) //optional
          .setAdvertiseMode(AdvertiseMode.balanced) //Android-only, optional
          .setIdentifier('com.example.myDeviceRegion') //iOS-only, optional
          .setLayout(BeaconBroadcast.ALTBEACON_LAYOUT) //Android-only, optional
          .setManufacturerId(0xCF23) //Android-only, optional
          .start();

      // Start scanning
      StreamSubscription<DiscoveredDevice> bleScan = bluetooth.scanForDevices(withServices: [],
          scanMode: ScanMode.lowLatency).listen((device) {

        // Device info string printed to terminal for testing.
        print("Name: " + device.name + "\n" +
              "ID: " + device.id + "\n" +
              "Manufacturer Data: " + device.manufacturerData.toString() + "\n" +
              "RSSI: " + device.rssi.toString() + "\n" +
              "Service Data: " + device.serviceData.toString() + "\n" +
              "Service UUIDs: " + device.serviceUuids.toString() + "\n\n");
      });

      return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.fromLTRB(30, 30, 30, 450),
          child: Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              Container(
                width: double.infinity,
                height: 600,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(45),
                  color: Colors.black,
                ),
                padding: EdgeInsets.fromLTRB(10, 0, 20, 70),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(height: 20),
                    Text("Select Partners:", style: GoogleFonts.openSans(color: Colors.white, fontSize: 20)),
                    ElevatedButton(
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
                          //TODO Connect to partner
                        },
                        child: Wrap(
                          spacing: 90,
                          alignment: WrapAlignment.spaceEvenly,
                          children: [
                            const Icon(Icons.directions_walk_outlined, size: 50,),
                            // Spacer(),
                            Text('Walking', style: GoogleFonts.openSans(
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                                height: 1.7
                            )),
                          ],
                        )
                    ),
                  ],
                ),
              ),
              Positioned(
                  width: 30,
                  height: 30,
                  top: 15,
                  right: 15,
                  child: FloatingActionButton(
                      mini: true,
                      backgroundColor: Colors.red,
                      onPressed: () {
                        bleScan.cancel();  // Stop scanning.
                        beaconBroadcast.stop();  // Stop advertising.
                        continueCallBack();
                      },
                      child: Icon(Icons.clear)
                  ))
            ],
          )
      );
    }

    throw Exception("bloop");
  }
}