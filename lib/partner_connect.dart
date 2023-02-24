import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:google_fonts/google_fonts.dart';

enum DeviceType { advertiser, browser }

class PartnerConnect extends StatefulWidget {
  final DeviceType deviceType;
  final LayerLink link;
  final Offset offset;
  final double dialogWidth;
  final double dialogHeight;
  final OverlayEntry overlayEntry;

  const PartnerConnect({super.key, required this.deviceType, required this.link,
            required this.offset, required this.dialogWidth, required this.dialogHeight, required this.overlayEntry});

  @override
  State<PartnerConnect> createState() => _PartnerConnectState();
}

class _PartnerConnectState extends State<PartnerConnect> {
  List<Device> devices = [];
  List<Device> connectedDevices = [];
  late NearbyService nearbyService;
  late StreamSubscription subscription;
  late StreamSubscription receivedDataSubscription;

  bool isInit = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    subscription.cancel();
    receivedDataSubscription.cancel();
    nearbyService.stopBrowsingForPeers();
    nearbyService.stopAdvertisingPeer();
    super.dispose();
  }

  String getStateName(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
        return "disconnected";
      case SessionState.connecting:
        return "waiting";
      default:
        return "connected";
    }
  }

  String getButtonStateName(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
      case SessionState.connecting:
        return "Connect";
      default:
        return "Disconnect";
    }
  }

  Color getStateColor(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
        return Colors.white;
      case SessionState.connecting:
        return Colors.yellow;
      default:
        return Colors.green;
    }
  }

  Color getButtonColor(SessionState state) {
    switch (state) {
      case SessionState.notConnected:
      case SessionState.connecting:
        return Colors.green;
      default:
        return Colors.red;
    }
  }

  _onTabItemListener(Device device) {
    if (device.state == SessionState.connected) {
      nearbyService.sendMessage(device.deviceId, "Hello world");
      // showDialog(
      //     context: context,
      //     builder: (BuildContext context) {
      //       final myController = TextEditingController();
      //       return AlertDialog(
      //         title: Text("Send message"),
      //         content: TextField(controller: myController),
      //         actions: [
      //           TextButton(
      //             child: Text("Cancel"),
      //             onPressed: () {
      //               Navigator.of(context).pop();
      //             },
      //           ),
      //           TextButton(
      //             child: Text("Send"),
      //             onPressed: () {
      //               nearbyService.sendMessage(
      //                   device.deviceId, myController.text);
      //               myController.text = '';
      //             },
      //           )
      //         ],
      //       );
      //     });
    }
  }

  int getItemCount() {
    // if (widget.deviceType == DeviceType.advertiser)
    //   return connectedDevices.length;

      String debugString = devices.length.toString();
      debugPrint("devices.length: $debugString");
      return devices.length;

  }

  _onButtonClicked(Device device) {
    switch (device.state) {
      case SessionState.notConnected:
        nearbyService.invitePeer(
          deviceID: device.deviceId,
          deviceName: device.deviceName,
        );
        break;
      case SessionState.connected:
        nearbyService.disconnectPeer(deviceID: device.deviceId);
        break;
      case SessionState.connecting:
        break;
    }
  }

  void init() async {
    nearbyService = NearbyService();
    String devInfo = '';
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      devInfo = androidInfo.model;
    }
    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      devInfo = iosInfo.localizedModel;
    }
    await nearbyService.init(
        serviceType: 'mp-connection',
        deviceName: devInfo,
        strategy: Strategy.P2P_CLUSTER,
        callback: (isRunning) async {
          if (isRunning) {
              await nearbyService.stopAdvertisingPeer();
              await nearbyService.stopBrowsingForPeers();
              await Future.delayed(Duration(microseconds: 200));
              await nearbyService.startAdvertisingPeer();
              await nearbyService.startBrowsingForPeers();
          }
        });
    subscription =
        nearbyService.stateChangedSubscription(callback: (devicesList) {
          devicesList.forEach((element) {
            print(
                " deviceId: ${element.deviceId} | deviceName: ${element.deviceName} | state: ${element.state}");

            if (Platform.isAndroid) {
              if (element.state == SessionState.connected) {
                nearbyService.stopBrowsingForPeers();
              } else {
                nearbyService.startBrowsingForPeers();
              }
            }
          });

          setState(() {
            devices.clear();
            devices.addAll(devicesList);
            connectedDevices.clear();
            connectedDevices.addAll(devicesList
                .where((d) => d.state == SessionState.connected)
                .toList());
          });
        });

    receivedDataSubscription =
        nearbyService.dataReceivedSubscription(callback: (data) {
          print("dataReceivedSubscription: ${jsonEncode(data)}");
          showToast(jsonEncode(data),
              context: context,
              axis: Axis.horizontal,
              alignment: Alignment.center,
              position: StyledToastPosition.bottom);
        });
  }


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
                          child: ListView.builder(
                              itemCount: getItemCount(),
                              itemBuilder: (context, index) {
                                final device = widget.deviceType == DeviceType.advertiser
                                    ? devices[index]
                                    : devices[index];
                                return Container(
                                  margin: EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                              child: GestureDetector(
                                                onTap: () => _onTabItemListener(device),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                        device.deviceName,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                    ),
                                                    Text(
                                                      getStateName(device.state),
                                                      style: TextStyle(
                                                          color: getStateColor(device.state)),
                                                    ),
                                                  ],
                                                ),
                                              )),
                                          // Request connect
                                          GestureDetector(
                                            onTap: () => _onButtonClicked(device),
                                            child: Container(
                                              margin: EdgeInsets.symmetric(horizontal: 8.0),
                                              padding: EdgeInsets.all(8.0),
                                              height: 35,
                                              width: 100,
                                              color: getButtonColor(device.state),
                                              child: Center(
                                                child: Text(
                                                  getButtonStateName(device.state),
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 8.0,
                                      ),
                                      const Divider(
                                        height: 1,
                                        color: Colors.grey,
                                      )
                                    ],
                                  ),
                                );
                              }),
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
                          child: Text('Discovered Partners:',
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

}


