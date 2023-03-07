import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_logger.dart';

class ExerciseType extends StatefulWidget {
  final LayerLink link;
  final OverlayEntry overlayEntry;
  final Offset offset;
  final double dialogWidth;
  final double dialogHeight;
  final AppLogger logger;
  final Function(String) callBack;

  const ExerciseType({Key? key,
    required this.link,
    required this.offset,
    required this.dialogWidth,
    required this.dialogHeight,
    required this.overlayEntry,
    required this.logger,
    required this.callBack,
  }) : super(key: key);

  @override
  State<ExerciseType> createState() => _ExerciseTypeState();
}

class _ExerciseTypeState extends State<ExerciseType> {
  Color _walkColor = Color.fromRGBO(90, 90, 90, 0.5);
  Color _runColor = Color.fromRGBO(90, 90, 90, 0.5);
  Color _cycleColor = Color.fromRGBO(90, 90, 90, 0.5);

  void _setColor(String type) {
    setState(() {
      _walkColor = Color.fromRGBO(90, 90, 90, 0.5);
      _runColor = Color.fromRGBO(90, 90, 90, 0.5);
      _cycleColor = Color.fromRGBO(90, 90, 90, 0.5);
      if (type == 'Walking') {
        _walkColor = Colors.green;
      }
      else if (type == 'Running') {
        _runColor = Colors.green;
      }
      else if (type == 'Cycling'){
        _cycleColor = Colors.green;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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
            child:
              Column(
                children: [
                  SizedBox(height: widget.dialogWidth * .12,),
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(height: 20),
                            //Text("Select exercise type:", style: GoogleFonts.openSans(color: Colors.white, fontSize: 20)),
                            ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(_walkColor),
                                    //minimumSize: MaterialStateProperty.all<Size>(const Size(300, 60)),
                                    fixedSize: MaterialStateProperty.all<Size>(Size(widget.dialogWidth*.8, widget.dialogHeight*.2)),
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15.0),
                                        )
                                    )
                                ),
                                onPressed: () {
                                  _setColor('Walking');
                                  widget.callBack('Walking');
                                },
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Wrap(
                                  spacing: widget.dialogWidth*.25,
                                  alignment: WrapAlignment.spaceEvenly,
                                  children: [
                                    const Icon(Icons.directions_walk_outlined, size: 50,),
                                    // Spacer(),
                                    Text('Walking', style: GoogleFonts.openSans(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w600,
                                        height: 1.7
                                    )),
                                  ],
                                )
                                )
                            ),
                            ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(_runColor) ,
                                    //minimumSize: MaterialStateProperty.all<Size>(const Size(300, 60)),
                                    fixedSize: MaterialStateProperty.all<Size>(Size(widget.dialogWidth*.8, widget.dialogHeight*.2)),
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15.0),
                                        )
                                    )
                                ),
                                onPressed: () {
                                  _setColor('Running');
                                  widget.callBack('Running');
                                },
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Wrap(
                                  spacing: widget.dialogWidth*.25,
                                  alignment: WrapAlignment.spaceEvenly,
                                  children: [
                                    const Icon(Icons.directions_run_outlined, size: 50,),
                                    Text('Running', style: GoogleFonts.openSans(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w600,
                                        height: 1.7
                                    )),
                                  ],
                                )
                                )
                            ),
                            ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(_cycleColor) ,
                                    //minimumSize: MaterialStateProperty.all<Size>(const Size(300, 60)),
                                    fixedSize: MaterialStateProperty.all<Size>(Size(widget.dialogWidth*.8, widget.dialogHeight*.2)),
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15.0),
                                        )
                                    )
                                ),
                                onPressed: () {
                                  _setColor('Cycling');
                                  widget.callBack('Cycling');
                                },
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Wrap(
                                  spacing: widget.dialogWidth*.25,
                                  alignment: WrapAlignment.spaceEvenly,
                                  children: [
                                    const Icon(Icons.directions_bike_outlined, size: 50,),
                                    Text('Cycling', style: GoogleFonts.openSans(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w600,
                                        height: 1.7
                                    )),
                                  ],
                                )
                                )
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                  )
                ],
              )
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
                        child: Icon(Icons.clear_rounded, size: widget.dialogWidth * .11)
                    )),
                Positioned(
                  top: widget.dialogWidth * .05,
                  left: widget.dialogWidth * .15,
                  height: widget.dialogHeight*.12,
                  width: widget.dialogWidth*.6,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.topLeft,
                    child: Text('Select exercise type:',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.openSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          height: 1.7,
                          color: Colors.white
                      )
                  ),
                  )
                )
              ],
            ),
          )
        ]
        )
      ),
    );
  }
}

