import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:hello_world/ble_sensor_device.dart';
import 'monitor_connect.dart';

class PopupDialog extends StatefulWidget {
  final Function(List<BleSensorDevice>) callBack;
  VoidCallback continueCallBack;
  String buttonType;
  final FlutterReactiveBle bluetooth;
  List<BleSensorDevice> connectedDevices;

  PopupDialog(this.continueCallBack, this.buttonType, this.bluetooth, this.callBack, this.connectedDevices, {super.key});

  @override
  State<PopupDialog> createState() => _PopupDialogState();
}

class _PopupDialogState extends State<PopupDialog> {
  //BleSensorDevice? connectedDevice;
  //List<BleSensorDevice>? connectedDevices;
  @override
  Widget build(BuildContext context) {
  bool _hasBeenPressed = false;

    if(widget.buttonType == "exerciseType")
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
                        widget.continueCallBack();
                      },
                      child: Icon(Icons.clear)
                  ))
            ],
          )
      );
    }

    if(widget.buttonType == "connectMonitors")
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
                        onPressed: () async {
                          await Navigator.push<void>(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      MonitorConnect(
                                        flutterReactiveBle: widget.bluetooth,
                                        callback: (deviceList)=> setState(() {
                                          widget.connectedDevices = deviceList;
                                        }),
                                        connectedDevices: widget.connectedDevices,
                                      )));
                        },
                        child: Wrap(
                          spacing: 90,
                          alignment: WrapAlignment.spaceEvenly,
                          children: [
                            const Icon(Icons.monitor_heart_outlined, size: 50,),
                            // Spacer(),
                            Text('Scan for devices', style: GoogleFonts.openSans(
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
                        widget.callBack(widget.connectedDevices);
                        widget.continueCallBack();
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
    if(widget.buttonType == "connectPartners")
    {
      // Start scanning
      // MAC is used to connect but is random, need to scan for UUID
      List<String> foundPartnersUUIDs = [];
      StreamSubscription<DiscoveredDevice> bleScan = widget.bluetooth.scanForDevices(withServices: [],
          scanMode: ScanMode.lowLatency).listen((device) {
            // Ignore if already seen during this scan.
            bool newUUID = true;
            for (String UUID in foundPartnersUUIDs) {
              if (UUID == device.serviceUuids.toString()) {
                newUUID = false;
              }
            }
            if (newUUID == true) {
              if (device.serviceUuids.toString() == "[48454c4c-4f57-4f52-4c44-2d4852313034]") {
                print("Partner found!");
              }
              foundPartnersUUIDs.add(device.serviceUuids.toString());
            }
            // Device info string printed to terminal for testing.
            if (device.serviceUuids.toString() == "[48454c4c-4f57-4f52-4c44-2d4852313034]") {
              print("Partner found!");
            }
            print("Name: " + device.name + "\n" +
                "ID: " + device.id + "\n" +
                "Manufacturer Data: " + device.manufacturerData.toString() +
                "\n" +
                "RSSI: " + device.rssi.toString() + "\n" +
                "Service Data: " + device.serviceData.toString() + "\n" +
                "Service UUIDs: " + device.serviceUuids.toString() + "\n\n");

          });  // End of BLE listener.


    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.fromLTRB(30, 30, 30, 450),
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          ListView.builder(
            itemCount: foundPartnersUUIDs.length,
            prototypeItem: const ListTile(
                title: Text("[48454c4c-4f57-4f52-4c44-2d4852313034]")
            ),
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(foundPartnersUUIDs[index]),
              );
            },
          ),
          Container(
            width: double.infinity,
            height: 600,
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(45),
            color: Colors.black),
            padding: EdgeInsets.fromLTRB(10, 0, 20, 70),
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
                    widget.continueCallBack();
                    bleScan.cancel();
                  },
                  child: Icon(Icons.clear)
              )
          ),
        ],
      )
    );
  }

    throw Exception("bloop");
  }
}