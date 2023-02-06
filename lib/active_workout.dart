import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'home_screen.dart';

class ActiveWorkout extends StatefulWidget {
  const ActiveWorkout({super.key});

  @override
  State<ActiveWorkout> createState() => _ActiveWorkoutState();
}

class _ActiveWorkoutState extends State<ActiveWorkout> {
    Completer<GoogleMapController> controller1 = Completer();
    Duration duration = Duration();
    Timer? timer;
    double speed = 0.0;
    int? heartrate;

    static LatLng? _initialPosition;

    @override
    void initState(){
      super.initState();
      _getUserLocation();
      startTimer();
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

    @override
    Widget build(BuildContext context) {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      String? hours,minutes,seconds;
      hours = twoDigits(duration.inHours.remainder(60));
      minutes = twoDigits(duration.inMinutes.remainder(60));
      seconds = twoDigits(duration.inSeconds.remainder(60));

      return Scaffold(
        body: Container(
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
                Positioned(
                  top: 30,
                  left: 15,
                  // for testing purposes to be able to go back to home screen
                  child: GestureDetector(
                    onTap: (){
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                              (route) => false);
                    },
                    child: const Icon(Icons.arrow_back),
                  ),
                ),
                //Duration field
                Positioned(
                    bottom: 25,
                    left: 25,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      child: Text(
                          '$hours:$minutes:$seconds',
                          textAlign: TextAlign.center,
                      ),
                    )
                ),
                //Speed field
                Positioned(
                    bottom: 25,
                    left: 140,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      child: Text(
                        '${speed.toStringAsFixed(2)}\nm/s',
                        textAlign: TextAlign.center,
                      ),
                    )
                ),
                //Heart rate field
                Positioned(
                    bottom: 25,
                    right: 60,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      child: Text(((){
                        return '${heartrate==null ? "--" : '$heartrate'} \nbpm';
                      })(),
                      textAlign: TextAlign.center,
                      ),
                    )
                )
              ],
            ),
        ),
      );
    }
}