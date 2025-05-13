import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/word.dart';
import '../models/test_result.dart';
import '../models/settings.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('english_learning.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE,
        password TEXT,
        displayName TEXT,
        createdAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE words (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        english TEXT,
        chinese TEXT,
        pronunciation TEXT,
        exampleSentence TEXT,
        difficultyLevel TEXT,
        category TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE learning_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        wordId INTEGER,
        learnedAt TEXT,
        FOREIGN KEY (userId) REFERENCES users (id),
        FOREIGN KEY (wordId) REFERENCES words (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE favorite_words (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        wordId INTEGER,
        FOREIGN KEY (userId) REFERENCES users (id),
        FOREIGN KEY (wordId) REFERENCES words (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE test_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        testDate TEXT,
        score INTEGER,
        totalQuestions INTEGER,
        testType TEXT,
        difficultyLevel TEXT,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE user_settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER UNIQUE,
        dailyGoal INTEGER DEFAULT 10,
        notificationEnabled INTEGER DEFAULT 0,
        darkMode INTEGER DEFAULT 0,
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    await _insertSampleWords(db);
  }

  Future<void> _insertSampleWords(Database db) async {
    final words = [
      {
        'english': 'apple',
        'chinese': '苹果',
        'pronunciation': '/ˈæp.əl/',
        'exampleSentence': 'I eat an apple every day.',
        'difficultyLevel': 'beginner',
        'category': 'food'
      },
      {
        'english': 'banana',
        'chinese': '香蕉',
        'pronunciation': '/bəˈnɑː.nə/',
        'exampleSentence': 'Monkeys love bananas.',
        'difficultyLevel': 'beginner',
        'category': 'food'
      },
      {
        'english': 'diligent',
        'chinese': '勤奋的',
        'pronunciation': '/ˈdɪl.ɪ.dʒənt/',
        'exampleSentence': 'She is a diligent student.',
        'difficultyLevel': 'intermediate',
        'category': 'adjective'
      },
      {
        'english': 'perseverance',
        'chinese': '毅力',
        'pronunciation': '/ˌpɜː.sɪˈvɪə.rəns/',
        'exampleSentence': 'Success requires perseverance.',
        'difficultyLevel': 'advanced',
        'category': 'noun'
      }
    ];

    for (var word in words) {
      await db.insert('words', word);
    }
  }
}