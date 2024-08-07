import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'app_logger.dart';
import 'edit_workout_type.dart';

class ExerciseType extends StatefulWidget {
  final LayerLink link;
  final OverlayEntry overlayEntry;
  final Offset offset;
  final double dialogWidth;
  final double dialogHeight;
  final AppLogger logger;
  final String exerciseType;
  final Function(String) callBack;

  const ExerciseType({Key? key,
    required this.link,
    required this.offset,
    required this.dialogWidth,
    required this.dialogHeight,
    required this.overlayEntry,
    required this.logger,
    required this.callBack,
    required this.exerciseType,
  }) : super(key: key);

  @override
  State<ExerciseType> createState() => _ExerciseTypeState();
}

class _ExerciseTypeState extends State<ExerciseType> {
  Color _inWalkColor = const Color.fromRGBO(90, 90, 90, 0.5);
  Color _outWalkColor = const Color.fromRGBO(90, 90, 90, 0.5);
  Color _outRunColor = const Color.fromRGBO(90, 90, 90, 0.5);
  Color _inRunColor = const Color.fromRGBO(90, 90, 90, 0.5);
  Color _outCycleColor = const Color.fromRGBO(90, 90, 90, 0.5);
  Color _inCycleColor = const Color.fromRGBO(90, 90, 90, 0.5);

  @override
  void initState() {
    super.initState();
    _setColor(widget.exerciseType);
  }

  void _setColor(String type) {
    setState(() {
      _outWalkColor = const Color.fromRGBO(90, 90, 90, 0.5);
      _inWalkColor = const Color.fromRGBO(90, 90, 90, 0.5);
      _outRunColor = const Color.fromRGBO(90, 90, 90, 0.5);
      _inRunColor = const Color.fromRGBO(90, 90, 90, 0.5);
      _outCycleColor = const Color.fromRGBO(90, 90, 90, 0.5);
      _inCycleColor = const Color.fromRGBO(90, 90, 90, 0.5);

      if (type == 'Outdoor Walk')
      {
        _outWalkColor = const Color(0xFF4F45C2);
      }
      if (type == 'Indoor Walk')
      {
        _inWalkColor = const Color(0xFF4F45C2);
      }
      else if (type == 'Outdoor Run')
      {
        _outRunColor = const Color(0xFF4F45C2);
      }
      else if (type == 'Indoor Run')
      {
        _inRunColor = const Color(0xFF4F45C2);
      }
      else if (type == 'Outdoor Biking')
      {
        _outCycleColor = const Color(0xFF4F45C2);
      }
      else if (type == 'Indoor Biking')
      {
        _inCycleColor = const Color(0xFF4F45C2);
      }
    });
  }

  Future<List<Widget>> getWorkoutTypes(BuildContext context) async {
    String appDocumentsDirectory = (await getApplicationDocumentsDirectory()).path;
    Directory pageOrderDir = Directory("$appDocumentsDirectory/pageOrder");

    try {
      return pageOrderDir
          .listSync()
          .map((entry) => entry.path)
          .where((path) => path.endsWith(".json"))
          .map((path) {
        String fileName = path.substring(path.lastIndexOf("/") + 1);

        final String workoutType = fileName.substring(0, fileName.lastIndexOf(".json"));
        String type = '';
        Icon workoutIcon = const Icon(Icons.directions_walk_outlined, size: 40, color: Color(0xFF71F1B5));
        Color workoutColor = _outRunColor;

          switch (workoutType) {
          case "Outdoor Run":
            workoutIcon = const Icon(Icons.directions_run_outlined, size: 40, color: Color(0xFF71F1B5));
            workoutColor = _outRunColor;
            break;
            case "Indoor Run":
            workoutIcon = const Icon(Icons.directions_run_outlined, size: 40, color: Color(0xFF71F1B5));
            workoutColor = _inRunColor;
            break;
          case "Outdoor Walk":
            workoutColor = _outWalkColor;
            break;
          case "Indoor Walk":
            workoutColor = _inWalkColor;
            break;
          case "Outdoor Biking":
            workoutIcon = const Icon(Icons.directions_bike_outlined, size: 30, color: Color(0xFF71F1B5));
            workoutColor = _outCycleColor;
            break;
          case "Indoor Biking":
            workoutIcon = const Icon(Icons.directions_bike_outlined, size: 30, color: Color(0xFF71F1B5));
            workoutColor = _inCycleColor;
            break;
        }

        return Padding(
          padding: const EdgeInsets.only(top: 20), // Add 20 pixels of padding above each button
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(workoutColor),
              padding: MaterialStateProperty.all(const EdgeInsets.all(20)), // Padding inside the button
              fixedSize: MaterialStateProperty.all<Size>(Size(widget.dialogWidth * .8, widget.dialogHeight * .2)),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
            ),
            onPressed: () {
              _setColor(workoutType);

              // this should just be setExerciseType in home_screen.dart
              // I might be wrong though.
              widget.callBack(workoutType);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                workoutIcon,
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          workoutType,
                          style: GoogleFonts.openSans(
                            color: const Color(0xFFF1F1F1),
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            height: 1.7,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 25, color: Color(0xFF71F1B5)),
                          onPressed: () {
                            _setColor(workoutType);
                            // this should just be setExerciseType in home_screen.dart
                            // I might be wrong though.
                            widget.callBack(workoutType);
                            widget.overlayEntry.remove();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ModifyExerciseType(
                                  exerciseType: workoutType,  // Pass the exerciseType as a parameter
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }


  @override
  Widget build(BuildContext context) {
    return CompositedTransformFollower(
      offset: widget.offset,
      link: widget.link,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(45.0)),
        color: Colors.black,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            SizedBox(
              width: widget.dialogWidth * 0.9,
              child: Column(
                children: [
                  SizedBox(height: widget.dialogWidth * .12),
                  Flexible(
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          height: 600,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(45),
                            color: Colors.black,
                          ),
                          padding: EdgeInsets.fromLTRB(10, 0, 20, 70),
                          child: SingleChildScrollView(
                            child: FutureBuilder<List<Widget>>(
                              future: getWorkoutTypes(context),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return Text('No workout types found.');
                                } else {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: snapshot.data!,
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: widget.dialogHeight * 0.15,
              child: Stack(
                children: [
                  Positioned(
                      width: widget.dialogWidth * .12,
                      height: widget.dialogWidth * .12,
                      top: widget.dialogWidth * .05,
                      right: widget.dialogWidth * .05,
                      child: FloatingActionButton(
                          mini: true,
                          backgroundColor: Colors.red,
                          onPressed: () {
                            widget.overlayEntry.remove();
                          },
                          child: Icon(Icons.clear_rounded, size: widget.dialogWidth * .11))),
                  Positioned(
                      top: widget.dialogWidth * .05,
                      left: widget.dialogWidth * .15,
                      height: widget.dialogHeight * .12,
                      width: widget.dialogWidth * .6,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Select exercise type:',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.openSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              height: 1.7,
                              color: Colors.white),
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
