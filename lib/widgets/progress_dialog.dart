import 'dart:convert';

import 'package:book_tracker/const.dart';
import 'package:book_tracker/databases/sql_helper.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/services/auth_service.dart';
import 'package:book_tracker/widgets/animated_percent_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:book_tracker/l10n/app_localizations.dart';
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
  bool didChangeMade = false;

  @override
  void initState() {
    insertingProcesses(
        widget.listOfBooksFromFirestore, widget.listOfBooksFromSql);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        TextButton(
          onPressed: () {
            if (mounted) Navigator.pop(context, didChangeMade);
          },
          child: Text(AppLocalizations.of(context)!.close),
        )
      ],
      title: Text(AppLocalizations.of(context)!.booksSyncing,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(
          children: [
            const SizedBox(
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
        Text(AppLocalizations.of(context)!.pleaseWait),
        const Divider(
          color: Colors.transparent,
          thickness: 0,
        ),
        Text("$currentCount/$currentProcessLength",
            style: const TextStyle(color: Colors.grey)),
        const Divider(
          color: Colors.transparent,
          thickness: 0,
        ),
        Text(currentBookName,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold))
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
          didChangeMade = true;
          if (mounted) {
            setState(() {
              percentage = ((i + 1) * (100 / listOfBooksFromSql.length) / 100);
              currentCount = i + 1;
            });
          }
          if (mounted) {
            await insertBookToFirebase(listOfBooksFromSql[i], context);
          }
        }
      }
      percentage = 0;
      currentCount = 0;
    }
    if (listOfBooksFromFirestore != null) {
      currentProcessLength = listOfBooksFromFirestore.length;
      for (var i = 0; i < listOfBookIdsFromFirebase.length; i++) {
        if (!listOfBookIdsFromSql.contains(listOfBookIdsFromFirebase[i])) {
          didChangeMade = true;

          if (mounted) {
            setState(() {
              percentage =
                  ((i + 1) * (100 / listOfBooksFromFirestore.length) / 100);
              currentBookName = listOfBooksFromFirestore[i].title??"";
              currentCount = i + 1;
            });
          }
          if (mounted) {
            await insertBookToSql(listOfBooksFromFirestore[i], context);
          }
        }
      }
    }

    if (mounted) Navigator.pop(context, didChangeMade);
  }

  Future<void> insertBookToSql(
      BookWorkEditionsModelEntries bookInfo, BuildContext context) async {
    if (bookInfo.imageAsByte != null) {
      await _sqlHelper.insertBook(bookInfo, bookInfo.bookStatus!,
          base64Decode(bookInfo.imageAsByte!), context);
      await insertAuthor(bookInfo, context);
    } else if (bookInfo.imageAsByte == null && bookInfo.covers != null) {
      try {
        String imageLink =
            "https://covers.openlibrary.org/b/id/${bookInfo.covers!.first}-M.jpg";
        final ByteData data =
            await NetworkAssetBundle(Uri.parse(imageLink)).load(imageLink);
        final Uint8List bytes = data.buffer.asUint8List();

        Uint8List imageAsByte = bytes;

        await _sqlHelper.insertBook(
            bookInfo, bookInfo.bookStatus!, imageAsByte, context);
        await insertAuthor(bookInfo, context);
      } catch (e) {}
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
        "number_of_pages": bookInfo.number_of_pages,
        "covers": bookInfo.covers,
        "bookStatus": bookInfo.bookStatus,
        "publishers": bookInfo.publishers,
        "physical_format": bookInfo.physical_format,
        "publish_date": bookInfo.publish_date,
        "isbn_10": bookInfo.isbn_10,
        "isbn_13": bookInfo.isbn_13,
        "authorsNames": bookInfo.authorsNames,
        "description": bookInfo.description,
        "languages": bookInfo.languages?.first?.key
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
