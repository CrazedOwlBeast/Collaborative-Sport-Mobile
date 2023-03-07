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

class _SettingsState extends State<Settings>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final hrController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  String getName() {
    return nameController.text;
  }

  String getAge() {
    return ageController.text;
  }

  String getMaxHR() {
    return hrController.text;
  }

  String calculateMaxHRString(String age) {
    return (208 - (0.7 * int.parse(age))).toString();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;
    return PageView(children: [
      Scaffold(
          backgroundColor: Colors.black,
          body: Column(children: [
            Padding(padding: EdgeInsets.all(40)),
            Text("Edit Profile",
                style: TextStyle(fontSize: 35, color: Colors.white)),
            Padding(padding: EdgeInsets.all(5)),
            Container(
                height: screenHeight / 5,
                width: screenWidth / 3,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 2, color: Colors.white)),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.person, color: Colors.white, size: 130),
                    Positioned(
                        top: screenHeight / 7,
                        left: screenWidth / 4,
                        child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(width: 2, color: Colors.white)),
                            child:
                                Icon(Icons.add, color: Colors.green, size: 25)))
                  ],
                )),
            Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  child: Text(
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    "Name",
                    textAlign: TextAlign.left,
                  ),
                )),
            Padding(padding: EdgeInsets.all(5)),
            Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                    width: screenWidth / 1.5,
                    child: TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey,
                          hintText: 'Enter name',
                        )))),
            Padding(padding: EdgeInsets.all(10)),
            Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  child: Text(
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    "Age",
                    textAlign: TextAlign.left,
                  ),
                )),
            Padding(padding: EdgeInsets.all(5)),
            Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                    width: screenWidth / 4,
                    child: TextField(
                        onSubmitted: (value) {
                          hrController.text = calculateMaxHRString(value);
                        },
                        controller: ageController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey,
                          hintText: 'Enter age',
                        )))),
            Padding(padding: EdgeInsets.all(10)),
            Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  child: Text(
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    "Max Heart Rate",
                    textAlign: TextAlign.left,
                  ),
                )),
            Padding(padding: EdgeInsets.all(5)),
            Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                    width: screenWidth / 3,
                    child: TextField(
                        onSubmitted: (value) {
                          debugPrint(value);
                        },
                        controller: hrController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.grey,
                          hintText: 'Enter max HR',
                        )))),
            Padding(padding: EdgeInsets.all(10))
          ]))
    ]);
  }
}
