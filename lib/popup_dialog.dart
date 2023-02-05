import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PopupDialog extends StatelessWidget {

  String buttonType;
  VoidCallback continueCallBack;

  PopupDialog(this.continueCallBack, this.buttonType, {super.key});

  @override
  Widget build(BuildContext context) {
  bool _hasBeenPressed = false;

    if(buttonType == "exerciseType")
    {
      return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.fromLTRB(30, 30, 30, 450),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(height: 20),
                    Text("Select exercise type:", style: GoogleFonts.openSans(color: Colors.white, fontSize: 20)),
                    ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Color.fromRGBO(90, 90, 90, 0.5)),
                            minimumSize: MaterialStateProperty.all<Size>(const Size(300, 60)),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                )
                            )
                        ),
                        onPressed: () {
                          //TODO Set exercise type to walking
                        },
                        child: Wrap(
                          spacing: 90,
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
                    ),
                    ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Color.fromRGBO(90, 90, 90, 0.5)) ,
                            minimumSize: MaterialStateProperty.all<Size>(const Size(300, 60)),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                )
                            )
                        ),
                        onPressed: () {
                          //TODO Set exercise type to running
                        },
                        child: Wrap(
                          spacing: 90,
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
                    ),
                    ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Color.fromRGBO(90, 90, 90, 0.5)) ,
                            minimumSize: MaterialStateProperty.all<Size>(const Size(300, 60)),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                )
                            )
                        ),
                        onPressed: () {

                          //TODO Set exercise type to cycling
                        },
                        child: Wrap(
                          spacing: 100,
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
                    ),
                  ],
                ),
              ),
              Positioned(
                width: 30,
                  height: 30,
                  top: 15,
                  right: 15,
                  child: FloatingActionButton(
                      mini: true,
                      backgroundColor: Colors.red,
                      onPressed: () {
                        continueCallBack();
                      },
                      child: Icon(Icons.clear)
                  ))
            ],
          )
      );
    }

    if(buttonType == "connectMonitors")
    {
      // TODO: add buttons dynamically for every device found, no need to have all this code, but just here now for temp reasons
      return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.fromLTRB(30, 30, 30, 450),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(height: 20),
                    Text("Select Monitors:", style: GoogleFonts.openSans(color: Colors.white, fontSize: 20)),
                    ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Color.fromRGBO(90, 90, 90, 0.5)),
                            minimumSize: MaterialStateProperty.all<Size>(const Size(300, 60)),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                )
                            )
                        ),
                        onPressed: () {
                          //TODO Set exercise type to walking
                        },
                        child: Wrap(
                          spacing: 90,
                          alignment: WrapAlignment.spaceEvenly,
                          children: [
                            const Icon(Icons.monitor_heart_outlined, size: 50,),
                            // Spacer(),
                            Text('Garmin Dual 3', style: GoogleFonts.openSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                height: 1.7
                            )),
                          ],
                        )
                    ),
                  ],
                ),
              ),
              Positioned(
                  width: 30,
                  height: 30,
                  top: 15,
                  right: 15,
                  child: FloatingActionButton(
                      mini: true,
                      backgroundColor: Colors.red,
                      onPressed: () {
                        continueCallBack();
                      },
                      child: Icon(Icons.clear)
                  ))
            ],
          )
      );
    }

    if(buttonType == "connectPartners")
    {
      // TODO: add buttons dynamically for every device found, no need to have all this code, but just here now for temp reasons
      return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.fromLTRB(30, 30, 30, 450),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(height: 20),
                    Text("Select Partners:", style: GoogleFonts.openSans(color: Colors.white, fontSize: 20)),
                    ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Color.fromRGBO(90, 90, 90, 0.5)),
                            minimumSize: MaterialStateProperty.all<Size>(const Size(300, 60)),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                )
                            )
                        ),
                        onPressed: () {
                          //TODO Set exercise type to walking
                        },
                        child: Wrap(
                          spacing: 90,
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
                    ),
                  ],
                ),
              ),
              Positioned(
                  width: 30,
                  height: 30,
                  top: 15,
                  right: 15,
                  child: FloatingActionButton(
                      mini: true,
                      backgroundColor: Colors.red,
                      onPressed: () {
                        continueCallBack();
                      },
                      child: Icon(Icons.clear)
                  ))
            ],
          )
      );
    }

    throw Exception("bloop");
  }
}