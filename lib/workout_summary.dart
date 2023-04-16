import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hello_world/workout_model.dart';
import 'package:intl/intl.dart';

class WorkoutSummary extends StatefulWidget {
  final Workout workout;
  const WorkoutSummary({super.key, required this.workout});

  @override
  State<WorkoutSummary> createState() => _WorkoutSummaryState();
}

class _WorkoutSummaryState extends State<WorkoutSummary> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String name = '';
  LatLng? initialPosition;
  GoogleMapController? mapController;
  late Map<String, dynamic> workoutJson;
  Set<Polyline> polylines = {};
  //late var database;

  T? cast<T>(x) => x is T ? x : null;

  @override
  void initState() {
    super.initState();
    workoutJson = jsonDecode(widget.workout.jsonString)["workout"];
    String polyLineJson = widget.workout.polylines;
    PolylineList polylineList = PolylineList.fromJson(jsonDecode(polyLineJson));
    Map<String, dynamic>? temp = cast<Map<String, dynamic>>(polylineList.polylines?.first);
    if (temp != null) {
      List<dynamic> templist = temp["points"];
      List<LatLng> latlnglist = <LatLng>[];
      for (dynamic x in templist) {
        latlnglist.add(LatLng(x.first, x.last));
      }

      Polyline myline = Polyline(
        polylineId: PolylineId(temp["polylineId"]) ,
        consumeTapEvents: temp["consumeTapEvents"],
        color: Color(temp["color"]),
        width: temp["width"],
        points: latlnglist,
      );

      setState(() {
        initialPosition = latlnglist.first;
        polylines.add(myline);
      });
    }
  }

  String _getStartTime() {
    int? seconds = int.tryParse(workoutJson['start_timestamp']);
    if (seconds != null) {
      DateTime date = DateTime.fromMillisecondsSinceEpoch((seconds*1000));
      String time = DateFormat.jm().format(date);
      return "$time ${date.month}/${date.day}/${date.year}";
    }
    else {
      return "Date not found";
    }
  }

  String _getDuration() {
    int? start = int.tryParse(workoutJson['start_timestamp']);
    int? end = int.tryParse(workoutJson['end_timestamp']);
    if (start != null && end != null) {
      int seconds = end - start;
      int hours = seconds~/360;
      int minutes = ((seconds-(hours*360))~/60);
      seconds = seconds - (minutes*60) - (hours*360);
      return "Duration: ${hours}h:${minutes}m:${seconds}s";
    }
    else {
      return "Duration unavailable";
    }
  }

  String _getDistance() {
    if (workoutJson['distance'] != null) {
      return "Distance: ${workoutJson['distance']['data'].last['value']} meters";
    }
    else {
      return "0.0 meters";
    }
  }

  String _getPartners() {
    if (workoutJson['partners'].isEmpty) {
      return "Partners: ";
    }
    else {
      return "No partners";
    }
  }

  String _getWorkoutType() {
    return "Workout type: ${workoutJson['workout_type']}";
  }


  Set<Polyline> _getPolylines() {
    if (polylines != null) {
      return polylines;
    }
    else {
      return {};
    }
  }


  _onMapCreated(GoogleMapController controller) {
    controller = controller;
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
                        FittedBox(
                          fit: BoxFit.fitWidth,
                          child: Text(
                              widget.workout.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 40
                              )
                          ),
                        ),
                        SizedBox(
                          width: screenWidth*.8,
                          height: screenHeight*.4,
                          child: initialPosition == null ? Center(child:Text('loading map..', style: TextStyle(fontFamily: 'Avenir-Medium', color: Colors.grey[400]),),) :
                          GoogleMap(
                            initialCameraPosition: CameraPosition(target: initialPosition!, zoom: 15),
                            rotateGesturesEnabled: false,
                            zoomControlsEnabled: false,
                            tiltGesturesEnabled: false,
                            myLocationButtonEnabled: false,
                            onMapCreated: _onMapCreated,
                            //cameraTargetBounds: ,
                            polylines: _getPolylines(),
                          ),
                        ),
                        Text(
                          _getStartTime(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15
                            )
                        ),
                        Text(
                            _getWorkoutType(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15
                            )
                        ),
                        Text(
                            _getDuration(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15
                            )
                        ),
                        Text(
                            _getDistance(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15
                            )
                        ),
                        Text(
                            _getPartners(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15
                            )
                        ),
                        FilledButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: FilledButton.styleFrom(backgroundColor: Colors.white38),
                          child: const Text(
                            'Back',
                          ),
                        )
                      ]
                  )
              ),

            ]
        )
    );
  }
}
