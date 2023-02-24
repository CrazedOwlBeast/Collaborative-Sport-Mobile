import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hello_world/ble_sensor_device.dart';

import 'home_screen.dart';

class ActiveWorkout extends StatefulWidget {
  final FlutterReactiveBle flutterReactiveBle;
  final List<BleSensorDevice>? deviceList;
  const ActiveWorkout({super.key, required this.flutterReactiveBle, required this.deviceList});

  @override
  State<ActiveWorkout> createState() => _ActiveWorkoutState();
}

class _ActiveWorkoutState extends State<ActiveWorkout> {
    bool _changeDistance = false;
    //late final BleSensorDevice device;
    //late final List<BleSensorDevice> deviceList;
    Completer<GoogleMapController> controller1 = Completer();
    Duration duration = Duration();
    Timer? timer;
    double speed = 0.0;
    int? heartrate = 0;
    int? power = 0;
    int? targetHeartRate = 168;
    double distance = 1000;

    static LatLng? _initialPosition;
    static LatLng? _finalPosition;
    StreamSubscription<List<int>>? subscribeStreamHR;
    StreamSubscription<List<int>>? subscribeStreamPower;
    @override
    void initState(){
      super.initState();
      _getUserLocation();
      startTimer();

      if (widget.deviceList != null) {
        for (BleSensorDevice device in widget.deviceList!) {
          if (device.type == 'HR') {
            subscribeStreamHR = widget.flutterReactiveBle.subscribeToCharacteristic(
                QualifiedCharacteristic(
                    characteristicId: device.characteristicId,
                    serviceId: device.serviceId,
                    deviceId: device.deviceId
                )).listen((event) {
              setState(() {
                heartrate = event[1];
              });
            });
          }
          else if (device.type == 'POWER') {
            subscribeStreamPower = widget.flutterReactiveBle.subscribeToCharacteristic(
                QualifiedCharacteristic(
                    characteristicId: device.characteristicId,
                    serviceId: device.serviceId,
                    deviceId: device.deviceId
                )).listen((event) {
              setState(() {
                power = event[1];
              });
            });
          }
        }

      }

      Geolocator.getPositionStream(locationSettings: const LocationSettings(accuracy: LocationAccuracy.bestForNavigation)).listen((Position position) => setSpeed(position.speed));
    }

    void addTime() {
      setState(() {
        final seconds = duration.inSeconds + 1;
        duration = Duration(seconds: seconds);
      });
    }

    void startTimer() {
      timer = Timer.periodic(const Duration(seconds: 1), (_) => addTime());
    }

    void setSpeed(double speed) {
      this.speed = (this.speed + speed)/2;
    }

