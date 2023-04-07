import 'dart:async';
import 'dart:math';

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hello_world/longpress_button.dart';
import 'package:hello_world/app_logger.dart';
import 'package:hello_world/ble_sensor_device.dart';
import 'package:hello_world/bluetooth_manager.dart';
import 'package:hello_world/completed_workout.dart';
import 'package:hello_world/exercise_type.dart';
import 'package:hello_world/past_workouts.dart';
import 'package:hello_world/settings.dart';

import 'home_screen.dart';

class ActiveWorkout extends StatefulWidget {
  final FlutterReactiveBle flutterReactiveBle;
  final List<BleSensorDevice>? deviceList;
  final AppLogger logger;
  final String exerciseType;
  final SettingsStorage settings;
  const ActiveWorkout({super.key,
    required this.flutterReactiveBle,
    required this.deviceList,
    required this.logger,
    required this.exerciseType,
    required this.settings
  });

  @override
  State<ActiveWorkout> createState() => _ActiveWorkoutState();
}

class _ActiveWorkoutState extends State<ActiveWorkout> {
    bool _showProgressIndicator = false;
    bool _changeDistance = false;
    int lastLoggedDistance = 0;
    var rng = Random();
    GoogleMapController? controller;
    Duration duration = Duration();
    Timer? timer;
    double speed = 0.0;
    int? heartrate = 0;
    int? peerHeartRate = 0;
    int? power = 0;
    int? peerPower = 0;
    int? targetHeartRate = 168;
    double distance = 0.0;
    bool pauseWorkout = true;
    bool stopWorkout = false;
    late StreamSubscription peerSubscription;
    StreamSubscription? stateSubsciption;

    int numBroadcasts = 0;
    String peerName = "";
    String peerDeviceId = "";

    String? userDevice = "";
    String userName = "";
    String peerInfo = "";

    Position? _initialPosition;
    Position? _currentPosition;
    List<LatLng> _points = [];
    Set<Polyline> _polyLines = {};
    late StreamSubscription<Position> _positionStreamSubscription;

    StreamSubscription<List<int>>? subscribeStreamHR;
    StreamSubscription<List<int>>? subscribeStreamPower;

