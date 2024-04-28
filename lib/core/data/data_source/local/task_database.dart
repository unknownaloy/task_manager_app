import 'package:sqflite/sqflite.dart';
import 'package:task_manager_app/core/data/data_source/local/database_service.dart';
import 'package:task_manager_app/core/utils/typedefs.dart';
import 'package:task_manager_app/features/task/data/model/task/task.dart';

class TaskDatabase {
  factory TaskDatabase() => _instance;

  TaskDatabase._();

  static final TaskDatabase _instance = TaskDatabase._();

  final _tableName = "tasks";

  Future<void> createTable(Database database) async {
    final createdDB = await database.execute("""
      CREATE TABLE IF NOT EXISTS $_tableName(
      "id" INTEGER PRIMARY KEY,
      "todo" TEXT NOT NULL,
      "completed" INTEGER NOT NULL
      ");
      """);

    return createdDB;
  }

  Future<void> cacheTasks(List<Task> tasks) async {
    final db = await DatabaseService().database;

    // Delete all records from the table before inserting the new tasks
    await db.delete(_tableName);

    for (final task in tasks) {
      await db.insert(
        _tableName,
        task.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<int> addTask(Task task) async {
    final db = await DatabaseService().database;
    final id = await db.insert(
      _tableName,
      task.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<int> updateTask(Task task) async {
    final db = await DatabaseService().database;
    final id = await db.update(
      _tableName,
      task.toJson(),
      where: 'id = ?',
      whereArgs: [task.id],
      conflictAlgorithm: ConflictAlgorithm.rollback,
    );
    return id;
  }

  Future<int> deleteTask(Task task) async {
    final db = await DatabaseService().database;
    final id = await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [task.id],
    );
    return id;
  }

  Future<List<Task>> getAllTasks() async {
    final db = await DatabaseService().database;

    final List<JSON> maps = await db.query(_tableName);

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(
      maps.length,
      (index) => Task.fromJson(
        maps[index],
      ),
    );
  }
}