    void _getUserLocation() async {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
      });
    }

    void _currentLocation() async {
      final GoogleMapController controller = await controller1.future;
      Position position = await Geolocator.getCurrentPosition();
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15.0,
        ),
      ));
    }

    _onMapCreated(GoogleMapController controller) {
      setState(() {
        controller1.complete(controller);
      });
    }
    // TODO: Update distance and display it
    // void _getDistance() {
    //   distance = Geolocator.distanceBetween(
    //       _initialPosition!.latitude,
    //       _initialPosition!.longitude,
    //       _finalPosition!.latitude,
    //       _finalPosition!.longitude);
    // }

    @override
    Widget build(BuildContext context) {
      int heartRatePercent = ((heartrate! / targetHeartRate!) * 100).round();
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      String? hours,minutes,seconds;
      hours = twoDigits(duration.inHours.remainder(60));
      minutes = twoDigits(duration.inMinutes.remainder(60));
      seconds = twoDigits(duration.inSeconds.remainder(60));

      var screenWidth = MediaQuery.of(context).size.width;
      var screenHeight = MediaQuery.of(context).size.height;

      return Scaffold(
        body: Column(
          children: [
            SizedBox(
            height: MediaQuery.of(context).size.height * 0.60,
            width: MediaQuery.of(context).size.width,
            child: _initialPosition == null ? Center(child:Text('loading map..', style: TextStyle(fontFamily: 'Avenir-Medium', color: Colors.grey[400]),),) :
              Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(target: _initialPosition!, zoom: 15),
                    mapType: MapType.normal,
                    onMapCreated: _onMapCreated,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                  ),
                  Padding(
                      padding: EdgeInsets.fromLTRB(350, 50, 30, 0),
                      child: FloatingActionButton(
                        backgroundColor: Colors.white,
                        onPressed: _currentLocation,
                        child: Icon(Icons.location_on, color: Colors.black),
                      )
                  ),
                  Positioned(
                    top: 40,
                    left: 15,
                    // for testing purposes to be able to go back to home screen
                    child: GestureDetector(
                      onTap: () {
                        if (subscribeStreamHR != null) {
                          subscribeStreamHR?.cancel();
                        }
                        if (subscribeStreamPower != null) {
                          subscribeStreamPower?.cancel();
                        }
                        Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const HomeScreen()),
                                (route) => false);
                      },
                      child: const Icon(Icons.arrow_back, size: 50),
                    ),
                  ),
                ],
              ),
          ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
              child: SizedBox(
                height: screenHeight * 0.12,
                width: screenWidth * 0.98,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(75.0)),
                  child: Row(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            ElevatedButton(
                              onPressed: () {

                              },
                              style: ButtonStyle(
                                padding: MaterialStateProperty.all(const EdgeInsets.fromLTRB(40, 20, 0, 0)),
                                backgroundColor: MaterialStateProperty.all(Colors.black) ,
                                overlayColor: MaterialStateProperty.all(Colors.transparent),
                                shape: MaterialStateProperty.all(const CircleBorder()),
                              ),
                              child: SizedBox(
                                height: 100,
                                width: screenWidth/4,
                                child: RichText(
                                  text: TextSpan(
                                    text: '$minutes:$seconds',
                                    style: const TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.w600),
                                  children: const [
                                    TextSpan(
                                      text: '\n\t\tDuration',
                                      style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w400)
                                    )
                                  ],
                              ))
                            )),
                             ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _changeDistance = !_changeDistance;
                                  });
                                },
                                style: ButtonStyle(
                                  padding: MaterialStateProperty.all(EdgeInsets.fromLTRB(10, 20, 0, 10)),
                                  backgroundColor: MaterialStateProperty.all(Colors.black) ,
                                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                                  shape: MaterialStateProperty.all(CircleBorder()),
                                ),
                                 child: SizedBox(
                                   height: 100,
                                  width: screenWidth/4,
                                child: _changeDistance ?
                                RichText(
                                  text: TextSpan(
                                    text: ' ${(distance / 1609).toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.w600),
                                    children: const [
                                      TextSpan(
                                        text: '\nDistance\n\t\t\t(mi)',
                                        style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w400),
                                      )]))  :
                                RichText(
                                  text: TextSpan(
                                      text: ' ${(distance / 1000).toStringAsFixed(2)}',
                                      style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.w600),
                                      children: const [
                                        TextSpan(
                                          text: '\nDistance\n\t\t\t(km)',
                                          style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w400),
                                   )]))
                             )),
                            ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _changeDistance = !_changeDistance;
                                  });
                                },
                                style: ButtonStyle(
                                  padding: MaterialStateProperty.all(const EdgeInsets.fromLTRB(0, 20, 0, 0)),
                                  backgroundColor: MaterialStateProperty.all(Colors.black) ,
                                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                                  shape: MaterialStateProperty.all(const CircleBorder()),
                                ),
                                child: SizedBox(
                                    height: 100,
                                    width: screenWidth/4,
                                child: _changeDistance ?
                                RichText(
                                    text: TextSpan(
                                        text: '  ${(duration.inMinutes / (distance / 1609)).toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.w600),
                                        children: const [
                                          TextSpan(
                                            text: '\n\t\t\t\tPace\n\t\t(min/mi)',
                                            style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w400),
                                          )]))  :
                                RichText(
                                    text: TextSpan(
                                        text: '  ${(duration.inMinutes / (distance / 1000)).toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.w600),
                                        children: const [
                                          TextSpan(
                                            text: '\n\t\t\t\tPace\n\t\t(min/km)',
                                            style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w400),
                                          )]))
                             ))
                          ]
                      ),
                    ]
                  ),
              ),
            )
          ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  //padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                    radius: 60,
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    child:
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.monitor_heart, size: 30,),
                          Text(
                            "$heartrate",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "bpm",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w400),
                          )
                        ]
                    )
                ),
                CircleAvatar(
                  //padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                    radius: 60,
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    child:
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.power, size: 30,),
                          Text(
                            "$power",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "bpm",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w400),
                          )
                        ]
                    )
                ),
              ],
            ),
        ]
      )
    );
  }
}