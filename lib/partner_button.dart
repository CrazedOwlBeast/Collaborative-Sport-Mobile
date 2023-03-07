import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PartnerButton extends StatefulWidget {
  List<String> deviceIds = [];

  PartnerButton({super.key, required this.deviceIds});
  _PartnerButtonState createState() => _PartnerButtonState();
}

class _PartnerButtonState extends State<PartnerButton> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: widget.deviceIds.length,
      itemBuilder: (context, index) {
        return CircleAvatar(
          child: Text(widget.deviceIds[index]),
        );
      },
    );
  }

  void addDevice(String newDeviceId){
    setState(() {
      widget.deviceIds.add(newDeviceId);
    });
  }
}
