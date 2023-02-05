import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hello_world/exercise_type.dart';
import 'package:hello_world/monitor_connect.dart';
import 'package:hello_world/partner_connect.dart';
import 'package:hello_world/popup_dialog.dart';
import 'active_workout.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Completer<GoogleMapController> controller1 = Completer();
  static LatLng? _initialPosition;

  @override
  void initState(){
    super.initState();
    _getUserLocation();
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

  _onMapCreated(GoogleMapController controller) {
    setState(() {
      controller1.complete(controller);
    });
  }
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
          children: [
            Container(
              color: Colors.green,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.70, // map takes 70% of screen
              child: Container(
                height: MediaQuery.of(context).size.height,
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
                    Padding(
                        padding: EdgeInsets.fromLTRB(screenWidth * 0.08, 580, 30, 0),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(const CircleBorder()),
                            padding: MaterialStateProperty.all(const EdgeInsets.all(10)),
                            backgroundColor: MaterialStateProperty.all(Colors.orange), // <-- Button color
                          ),
                          onPressed: () {
                              _showDialog(context, "exerciseType");
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
                            _showDialog(context, "connectMonitors");

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
                        onPressed: () {
                          _showDialog(context, "connectPartners");
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
      bottomNavigationBar: SizedBox(
        height: MediaQuery.of(context).size.height * 0.12, // navigation bar takes 12% of screen
        child: BottomNavigationBar(
        // TODO: implement indexes and _onTap to follow through to other screens
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
              label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.white),
            label: 'Home',
          ),
        ],
        iconSize: 45,
        elevation: 3
      )
    ),
    );
  }

}


_showDialog(BuildContext context, String buttonType)
{
  continueCallBack() => {
    Navigator.of(context).pop()
  };
  PopupDialog  alert = PopupDialog(continueCallBack, buttonType);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
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