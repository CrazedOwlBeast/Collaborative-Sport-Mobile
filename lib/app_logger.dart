import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'dart:io';

import 'workout_database.dart';

enum WorkoutType { cycling, running, walking }

// Class to be initialized at app start and log all events.
class AppLogger {
  LoggerDevice? userDevice;

  List<Map<String, Object?>> logsToSend = [];
  bool workoutsToSend = false;
  bool sending = false;
  int tempLogId = -1;

  LoggerWorkout? workout;
  LoggerEvents loggerEvents = LoggerEvents();

  AppLogger() {
    // Send app launch event when constructor is called (always from home screen).
    LoggerEvent loggedEvent = LoggerEvent(eventType: "0");
    loggedEvent.currentPage = "home_page";
    loggedEvent.processEvent();
    loggerEvents.events.add(loggedEvent);

    getLogsFromDb();

    // Clear logs for testing.
    WorkoutDatabase.instance.deleteLogs();
  }

  // Check local db for logs to send.
  Future<List<Map<String, Object?>>> getLogsFromDb() async {
    logsToSend = await WorkoutDatabase.instance.getLogs();
    if (logsToSend.isNotEmpty) {
      workoutsToSend = true;
      uploadWorkoutLogs();
    }

    return logsToSend;
  }

  // Save temp log during exercise, for when app closes before exercise ends.
  void saveTempLog() async {
    Map<String, dynamic> map = {};

    // Use time at last log for workout end timestamp.
    workout?.endTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Log should have an event for app closing if this log is used.
    LoggerEvent loggedEvent = LoggerEvent(eventType: "1");
    loggedEvent.currentPage = "active_workout_page";
    loggedEvent.processEvent();
    loggerEvents.events.add(loggedEvent);

    map['group_id'] = 2;
    map['name'] = userDevice?.name;
    map['device_id'] = userDevice?.deviceId;
    map['workout'] = workout?.toMap();
    map['events'] = loggerEvents.toMap();

    if (tempLogId == -1) {
      tempLogId = await WorkoutDatabase.instance.addLog(jsonEncode(map));
    }
    else {
      WorkoutDatabase.instance.deleteLogById(tempLogId);
      tempLogId = await WorkoutDatabase.instance.addLog(jsonEncode(map));
    }

    debugPrint("Temp log saved.");
  }

  void saveLog() async {
    Map<String, dynamic> map = {};

    map['group_id'] = 2;
    map['name'] = userDevice?.name;
    map['device_id'] = userDevice?.deviceId;
    map['workout'] = workout?.toMap();
    map['events'] = loggerEvents.toMap();

    await WorkoutDatabase.instance.addLog(jsonEncode(map));

    debugPrint("Log saved.");
  }

  void startWorkout() {
    workout = LoggerWorkout();
  }

  // Prepare object for saving to local sqlite db.
  Map<String, dynamic> toSave() {
    Map<String, dynamic> map = {};

    map['group_id'] = 2;
    map['name'] = userDevice?.name;
    map['device_id'] = userDevice?.deviceId;
    // map['serial_number'] = userDevice?.serialNumber;
    map['workout'] = workout?.toMap();
    map['events'] = loggerEvents.toMap();

    return map;
  }

  // Function to send JSON data to analytics group.
  void uploadWorkoutLogs() async {
    sending = true;
    logsToSend = await WorkoutDatabase.instance.getLogs();

    try {
      while (logsToSend.isNotEmpty) {

        HttpClient httpClient = HttpClient();
        HttpClientRequest request = await httpClient.postUrl(Uri.parse(
            'https://us-east-1.aws.data.mongodb-api.com/app/data-nphof/endpoint/insert'));
        request.headers.set('apiKey',
            'e1G2HlcHaZPlJ2NOoFtP3ocZilWoQOoPIdZ8pndoFpECJhoNn7e5684PV0NTZSXg');
        request.headers.contentType = ContentType('application', 'json');

        Map<String, dynamic> currentLog = logsToSend.last;
        Map<String, dynamic> currentLogJson = jsonDecode(currentLog['log']);

        Map<String, dynamic> body = {
          'document': currentLogJson
        };

        debugPrint(jsonEncode(body));
        request.write(jsonEncode(body));

        HttpClientResponse response = await request.close();
        String reply = await response.transform(utf8.decoder).join();
        httpClient.close();

        if (response.statusCode == 201 || response.statusCode == 200) {
          debugPrint(reply);
          WorkoutDatabase.instance.deleteLogById(currentLog['_id'] as int);

          // debugPrint(await response.stream.bytesToString());
        }
        else {
          // Save for later if data can't be sent.
          workoutsToSend = true;
          debugPrint(response.reasonPhrase);
          // Stop trying to send for now.
          sending = false;
          break;
        }

        logsToSend = await WorkoutDatabase.instance.getLogs();
      }

      // All logs have sent successfully.
      workoutsToSend = false;
      sending = false;
      WorkoutDatabase.instance.deleteLogs();
    }

    on Exception catch (_) {
      workoutsToSend = true;
      sending = false;
      debugPrint('No network connection, saving logs for later...');
    }
  }
}

