// lib/data/folder_repository.dart
import 'package:sqflite/sqflite.dart' as sqflite;
import '../models/folder.dart';
import 'database_helper.dart';

class FolderRepository {
  final dbHelper = DatabaseHelper();

  Future<List<Folder>> getAllFolders() async {
    final db = await dbHelper.database;
    final rows = await db.query('folders', orderBy: 'id ASC');
    return rows.map((e) => Folder.fromMap(e)).toList();
  }

  Future<int> countInFolder(int folderId) async {
    final db = await dbHelper.database;
    final r = await db.rawQuery(
      'SELECT COUNT(*) FROM cards WHERE folderId = ?',
      [folderId],
    );
    return sqflite.Sqflite.firstIntValue(r) ?? 0;
  }

  Future<void> updatePreview(int folderId, String previewUrl) async {
    final db = await dbHelper.database;
    await db.update(
      'folders',
      {'previewImage': previewUrl},
      where: 'id = ?',
      whereArgs: [folderId],
    );
  }
}
