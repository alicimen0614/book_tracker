import 'dart:typed_data';

import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sealed_languages/sealed_languages.dart';
import 'package:book_tracker/databases/sql_helper.dart';

enum BookStatus { wantToRead, currentlyReading, alreadyRead }

class DetailedEditionInfo extends ConsumerStatefulWidget {
  DetailedEditionInfo({super.key, required this.editionInfo});

  final BookWorkEditionsModelEntries editionInfo;

  @override
  ConsumerState<DetailedEditionInfo> createState() =>
      _DetailedEditionInfoState();
}

class _DetailedEditionInfoState extends ConsumerState<DetailedEditionInfo> {
  final SqlHelper _sqlHelper = SqlHelper();

  BookStatus bookStatus = BookStatus.wantToRead;

  @override
  Widget build(BuildContext context) {
    print(widget.editionInfo.title.hashCode);
    print(bookStatus);
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 50,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 30,
            )),
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromRGBO(195, 129, 84, 1),
        elevation: 0,
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: const Color.fromRGBO(195, 129, 84, 1),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade900),
                onPressed: () async {
                  await _sqlHelper.deleteDatabasef();
                },
                icon: Icon(Icons.shopping_cart),
                label: Text("Kitapçılar")),
            ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown.shade600),
                onPressed: () async {
                  bookStatusDialog(context);
                },
                icon: Icon(Icons.shelves),
                label: Text("Rafa ekle")),
          ],
        ),
      ),
      backgroundColor: const Color.fromRGBO(195, 129, 84, 1),
      body: Padding(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            widget.editionInfo.covers != null
                ? Align(
                    alignment: Alignment.center,
                    child: Card(
                      elevation: 18,
                      child: Image.network(
                        "https://covers.openlibrary.org/b/id/${widget.editionInfo.covers!.first}-M.jpg",
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset("lib/assets/images/error.png"),
                        height: 200,
                      ),
                    ),
                  )
                : Align(
                    alignment: Alignment.center,
                    child: Image.asset("lib/assets/images/nocover.jpg")),
            SizedBox(
              height: 20,
            ),
            editionInfoBodyBuilder(context)
          ],
        ),
      ),
    );
  }

  Future<dynamic> bookStatusDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Kitaplıktaki durumunu seçiniz.",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    ListTile(
                      title: Text("Okumak istediklerim"),
                      leading: Radio<BookStatus>(
                        value: BookStatus.wantToRead,
                        groupValue: bookStatus,
                        onChanged: (BookStatus? value) {
                          setState(() {
                            bookStatus = value!;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: Text("Şu an okuduklarım"),
                      leading: Radio<BookStatus>(
                        value: BookStatus.currentlyReading,
                        groupValue: bookStatus,
                        onChanged: (BookStatus? value) {
                          setState(() {
                            bookStatus = value!;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: Text("Okuduklarım"),
                      leading: Radio<BookStatus>(
                        value: BookStatus.alreadyRead,
                        groupValue: bookStatus,
                        onChanged: (BookStatus? value) {
                          setState(() {
                            bookStatus = value!;
                          });
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Vazgeç")),
                        TextButton(
                            onPressed: () async {
                              if (widget.editionInfo.covers != null) {
                                Uint8List? base64AsString = await readNetworkImage(
                                    "https://covers.openlibrary.org/b/id/${widget.editionInfo.covers!.first}-M.jpg");
                                await insertToSqlDatabase(
                                    base64AsString, context);
                                if (ref.read(authProvider).currentUser !=
                                    null) {
                                  await insertToFirestore();
                                }
                              } else {
                                await insertToSqlDatabase(null, context);
                                if (ref.read(authProvider).currentUser !=
                                    null) {
                                  await insertToFirestore();
                                }
                              }

                              Navigator.pop(context);
                            },
                            child: const Text("Onayla"))
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> insertToFirestore() {
    BookWorkEditionsModelEntries editionInfo = widget.editionInfo;

    //for uniqueId we are creating a unique int because ı want to avoid duplicates and sqlite only wants an int as id//
    int uniqueId;
    if (editionInfo.isbn_10 != null &&
        int.tryParse(editionInfo.isbn_10!.first!) != null) {
      uniqueId = int.parse(editionInfo.isbn_10!.first!);
    } else if (editionInfo.isbn_13 != null &&
        int.tryParse(editionInfo.isbn_13!.first!) != null) {
      uniqueId = int.parse(editionInfo.isbn_13!.first!);
    } else if (editionInfo.publishers != null) {
      uniqueId = int.parse(
          "${editionInfo.title.hashCode}${editionInfo.publishers!.first.hashCode}");
    } else {
      uniqueId = int.parse("${editionInfo.title.hashCode}");
    }

    return ref.read(firestoreProvider).setBookData(
        collectionPath: "usersBooks",
        bookAsMap: {
          "title": editionInfo.title,
          "numberOfPages": editionInfo.numberOfPages,
          "covers": editionInfo.covers,
          "bookStatus": bookStatus == BookStatus.alreadyRead
              ? "Okuduklarım"
              : bookStatus == BookStatus.currentlyReading
                  ? "Şu an okuduklarım"
                  : "Okumak istediklerim",
          "publishers": editionInfo.publishers,
          "physicalFormat": editionInfo.physicalFormat,
          "publishDate": editionInfo.publishDate,
          "isbn_10": editionInfo.isbn_10,
          "isbn_13": editionInfo.isbn_13
        },
        userId: ref.read(authProvider).currentUser!.uid,
        uniqueBookId: uniqueId);
  }

  Future<void> insertToSqlDatabase(
      Uint8List? base64AsString, BuildContext context) async {
    await _sqlHelper
        .insertBook(
            widget.editionInfo,
            bookStatus == BookStatus.alreadyRead
                ? "Okuduklarım"
                : bookStatus == BookStatus.currentlyReading
                    ? "Şu an okuduklarım"
                    : "Okumak istediklerim",
            base64AsString)
        .whenComplete(() => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: Duration(seconds: 1),
              content: const Text('Kitap başarıyla kitaplığına eklendi.'),
              action: SnackBarAction(label: 'Tamam', onPressed: () {}),
              behavior: SnackBarBehavior.floating,
            )));
  }

  Future<Uint8List> readNetworkImage(String imageUrl) async {
    final ByteData data =
        await NetworkAssetBundle(Uri.parse(imageUrl)).load(imageUrl);
    final Uint8List bytes = data.buffer.asUint8List();
    print("abc${bytes}");
    return bytes;
  }

  Expanded editionInfoBodyBuilder(BuildContext context) {
    print(widget.editionInfo.isbn_10);
    return Expanded(
      child: Scrollbar(
        thickness: 2,
        radius: Radius.circular(20),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Başlık",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: MediaQuery.sizeOf(context).width - 40,
                child: Text(
                  widget.editionInfo.title!,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
              if (widget.editionInfo.languages != null)
                SizedBox(
                  height: 20,
                ),
              if (widget.editionInfo.languages != null)
                Text(
                  "Dil",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              if (widget.editionInfo.languages != null)
                SizedBox(
                  height: 20,
                ),
              if (widget.editionInfo.languages != null)
                SizedBox(
                  width: MediaQuery.sizeOf(context).width - 40,
                  child: Text(
                    NaturalLanguage.fromCode(widget
                            .editionInfo.languages!.first!.key!.characters
                            .getRange(11, 14)
                            .toUpperCase()
                            .toString())
                        .name,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              if (widget.editionInfo.numberOfPages != null)
                SizedBox(
                  height: 20,
                ),
              if (widget.editionInfo.numberOfPages != null)
                Text(
                  "Sayfa Sayısı",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              if (widget.editionInfo.numberOfPages != null)
                SizedBox(
                  height: 20,
                ),
              if (widget.editionInfo.numberOfPages != null)
                SizedBox(
                    width: MediaQuery.sizeOf(context).width - 40,
                    child: Text(
                      widget.editionInfo.numberOfPages.toString(),
                      style: const TextStyle(
                          color: Colors.grey, fontStyle: FontStyle.italic),
                    )),
              if (widget.editionInfo.publishers != null)
                SizedBox(
                  height: 20,
                ),
              if (widget.editionInfo.publishers != null)
                Text(
                  "Yayıncı",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              if (widget.editionInfo.publishers != null)
                SizedBox(
                  height: 20,
                ),
              if (widget.editionInfo.publishers != null)
                SizedBox(
                    width: MediaQuery.sizeOf(context).width - 40,
                    child: Text(
                      widget.editionInfo.publishers!.first!,
                      style: const TextStyle(color: Colors.black, fontSize: 15),
                    )),
              if (widget.editionInfo.publishDate != null)
                SizedBox(
                  height: 20,
                ),
              if (widget.editionInfo.publishDate != null)
                Text(
                  "Yayınlanma tarihi",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              if (widget.editionInfo.publishDate != null)
                SizedBox(
                  height: 20,
                ),
              if (widget.editionInfo.publishDate != null)
                SizedBox(
                    width: MediaQuery.sizeOf(context).width - 40,
                    child: Text(
                      widget.editionInfo.publishDate!,
                      style: const TextStyle(color: Colors.black, fontSize: 15),
                    )),
              if (widget.editionInfo.physicalFormat != null)
                SizedBox(
                  height: 20,
                ),
              if (widget.editionInfo.physicalFormat != null)
                Text(
                  "Format",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              if (widget.editionInfo.physicalFormat != null)
                SizedBox(
                  height: 20,
                ),
              if (widget.editionInfo.physicalFormat != null)
                SizedBox(
                  width: MediaQuery.sizeOf(context).width - 40,
                  child: widget.editionInfo.physicalFormat == "paperback"
                      ? Text(
                          "Ciltsiz",
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        )
                      : Text(
                          "Ciltli",
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                ),
              if (widget.editionInfo.isbn_10 != null)
                SizedBox(
                  height: 20,
                ),
              if (widget.editionInfo.isbn_10 != null)
                Text(
                  "isbn 10",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              if (widget.editionInfo.isbn_10 != null)
                SizedBox(
                  height: 20,
                ),
              if (widget.editionInfo.isbn_10 != null)
                SizedBox(
                    width: MediaQuery.sizeOf(context).width - 40,
                    child: Text(
                      widget.editionInfo.isbn_10!.first!,
                      style: const TextStyle(color: Colors.black, fontSize: 15),
                    )),
              if (widget.editionInfo.isbn_13 != null)
                SizedBox(
                  height: 20,
                ),
              if (widget.editionInfo.isbn_13 != null)
                Text(
                  "isbn 13",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              if (widget.editionInfo.isbn_13 != null)
                SizedBox(
                  height: 20,
                ),
              if (widget.editionInfo.isbn_13 != null)
                SizedBox(
                    width: MediaQuery.sizeOf(context).width - 40,
                    child: Text(
                      widget.editionInfo.isbn_13!.first!,
                      style: const TextStyle(color: Colors.black, fontSize: 15),
                    )),
            ],
          ),
        ),
      ),
    );
  }
}
