import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


import 'home_screen.dart';

class CompletedWorkout extends StatefulWidget {
  const CompletedWorkout({super.key});

  @override
  State<CompletedWorkout> createState() => _CompletedWorkoutState();
}

class _CompletedWorkoutState extends State<CompletedWorkout> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  @override
  void initState(){
    super.initState();
  }

  void _showDialog() {
    showDialog(
        context: context,
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
