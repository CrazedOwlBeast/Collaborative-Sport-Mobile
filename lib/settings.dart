import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'home_screen.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
    

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
              child: Text(
                "Settings",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 45
                )
              )
              ),
              settingsButtonMaker(context, "Edit user info"),
              settingsButtonMaker(context, "How to use"),
              settingsButtonMaker(context, "Legal"),

        ]
      )
    );
  }
}

Container settingsButtonMaker(BuildContext context, String text)
{
  return           
    Container(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                color: Colors.black,
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.13, // go button takes 18% of screen
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                      },
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.grey[850]) ,
                          minimumSize: MaterialStateProperty.all<Size>(Size(300, 70)),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(45.0),
                              )
                          )
                      ),
                      child: Wrap(
                        alignment: WrapAlignment.spaceAround,
                        children:  [
                          Text(
                            text,
                            style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white
                            ),
                          ),
                        ],
                      ),
                    )
                  ], // Children
                ),
            );
}