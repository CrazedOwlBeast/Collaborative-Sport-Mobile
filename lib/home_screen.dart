import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:background_fetch/background_fetch.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hello_world/ble_sensor_device.dart';
import 'package:hello_world/exercise_type.dart';
import 'package:hello_world/partner_connect.dart';
import 'package:hello_world/settings_model.dart';
import 'package:hello_world/workout_database.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:hello_world/popup_dialog.dart';
import 'active_workout.dart';
import 'bluetooth_manager.dart';
import 'monitor_connect.dart';
import 'settings.dart';
import 'past_workouts.dart';
import 'app_logger.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // TODO: Restore settings from file if it exists.
  SettingsStorage settings = SettingsStorage();

  late double dialogWidth = MediaQuery.of(context).size.width * 0.9;
  late double dialogHeight = MediaQuery.of(context).size.height * .60;
  final LayerLink layerLink = LayerLink();
  late OverlayEntry overlayEntry;
  late Offset dialogOffset;
  late PartnerConnect partnerConnectAdvertiser;
  bool noSensors = false;
  bool noPartners = false;

  // Create logger for entire app.
  static LoggerDevice device = LoggerDevice();
  static AppLogger logger = AppLogger();

  void showExerciseTypeDialog() {
    dialogOffset = Offset(dialogWidth * .06, dialogHeight * .12);
    overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return Stack(children: <Widget>[
          Positioned.fill(
              child: GestureDetector(
            onTap: dismissMenu,
            child: Container(
              color: Colors.transparent,
            ),
          )),
          Positioned(
            width: dialogWidth,
            height: dialogHeight,
            top: 0.0,
            left: 0.0,
            child: ExerciseType(
              offset: dialogOffset,
              link: layerLink,
              dialogWidth: dialogWidth,
              dialogHeight: dialogHeight,
              overlayEntry: overlayEntry,
              logger: logger,
              callBack: setExerciseType,
            ),
          )
        ]);
      },
    );
    Overlay.of(context)?.insert(overlayEntry);
  }

  void showConnectMonitorsDialog() {
    dialogOffset = Offset(dialogWidth * .06, dialogHeight * .12);
    overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return Stack(children: <Widget>[
          Positioned.fill(
              child: GestureDetector(
            onTap: dismissMenu,
            child: Container(
              color: Colors.transparent,
            ),
          )),
          Positioned(
            width: dialogWidth,
            height: dialogHeight,
            top: 0.0,
            left: 0.0,
            child: MonitorConnect(
                flutterReactiveBle: flutterReactiveBle,
                callback: (deviceList) => setState(() {
                      connectedDevices = deviceList;
                    }),
                connectedDevices: connectedDevices,
                offset: dialogOffset,
                link: layerLink,
                dialogWidth: dialogWidth,
                dialogHeight: dialogHeight,
                overlayEntry: overlayEntry,
                logger: logger),
          )
        ]);
      },
    );
    Overlay.of(context)?.insert(overlayEntry);
  }

  void showConnectPartnersDialog() {
    dialogOffset = Offset(dialogWidth * .06, dialogHeight * .12);
    overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        //partnerConnectAdvertiser = PartnerConnect(deviceType: DeviceType.advertiser, link: layerLink, offset: dialogOffset, dialogWidth: dialogWidth, dialogHeight: dialogHeight, overlayEntry: overlayEntry);
        return Stack(
          children: <Widget>[
            Positioned.fill(
                child: GestureDetector(
              onTap: dismissMenu,
              child: Container(
                color: Colors.transparent,
              ),
            )),
            Positioned(
              width: dialogWidth,
              height: dialogHeight,
              top: 0.0,
              left: 0.0,
              child: PartnerConnect(
                  // flutterReactiveBle: flutterReactiveBle,
                  // callback: (deviceList)=> setState(() {
                  //   connectedDevices = deviceList;
                  // }),
                  // connectedDevices: connectedDevices,
                  deviceType: DeviceType.advertiser,
                  offset: dialogOffset,
                  link: layerLink,
                  dialogWidth: dialogWidth,
                  dialogHeight: dialogHeight,
                  overlayEntry: overlayEntry,
                  logger: logger,
                  myFullName: settings.name),
            )
          ],
        );
      },
    );
    Overlay.of(context)?.insert(overlayEntry);
  }

  void dismissMenu() {
    overlayEntry.remove();
  }

  // BleSensorDevice? device;
  List<BleSensorDevice> connectedDevices = <BleSensorDevice>[];
  String exerciseType = "";

  Completer<GoogleMapController> controller1 = Completer();
  static LatLng? _initialPosition;

  // Obtain FlutterReactiveBle instance for entire app.
  final flutterReactiveBle = FlutterReactiveBle();

  @override
  void initState() {
    super.initState();
    _getPermissions(); // TODO: Wait for permissions before getting location. (affects first run)
    _getUserLocation();
    _getDeviceInfo();
    logger.userDevice = device;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _showSetupDialog();
    });
  }

  Future<bool> _getProfileSettings() async {
    ProfileSettings? previous = await WorkoutDatabase.instance.readSettings();
    bool result = false;
    setState(() {
      if (previous != null) {
        result = true;
        settings.name = previous.name;
        if (previous.age != null) {
          settings.age = previous.age.toString();
        }
        if (previous.maxHR != null) {
          settings.maxHR = previous.maxHR.toString();
        }
      }
    });
    return result;
  }

  void _showSetupDialog() async {
    bool result = await _getProfileSettings();
    if (!result) {
      showDialog(
          context: this.context,
          builder: (BuildContext context) {
            return AlertDialog(
                backgroundColor: Colors.white,
                title: const Text("Welcome to Collaborative Sport Mobile!"),
                content: const Text("Go to the Settings Page to set up your profile."),
                actionsAlignment: MainAxisAlignment.spaceEvenly,
                actionsOverflowAlignment: OverflowBarAlignment.center,
                actionsOverflowDirection: VerticalDirection.up,
                actions: <Widget>[
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel')
                  ),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          Navigator.of(context).pop();
                          _currentIndex = 2;
                        });
                      },
                      child: const Text('Confirm')
                  ),
                ]
            );
          }
      );
    }
  }


  @override
  void dispose() {
    LoggerEvent loggedEvent = LoggerEvent(eventType: 1);
    loggedEvent.currentPage = "home_page";
    logger.loggerEvents.events.add(loggedEvent);
    super.dispose();
  }

  void _getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      device.deviceId = androidInfo.androidId;
      // device.serialNumber = androidInfo.;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      device.deviceId =
          iosInfo.utsname.machine; // TODO: Not sure how to get UUID for iOS
    }
  }

  // Function to get permissions.
  void _getPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.location,
      Permission.locationAlways,
      Permission.nearbyWifiDevices,
      Permission.sensors,
      Permission.locationWhenInUse,
      //Permission.ignoreBatteryOptimizations,
    ].request();
  }

  void _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition();
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

  // Shows popup dialog when buttons are pressed.
  _onMapCreated(GoogleMapController controller) async {
    if (!controller1.isCompleted) {
      setState(() {
        controller1.complete(controller);
      });
    }
  }

  void setConnectedDevice(List<BleSensorDevice> deviceList) {
    this.connectedDevices = deviceList;
  }

  void setExerciseType(String type) {
    this.exerciseType = type;
  }

  // Function to show dialog when action buttons are pressed.
  // TODO: Make stateful?
  _showDialog(
      BuildContext context, String buttonType, FlutterReactiveBle bluetooth) {
    continueCallBack() => {Navigator.of(context).pop()};
    PopupDialog alert = PopupDialog(continueCallBack, buttonType, bluetooth,
        setConnectedDevice, connectedDevices);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _showExerciseTypeAlert() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Please select a workout type.'),
            actionsAlignment: MainAxisAlignment.center,
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    showExerciseTypeDialog();
                  },
                  child: const Text('Confirm'),
              )
            ],
          );
        }
    );
  }

  _showMonitorAlert() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Not connected to a heart rate sensor.'),
            content: const Text('This app works best when connected to a sensor, do you want to connect to a sensor?'),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actionsOverflowAlignment: OverflowBarAlignment.center,
            actionsOverflowDirection: VerticalDirection.up,
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (BluetoothManager.instance.connectedDevices.isEmpty) {
                    _showPartnerAlert();
                  }
                  else {
                    LoggerEvent loggedEvent = LoggerEvent(eventType: 5);
                    logger.loggerEvents.events.add(loggedEvent);
                    Navigator.of(context).push(_createRoute(
                        flutterReactiveBle,
                        connectedDevices,
                        exerciseType,
                        settings));
                  }
                },
                child: const Text(
                    'Continue without sensor',
                  textAlign: TextAlign.end,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  showConnectMonitorsDialog();
                },
                child: const Text('Connect to sensor'),
              ),
            ],
          );
        }
    );
  }

  _showPartnerAlert() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Not connected to a partner.'),
            content: const Text('This app works best when connected to a partner, do you want to connect to a partner?'),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actionsOverflowAlignment: OverflowBarAlignment.center,
            actionsOverflowDirection: VerticalDirection.up,
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  LoggerEvent loggedEvent = LoggerEvent(eventType: 5);
                  logger.loggerEvents.events.add(loggedEvent);
                  Navigator.of(context).push(_createRoute(
                      flutterReactiveBle,
                      connectedDevices,
                      exerciseType,
                      settings));
                },
                child: const Text('Continue without partner'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  showConnectPartnersDialog();
                },
                child: const Text(
                    'Connect to partner',
                    textAlign: TextAlign.end
                ),
              ),
            ],
          );
        }
    );
  }

  _isDialogShowing(BuildContext context) =>
      ModalRoute.of(context)?.isCurrent != true;

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    device.name = settings.name;
    logger.userDevice = device;

    final List<Widget> _children = [
      CompositedTransformTarget(
        link: layerLink,
        child: Column(children: [
          Container(
            color: Colors.green,
            width: screenWidth,
            height: screenHeight * 0.70, // map takes 70% of screen
            child: Container(
              height: screenHeight,
              width: screenWidth,
              child: _initialPosition == null
                  ? Center(
                      child: Text(
                        'loading map..',
                        style: TextStyle(
                            fontFamily: 'Avenir-Medium',
                            color: Colors.grey[400]),
                      ),
                    )
                  : Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: CameraPosition(
                              target: _initialPosition!, zoom: 15),
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
                              child:
                                  Icon(Icons.location_on, color: Colors.black),
                            )),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              screenWidth * 0.08, screenHeight * 0.63, 30, 0),
                          child: ElevatedButton(
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    const CircleBorder()),
                                padding: MaterialStateProperty.all(
                                    const EdgeInsets.all(10)),
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.orange), // <-- Button color
                              ),
                              onPressed: () {
                                showExerciseTypeDialog();
                                //_showDialog(context, "exerciseType", flutterReactiveBle);
                                // Navigator.of(context).push(
                                //     MaterialPageRoute(builder: (context) => const ExerciseType()));
                              },
                              child: const Icon(Icons.pedal_bike, size: 30)),
                        ),
                        Padding(
                          /// Connect monitors
                          padding: EdgeInsets.fromLTRB((screenWidth - 65) / 2,
                              screenHeight * 0.63, 30, 0),
                          child: ElevatedButton(
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    const CircleBorder()),
                                padding: MaterialStateProperty.all(
                                    const EdgeInsets.all(10)),
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.orange), // <-- Button color
                              ),
                              onPressed: () async {
                                showConnectMonitorsDialog();
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(builder: (context) => const MonitorConnect()),
                                // );
                              },
                              child: const Icon(Icons.bluetooth_connected,
                                  size: 30)),
                        ),
                        Padding(
                          /// Connect partners
                          padding: EdgeInsets.fromLTRB(
                              screenWidth * 0.78, screenHeight * 0.63, 30, 0),
                          child: ElevatedButton(
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    const CircleBorder()),
                                padding: MaterialStateProperty.all(
                                    const EdgeInsets.all(10)),
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.orange), // <-- Button color
                              ),
                              onPressed: () async {
                                showConnectPartnersDialog();
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(builder: (context) => const PartnerConnect()),
                                // );
                              },
                              child: const Icon(Icons.people_alt_sharp)),
                        ),
                      ],
                    ),
            ),
          ),
          Container(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              color: Colors.black,
              alignment: Alignment.topCenter,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height *
                  0.17, // go button takes 18% of screen
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (exerciseType.isEmpty) {
                        _showExerciseTypeAlert();
                      }
                      else if (connectedDevices.isEmpty) {
                        _showMonitorAlert();
                      }
                      else if (BluetoothManager.instance.connectedDevices.isEmpty) {
                        _showPartnerAlert();
                      }
                      else {
                        LoggerEvent loggedEvent = LoggerEvent(eventType: 5);
                        logger.loggerEvents.events.add(loggedEvent);
                        Navigator.of(context).push(_createRoute(
                            flutterReactiveBle,
                            connectedDevices,
                            exerciseType,
                            settings));
                      }
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.green),
                        minimumSize:
                            MaterialStateProperty.all<Size>(Size(350, 100)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(45.0),
                        ))),
                    child: Wrap(
                      alignment: WrapAlignment.spaceAround,
                      children: const [
                        Text(
                          'GO!',
                          style: TextStyle(
                              fontSize: 75.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Icon(
                          Icons.play_arrow_rounded,
                          size: 90,
                        ),
                      ],
                    ),
                  )
                ], // Children
              ))
        ]),
      ),
      PastWorkouts(),
      Settings(
        settings: settings,
      ),
      Padding(
        /// Connect monitors
        padding: EdgeInsets.fromLTRB(
            (screenWidth - 65) / 2, screenHeight * 0.63, 30, 0),
        child: ElevatedButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(const CircleBorder()),
              padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
              backgroundColor:
                  MaterialStateProperty.all(Colors.orange), // <-- Button color
            ),
            onPressed: () async {
              LoggerEvent loggedEvent = LoggerEvent(eventType: 2);
              loggedEvent.buttonName = "connect_monitors_button";
              loggedEvent.processEvent();
              logger.loggerEvents.events.add(loggedEvent);
              showConnectMonitorsDialog();
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => const MonitorConnect()),
              // );
            },
            child: const Icon(Icons.bluetooth_connected, size: 30)),
      ),
      Padding(
        /// Connect partners
        padding:
            EdgeInsets.fromLTRB(screenWidth * 0.78, screenHeight * 0.63, 30, 0),
        child: ElevatedButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(const CircleBorder()),
              padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
              backgroundColor:
                  MaterialStateProperty.all(Colors.orange), // <-- Button color
            ),
            onPressed: () async {
              LoggerEvent loggedEvent = LoggerEvent(eventType: 2);
              loggedEvent.buttonName = "connect_partners_button";
              loggedEvent.processEvent();
              logger.loggerEvents.events.add(loggedEvent);

              showConnectPartnersDialog();
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => const PartnerConnect()),
              // );
            },
            child: const Icon(Icons.people_alt_sharp)),
      ),
      Container(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          color: Colors.black,
          alignment: Alignment.topCenter,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height *
              0.17, // go button takes 18% of screen
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  LoggerEvent loggedEvent = LoggerEvent(eventType: 5);
                  loggedEvent.workoutType = exerciseType;
                  loggedEvent.processEvent();
                  logger.loggerEvents.events.add(loggedEvent);

                  loggedEvent = LoggerEvent(eventType: 3);
                  loggedEvent.prevPage = "home_page";
                  loggedEvent.nextPage = "active_workout_page";
                  loggedEvent.processEvent();
                  logger.loggerEvents.events.add(loggedEvent);

                  Navigator.of(context).push(_createRoute(flutterReactiveBle,
                      connectedDevices, exerciseType, settings));
                },
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green),
                    minimumSize:
                        MaterialStateProperty.all<Size>(Size(350, 100)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(45.0),
                    ))),
                child: Wrap(
                  alignment: WrapAlignment.spaceAround,
                  children: const [
                    Text(
                      'GO!',
                      style: TextStyle(
                          fontSize: 75.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Icon(
                      Icons.play_arrow_rounded,
                      size: 90,
                    ),
                  ],
                ),
              )
            ], // Children
          )),
      PastWorkouts(),
      Settings(
        settings: settings,
      )
    ];

    return Scaffold(
      body: IndexedStack(children: _children, index: _currentIndex),
      bottomNavigationBar: SizedBox(
          height: MediaQuery.of(context).size.height *
              0.13, // navigation bar takes 12% of screen
          child: BottomNavigationBar(
              onTap: onTabTapped,
              currentIndex: _currentIndex,
              type: BottomNavigationBarType.fixed,
              landscapeLayout: BottomNavigationBarLandscapeLayout.spread,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              backgroundColor: Colors.black87,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home, color: Colors.white),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.bar_chart_rounded,
                    color: Colors.white,
                  ),
                  label: 'Workouts',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person, color: Colors.white),
                  label: 'Settings',
                ),
              ],
              iconSize: 45,
              elevation: 3)),
    );
  }

  void onTabTapped(int currentIndex) async {
    setState(() {
      _currentIndex = currentIndex;
    });
  }
}

Route _createRoute(
    FlutterReactiveBle ble,
    List<BleSensorDevice>? connectedDevices,
    String type,
    SettingsStorage settingsStorage) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ActiveWorkout(
        flutterReactiveBle: ble,
        deviceList: connectedDevices,
        logger: _HomeScreenState.logger,
        exerciseType: type,
        settings: settingsStorage),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
