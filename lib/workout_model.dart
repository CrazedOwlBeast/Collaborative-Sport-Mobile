final String tableWorkouts = 'workouts';

class WorkoutFields {
  static final List<String> values = [
    id, name, jsonString
  ];

  static final String id = '_id';
  static final String name = 'name';
  static final String jsonString = 'jsonString';
}

class Workout {
  final int? id;
  final String name;
  final String jsonString;

  const Workout({
    this.id,
    required this.name,
    required this.jsonString,
  });

  Workout copy({
    int? id,
    String? name,
    String? jsonString,
  }) => Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      jsonString: jsonString ?? this.jsonString
  );

  static Workout fromJson(Map<String, Object?> json) => Workout(
    id: json[WorkoutFields.id] as int?,
    name: json[WorkoutFields.name] as String,
    jsonString: json[WorkoutFields.jsonString] as String,
  );

  Map<String, Object?> toJson() => {
      WorkoutFields.id: id,
      WorkoutFields.name: name,
      WorkoutFields.jsonString: jsonString,
  };

}