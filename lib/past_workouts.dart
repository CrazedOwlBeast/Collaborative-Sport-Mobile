import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


import 'home_screen.dart';

class PastWorkouts extends StatefulWidget {
  const PastWorkouts({super.key});

  @override
  State<PastWorkouts> createState() => _PastWorkoutsState();
}

class _PastWorkoutsState extends State<PastWorkouts> {
    

    @override
    void initState(){
      super.initState();
    }

    @override
    Widget build(BuildContext context) {

      var screenWidth = MediaQuery.of(context).size.width;
      var screenHeight = MediaQuery.of(context).size.height;

      return Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(0, 75, 0, 0),
              alignment: Alignment.bottomCenter,
              color: Colors.black,
              child: Column(
                children: [
                  Text(
                    "Your Workouts",
                    style: TextStyle(
                    color: Colors.white,
                    fontSize: 45
                )
              ),
              getPreviousWorkouts()]
              )
              ),

        ]
      )
    );
  }
}

Container getPreviousWorkouts()
{
  //TODO: create data structure to grab previous workouts from.
  return Container(padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
      child: Text(
        "No workouts recorded", style: TextStyle(
          color: Colors.white)));
}