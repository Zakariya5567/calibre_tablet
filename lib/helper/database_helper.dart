import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';
import '../models/file_model.dart';

class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  // Getter to get the database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDb() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'pdf_library.db');

    return await openDatabase(
      path,
      version: 1, // Increment version for schema changes
      onCreate: _onCreate,
    );
  }

  // Create table schema
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE files(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        author TEXT,      
        authorSort TEXT, 
        description TEXT,
        filePath TEXT,   
        fileMetaPath TEXT,
        coverImagePath TEXT,
        publishedDate TEXT,
        readStatus TEXT,
        downloadDate TEXT,
        totalPages INTEGER
      )
    ''');
  }

  // Insert a new file into the database
  Future<void> saveFileToDatabase({
    required String title,
    required String author,
    required String authorSort,
    required String description,
    required String filePath,
    required String fileMetaPath,
    required String coverImagePath, // Changed to store cover image path
    required String publishedDate,
    required String readStatus,
    required String downloadDate,
    required int totalPages,
  }) async {
    final db = await database;

    // Prepare the file data to insert
    Map<String, dynamic> fileData = {
      'title': title,
      'author': author,
      'authorSort': authorSort,
      'description': description,
      'filePath': filePath,
      'fileMetaPath': fileMetaPath,
      'coverImagePath': coverImagePath,
      'publishedDate': publishedDate,
      'readStatus': readStatus,
      'downloadDate': downloadDate,
      'totalPages': totalPages
    };

    // Insert or replace the file record
    await db.insert(
      'files',
      fileData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch all files from the database
  Future<List<FileModel>> fetchFilesFromDatabase({
    required String filterByStatus,
    required String sortOrder,
    required String orderBy,
  }) async {
    final db = await database;

    // Construct the WHERE clause for filtering by read/unread status
    String whereClause = '';
    if (filterByStatus == "1") {
      whereClause = 'readStatus = 1'; // Filter by read
    } else if (filterByStatus == "0") {
      whereClause = 'readStatus = 0'; // Filter by unread
    }

    // Construct the ORDER BY clause for sorting by title or author, ascending/descending
    String orderByClause = sortOrder; // Default sorting by title
    String order = orderBy;
    if (order == "descending") {
      orderByClause = '$orderByClause DESC';
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'files',
      where: whereClause.isNotEmpty ? whereClause : null,
      orderBy:
          orderByClause, // Default ordering by title in ascending/descending
    );

    return List.generate(maps.length, (i) {
      return FileModel.fromMap(maps[i]);
    });
  }

  // Fetch files from the database based on search criteria
  Future<List<FileModel>> fetchSearchFilesFromDatabase(
      {required String searchText,
      required String filterByStatus,
      required String sortOrder,
      required String orderBy}) async {
    final db = await database;

    // Construct the WHERE clause for filtering by search text and read/unread status
    String whereClause = 'title LIKE ?';
    if (filterByStatus == "1") {
      whereClause = '$whereClause AND readStatus = 1'; // Filter by read
    } else if (filterByStatus == "0") {
      whereClause = '$whereClause AND readStatus = 0'; // Filter by unread
    }

    // Construct the ORDER BY clause for sorting by title or author, ascending/descending
    String orderByClause = sortOrder; // Default sorting by title
    String order = orderBy;
    if (order == "descending") {
      orderByClause = '$orderByClause DESC';
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'files',
      where: whereClause,
      whereArgs: ['%$searchText%'], // Search text applied to the title
      orderBy:
          orderByClause, // Default ordering by title in ascending/descending
    );

    return List.generate(maps.length, (i) {
      return FileModel.fromMap(maps[i]);
    });
  }

  // Delete a file by ID
  Future<void> deleteFile(int id) async {
    final db = await database;
    await db.delete(
      'files',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Check if the file already exists in the database
  Future<bool> isFileInDatabase(String filePath) async {
    final db = await database;
    final result = await db.query(
      'files',
      where: 'fileMetaPath = ?',
      whereArgs: [filePath],
    );

    return result.isNotEmpty;
  }

  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('files');
    print('Database cleared: All files have been deleted.');
  }

  Future<void> markBookAsRead(int id) async {
    final db = await database;
    // Update the read_status to "1" (read)
    await db.update(
      'files',
      {'readStatus': "1"}, // Set the read status to "1" (read)
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
