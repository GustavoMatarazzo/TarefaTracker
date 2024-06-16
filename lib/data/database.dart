import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'tasks.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }
  Future<Map<String, dynamic>?> getUserProfile() async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query('user_profile', limit: 1);
    if (result.isNotEmpty) {
      print('retornando$result');
      return result.first;
    }
    print('retornando222$result');

    return null;
  }
  Future<void> updateTaskCompletion(int id, bool isCompleted) async {
    final db = await database;
    await db.update(
      'tasks',
      {'isCompleted': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }



  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE tasks (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      description TEXT,
      dueDate TEXT,
      priority TEXT,
      isCompleted INTEGER DEFAULT 0
    )
  ''');

    await db.execute('''
    CREATE TABLE user_profile (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      goal INTEGER,
      points INTEGER DEFAULT 0
    )
  ''');


    await db.insert('user_profile', {'goal': 0, 'points': 0});
  }



  Future<int> insertTask(Map<String, dynamic> task) async {
    Database db = await database;
    print('taks inserida');
    return await db.insert('tasks', task);
  }

  Future<List<Map<String, dynamic>>> getTasks() async {
    Database db = await database;
    return await db.query('tasks');
  }
  Future<Map<String, dynamic>?> getTask(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> tasks = await db.query('tasks', where: 'id = ?', whereArgs: [id]);
    if (tasks.isNotEmpty) {
      return tasks.first;
    }
    return null;
  }


  Future<int> updateTask(Map<String, dynamic> task, int id) async {
    Database db = await database;
    return await db.update('tasks', task, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteTask(int id) async {
    Database db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
  Future<int> updateUserProfile(Map<String, dynamic> profile) async {
    Database db = await database;
    return await db.update('user_profile', profile, where: 'id = ?', whereArgs: [1]);
  }

  Future<int> incrementUserPoints(int taskId) async {
    Database db = await database;


    List<Map<String, dynamic>> task = await db.query(
      'tasks',
      columns: ['priority'],
      where: 'id = ?',
      whereArgs: [taskId],
    );

    if (task.isEmpty) {
      throw Exception('Task not found');
    }

    String priority = task.first['priority'];
    int points;
    print(priority);
    switch (priority) {
      case 'Alta (30 pts)':
        points = 30;
        break;
      case 'Média (20 pts)':
        points = 20;
        break;
      case 'Baixa (10 pts)':
        points = 10;
        break;
      default:
        points = 0;
    }
    print('pontosadicionados$points');
    return await db.rawUpdate('UPDATE user_profile SET points = points + ? WHERE id = 1', [points]);
  }


}
