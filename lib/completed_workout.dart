import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hello_world/workout_info.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'workout_database.dart';


import 'home_screen.dart';

class CompletedWorkout extends StatefulWidget {
  final String jsonString;
  const CompletedWorkout({super.key, required this.jsonString});

  @override
  State<CompletedWorkout> createState() => _CompletedWorkoutState();
}

class _CompletedWorkoutState extends State<CompletedWorkout> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String name = '';
  //late var database;


  @override
  void initState() {
    // database = openDatabase(
    //   join(await getDatabasesPath(), 'collaborative_sport.db'),
    //   onCreate: (db, version) {
    //       return db.execute(
    //         'CREATE TABLE workout(name TEXT, workout_info TEXT)',
    //       );
    //   },
    // );
    debugPrint(widget.jsonString);
    super.initState();
  }

  void _showDialog() {
    showDialog(
        context: this.context,
        builder: (BuildContext context) {
          return SimpleDialog(
              backgroundColor: Colors.white,
              children:[ Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text('Workout Name:'),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Enter workout name',
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                        onChanged: (value) => setState(() {
                          name = value;
                        }),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                //push to database
                                final workout = Workout(name: name, jsonString: widget.jsonString);
                                WorkoutDatabase.instance.create(workout);

                                setState(() {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) => const HomeScreen()));
                                });
                              }
                            },
                            child: const Text('Confirm'),
                          )
                        ],
                      )
                    ],
                  )
              )
          ]
          );
        }
    );
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
                            "Workout Complete!",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 45
                            )
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => const HomeScreen()));
                                  });
                                },
                                child: const Text('Discard'),
                            ),
                            ElevatedButton(
                                onPressed: () {
                                   _showDialog();
                                },
                                child: const Text('Save'),
                            ),
                          ],
                        )
                      ]
                  )
              ),

            ]
        )
    );
  }
}
