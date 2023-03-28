import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_logger.dart';
import 'completed_workout.dart';

class LongPressButton extends StatefulWidget {
  final AppLogger logger;
  final String exerciseType;

  const LongPressButton({super.key, required this.logger, required this.exerciseType});

  @override
  _LongPressButtonState createState() => _LongPressButtonState();
}

class _LongPressButtonState extends State<LongPressButton> {
  Timer? _timer;
  double _progress = 0;

  void _startTimer() {
    const interval = const Duration(milliseconds: 10);
    var elapsed = const Duration();
    _timer = Timer.periodic(interval, (timer) {
      elapsed += interval;
      setState(() {
        _progress = elapsed.inMilliseconds / 1000;
        if (_progress >= 1) {
          _timer?.cancel();
          _timer = null;
          _progress = 0;
          LoggerEvent loggedEvent = LoggerEvent(eventType: 6);
          loggedEvent.workoutType = widget.exerciseType;
          loggedEvent.processEvent();
          widget.logger.loggerEvents.events.add(loggedEvent);

          /// Send logger data to analytics group.
          widget.logger.insertToDatabase();

          // widget.logger.testInsertToDatabase();

          // TODO: grab all information before transitioning to new screen
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const CompletedWorkout()));
        }
      });
    });
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _progress = 0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _startTimer(),
      onTapCancel: _cancelTimer,
      onTapUp: (_) => _cancelTimer(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 130,
            height: 130,
            child: CircularProgressIndicator(
              strokeWidth: 6.0,
              color: Colors.black,
              value: _progress,
            ),
          ),
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.orange,
            child: Icon(
              Icons.stop,
              size: 80,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
