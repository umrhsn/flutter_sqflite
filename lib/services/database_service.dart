import 'package:flutter/cupertino.dart';
import 'package:flutter_sqflite/models/task.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  final String _tasksTableName = 'tasks';
  final String _tasksIdColumnName = 'id';
  final String _tasksContentColumnName = 'content';
  final String _tasksStatusColumnName = 'status';

  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    return _db = await getDatabase();
  }

  Future<Database> getDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, 'master_db.db');
    final database =
        await openDatabase(databasePath, version: 1, onCreate: (db, version) {
      if (version == 1) {
        // Create tables and indices here
        // Example:
        db.execute(
          '''
              CREATE TABLE $_tasksTableName (
              $_tasksIdColumnName INTEGER PRIMARY KEY,
              $_tasksContentColumnName TEXT NOT NULL,
              $_tasksStatusColumnName INTEGER NOT NULL
              )            
              ''',
        );
      }
    });
    return database;
  }

  void addTask(String content) async {
    final db = await database;
    await db.insert(
      _tasksTableName,
      {
        _tasksContentColumnName: content,
        _tasksStatusColumnName: 0,
      },
    );
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final data = await db.query(_tasksTableName);
    List<Task> tasks = data
        .map(
          (e) => Task(
            id: e['id'] as int,
            status: e['status'] as int,
            content: e['content'] as String,
          ),
        )
        .toList();
    return tasks;
  }

  void updateTaskStatus(int id, int status) async {
    final db = await database;
    await db.update(
      _tasksTableName,
      {
        _tasksStatusColumnName: status,
      },
      where: '$_tasksIdColumnName = ?',
      whereArgs: [id],
    );
  }

  void deleteTask(int id) async {
    final db = await database;
    await db.delete(
      _tasksTableName,
      where: '$_tasksIdColumnName = ?',
      whereArgs: [id],
    );
  }
}
