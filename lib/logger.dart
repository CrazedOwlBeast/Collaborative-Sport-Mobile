import 'package:device_info_plus/device_info_plus.dart';

enum WorkoutType { cycling, running, walking }

// TODO: Transmit logged data.
// Class to be initialized at app start and log all events.
class Logger {
  LoggerDevice? userDevice;

  // TODO: Maps instead of lists?
  List<LoggerWorkout> workouts = [];
  List<LoggerEvent> events = [];
}

// Class to gather data during workout.
class LoggerWorkout {
  final WorkoutType workoutType;
  LoggerDevice? partnerDevice;
  String? startTimestamp;
  LoggerHeartRate loggerHeartRate = LoggerHeartRate();
  LoggerDistance loggerDistance = LoggerDistance();

  // Constructor.
  LoggerWorkout({required this.workoutType}) {
    startTimestamp = DateTime.now().millisecondsSinceEpoch.toString();  // TODO: Is this the correct timestamp format?
  }

  // Create a new LoggerWorkoutData object and add it to loggerHeartRate.data.
  void logHeartRate(int heartRate) {
    loggerHeartRate.data.add(LoggerWorkoutData(value: heartRate));
  }

  // Create a new LoggerWorkoutData object and add it to loggerDistance.data.
  void logDistance(int distance) {
    loggerDistance.data.add(LoggerWorkoutData(value: distance));
  }
}

// Class for app events.
class LoggerEvent {
  final int eventType;
  String? timestamp;

  LoggerEvent({required this.eventType}) {
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

}

// Class for basic info about a user/device.
class LoggerDevice {
  String? name;
  String? deviceId;
  String? serialNumber;
}

// Class to store heart rate data.
class LoggerHeartRate {
  String? units;
  int? maxHeartRate;
  List<LoggerWorkoutData> data = [];
}

// Class to store distance data.
class LoggerDistance {
  String? units;
  List<LoggerWorkoutData> data = [];
}

// Data object for workout lists
class LoggerWorkoutData {
  final int value;
  String? timestamp;

  LoggerWorkoutData({required this.value}) {
    timestamp = DateTime.now().millisecondsSinceEpoch.toString();  // TODO: Is this the correct timestamp format?
  }
}
