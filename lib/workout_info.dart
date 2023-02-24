class Workout {

  final String type;
  final List<String> partners;
  final double duration;
  final double distance;
  /*
  List<int>? hr;
  List<int>? speed;
  */

  Workout({
    required this.type,
    required this.duration,
    required this.distance,
    required this.partners,
    /*
    this.hr,
    this.speed
     */
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'duration': duration,
      'distance': distance,
    };
  }

}