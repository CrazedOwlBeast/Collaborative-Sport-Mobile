import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
//import model
import 'workout_info.dart';

class WorkoutDatabase {
  static final WorkoutDatabase instance = WorkoutDatabase._init();

  static Database? _database;

  WorkoutDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('workout_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    final idType = 'integer primary key autoincrement';
    final textType = 'text not null';

    await db.execute('''
    CREATE TABLE $tableWorkouts (
    ${WorkoutFields.id} $idType,
    ${WorkoutFields.name} $textType,
    ${WorkoutFields.jsonString} $textType
    )
    ''');
  }

  Future<Workout> create(Workout workout) async {
    final db = await instance.database;

    final id = await db.insert(tableWorkouts, workout.toJson());
    return workout.copy(id: id);
  }

  Future<Workout> readWorkout(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableWorkouts,
      columns: WorkoutFields.values,
      where: '${WorkoutFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Workout.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Workout>> readAllWorkouts() async {
    final db = await instance.database;

    final result = await db.query(tableWorkouts);
    return result.map((json) => Workout.fromJson(json)).toList();
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableWorkouts,
      where: '${WorkoutFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
  
}