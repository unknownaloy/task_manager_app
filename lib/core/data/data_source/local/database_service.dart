import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:task_manager_app/core/data/data_source/local/task_database.dart';

class DatabaseService {
  factory DatabaseService() => _instance;

  DatabaseService._();

  static final DatabaseService _instance = DatabaseService._();

  final _version = 1;
  final _dbName = "task.db";

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    final path = await getDatabasesPath();
    return openDatabase(
      join(path, _dbName),
      version: _version,
      onCreate: create,
    );
  }

  Future<void> create(Database db, int version) async {
    await TaskDatabase().createTable(db);
  }
}
