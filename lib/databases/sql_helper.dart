import 'dart:convert';
import 'dart:typed_data';

import 'package:book_tracker/const.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/widgets/error_snack_bar.dart';
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
      // When the database is first created, create a table to store books.
      onCreate: (db, version) async {
        // Run the CREATE TABLE statement on the database.
        await db.execute(
          'CREATE TABLE bookshelf(id INTEGER PRIMARY KEY UNIQUE, title TEXT, publishDate TEXT, numberOfPages INTEGER, publishers TEXT, physicalFormat TEXT, isbn_10 TEXT, isbn_13 TEXT, covers INTEGER, bookStatus TEXT NOT NULL, imageAsByte TEXT, language TEXT, description TEXT)',
        );

        await db.execute(
            'CREATE TABLE notes(id INTEGER PRIMARY KEY UNIQUE, bookId INTEGER, note TEXT, noteDate TEXT)');

        await db.execute(
            'CREATE TABLE authors(id INTEGER PRIMARY KEY UNIQUE,authorName TEXT,bookId INTEGER)');
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
      String bookStatus, Uint8List? imageAsByte, BuildContext context) async {
    try {
      // Get a reference to the database.
      final db = await _openDatabase();
      //for uniqueId we are creating a unique int because ı want to avoid duplicates and sqlite only wants an int as id//

      await db.insert(
        'bookshelf',
        {
          "id": uniqueIdCreater(bookEditionInfo),
          "imageAsByte": imageAsByte != null ? base64Encode(imageAsByte) : null,
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
              : null,
          "language": bookEditionInfo.languages != null
              ? bookEditionInfo.languages!.first!.value
              : null,
          "description": bookEditionInfo.description != null
              ? bookEditionInfo.description
              : null
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      errorSnackBar(context, e.toString(),
          infoMessage: "Kitap yazdırılırken bir hata oluştu");
    }
  }

  Future<void> updateBook(
    int bookId,
    String newBookStatus,
    BuildContext context,
  ) async {
    try {
      // Get a reference to the database.
      final db = await _openDatabase();
      //for uniqueId we are creating a unique int because ı want to avoid duplicates and sqlite only wants an int as id//

      await db.rawUpdate('UPDATE bookshelf SET bookStatus = ? WHERE id = ?',
          ['$newBookStatus', '$bookId']);
      print(await db.rawQuery("SELECT * FROM bookshelf"));
    } catch (e) {
      errorSnackBar(context, e.toString(),
          infoMessage: "Kitap yazdırılırken bir hata oluştu");
    }
  }

  Future<void> insertNoteToBook(
      String note, int bookId, BuildContext context, String noteDate) async {
    try {
      print("not eklenen kitabın id'si $bookId");
      // Get a reference to the database.
      final db = await _openDatabase();

      await db.insert(
        'notes',
        {
          "id": bookId + note.hashCode,
          "bookId": bookId,
          "note": note,
          "noteDate": noteDate
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      errorSnackBar(context, e.toString(),
          infoMessage: "Not yazdırılırken bir hata oluştu");
    }
  }

  Future<void> insertAuthors(
      String authorName, int bookId, BuildContext context) async {
    try {
      // Get a reference to the database.
      final db = await _openDatabase();

      await db.insert(
        'authors',
        {
          "id": bookId + authorName.hashCode,
          "bookId": bookId,
          "authorName": authorName,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      errorSnackBar(
        context,
        e.toString(),
      );
    }
  }

  Future<List<String>?>? getAuthors(int bookId, BuildContext context) async {
    // Get a reference to the database.
    final db = await _openDatabase();

    // Query the table for all the Authors.
    final List<Map<String, dynamic>> maps = await db.query('authors');

    // Convert the List<Map<String, dynamic> into a List<String>.
    List<Map<String, dynamic>> matchedAuthors =
        maps.where((element) => element['bookId'] == bookId).toList();

    return matchedAuthors.map((e) => e['authorName'] as String).toList();
  }

  Future<List<BookWorkEditionsModelEntries>?> getBookShelf(
      BuildContext context) async {
    try {
      // Get a reference to the database.
      final db = await _openDatabase();

      List<BookWorkEditionsModelEntries?>? booksList = [];
      List<BookWorkEditionsModelEntries> booksListReal = [];

      // Query the table for all The Books.
      final List<Map<String, dynamic>> maps = await db.query('bookshelf');
      print(maps);

      // Convert the List<Map<String, dynamic> into a List<BookWorkEditionsModelEntries>.
      booksList = List.generate(maps.length, (i) {
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
            description: maps[i]['description']);
      });

      for (var element in booksList) {
        booksListReal.add(BookWorkEditionsModelEntries(
            imageAsByte: element?.imageAsByte,
            bookStatus: element!.bookStatus,
            covers: element.covers,
            title: element.title,
            publishDate: element.publishDate,
            numberOfPages: element.numberOfPages,
            publishers: element.publishers,
            physicalFormat: element.physicalFormat,
            isbn_10: element.isbn_10,
            isbn_13: element.isbn_13,
            description: element.description,
            authorsNames: await getAuthors(uniqueIdCreater(element), context)));
      }

      return booksListReal;
    } catch (e) {
      errorSnackBar(context, e.toString(),
          infoMessage: "Kitaplar getirilirken bir hata oluştu");
      return null;
    }
  }

  Future<dynamic> getNewStatus(BuildContext context, int bookId) async {
    try {
      // Get a reference to the database.
      final db = await _openDatabase();

      // Query the table for all The Books.
      List<Map<String, Object?>> newStatus = await db
          .rawQuery('SELECT bookStatus FROM bookshelf WHERE id= $bookId');
      print(newStatus);

      return newStatus.first.values.first;
    } catch (e) {
      print(e);
      errorSnackBar(context, e.toString(),
          infoMessage: "Kitaplar getirilirken bir hata oluştu");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>?> getNotes(BuildContext context,
      {int? bookId}) async {
    try {
      // Get a reference to the database.
      final db = await _openDatabase();

      // Query the table for all The Notes.
      final List<Map<String, dynamic>> maps = await db.query('notes');

      print("gelen bookid=$bookId first $maps");
      if (bookId == null) {
        print(maps);
        return maps;
      } else {
        print(maps.where((element) => element['bookId'] == bookId).toList());
        return maps.where((element) => element['bookId'] == bookId).toList();
      }

      // Convert the List<Map<String, dynamic> into a List<Notes>.
    } catch (e) {
      errorSnackBar(context, e.toString(),
          infoMessage: "Notlar getirilirken bir hata oluştu");
      return null;
    }
  }

  Future<void> deleteBook(int id, BuildContext context) async {
    try {
      // Get a reference to the database.
      final db = await _openDatabase();

      // Remove the Book from the database.
      await db.delete(
        'bookshelf',
        // Use a `where` clause to delete a specific book.
        where: 'id = ?',
        // Pass the Book's id as a whereArg to prevent SQL injection.
        whereArgs: [id],
      );
    } catch (e) {
      errorSnackBar(context, e.toString(),
          infoMessage: "Kitap silinirken bir hata oluştu");
    }
  }

  Future<void> deleteNote(int id, BuildContext context) async {
    try {
      // Get a reference to the database.
      final db = await _openDatabase();

      // Remove the Note from the database.
      await db.delete(
        'notes',
        // Use a `where` clause to delete a specific Note.
        where: 'id = ?',
        // Pass the Note's id as a whereArg to prevent SQL injection.
        whereArgs: [id],
      );
    } catch (e) {
      errorSnackBar(context, e.toString(),
          infoMessage: "Not silinirken bir hata oluştu");
    }
  }

  Future<void> deleteAuthors(int bookId) async {
    // Get a reference to the database.
    final db = await _openDatabase();

    // Remove the Author from the database.
    await db.delete(
      'authors',
      // Use a `where` clause to delete a specific Author.
      where: 'bookId = ?',
      // Pass the Author's id as a whereArg to prevent SQL injection.
      whereArgs: [bookId],
    ).whenComplete(() => print("sql document deleted"));
  }

  Future<void> deleteNotesFromBook(int bookId) async {
    // Get a reference to the database.
    final db = await _openDatabase();

    // remove all the notes belong to a specific book by passing bookId as a whereArg.
    await db.delete(
      'notes',
      where: 'bookId = ?',
      whereArgs: [bookId],
    ).whenComplete(() => print("sql document deleted"));
  }
}
