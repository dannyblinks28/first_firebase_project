import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

import 'crud_exceptions.dart';

class PrivateNoteService {
  Database? _db;

  List<DataBasePrivateNote> _notes = [];

  final _privateNotesStreamController =
      StreamController<List<DataBasePrivateNote>>.broadcast();

  //to get all notes in noteService
  Stream<List<DataBasePrivateNote>> get allPrivateNotes =>
      _privateNotesStreamController.stream;

//get or create user in note
  Future<DataBaseUser> getOrCreateUser({required String email}) async {
    try {
      final user = await getUser(email: email);
      return user;
    } on CouldNotFindUserExeception {
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  //reading and caching notes
  Future<void> _cachePrivateNotes() async {
    final allPrivateNote = await getAllPrivateNote();
    _notes = allPrivateNote.toList();
    _privateNotesStreamController.add(_notes);
  }

  //updating existing notes
  Future<DataBasePrivateNote> updatePrivateNote(
      {required DataBasePrivateNote note, required String text}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    //make sure note exist
    await getPrivateNote(id: note.id);
    //update database
    final updatesCount = await db.update(noteTable, {
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });
    if (updatesCount == 0) {
      throw CouldNotUpdatePrivateNoteExeception();
    } else {
      final updatedPrivateNote = await getPrivateNote(id: note.id);
      _notes.removeWhere((element) => note.id == updatedPrivateNote.id);
      _notes.add(updatedPrivateNote);
      _privateNotesStreamController.add(_notes);
      return updatedPrivateNote;
    }
  }

  //fetching all the notes
  Future<Iterable<DataBasePrivateNote>> getAllPrivateNote() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);
    return notes.map((noteRow) => DataBasePrivateNote.fromRow(noteRow));
  }

  //fetching a specific note
  Future<DataBasePrivateNote> getPrivateNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (notes.isEmpty) {
      throw CouldNotFindPrivateNoteExeception();
    } else {
      //we create an instance of our databasenote
      final note = DataBasePrivateNote.fromRow(notes.first);
      _notes.removeWhere((note) => note.id == id);
      _notes.add(note);
      _privateNotesStreamController.add(_notes);

      return note;
    }
  }

  //ability to delete all notes
  Future<int> deleteAllPrivateNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletions = await db.delete(noteTable);
    //making sure our local cache is deleted
    _notes = [];
    //also making sure that the UI of our class is updated
    _privateNotesStreamController.add(_notes);

    return numberOfDeletions;
  }

  //notes to be deleted
  Future<void> deletePrivateNote({required int id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteNoteExeception();
    } else {
      //delete note from cache
      _notes.removeWhere((note) => note.id == id);
    }
  }

  //creation of new notes
  Future<DataBasePrivateNote> createPrivateNote(
      {required DataBaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    //make sure owner exist in the database with the correct id
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUserExeception();
    }
    const text = '';
    //create the private note
    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedWithCloudColumn: 1,
    });

    final note = DataBasePrivateNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );

    //after creating notes we add it to our notes and streamcontroller
    _notes.add(note);
    _privateNotesStreamController.add(_notes);

    return note;
  }

  //ability to fetch users
  Future<DataBaseUser> getUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty) {
      throw CouldNotFindUserExeception();
    } else {
      return DataBaseUser.fromRow(results.first);
    }
  }

  //allowing users to be created
  Future<DataBaseUser> createUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExistExeception();
    }

    final userId = await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });

    return DataBaseUser(
      id: userId,
      email: email,
    );
  }

  //allowing users to be deleted
  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeletedUserExeception();
    }
  }

  //getting current database
  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DataBaseIsNotOpenExeception();
    } else {
      return db;
    }
  }

  //close our database
  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DataBaseIsNotOpenExeception();
    } else {
      await db.close();
      _db = null;
    }
  }

  //ensuring our database is open
  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DataBaseAlreadyOpenExeception {}
    //empty
  }

  //open our database
  Future<void> open() async {
    if (_db != null) {
      throw DataBaseAlreadyOpenExeception();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      //create user table
      await db.execute(createUserTable);
      //create note table
      await db.execute(createPrivateNoteTable);
      await _cachePrivateNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }
}

@immutable
class DataBaseUser {
  final int id;
  final String email;

  const DataBaseUser({
    required this.id,
    required this.email,
  });

  DataBaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID = $id, email = $email';

  @override
  bool operator ==(covariant DataBaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DataBasePrivateNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DataBasePrivateNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });
  DataBasePrivateNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Note, ID = $id, userId = $userId, isSyncedWithCloud = $isSyncedWithCloud, text = $text';

  @override
  bool operator ==(covariant DataBasePrivateNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = 'database.db';
const noteTable = 'privateNote';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';
const createUserTable = '''
        CREATE TABLE IF NOT EXISTS "user" (
        "id"	INTEGER NOT NULL,
        "email"	TEXT NOT NULL UNIQUE,
        PRIMARY KEY("id")
        );''';
const createPrivateNoteTable = '''
        CREATE TABLE IF NOT EXISTS "privateNote" (
          "id"	INTEGER NOT NULL,
          "user_id"	INTEGER NOT NULL,
          "text"	TEXT,
          "is_sync_with_cloud"	INTEGER NOT NULL DEFAULT 0,
          PRIMARY KEY("id" AUTOINCREMENT),
          FOREIGN KEY("user_id") REFERENCES "user"("id")
        );''';
