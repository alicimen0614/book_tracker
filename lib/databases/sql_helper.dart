import 'dart:typed_data';

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
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          'CREATE TABLE bookshelf(id INTEGER PRIMARY KEY, title TEXT, publishDate TEXT, numberOfPages INTEGER, publishers TEXT, physicalFormat TEXT, isbn_10 TEXT, isbn_13 TEXT, covers INTEGER, bookStatus TEXT NOT NULL, imageAsByte BLOB)',
        );
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

  // Define a function that inserts dogs into the database
  Future<void> insertBook(BookWorkEditionsModelEntries bookEditionInfo,
      String bookStatus, Uint8List? imageAsByte) async {
    // Get a reference to the database.
    final db = await _openDatabase();

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'bookshelf',
      {
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
}
