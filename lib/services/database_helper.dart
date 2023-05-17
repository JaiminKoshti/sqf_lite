import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqf_lite/models/note_model.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {

  static const int _version = 1;
  static const String _dbName = "Notes.db";

  static Future<Database> _getDB() async {
    return openDatabase(join(await getDatabasesPath(), _dbName),
        onCreate: (db, version) async => await db.execute('''
        CREATE TABLE Note(id INTEGER PRIMARY KEY , title TEXT NOT NULL , description TEXT NOT NULL , name TEXT , imagePath TEXT)
        '''),
        version: _version);
  }

  static Future<int> addNote(Note note) async {
    final db = await _getDB();
    File? _imageFile;

    // Save the image file to local storage
    String? imagePath;
    if (note.imagePath != null && note.imagePath!.isNotEmpty) {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String imageFileName = DateTime.now().millisecondsSinceEpoch.toString();
      final File localImageFile = await _imageFile!.copy('${appDir.path}/$imageFileName');
      imagePath = localImageFile.path;
    }

    // Save the profile details in the database
    final profileMap = note.toJson();
    profileMap['imagePath'] = imagePath;
    await db.insert('profiles', profileMap, conflictAlgorithm: ConflictAlgorithm.replace);

    return await db.insert("Note", note.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> updateNote(Note note) async {
    final db = await _getDB();
    return await db.update("Note", note.toJson(),
        where: 'id = ?',
        whereArgs: [note.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> deleteNote(Note note) async {
    final db = await _getDB();
    return await db.delete("Note", where: 'id = ?', whereArgs: [note.id]);
  }

  static Future<List<Note>?> getAllNotes() async {
    final db = await _getDB();

    final List<Map<String, dynamic>> maps = await db.query("Note");

    if (maps.isEmpty) {
      return null;
    }
    return List.generate(maps.length, (index) => Note.fromJson(maps[index]));
  }
}
