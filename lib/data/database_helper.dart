import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static const _dbName = 'cards_partb.db';
  static const _dbVersion = 1;
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, _dbName);
    _db = await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
    return _db!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(
      'CREATE TABLE folders(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, previewImage TEXT, createdAt TEXT)',
    );
    await db.execute(
      'CREATE TABLE cards(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, suit TEXT, imageUrl TEXT, imageBytes TEXT, folderId INTEGER, createdAt TEXT, FOREIGN KEY(folderId) REFERENCES folders(id))',
    );
    final suits = ['Hearts', 'Spades', 'Diamonds', 'Clubs'];
    for (var s in suits) {
      await db.insert('folders', {
        'name': s,
        'previewImage': '',
        'createdAt': DateTime.now().toIso8601String(),
      });
    }
  }
}
