import 'dart:typed_data';

import 'package:book_tracker/const.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqlHelper {
  Future<Database> _openDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();

    final database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'bookshelf_database.db'),
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) async {
        // Run the CREATE TABLE statement on the database.
        await db.execute(
          'CREATE TABLE bookshelf(id INTEGER PRIMARY KEY UNIQUE, title TEXT, publishDate TEXT, numberOfPages INTEGER, publishers TEXT, physicalFormat TEXT, isbn_10 TEXT, isbn_13 TEXT, covers INTEGER, bookStatus TEXT NOT NULL, imageAsByte BLOB)',
        );

        await db.execute(
            'CREATE TABLE notes(id INTEGER PRIMARY KEY UNIQUE, bookId INTEGER, note TEXT)');
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
    return database;
  }

  Future<void> deleteDatabasef() async {
    await deleteDatabase(
        join(await getDatabasesPath(), 'bookshelf_database.db'));
  }

  Future<void> insertBook(BookWorkEditionsModelEntries bookEditionInfo,
      String bookStatus, Uint8List? imageAsByte) async {
    print("sql e yazdı");
    print(bookEditionInfo.title);
    // Get a reference to the database.
    final db = await _openDatabase();
    //for uniqueId we are creating a unique int because ı want to avoid duplicates and sqlite only wants an int as id//

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'bookshelf',
      {
        "id": uniqueIdCreater(bookEditionInfo),
        "imageAsByte": imageAsByte,
        "bookStatus": bookStatus,
        "title": bookEditionInfo.title,
        "publishDate": bookEditionInfo.publishDate ?? null,
        "numberOfPages": bookEditionInfo.numberOfPages ?? null,
        "publishers": bookEditionInfo.publishers != null
            ? bookEditionInfo.publishers!.first
            : null,
        "physicalFormat": bookEditionInfo.physicalFormat ?? null,
        "isbn_10": bookEditionInfo.isbn_10 != null
            ? bookEditionInfo.isbn_10!.first
            : null,
        "isbn_13": bookEditionInfo.isbn_13 != null
            ? bookEditionInfo.isbn_13!.first
            : null,
        "covers": bookEditionInfo.covers != null
            ? bookEditionInfo.covers!.first
            : null
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertNoteToBook(String note, int bookId) async {
    print("note a yazdı");

    // Get a reference to the database.
    final db = await _openDatabase();
    //for uniqueId we are creating a unique int because ı want to avoid duplicates and sqlite only wants an int as id//

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'notes',
      {
        "id": bookId + note.hashCode,
        "bookId": bookId,
        "note": note,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print(note);
    print(bookId);
  }

  Future<List<BookWorkEditionsModelEntries>> getBookShelf() async {
    // Get a reference to the database.
    final db = await _openDatabase();

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('bookshelf');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      List<int?>? coverList = [];
      if (maps[i]['covers'] != null) {
        coverList.add(maps[i]['covers']);
      } else {
        coverList = null;
      }
      List<String?>? publisherList = [];
      if (maps[i]['publishers'] != null) {
        publisherList.add(maps[i]['publishers']);
      } else {
        publisherList = null;
      }
      List<String?>? isbn10_List = [];
      if (maps[i]['isbn_10'] != null) {
        isbn10_List.add(maps[i]['isbn_10']);
      } else {
        isbn10_List = null;
      }

      List<String?>? isbn13_List = [];
      if (maps[i]['isbn_13'] != null) {
        isbn13_List.add(maps[i]['isbn_13']);
        ;
      } else {
        isbn13_List = null;
      }

      return BookWorkEditionsModelEntries(
        imageAsByte: maps[i]['imageAsByte'],
        bookStatus: maps[i]['bookStatus'],
        covers: coverList,
        title: maps[i]['title'],
        publishDate: maps[i]['publishDate'],
        numberOfPages: maps[i]['numberOfPages'],
        publishers: publisherList,
        physicalFormat: maps[i]['physicalFormat'],
        isbn_10: isbn10_List,
        isbn_13: isbn13_List,
      );
    });
  }

  Future<List<Map<String, dynamic>>> getNotes() async {
    // Get a reference to the database.
    final db = await _openDatabase();

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('notes');
    print(maps);
    print(List.generate(maps.length, (i) {
      return maps[i]['note'];
    }));

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return maps;
  }

  Future<void> deleteBook(int id) async {
    // Get a reference to the database.
    final db = await _openDatabase();

    // Remove the Dog from the database.
    await db.delete(
      'bookshelf',
      // Use a `where` clause to delete a specific dog.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    ).whenComplete(() => print("sql document deleted"));
  }

  Future<void> deleteNote(int id) async {
    // Get a reference to the database.
    final db = await _openDatabase();

    // Remove the Dog from the database.
    await db.delete(
      'notes',
      // Use a `where` clause to delete a specific dog.
      where: 'id = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    ).whenComplete(() => print("sql document deleted"));
  }

  Future<void> deleteNotesFromBook(int bookId) async {
    // Get a reference to the database.
    final db = await _openDatabase();

    // Remove the Dog from the database.
    await db.delete(
      'notes',
      // Use a `where` clause to delete a specific dog.
      where: 'bookId = ?',
      // Pass the Dog's id as a whereArg to prevent SQL injection.
      whereArgs: [bookId],
    ).whenComplete(() => print("sql document deleted"));
  }
}