// Class to gather data during workout.
class LoggerWorkout {
  String workoutType = "";
  LoggerDevice? partnerDevice;
  int startTimestamp = -1;
  int endTimestamp = -1;
  LoggerHeartRate loggerHeartRate = LoggerHeartRate();
  LoggerDistance loggerDistance = LoggerDistance();
  LoggerPower loggerPower = LoggerPower();
  LoggerLocation loggerLocation = LoggerLocation();
  LoggerSpeed loggerSpeed = LoggerSpeed();

  String partnerName = "";
  String partnerDeviceId = "";

  // Constructor.
  LoggerWorkout() {
    startTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }

  // Create a new LoggerWorkoutData object and add it to loggerHeartRate.data.
  void logHeartRate(String heartRate) {
    loggerHeartRate.data.add(LoggerWorkoutData(value: heartRate));
  }

  // Create a new LoggerWorkoutData object and add it to loggerDistance.data.
  void logDistance(String distance) {
    loggerDistance.data.add(LoggerWorkoutData(value: distance));
  }

  // Create a new LoggerWorkoutData object and add it to loggerPower.data.
  void logPower(String power) {
    loggerPower.data.add(LoggerWorkoutData(value: power));
  }

  // Create a new LoggerWorkoutData object and add it to loggerLocation.data.
  void logLocation(String location) {
    loggerLocation.data.add(LoggerWorkoutData(value: location));
  }

  void logSpeed(String speed) {
    loggerSpeed.data.add(LoggerWorkoutData(value: speed));
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};

    map['workout_type'] = workoutType;
    map['start_timestamp'] = startTimestamp;
    map['end_timestamp'] = endTimestamp;
    if (partnerName.isNotEmpty) {
      map['partners'] = [{
        'name': partnerName,
        'device_id': partnerDeviceId,
      }
      ];
    }


    if (loggerHeartRate.data.isNotEmpty) {
      map['heart_rate'] = loggerHeartRate.toMap();
    }
    if (loggerDistance.data.isNotEmpty) {
      map['distance'] = loggerDistance.toMap();
    }
    if (loggerPower.data.isNotEmpty) {
      map['power'] = loggerPower.toMap();
    }
    if (loggerLocation.data.isNotEmpty) {
      map['location'] = loggerLocation.toMap();
    }
    if (loggerSpeed.data.isNotEmpty) {
      map['speed'] = loggerSpeed.toMap();
    }

    return map;
  }
}

class LoggerEvents {
  List<LoggerEvent> events = [];

  List<Map<String, dynamic>> toMap() {
    List<Map<String, dynamic>> map = [];
    for (LoggerEvent event in events) {
      map.add(event.toMap());
    }

    return map;
  }

}

// Class for app events.
class LoggerEvent {
  final String eventType;
  int timestamp = -1;
  String prevPage = "";
  String nextPage = "";
  String currentPage = "";
  String buttonName = "";
  String workoutType = "";
  String bleDeviceName = "";
  String partnerName = "";
  String partnerDeviceId = "";

  Map<String, dynamic> map = {};


  LoggerEvent({required this.eventType}) {
    // Every event has a timestamp.
    timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    map['event_type'] = eventType;
    map['timestamp'] = timestamp;
  }

