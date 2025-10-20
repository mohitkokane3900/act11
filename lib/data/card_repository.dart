import '../models/card_item.dart';
import 'database_helper.dart';

class CardRepository {
  final dbHelper = DatabaseHelper();

  Future<List<CardItem>> getCardsByFolder(int folderId) async {
    final db = await dbHelper.database;
    final rows = await db.query(
      'cards',
      where: 'folderId = ?',
      whereArgs: [folderId],
      orderBy: 'id DESC',
    );
    return rows.map((e) => CardItem.fromMap(e)).toList();
  }

  Future<int> insertCard(CardItem c) async {
    final db = await dbHelper.database;
    return db.insert('cards', c.toMap());
  }

  Future<int> updateCard(CardItem c) async {
    final db = await dbHelper.database;
    return db.update('cards', c.toMap(), where: 'id = ?', whereArgs: [c.id]);
  }

  Future<int> deleteCard(int id) async {
    final db = await dbHelper.database;
    return db.delete('cards', where: 'id = ?', whereArgs: [id]);
  }
}
