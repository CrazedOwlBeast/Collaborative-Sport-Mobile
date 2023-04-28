import 'dart:core';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
//import models
import 'workout_model.dart';
import 'logs_model.dart';
import 'package:hello_world/settings_model.dart';

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
    final intType = 'integer';

    await db.execute('''
    CREATE TABLE $tableWorkouts (
    ${WorkoutFields.id} $idType,
    ${WorkoutFields.name} $textType,
    ${WorkoutFields.jsonString} $textType,
    ${WorkoutFields.polylines} $textType
    )
    ''');

    await db.execute('''
    CREATE TABLE $tableSettings (
    ${SettingsFields.id} $idType,
    ${SettingsFields.name} $textType,
    ${SettingsFields.age} $intType,
    ${SettingsFields.maxHR} $intType,
    ${SettingsFields.ftp} $intType
    )
    ''');

    await db.execute('''
    CREATE TABLE $tableLogs (
    ${LogsFields.id} $idType,
    ${LogsFields.log} $textType
    )
    ''');
  }

  Future<int> addLog(String logToSend) async {
    final db = await instance.database;

    Map<String, Object?> logMap = {
      "log" : logToSend
    };

    return await db.insert(tableLogs, logMap);
  }

  void deleteLogById(int logId) async {
    final db = await instance.database;
    db.delete(tableLogs, where: '${LogsFields.id} = $logId');
  }

  // TODO: Delete logs individually as they are sent.
  void deleteLogs() async {
    final db = await instance.database;
    db.delete(tableLogs);
  }

  Future<List<Map<String, Object?>>> getLogs() async {
    List<Map<String, Object?>> maps = [];
    final db = await instance.database;

    // Try to read saved logs. Create table if it doesn't exist (first run).
    try {
      maps = await db.query(tableLogs);
    }
    catch (e) {
        if (e is DatabaseException) {
          await db.execute('''
            CREATE TABLE $tableLogs (
            ${LogsFields.id} 'integer primary key autoincrement',
            ${LogsFields.log} 'text not null'
            )
          ''');
          maps = await db.query(tableLogs);
        }
    }

    return maps;
  }

  //updates settings or inserts settings if none
  Future<ProfileSettings> updateSettings(ProfileSettings settings) async {
    final db = await instance.database;

    List maps = await db.query(tableSettings);
    int id;
    if (maps.isEmpty) {
      id = await db.insert(tableSettings, settings.toJson());
    }
    else {
      id = await db.update(
          tableSettings,
          settings.toJson(),
          where: '_id = ?',
          whereArgs: [settings.id],
      );
    }
    return settings.copy(id: id);
  }

  //returns settigns from database (should only contain one)
  Future<ProfileSettings?> readSettings() async {
    final db = await instance.database;

    final maps = await db.query(tableSettings);
    if (maps.isNotEmpty) {
      return ProfileSettings.fromJson(maps.first);
    } else {
      return null;
    }
  }

  Future<Workout> createWorkout(Workout workout) async {
    final db = await instance.database;

    final id = await db.insert(tableWorkouts, workout.toJson());
    return workout.copy(id: id);
  }

  Future<Workout?> readWorkout(int id) async {
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
      return null;
    }
  }

  Future<List<Workout>> readAllWorkouts() async {
    final db = await instance.database;

    final result = await db.query(tableWorkouts);
    return result.map((json) => Workout.fromJson(json)).toList();
  }

  Future<int> deleteWorkout(int id) async {
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