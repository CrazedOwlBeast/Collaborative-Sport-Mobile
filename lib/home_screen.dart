import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:hello_world/popup_dialog.dart';
import 'active_workout.dart';
import 'settings.dart';
import 'past_workouts.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';

void main() {
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

  

  
  Completer<GoogleMapController> controller1 = Completer();
  static LatLng? _initialPosition;

  // Obtain FlutterReactiveBle instance for entire app.
  final flutterReactiveBle = FlutterReactiveBle();

  // Config for flutter_ble_peripheral
  final FlutterBlePeripheral blePeripheral = FlutterBlePeripheral();
  bool _isSupported = false;
  // Data to be advertised.
  final AdvertiseData advertiseData = AdvertiseData(
    serviceUuid: '48454C4C-4F57-4F52-4C44-2D4852313034',
    manufacturerId: 1234,
    manufacturerData: Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8, 8, 8]),
  );
  // Settings for advertisement.
  final AdvertiseSettings advertiseSettings = AdvertiseSettings(
    advertiseMode: AdvertiseMode.advertiseModeLowLatency,
    txPowerLevel: AdvertiseTxPower.advertiseTxPowerMedium,
    timeout: 3000,
  );
  // More advertisement parameters
  final AdvertiseSetParameters advertiseSetParameters = AdvertiseSetParameters(
    connectable: true,
    txPowerLevel: txPowerHigh,
    interval: intervalMin,
    legacyMode: false,
    primaryPhy: 1,
    // scannable: true,
    // secondaryPhy: 13,
    duration: 9999,
    // maxExtendedAdvertisingEvents: 444,
  );



  @override
  void initState(){
    super.initState();
    _getPermissions();  // TODO: Wait for permissions before getting location. (affects first run)
    _getUserLocation();
    initPlatformState();  // Config for flutter_ble_peripheral
    // Start BLE advertisement.
    // TODO: Not sure if we should broadcast all time?  Seems to stop broadcasting after awhile...
    //_toggleAdvertiseSet();

  }

  // Config for flutter_ble_peripheral
  Future<void> initPlatformState() async {
    final isSupported = await blePeripheral.isSupported;
    setState(() {
      _isSupported = isSupported;
    });
  }
  // Function to start advertisement.  Not used.
  Future<void> _toggleAdvertise() async {
    if (await blePeripheral.isAdvertising) {
      await blePeripheral.stop();
    } else {

      await blePeripheral.start(advertiseData: advertiseData,
                                advertiseSettings: advertiseSettings);
    }
  }
  // Function to start advertisement with extra parameters.  Disabled the toggle for now.
  Future<void> _toggleAdvertiseSet() async {
    // if (await blePeripheral.isAdvertising) {
    //   await blePeripheral.stop();
    // } else {
      await blePeripheral.start(
        advertiseData: advertiseData,
        advertiseSetParameters: advertiseSetParameters,
      );
    // }
  }

  // Function to get permissions.
  void _getPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.location,
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
    if (!controller1.isCompleted)
    {
    setState(() {
      controller1.complete(controller);
    });
    }
  }

  // Function to show dialog when action buttons are pressed.
  // TODO: Make stateful?
  _showDialog(BuildContext context, String buttonType, FlutterReactiveBle bluetooth) {
    continueCallBack() => {
      Navigator.of(context).pop()
    };
    PopupDialog alert = PopupDialog(continueCallBack, buttonType, bluetooth);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    final List<Widget> _children = [
      Column(
          children: [
            Container(
              color: Colors.green,
              width: screenWidth,
              height: screenHeight * 0.70, // map takes 70% of screen
              child: Container(
                height: screenHeight,
                width: screenWidth,
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
                    Padding(
                        padding: EdgeInsets.fromLTRB(screenWidth * 0.08, 580, 30, 0),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(const CircleBorder()),
                            padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
                            backgroundColor: MaterialStateProperty.all(Colors.orange), // <-- Button color
                          ),
                          onPressed: () {
                              _showDialog(context, "exerciseType", flutterReactiveBle);
                            // Navigator.of(context).push(
                            //     MaterialPageRoute(builder: (context) => const ExerciseType()));
                          },
                          child: const Icon(Icons.pedal_bike, size: 30)
                        ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB((screenWidth - 65 )/ 2, 580, 30, 0),
                      child: ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(const CircleBorder()),
                            padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
                            backgroundColor: MaterialStateProperty.all(Colors.orange), // <-- Button color
                          ),
                          onPressed: () {
                            _showDialog(context, "connectMonitors", flutterReactiveBle);

                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(builder: (context) => const MonitorConnect()),
                            // );
                          },
                          child: const Icon(Icons.bluetooth_connected, size: 30)
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(screenWidth * 0.78, 580, 30, 0),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(const CircleBorder()),
                          padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
                          backgroundColor: MaterialStateProperty.all(Colors.orange), // <-- Button color
                        ),
                        onPressed: () async {
                          _showDialog(context, "connectPartners", flutterReactiveBle);
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(builder: (context) => const PartnerConnect()),
                          // );
                        },
                        child: const Icon(Icons.people_alt_sharp)
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
                padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                color: Colors.black,
                alignment: Alignment.topCenter,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.18, // go button takes 18% of screen
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(_createRoute());
                      },
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.green) ,
                          minimumSize: MaterialStateProperty.all<Size>(Size(350, 100)),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(45.0),
                              )
                          )
                      ),
                      child: Wrap(
                        alignment: WrapAlignment.spaceAround,
                        children: const [
                          Text(
                            'GO!',
                            style: TextStyle(
                                fontSize: 75.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white
                            ),
                          ),
                          Icon(Icons.play_arrow_rounded, size: 90,),
                        ],
                      ),
                    )
                  ], // Children
                )
            )
 
          ]),
          PastWorkouts(),
          Settings()
  ];

    return Scaffold(
      body: Center(child: _children[_currentIndex]),
      bottomNavigationBar: SizedBox(
        height: MediaQuery.of(context).size.height * 0.12, // navigation bar takes 12% of screen
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
              icon: Icon(Icons.bar_chart_rounded, color: Colors.white,),
              label: 'Workouts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.white),
            label: 'Settings',
          ),
        ],
        iconSize: 45,
        elevation: 3
      )
    ),
    );
  }

  void onTabTapped(int currentIndex) async
  {
    setState(() {
        _currentIndex = currentIndex;
      });
  }
}


Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => const ActiveWorkout(),
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