    @override
    void initState(){
      super.initState();

      widget.logger.workout.workoutType = widget.exerciseType;

      // _getUserLocation();
      _getCurrentLocation();
      _positionStreamSubscription = Geolocator.getPositionStream(
          locationSettings: LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 15))
          .listen(_onPositionUpdate);
      startTimer();
      debugPrint('Exercise Type = ${widget.exerciseType}');
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
                // Update UI.
                heartrate = event[1];
                // Broadcast heartrate to partner.
                BluetoothManager.instance.broadcastString('0: $heartrate');
                // Log heartrate.
                widget.logger.workout.logHeartRate(event[1]);
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
                //Power can take two bytes, get upper byte
                int temp = event[3];
                //convert from little endian
                temp = event[3] << 8;
                //add to lower byte
                power = event[2] + temp;
                BluetoothManager.instance.broadcastString('1: $power');
              });
            });
          }
        }
      }
      peerSubscription = BluetoothManager.instance.deviceDataStream.listen((event) {
        setState(() {
          int type = int.parse(event.substring(0, 1));
          switch (type) {
            case 0:
              int value = int.parse(event.substring(3));
              peerHeartRate = value;
              break;
            case 1:
              int value = int.parse(event.substring(3));
              peerPower = value;
              break;
            case 2:
              peerName = event.substring(3, event.length);
              widget.logger.workout.partnerName = peerName;
              break;
            case 3:
              peerDeviceId = event.substring(3, event.length);
              widget.logger.workout.partnerDeviceId = peerDeviceId;
              break;
            default:
          }
        });
      });

      stateSubsciption = BluetoothManager.instance.reconnectStateSubscription();

      Geolocator.getPositionStream(locationSettings: const LocationSettings(accuracy: LocationAccuracy.bestForNavigation)).listen((Position position) => setSpeed(position.speed));
      initPlatformState();
    }

  Future<void> initPlatformState() async {
    BackgroundFetch.configure(BackgroundFetchConfig(
      minimumFetchInterval: 15, // minimum time interval between background fetches
      stopOnTerminate: false, // whether to stop background fetches when app is terminated
      enableHeadless: true, // whether to execute the fetch callback function in the background
      startOnBoot: true, // whether to start background fetches when the device boots up
    ), (String taskId) async {
      // your fetch callback function here
      // this function will be executed when a background fetch is triggered
      // use the taskId parameter to identify the fetch task
      // perform your background work here
      // call the BackgroundFetch.finish(taskId) method when your work is complete
      BackgroundFetch.finish(taskId);
    }).then((int status) {
      // handle success
    }).catchError((e) {
      // handle error
    });
  }

    @override
  void dispose() {
      peerSubscription = BluetoothManager.instance.deviceDataStream.listen((event) {});
      if (subscribeStreamHR != null) {
        subscribeStreamHR?.cancel();
      }
      if (subscribeStreamPower != null) {
        subscribeStreamPower?.cancel();
      }
    super.dispose();
      if(_positionStreamSubscription != null) {
        _positionStreamSubscription.cancel();
        BackgroundFetch.stop();
      }
  }

    void addTime() {
      setState(() {
        final seconds = duration.inSeconds + 1;
        duration = Duration(seconds: seconds);

        //Testing purposes for peers
        //BluetoothManager.instance.broadcastString('0: ${rng.nextInt(200)}');
        //BluetoothManager.instance.broadcastString('1: ${rng.nextInt(200)}');
      });
    }

    void startTimer() {
      timer = Timer.periodic(const Duration(seconds: 1), (_) => addTime());
    }

    void setSpeed(double speed) {
      this.speed = (this.speed + speed)/2;
    }


    void _currentLocation() async {
      final GoogleMapController? cntrl = controller;
      Position position = await Geolocator.getCurrentPosition();
      cntrl!.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 15.0,
        ),
      ));
    }

    void _getCurrentLocation() async {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _initialPosition = position;
        _currentPosition = position;
        _points.add(LatLng(position.latitude, position.longitude));

        if (controller != null) {
          controller!.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 15,
            ),
          ));

          _polyLines.add(Polyline(
            polylineId: const PolylineId('userRoute'),
            visible: true,
            points: [
              LatLng(_initialPosition!.latitude, _initialPosition!.longitude)
            ],
            color: Colors.blue,
            width: 5,));
        }
      });
      _listenToLocationChanges();
    }

    void _listenToLocationChanges() {
      Geolocator.getPositionStream().listen((position) {
        if (mounted) {
          setState(() {
            _currentPosition = position;
            _points.add(LatLng(position.latitude, position.longitude));
            _polyLines.add(Polyline(
              polylineId: PolylineId("workout_route"),
              color: Colors.blue,
              width: 5,
              points: _points,
            ));
            distance = Geolocator.distanceBetween(
              _initialPosition!.latitude,
              _initialPosition!.longitude,
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            );
          });
        }
      });
    }

    void _onPositionUpdate(Position newPosition) {
      setState(() {
        _currentPosition = newPosition;
        if(_initialPosition != null) {
          final distanceInMeters = Geolocator.distanceBetween(
              _initialPosition!.latitude,
              _initialPosition!.longitude,
              _currentPosition!.latitude,
              _currentPosition!.longitude);
          distance += distanceInMeters;
          _points.add(LatLng(newPosition.latitude, newPosition.longitude));

          // Log the distance every meter.
          // TODO: Determine logging interval for distance.
          if (distance.floor() > lastLoggedDistance + 1) {
            widget.logger.workout.logDistance(distance.floor());
            lastLoggedDistance = distance.floor();
          }
        }
      });
    }

    _onMapCreated(GoogleMapController controller) {
      controller = controller;
    }

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

      // Broadcast user info to partner.
      if (numBroadcasts < 5) {
        setState(() {
          userName = widget.settings.name;
          BluetoothManager.instance.broadcastString('2: $userName');

          userDevice = widget.logger.userDevice?.deviceId;
          BluetoothManager.instance.broadcastString('3: $userDevice');

          numBroadcasts++;
        });
      }
      var statsRow = Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(75.0)),
          color: Colors.black,
          child:
              SizedBox(
                width: screenWidth * .45,
                child: Column(
                  children: [
                    SizedBox(
                      height: 45,
                      child:
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: screenWidth * .1,
                            child: const Icon(Icons.heart_broken, size: 30, color: Colors.white60,),
                          ),
                          SizedBox(
                            width: screenWidth * .15,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                            child: Text(
                              "$heartrate",
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.w600),
                            ),)
                          ),
                          SizedBox(
                              width: screenWidth * .1,
                              child: const FittedBox(
                                fit: BoxFit.scaleDown,
                              child: Text(
                                "bpm",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 15, color: Colors.white60, fontWeight: FontWeight.w500),
                              ))
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 35,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: screenWidth * .1,
                            child: const Icon(Icons.electric_bolt_sharp, size: 30, color: Colors.white60,),
                          ),
                          SizedBox(
                            width: screenWidth * .15,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                            child: Text(
                              "$power",
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.w600),
                            ),)
                          ),
                          SizedBox(
                              width: screenWidth * .1,
                              child: const FittedBox(
                                fit: BoxFit.scaleDown,
                              child: Text(
                                "W",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 15, color: Colors.white60, fontWeight: FontWeight.w500),
                              ))
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              )

          )
        ],
      );

      if (BluetoothManager.instance.connectedDevices.isNotEmpty) {
        statsRow.children.add(Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(75.0)),
            color: Colors.black,
            child:
            SizedBox(
              width: screenWidth * .45,
              child: Column(
                children: [
                  SizedBox(
                    height: 45,
                    child:
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: screenWidth * .1,
                          child: const Icon(Icons.heart_broken, size: 30, color: Colors.red,),
                        ),
                        SizedBox(
                          width: screenWidth * .15,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                            "$peerHeartRate",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 25, color: Colors.red.shade200, fontWeight: FontWeight.w600),
                          ),)
                        ),
                        SizedBox(
                            width: screenWidth * .1,
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                              "bpm",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 15, color: Colors.red, fontWeight: FontWeight.w500),
                            ))
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 35,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: screenWidth * .1,
                          child: const Icon(Icons.electric_bolt_sharp, size: 30, color: Colors.red,),
                        ),
                        SizedBox(
                          width: screenWidth * .15,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                            "$peerPower",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 25, color: Colors.red.shade200, fontWeight: FontWeight.w600),
                          ),)
                        ),
                        SizedBox(
                            width: screenWidth * .1,
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                              "W",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 15, color: Colors.red, fontWeight: FontWeight.w500),
                            ))
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            )

        ));
      }

      return Scaffold(
        body: Column(
          children: [
            SizedBox(
            height: screenHeight * 0.52,
            width: screenWidth,
            child:
            _initialPosition == null ? Center(child:Text('loading map..', style: TextStyle(fontFamily: 'Avenir-Medium', color: Colors.grey[400]),),) :
              Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(target: LatLng(_initialPosition!.latitude, _initialPosition!.longitude), zoom: 15),
                    mapType: MapType.normal,
                    onMapCreated: _onMapCreated,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    gestureRecognizers: Set()
                      ..add(Factory<PanGestureRecognizer>(() => PanGestureRecognizer())),
                    polylines: _polyLines
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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Row(
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
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      text: '${(distance > 15 ? (distance / 1609).toStringAsFixed(2) : "-")}',
                                      style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.w600),
                                      children: const [
                                        TextSpan(
                                          text: '\nDistance\n(mi)',
                                          style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w400),
                                        )
                                      ]
                                    )
                                  )  :
                                  RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                        text: '${(distance > 15 ? (distance / 1000).toStringAsFixed(2) : "-")}',
                                        style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.w600),
                                        children: const [
                                          TextSpan(
                                            text: '\nDistance\n(km)',
                                            style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w400),
                                          )
                                        ]
                                    )
                                  )
                            )
                        ),
                        ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _changeDistance = !_changeDistance;
                              });
                            },
                            style: ButtonStyle(
                              padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
                              backgroundColor: MaterialStateProperty.all(Colors.black) ,
                              overlayColor: MaterialStateProperty.all(Colors.transparent),
                              shape: MaterialStateProperty.all(const CircleBorder()),
                            ),
                            child: SizedBox(
                                height: 100,
                                width: screenWidth/4,
                            child: _changeDistance ?
                              RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                      text: '${(distance > 15 ? (((duration.inSeconds / distance) * 1609) / 60).toStringAsFixed(2) : "-")}',
                                      style: const TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.w600),
                                      children: const [
                                        TextSpan(
                                          text: '\nPace\n(min/mi)',
                                          style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w400),
                                        )
                                      ]
                                  )
                              )  :
                              RichText(
                                textAlign: TextAlign.center,
                                  text: TextSpan(
                                      text: '${(distance > 15 ? (((duration.inSeconds / distance) * 1000) / 60).toStringAsFixed(2) : "-")}',
                                      style: const TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.w600),
                                      children: const [
                                        TextSpan(
                                          text: '\nPace\n(min/km)',
                                          style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w400),
                                        )
                                      ]
                                  )
                              )
                            )
                        )
                          ]
                      ),
                    ]
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            statsRow,
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    style: ButtonStyle(
                        overlayColor: MaterialStateProperty.all(Colors.transparent),
                        padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
                        elevation: MaterialStateProperty.all(0.0),
                        backgroundColor: MaterialStateProperty.all(Colors.transparent.withOpacity(0.0))
                    ),
                    onPressed: () {
                      setState(() {
                        if(pauseWorkout)
                        {
                          widget.logger.loggerEvents.events.add(LoggerEvent(eventType: 7));
                          LoggerEvent loggedEvent = LoggerEvent(eventType: 2);
                          loggedEvent.buttonName = "pause_workout";
                          loggedEvent.processEvent();
                          widget.logger.loggerEvents.events.add(loggedEvent);

                          timer?.cancel();
                          pauseWorkout = !pauseWorkout;
                          stopWorkout = !stopWorkout;
                        }
                        else
                        {
                          widget.logger.loggerEvents.events.add(LoggerEvent(eventType: 8));
                          LoggerEvent loggedEvent = LoggerEvent(eventType: 2);
                          loggedEvent.buttonName = "resume_workout";
                          loggedEvent.processEvent();
                          widget.logger.loggerEvents.events.add(loggedEvent);

                          startTimer();
                          pauseWorkout = !pauseWorkout;
                          stopWorkout = !stopWorkout;
                        }
                      });
                    },
                    child:
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.orange,
                      child: pauseWorkout ?
                      Icon(Icons.pause, size: 80,color: Colors.white) :
                      Icon(Icons.play_arrow, size: 80, color: Colors.white),
                    )
                ),
                Visibility(
                    visible: stopWorkout,
                    child: LongPressButton(logger: widget.logger, exerciseType: widget.exerciseType)
                )
              ],
            )
          ]
        )
      );
    }
}
