import 'package:google_maps_flutter/google_maps_flutter.dart';

class PolylineList {
  final List<dynamic>? polylines;

  PolylineList(this.polylines);

  PolylineList.fromJson(Map<String, dynamic> json)
  : polylines = json['polylines'] != null ? List.from(json['polylines']): null;

  Map<String, dynamic> toJson() => {
    'polylines': polylines,
  };
}

final String tableWorkouts = 'workouts';

class WorkoutFields {
  static final List<String> values = [
    id, name, jsonString, polylines
  ];

  static final String id = '_id';
  static final String name = 'name';
  static final String jsonString = 'jsonString';
  static final String polylines = 'polylines';
}

class Workout {
  final int? id;
  final String name;
  final String jsonString;
  final String polylines;

  const Workout({
    this.id,
    required this.name,
    required this.jsonString,
    required this.polylines,
  });

  Workout copy({
    int? id,
    String? name,
    String? jsonString,
    String? polylines
  }) => Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      jsonString: jsonString ?? this.jsonString,
      polylines: polylines ?? this.polylines
  );

  static Workout fromJson(Map<String, Object?> json) => Workout(
    id: json[WorkoutFields.id] as int?,
    name: json[WorkoutFields.name] as String,
    jsonString: json[WorkoutFields.jsonString] as String,
    polylines: json[WorkoutFields.polylines] as String,
  );

  Map<String, Object?> toJson() => {
      WorkoutFields.id: id,
      WorkoutFields.name: name,
      WorkoutFields.jsonString: jsonString,
      WorkoutFields.polylines: polylines,
  };

}