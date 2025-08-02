import 'package:book_tracker/l10n/app_localizations.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<bool> checkIfBookAlreadyExists(String? isbnData,List<BookWorkEditionsModelEntries> listOfBooksFromFirestore,List<BookWorkEditionsModelEntries> listOfBooksFromSql, WidgetRef ref) async {
  if (isbnData == null) return false;


  final firestoreBooks = listOfBooksFromFirestore;
  final sqlBooks = listOfBooksFromSql;


  bool checkIsbn(List<String?>? isbns) => isbns?.isNotEmpty == true && isbns!.first == isbnData;

  final existsInFirestore = firestoreBooks.any(
    (book) => checkIsbn(book.isbn_10) || checkIsbn(book.isbn_13),
  );

  final existsInSql = sqlBooks.any(
    (book) => checkIsbn(book.isbn_10) || checkIsbn(book.isbn_13),
  );

  return existsInFirestore || existsInSql;
}


Future<Uint8List?> readNetworkImage(String imageUrl) async {
    try {
      final ByteData data =
          await NetworkAssetBundle(Uri.parse(imageUrl)).load(imageUrl);
      final Uint8List bytes = data.buffer.asUint8List();
      return bytes;
    } catch (e) {
      return null;
    }
  } 

    Future<void> insertToSqlDatabase(
      Uint8List? imageAsByte, BuildContext context,WidgetRef ref,BookWorkEditionsModelEntries editionInfo,String bookStatus) async {
   

    await ref
        .read(sqlProvider)
        .insertBook(
           editionInfo,bookStatus,
            imageAsByte,
            context)
        .whenComplete(() => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: const Duration(seconds: 1),
              content: Text(
                  AppLocalizations.of(context)!.bookSuccessfullyAddedToLibrary),
              action: SnackBarAction(
                  label: AppLocalizations.of(context)!.okay, onPressed: () {}),
              behavior: SnackBarBehavior.floating,
            )));
  }

  Future<void> insertToFirestore(BookWorkEditionsModelEntries editionInfo,WidgetRef ref,BuildContext context,String bookStatus) async {

    List<int?>? coverList = [];
    editionInfo.covers != null
        ? coverList = [editionInfo.covers!.first]
        : coverList = null;

    return await ref.read(firestoreProvider).setBookData(
          context,
          collectionPath: "usersBooks",
          bookAsMap: {
            "title": editionInfo.title,
            "number_of_pages": editionInfo.number_of_pages,
            "covers": editionInfo.covers != null ? coverList : null,
            "bookStatus": bookStatus,
            "publishers": editionInfo.publishers,
            "physical_format": editionInfo.physical_format,
            "publish_date": editionInfo.publish_date,
            "isbn_10": editionInfo.isbn_10,
            "isbn_13": editionInfo.isbn_13,
            "description": editionInfo.description,
            "languages": editionInfo.languages?.first?.key
          },
          userId: ref.read(authProvider).currentUser!.uid,
        );
  }


