import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hello_world/workout_database.dart';
import 'package:hello_world/workout_model.dart';
import 'package:hello_world/workout_summary.dart';
import 'package:intl/intl.dart';


import 'home_screen.dart';

class PastWorkouts extends StatefulWidget {
  const PastWorkouts({super.key});

  @override
  State<PastWorkouts> createState() => _PastWorkoutsState();
}

class _PastWorkoutsState extends State<PastWorkouts> {
  List<Workout> workouts = <Workout>[];
  bool isLoading = false;

    @override
    void initState(){
      super.initState();
      refreshWorkouts();
    }

    Future refreshWorkouts() async {
      setState(() {
        isLoading = true;
      });

      workouts = await WorkoutDatabase.instance.readAllWorkouts();

      setState(() {
        isLoading = false;
      });
    }

    String _getStartTime(int index) {
      Map<String, dynamic> log = jsonDecode(workouts[index].jsonString);
      Map<String, dynamic> workout = log['workout'];
      //DateTime? date = DateTime.tryParse(workout['start_timestamp']);
      int? seconds = int.tryParse(workout['start_timestamp']);
      if (seconds != null) {
        DateTime date = DateTime.fromMillisecondsSinceEpoch((seconds*1000));
        String time = DateFormat.jm().format(date);
        return "$time ${date.month}/${date.day}/${date.year}";
      }
      else {
        return "Date not found";
      }
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
              child: SizedBox(
                width: screenWidth,
              height: screenHeight*.75,
              child: Column(
                children: [
                  Text(
                    "Your Workouts",
                    style: TextStyle(
                    color: Colors.white,
                    fontSize: 45
                  )
                ),
                  //SizedBox(height: screenHeight * .12,),
                  Flexible(
                  child: ListView.separated(
                      itemCount: workouts.length,
                        //padding: const EdgeInsets.all(8.0),
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            margin: const EdgeInsets.all(5.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => WorkoutSummary(workout: workouts[index],)));
                              },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                              workouts[index].name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 25
                                ),
                              ),
                              Text(
                                _getStartTime(index),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 25
                                ),
                              ),
                            ]
                            ))
                          );
                        }, separatorBuilder: (BuildContext context, int index) => const Divider(color: Colors.grey,),
                    ),
                  )
                ]
              ))
            ),
        ]
      )
    );
  }
}
