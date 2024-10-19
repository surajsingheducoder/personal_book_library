import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/book_model.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('books.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE books (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            author TEXT,
            genre TEXT,
            coverImage TEXT,
            isRead INTEGER,
            userEmail TEXT
          )
        ''');
      },
    );
  }

  Future<void> addBook(BookModel book) async {
    final db = await instance.database;
    await db.insert('books', book.toMap());
  }

  Future<List<BookModel>> getUserBooks(String email) async {
    final db = await instance.database;
    final result = await db.query('books', where: 'userEmail = ?', whereArgs: [email]);
    return result.map((map) => BookModel.fromMap(map)).toList();
  }

  Future<void> updateBook(BookModel book) async {
    final db = await instance.database;
    await db.update('books', book.toMap(), where: 'id = ?', whereArgs: [book.id]);
  }

  Future<void> deleteBook(int id) async {
    final db = await instance.database;
    await db.delete('books', where: 'id = ?', whereArgs: [id]);
  }
}