  void processEvent() {
    switch (eventType) {
      // App is launched.
      case "0": {
        map['current_page'] = currentPage;
      } break;

      // App is closed.
      case "1": {
        map['current_page'] = currentPage;
      } break;

      // Button is pressed.
      // TODO: Call on every button press :(
      case "2": {
        map['button_name'] = buttonName;
      } break;

      // Page is switched.
    // TODO: Call on every page switch :(
      case "3": {
        map['page_before_switch'] = prevPage;
        map['current_page'] = nextPage;
      } break;

      // Setting is changed.
      case "4": {
        // TODO: Log what setting, the previous and current value. Examples are a metric change for heart rate, change in displayed metric on the screen, change profile type, etc.
      } break;

      // Workout is started.
    // TODO
      case "5": {
        map['workout_type'] = workoutType;
      } break;

      // Workout is ended.
      case "6": {
        map['workout_type'] = workoutType;
      } break;

      // Workout is paused. Only records timestamp.
      case "7": {

      } break;

      // Workout is unpaused. Only records timestamp.
      case "8": {

      } break;

      // TODO: Make sure partner_device_id makes sense.
      // Partner is connected.
      case "9": {
        map['partner_name'] = partnerName;
        map['device_id'] = partnerDeviceId;
      } break;

      // Partner is disconnected.
      case "10": {
        map['partner_name'] = partnerName;
        map['device_id'] = partnerDeviceId;
      } break;

      // Bluetooth scan started. Only records timestamp.
      case "11": {

      } break;

      // BLE device connected.
      case "12": {
        map['device_id'] = bleDeviceName;
      } break;

      // BLE device disconnected.
      // TODO: Specs from analytics group should call for device type in separate field.?
      case "13": {
        map['device_id'] = bleDeviceName;
      } break;
    }
  }

  Map<String, dynamic> toMap() {
    return map;
  }
}

// Class for basic info about a user/device.
class LoggerDevice {
  String name = "";
  String deviceId = "";
  String serialNumber = "";
}

// TODO: These could probably all be one class...
// Class to store heart rate data.
class LoggerHeartRate {
  String units = "beats_per_minute";
  String maxHeartRate = "";
  List<LoggerWorkoutData> data = [];

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};

    map['units'] = units;
    map['target_heart_rate'] = int.parse(maxHeartRate);

    List<Map<String, dynamic>> dataMap = [];
    for (LoggerWorkoutData event in data) {
      dataMap.add(event.toMap());
    }
    map['data'] = dataMap;

    return map;
  }
}

// Class to store distance data.
class LoggerDistance {
  String units = "meters";
  List<LoggerWorkoutData> data = [];

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};

    map['units'] = units;

    List<Map<String, dynamic>> dataMap = [];
    for (LoggerWorkoutData event in data) {
      dataMap.add(event.toMap());
    }
    map['data'] = dataMap;

    return map;
  }
}

// Class to store power data.
class LoggerPower {
  String units = "watts";
  List<LoggerWorkoutData> data = [];

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};

    map['units'] = units;

    List<Map<String, dynamic>> dataMap = [];
    for (LoggerWorkoutData event in data) {
      dataMap.add(event.toMap());
    }
    map['data'] = dataMap;

    return map;
  }
}

// Class to store location data.
class LoggerLocation {
  String units = "latitude/longitude";
  List<LoggerWorkoutData> data = [];

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};

    map['units'] = units;

    List<Map<String, dynamic>> dataMap = [];
    for (LoggerWorkoutData event in data) {
      dataMap.add(event.toMap());
    }
    map['data'] = dataMap;

    return map;
  }
}

// Class to store speed data.
class LoggerSpeed {
  String units = "miles_per_hour";
  List<LoggerWorkoutData> data = [];

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};

    map['units'] = units;

    List<Map<String, dynamic>> dataMap = [];
    for (LoggerWorkoutData event in data) {
      dataMap.add(event.toMap());
    }
    map['data'] = dataMap;

    return map;
  }
}

// Data object for workout lists
class LoggerWorkoutData {
  final String value;
  int? timestamp;
  
  LoggerWorkoutData({required this.value}) {
    timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};

    map['value'] = value;
    map['timestamp'] = timestamp;

    return map;
  }
}
