import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hello_world/exercise_type.dart';
import 'package:hello_world/partner_connect.dart';
import 'package:hello_world/settings_model.dart';
import 'package:hello_world/workout_database.dart';
import 'package:permission_handler/permission_handler.dart';
import 'active_workout.dart';
import 'ble_manager.dart';
import 'bluetooth_manager.dart';
import 'monitor_connect.dart';
import 'settings.dart';
import 'past_workouts.dart';
import 'app_logger.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Force phone into portrait mode.
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  FlutterConfig.loadEnvVariables();
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

  // Initialize clasee to hold settings values.
  SettingsStorage settings = SettingsStorage();

  // Get responsive dialog sizes.
  late double dialogWidth = MediaQuery.of(context).size.width * 0.9;
  late double dialogHeight = MediaQuery.of(context).size.height * .60;

  // Transparent overlays for dialogs.
  final LayerLink layerLink = LayerLink();
  late OverlayEntry overlayEntry;
  late Offset dialogOffset;

  late PartnerConnect partnerConnectAdvertiser;

  // Keeps track of connection status.
  bool noSensors = false;
  bool noPartners = false;

  // Object for map UI.
  GoogleMapController? _controller;

  // Create logger for entire app.
  static LoggerDevice device = LoggerDevice();
  static AppLogger logger = AppLogger();

  // Dialog to choose exercise type.
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
              exerciseType: exerciseType,
            ),
          )
        ]);
      },
    );
    Overlay.of(context).insert(overlayEntry);
  }

  // Dialog to connect to sensors.
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
    Overlay.of(context).insert(overlayEntry);
  }

  // Dialog to connect to partners.
  void showConnectPartnersDialog() {
    dialogOffset = Offset(dialogWidth * .06, dialogHeight * .12);
    overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
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
    Overlay.of(context).insert(overlayEntry);
  }

  // Close overlay.
  void dismissMenu() {
    overlayEntry.remove();
  }

  // Default exercise type.
  String exerciseType = "Walking";

  // Future map controller
  Completer<GoogleMapController> controller1 = Completer();
  static LatLng? _initialPosition;

  // Used to listen for position updates.
  late StreamSubscription<Position> _positionStreamSubscription;

  // Initialize home screen state.
  @override
  void initState() {
    super.initState();

    _getPermissions().then((_) {
        _getUserLocation();
        // Subscribe to position stream.
        _positionStreamSubscription = Geolocator.getPositionStream(
            locationSettings: LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 15))
            .listen(_onPositionUpdate);
    });
    // _getUserLocation();

    // Used to get device id to send to partner.
    _getDeviceInfo();
    logger.userDevice = device;

    // Dialog shows at launch if name hasn't been set in Settings page.
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _showSetupDialog();
    });

  }

  // Restore saved settings from local database
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
        if (previous.ftp != null) {
          settings.ftp = previous.ftp.toString();
        }
      }
    });
    return result;
  }

  // Dialog shows at launch if name hasn't been set in Settings page.
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


  // Clean up when app is closed.
  @override
  void dispose() {
    LoggerEvent loggedEvent = LoggerEvent(eventType: "1");
    loggedEvent.currentPage = "home_page";
    logger.loggerEvents.events.add(loggedEvent);
    _positionStreamSubscription.cancel();
  }

  // Get device id, to be sent to partner and logged.
  void _getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      device.deviceId = androidInfo.androidId;
      // device.serialNumber = androidInfo.;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      device.deviceId =
          iosInfo.identifierForVendor;
    }
  }

  Future<void> _requestBluetoothPermissions() async {
    // Request permission to scan for Bluetooth devices
    var scanStatus = await Permission.bluetoothScan.request();
    if (scanStatus.isGranted) {
      print("Bluetooth scan permission granted.");
    } else {
      print("Bluetooth scan permission denied.");
    }

    // Request permission to connect to Bluetooth devices
    var connectStatus = await Permission.bluetoothConnect.request();
    if (connectStatus.isGranted) {
      print("Bluetooth connect permission granted.");
    } else {
      print("Bluetooth connect permission denied.");
    }

    var advertiseStatus = await Permission.bluetoothAdvertise.request();
    if (advertiseStatus.isGranted) {
      print("Bluetooth advertise permission granted.");
    } else {
      print("Bluetooth advertise permission denied.");
    }
  }

  // Function to get permissions.
  Future<void> _requestLocationPermission() async {
    var status = await Permission.locationWhenInUse.request();

    if (status.isGranted) {
      print("Foreground location permission granted.");

      var backgroundStatus = await Permission.locationAlways.request();
      if (backgroundStatus.isGranted) {
        print("Background location permission granted.");
      } else {
        print("Background location permission denied.");
      }

    } else if (status.isDenied) {
      print("Foreground location permission denied.");
    }

    if (status.isPermanentlyDenied) {
      openAppSettings();  // Suggest user to open app settings to change permission manually
    }
  }

  Future<void> _requestSensorsPermission() async {
    var status = await Permission.sensors.request();

    if (status.isGranted) {
      print("Sensors permission granted.");

    } else if (status.isDenied) {
      print("Sensors permission denied.");
    }
    if (status.isPermanentlyDenied) {
      openAppSettings();  // Suggest user to open app settings to change permission manually
    }
  }

  Future<void> _requestNearbyWifiDevicesPermission() async {
    var status = await Permission.nearbyWifiDevices.request();

    if (status.isGranted) {
      print("NearbyWifiDevices permission granted.");

    } else if (status.isDenied) {
      print("NearbyWifiDevices permission denied.");
    }
    if (status.isPermanentlyDenied) {
      openAppSettings();  // Suggest user to open app settings to change permission manually
    }
  }

  // TODO: Request permissions in app.
  Future<void> _getPermissions() async {
    await _requestLocationPermission();
    await _requestBluetoothPermissions();
    await _requestNearbyWifiDevicesPermission();
    await _requestSensorsPermission();
  }

  void _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
    });
  }

  // Moves camera to current location
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

  // Called when position changes.
  void _onPositionUpdate(Position position) {
    setState(() {
      if (_controller != null) {
        _controller!.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15,
          ),
        ));
      }
    });
  }

  // Shows popup dialog when buttons are pressed.
  _onMapCreated(GoogleMapController controller) async {
    if (!controller1.isCompleted) {
      setState(() {
        controller1.complete(controller);
      });
    }
    setState(() {
      _controller = controller;
    });
  }

  void setExerciseType(String type) {
    setState(() {
      this.exerciseType = type;
    });
  }

  // Displays if user tries to start workout without selecting exercise type.
  // Never reached because default exercise type is set.
  // Analytics server rejects uploads without exercise type set.
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

  // Displays if user tries to start workout without a sensor connected.
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
                    LoggerEvent loggedEvent = LoggerEvent(eventType: "5");
                    loggedEvent.workoutType = exerciseType;
                    loggedEvent.processEvent();
                    logger.loggerEvents.events.add(loggedEvent);
                    Navigator.of(context).push(_createRoute(
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

  // Displays if user tries to start workout without a partner connected
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
                  LoggerEvent loggedEvent = LoggerEvent(eventType: "5");
                  loggedEvent.workoutType = exerciseType;
                  loggedEvent.processEvent();
                  logger.loggerEvents.events.add(loggedEvent);
                  Navigator.of(context).push(_createRoute(
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

  // UI for dialog buttons that appear on map.
  _showDialogButtons(double screenHeight, double screenWidth) {
    return Stack(
      children: [
        // Choose exercise type button
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
              },
              child: Icon(_getIcon(), size: 30)),
        ),
        // Connect to sensors button
        Padding(
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
              },
              child: const Icon(Icons.bluetooth_connected,
                  size: 30)),
        ),
        // Connect to partners button
        Padding(
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
              },
              child: const Icon(Icons.people_alt_sharp)),
        )
      ]);
  }

  // Change icon for exercise type button depending on type that is chosen.
  IconData _getIcon() {
    if (exerciseType == 'Running') {
      return Icons.directions_run;
    }
    else if (exerciseType == 'Cycling') {
      return Icons.directions_bike;
    }
    else {
      return Icons.directions_walk;
    }
  }

  // Build home screen.
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    // Log user's name.
    device.name = settings.name;
    logger.userDevice = device;

    // Check for unsent logs.
    if (logger.workoutsToSend && !logger.sending) {
      logger.getLogsFromDb();
    }

    // Build UI for map.
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
                  ? Stack(
                  children: [
                    Center(
                      child: Text(
                        'loading map..',
                        style: TextStyle(
                            fontFamily: 'Avenir-Medium',
                            color: Colors.grey[400]),
                      ),
                    ),
                    _showDialogButtons(screenHeight, screenWidth),
                  ])
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
                            )
                        ),
                        _showDialogButtons(screenHeight, screenWidth),
                      ],
                    ),
            ),
          ),
          // Go button.
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
                      // Show necessary dialogs before running exercise.
                      if (exerciseType.isEmpty) {
                        _showExerciseTypeAlert();
                      }
                      else if (BleManager.instance.connectedSensors.isEmpty) {
                        _showMonitorAlert();
                      }
                      else if (BluetoothManager.instance.connectedDevices.isEmpty) {
                        _showPartnerAlert();
                      }
                      else {
                        // Log workout start
                        LoggerEvent loggedEvent = LoggerEvent(eventType: "5");
                        loggedEvent.workoutType = exerciseType;
                        loggedEvent.processEvent();
                        logger.loggerEvents.events.add(loggedEvent);

                        // Navigate to active_workout page.
                        Navigator.of(context).push(_createRoute(
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
              LoggerEvent loggedEvent = LoggerEvent(eventType: "2");
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
              LoggerEvent loggedEvent = LoggerEvent(eventType: "2");
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
                  LoggerEvent loggedEvent = LoggerEvent(eventType: "5");
                  loggedEvent.workoutType = exerciseType;
                  loggedEvent.processEvent();
                  logger.loggerEvents.events.add(loggedEvent);

                  loggedEvent = LoggerEvent(eventType: "3");
                  loggedEvent.prevPage = "home_page";
                  loggedEvent.nextPage = "active_workout_page";
                  loggedEvent.processEvent();
                  logger.loggerEvents.events.add(loggedEvent);

                  Navigator.of(context).push(_createRoute(exerciseType, settings));
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
      // Navigation bar
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
    String type,
    SettingsStorage settingsStorage) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ActiveWorkout(
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
