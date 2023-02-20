import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:hello_world/home_screen.dart';


class ConnectPartnersDialog {
  final HomeScreenState state;
  ConnectPartnersDialog(this.state);

  Future<void> showConnectPartnersDialog(BuildContext context) async {
    /// Call the function that triggers the native code.
    state.getBatteryLevel();



    // StreamSubscription<DiscoveredDevice> bleScan = state.scanBLE();


    return await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: EdgeInsets.fromLTRB(30, 30, 30, 450),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      height: 600,
                      alignment: Alignment.bottomCenter,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(45),
                        color: Colors.black),
                      padding: EdgeInsets.fromLTRB(10, 0, 20, 70),
                      child: //Column(
                          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //children: [
                          //  Text("Choose partners:", style: GoogleFonts.openSans(
                          //    color: Colors.white, fontSize: 20)
                          //  ),
                          //  Column(
                          //    children: state.partnerButtonsList.map((e) {
                          //      return Container(
                          //        child: e,
                          //      );
                          //    }
                          //    ).toList(),
                            //),
                            ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Color.fromRGBO(90, 90, 90, 0.5)),
                                    minimumSize: MaterialStateProperty.all<Size>(
                                        const Size(300, 60)),
                                    shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15.0),
                                        )
                                    )
                                ),
                                onPressed: () {
                                // TODO: Implement
                                },
                                child: Wrap(
                                  spacing: 100,
                                  alignment: WrapAlignment.spaceEvenly,
                                  children: [
                                // const Icon(Icons.directions_bike_outlined, size: 50,),
                                    Text(state.batteryLevel, style: GoogleFonts.openSans(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w600,
                                        height: 1.7
                                    )),
                                  ],
                                )
                            ),
                          //]
                      ),
                    //),
                    Positioned(
                      width: 30,
                      height: 30,
                      top: 15,
                      right: 15,
                      child: FloatingActionButton(
                        mini: true,
                        backgroundColor: Colors.red,
                        onPressed: () {
                          //bleScan.cancel();
                        },
                        child: Icon(Icons.clear)
                      )
                    ),
                  ],
                )
            );
          });
        });
  }

}
