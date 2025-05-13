import 'package:sqflite/sqflite.dart';
import '../models/user.dart';
import '../models/word.dart';
import '../models/test_result.dart';
import '../models/settings.dart';
import 'database_helper.dart';

class DBOperations {
  final DatabaseHelper dbHelper;

  DBOperations(this.dbHelper);

  // User operations
  Future<int> createUser(AppUser user) async {
    final db = await dbHelper.database;
    return await db.insert('users', user.toMap());
  }

  Future<AppUser?> getUserByEmail(String email) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return AppUser.fromMap(maps.first);
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<List<Word>> getWordsByLevel(String level) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'words',
      where: 'difficultyLevel = ?',
      whereArgs: [level],
    );
    return maps.map((map) => Word.fromMap(map)).toList();
  }

  Future<List<Word>> getAllWords() async {
    final db = await dbHelper.database;
    final maps = await db.query('words');
    return maps.map((map) => Word.fromMap(map)).toList();
  }
  // Learning records
  Future<void> markWordAsLearned(int userId, int wordId) async {
    final db = await dbHelper.database;
    await db.insert('learning_records', {
      'userId': userId,
      'wordId': wordId,
      'learnedAt': DateTime.now().toString(),
    });
  }

  Future<List<Map<String, dynamic>>> getLearningRecords(int userId) async {
    final db = await dbHelper.database;
    return await db.rawQuery('''
      SELECT words.*, learning_records.learnedAt 
      FROM learning_records
      JOIN words ON learning_records.wordId = words.id
      WHERE learning_records.userId = ?
      ORDER BY learning_records.learnedAt DESC
    ''', [userId]);
  }

  Future<List<Map<String, dynamic>>> getTodayLearnedWords(int userId) async {
    final db = await dbHelper.database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    return await db.rawQuery('''
      SELECT words.* 
      FROM learning_records
      JOIN words ON learning_records.wordId = words.id
      WHERE learning_records.userId = ? 
      AND learning_records.learnedAt >= ?
      ORDER BY learning_records.learnedAt DESC
    ''', [userId, startOfDay.toString()]);
  }

  // Favorite words
  Future<void> addToFavorites(int userId, int wordId) async {
    final db = await dbHelper.database;
    await db.insert('favorite_words', {
      'userId': userId,
      'wordId': wordId,
    });
  }

  Future<void> removeFromFavorites(int userId, int wordId) async {
    final db = await dbHelper.database;
    await db.delete(
      'favorite_words',
      where: 'userId = ? AND wordId = ?',
      whereArgs: [userId, wordId],
    );
  }

  Future<bool> isFavorite(int userId, int wordId) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'favorite_words',
      where: 'userId = ? AND wordId = ?',
      whereArgs: [userId, wordId],
    );
    return maps.isNotEmpty;
  }

  // Test results
  Future<int> saveTestResult(TestResult result) async {
    final db = await dbHelper.database;
    return await db.insert('test_results', result.toMap());
  }

  Future<List<Map<String, dynamic>>> getTestHistory(int userId) async {
    final db = await dbHelper.database;
    return await db.query(
      'test_results',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'testDate DESC',
    );
  }

  // Settings
  Future<void> saveUserSettings(UserSettings settings) async {
    final db = await dbHelper.database;
    await db.insert(
      'user_settings',
      settings.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserSettings> getUserSettings(int userId) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'user_settings',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    if (maps.isNotEmpty) {
      return UserSettings.fromMap(maps.first);
    }
    return UserSettings(
      userId: userId,
      dailyGoal: 10,
      notificationEnabled: false,
      darkMode: false,
    );
  }
}