import 'dart:convert';

final String tableWorkouts = 'workouts';

class WorkoutFields {
  static final String id = '_id';
  static final String name = 'name';
  static final String jsonString = 'jsonString';
}

class Workout {
  final int id;
  final String name;
  final String jsonString;

  const Workout({
    required this.id,
    required this.name,
    required this.jsonString,
  });

  // final String type;
  // final List<String> partners;
  // final double duration;
  // final double distance;
  // /*
  // List<int>? hr;
  // List<int>? speed;
  // */
  //
  // Workout({
  //   required this.type,
  //   required this.duration,
  //   required this.distance,
  //   required this.partners,
  //   /*
  //   this.hr,
  //   this.speed
  //    */
  // });

  Workout copy({
    int? id,
    String? name,
    String? jsonString,
  }) => Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      jsonString: jsonString ?? this.jsonString
  );

  // static Workout fromJson(Map<String, Object?> json) {
  //
  // }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'jsonString': jsonString,
    };
  }

}