import 'dart:convert';

import 'package:book_tracker/const.dart';
import 'package:book_tracker/databases/sql_helper.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/services/auth_service.dart';
import 'package:book_tracker/widgets/animated_percent_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../databases/firestore_database.dart';

enum CurrentProcess { InsertingToFirebase, InsertingToSql }

SqlHelper _sqlHelper = SqlHelper();
FirestoreDatabase _firestoreDatabase = FirestoreDatabase();
AuthService _authProvider = AuthService();

class ProgressDialog extends StatefulWidget {
  const ProgressDialog(
      {super.key,
      required this.listOfBooksFromFirestore,
      required this.listOfBooksFromSql});

  final List<BookWorkEditionsModelEntries> listOfBooksFromFirestore;
  final List<BookWorkEditionsModelEntries> listOfBooksFromSql;

  @override
  State<ProgressDialog> createState() => _ProgressDialogState();
}

class _ProgressDialogState extends State<ProgressDialog> {
  CurrentProcess currentProcess = CurrentProcess.InsertingToSql;
  double percentage = 0.0;
  int currentCount = 0;
  String currentBookName = "";
  int currentProcessLength = 0;

  @override
  void initState() {
    insertingProcesses(
        widget.listOfBooksFromFirestore, widget.listOfBooksFromSql);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(percentage);
    return AlertDialog(
      title: Text('Kitaplar senkronize ediliyor.',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(
          children: [
            SizedBox(
              width: 50,
            ),
            Image.asset(
              "lib/assets/images/backup.png",
              height: 80,
              width: 200,
            ),
          ],
        ),
        AnimatedPercentIndicator(
          percentage: percentage,
        ),
        Text("Lütfen bekleyiniz."),
        Divider(
          color: Colors.transparent,
          thickness: 0,
        ),
        Text("$currentCount/$currentProcessLength",
            style: TextStyle(color: Colors.grey)),
        Divider(
          color: Colors.transparent,
          thickness: 0,
        ),
        Text("$currentBookName",
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold))
      ]),
    );
  }

  Future<void> insertingProcesses(
      List<BookWorkEditionsModelEntries>? listOfBooksFromFirestore,
      List<BookWorkEditionsModelEntries>? listOfBooksFromSql) async {
    List<int> listOfBookIdsFromFirebase = [];
    List<int> listOfBookIdsFromSql = [];

    listOfBooksFromFirestore != null
        ? listOfBookIdsFromFirebase =
            listOfBooksFromFirestore.map((e) => uniqueIdCreater(e)).toList()
        : null;
    listOfBooksFromSql != null
        ? listOfBookIdsFromSql =
            listOfBooksFromSql.map((e) => uniqueIdCreater(e)).toList()
        : null;
    if (listOfBooksFromSql != null) {
      currentProcessLength = listOfBooksFromSql.length;
      for (var i = 0; i < listOfBookIdsFromSql.length; i++) {
        if (!listOfBookIdsFromFirebase.contains(listOfBookIdsFromSql[i])) {
          if (mounted)
            setState(() {
              percentage = ((i + 1) * (100 / listOfBooksFromSql.length) / 100);
              currentCount = i + 1;
            });
          await insertBookToFirebase(listOfBooksFromSql[i], context);
        }
      }
      percentage = 0;
      currentCount = 0;
    }
    if (listOfBooksFromFirestore != null) {
      currentProcessLength = listOfBooksFromFirestore.length;
      for (var i = 0; i < listOfBookIdsFromFirebase.length; i++) {
        if (!listOfBookIdsFromSql.contains(listOfBookIdsFromFirebase[i])) {
          print("kitap yazdırıldı => no: $i");
          if (mounted)
            setState(() {
              percentage =
                  ((i + 1) * (100 / listOfBooksFromFirestore.length) / 100);
              currentBookName = listOfBooksFromFirestore[i].title!;
              currentCount = i + 1;
              print(((i + 1) * (100 / listOfBookIdsFromFirebase.length) / 100));
            });
          if (mounted)
            await insertBookToSql(listOfBooksFromFirestore[i], context);
        }
      }
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> insertBookToSql(
      BookWorkEditionsModelEntries bookInfo, BuildContext context) async {
    if (bookInfo.imageAsByte != null) {
      print("ilk if e girdi");

      await _sqlHelper.insertBook(bookInfo, bookInfo.bookStatus!,
          base64Decode(bookInfo.imageAsByte!), context);
      await insertAuthor(bookInfo, context);
    } else if (bookInfo.imageAsByte == null && bookInfo.covers != null) {
      print("ikinci if e girdi");
      String imageLink =
          "https://covers.openlibrary.org/b/id/${bookInfo.covers!.first}-M.jpg";
      final ByteData data =
          await NetworkAssetBundle(Uri.parse(imageLink)).load(imageLink);
      final Uint8List bytes = data.buffer.asUint8List();

      Uint8List imageAsByte = bytes;

      await _sqlHelper.insertBook(
          bookInfo, bookInfo.bookStatus!, imageAsByte, context);
      await insertAuthor(bookInfo, context);
    } else {
      await _sqlHelper.insertBook(
          bookInfo, bookInfo.bookStatus!, null, context);
      await insertAuthor(bookInfo, context);
    }
  }

  Future<void> insertBookToFirebase(
      BookWorkEditionsModelEntries bookInfo, BuildContext context) async {
    //for uniqueId we are creating a unique int because ı want to avoid duplicates and sqlite only wants an int as id//

    await _firestoreDatabase.setBookData(
      context,
      collectionPath: "usersBooks",
      bookAsMap: {
        "title": bookInfo.title,
        "numberOfPages": bookInfo.numberOfPages,
        "covers": bookInfo.covers,
        "bookStatus": bookInfo.bookStatus,
        "publishers": bookInfo.publishers,
        "physicalFormat": bookInfo.physicalFormat,
        "publishDate": bookInfo.publishDate,
        "isbn_10": bookInfo.isbn_10,
        "isbn_13": bookInfo.isbn_13,
        "authorsNames": bookInfo.authorsNames,
        "description": bookInfo.description
      },
      userId: _authProvider.currentUser!.uid,
    );
  }

  Future<void> insertAuthor(
      BookWorkEditionsModelEntries bookInfo, BuildContext context) async {
    if (bookInfo.authorsNames != null) {
      for (var element in bookInfo.authorsNames!) {
        await _sqlHelper.insertAuthors(
            element!, uniqueIdCreater(bookInfo), context);
      }
    }
  }
}
