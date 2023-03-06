import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';

enum WorkoutType { cycling, running, walking }

// TODO: Transmit logged data.
// Class to be initialized at app start and log all events.
class AppLogger {
  LoggerDevice? userDevice;

  LoggerWorkout workout = LoggerWorkout();
  LoggerEvents loggerEvents = LoggerEvents();


  AppLogger() {
    loggerEvents.events.add(LoggerEvent(eventType: 0));  // App startup event.
  }

  // Prepare JSON for export.
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['name'] = userDevice?.name;
    json['device_id'] = userDevice?.deviceId;
    json['serial_number'] = userDevice?.serialNumber;
    json['workout'] = workout.toJson();
    json['events'] = loggerEvents.toJson();

    //json['events'] = eventsJson;
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');

    debugPrint(encoder.convert(json));
    return json;
  }
}

// Class to gather data during workout.
class LoggerWorkout {
  WorkoutType? workoutType;
  LoggerDevice? partnerDevice;
  String? startTimestamp;
  LoggerHeartRate loggerHeartRate = LoggerHeartRate();
  LoggerDistance loggerDistance = LoggerDistance();

  // Constructor.
  LoggerWorkout() {
    startTimestamp = DateTime.now().millisecondsSinceEpoch.toString();  // TODO: Is this the correct timestamp format?
  }

  // Create a new LoggerWorkoutData object and add it to loggerHeartRate.data.
  void logHeartRate(int heartRate) {
    loggerHeartRate.data.add(LoggerWorkoutData(value: heartRate));
    // debugPrint("Heartrate logged: $heartRate");
  }

  // Create a new LoggerWorkoutData object and add it to loggerDistance.data.
  void logDistance(int distance) {
    loggerDistance.data.add(LoggerWorkoutData(value: distance));
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    // json['workout_type'] = workoutType?.name;
    // TODO: partner info
    json['start_timestamp'] = startTimestamp;
    json['heart_rate'] = loggerHeartRate.toJson();
    json['distance'] = loggerDistance.toJson();

    return json;
  }
}

class LoggerEvents {
  List<LoggerEvent> events = [];

  List<Map<String, dynamic>> toJson() {
    List<Map<String, dynamic>> json = [];
    for (LoggerEvent event in events) {
      json.add(event.toJson());
    }

    return json;
  }

}

// Class for app events.
class LoggerEvent {
  final int eventType;
  String? timestamp;
  String? buttonName;


  LoggerEvent({required this.eventType, this.buttonName}) {
    // Every event has a timestamp.
    timestamp = DateTime.now().millisecondsSinceEpoch.toString();  // TODO: Is this the correct timestamp format?

    switch (eventType) {
      // App is launched.
      case 0: {
        // TODO: Log starting page/closing page name (if applicable)
      } break;

       // App is closed.
      case 1: {
        // TODO: Log starting page/closing page name (if applicable)
      } break;

      // Button is pressed.
      case 2: {
        // TODO: Log the button name
      } break;

      // Page is switched.
      case 3: {
        // TODO: Log the page before the switch (if applicable) and the page that was switched to
      } break;

      // Setting is changed.
      case 4: {
        // TODO: Log what setting, the previous and current value. Examples are a metric change for heart rate, change in displayed metric on the screen, change profile type, etc.
      } break;

      // Workout is started.
      case 5: {
        // TODO: Just log the timestamp and type of workout.
      } break;

      // Workout is ended.
      case 6: {
        // TODO: Just log the timestamp and type of workout.
      } break;

      // Workout is paused.
      case 7: {
        // TODO: Log timestamp only.
      } break;

      // Workout is unpaused.
      case 8: {
        // TODO: Log timestamp only.
      } break;

      // Partner is connected.
      case 9: {
        // TODO: Log their device id and their name if possible
      } break;

      // Partner is disconnected.
      case 10: {
        // TODO: Log their device id and their name if possible
      } break;

      case 11: {
        // TODO: Log timestamp only.
      } break;

      // BLE device connected.
      case 12: {
        // TODO: Log name of the device that was connected/disconnected
      } break;

      // BLE device disconnected.
      case 13: {
        // TODO: Log name of the device that was connected/disconnected
      } break;
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['event_type'] = eventType;
    json['time'] = timestamp;

    return json;
  }

}

// Class for basic info about a user/device.
class LoggerDevice {
  String? name;
  String? deviceId;
  String? serialNumber;
}

// Class to store heart rate data.
class LoggerHeartRate {
  String units = "";
  int? maxHeartRate;
  List<LoggerWorkoutData> data = [];

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['units'] = units;
    json['max_heart_rate'] = maxHeartRate;

    List<Map<String, dynamic>> dataJson = [];
    for (LoggerWorkoutData event in data) {
      dataJson.add(event.toJson());
    }
    json['data'] = dataJson;

    return json;
  }
}

// Class to store distance data.
class LoggerDistance {
  String units = "";
  List<LoggerWorkoutData> data = [];

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['units'] = units;

    List<Map<String, dynamic>> dataJson = [];
    for (LoggerWorkoutData event in data) {
      dataJson.add(event.toJson());
    }
    json['data'] = dataJson;

    return json;
  }
}

// Data object for workout lists
class LoggerWorkoutData {
  final int value;
  String? timestamp;

  LoggerWorkoutData({required this.value}) {
    timestamp = DateTime.now().millisecondsSinceEpoch.toString();  // TODO: Is this the correct timestamp format?
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['value'] = value;
    json['timestamp'] = timestamp;

    return json;
  }
}
