import 'dart:developer';

import 'package:book_tracker/const.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/discover_screen/detailed_edition_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:book_tracker/databases/sql_helper.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

SqlHelper _sqlHelper = SqlHelper();

class LibraryScreenView extends ConsumerStatefulWidget {
  const LibraryScreenView({super.key});

  @override
  ConsumerState<LibraryScreenView> createState() => _LibraryScreenViewState();
}

class _LibraryScreenViewState extends ConsumerState<LibraryScreenView> {
  ConnectivityResult connectivityResult = ConnectivityResult.none;
  bool isConnected = false;

  Future<bool> checkForInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

  @override
  void initState() {
    checkForInternetConnection().then((internet) {
      if (internet == true) {
        if (isConnected == false) {
          setState(() {
            isConnected = true;
          });
        }

        print("$isConnected -1");
      } else {
        if (isConnected == true) {
          setState(() {
            isConnected = false;
          });
        }

        print("$isConnected -2");
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<BookWorkEditionsModelEntries>? listOfBooksFromFirestore = [];
    print("libraryscreen build çalıştı");

    if (ref.read(authProvider).currentUser != null && isConnected != false) {
      print("ilk if e girdi connectivity: $isConnected");
      return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: ref
            .read(firestoreProvider)
            .getBooks("usersBooks", ref.read(authProvider).currentUser!.uid),
        builder: (context, firestoreSnapshot) {
          if (firestoreSnapshot.connectionState == ConnectionState.done) {
            print("firebase futurebuilder girdi");
            listOfBooksFromFirestore = firestoreSnapshot.data!.docs
                .map(
                  (e) => BookWorkEditionsModelEntries.fromJson(e.data()),
                )
                .toList();

            log(" if firebase lenght: ${listOfBooksFromFirestore!.length.toString()}");
            //if there is a user logged in
            return FutureBuilder(
              future: _sqlHelper.getBookShelf(),
              builder: (context, sqlSnapshot) {
                if (sqlSnapshot.connectionState == ConnectionState.done) {
                  print("sql futurebuilder girdi");
                  log(" if sql lenght: ${sqlSnapshot.data!.length.toString()}");
                  return defaultTabControllerBuilder(
                      listOfBooksFromSql: sqlSnapshot.data,
                      listOfBooksFromFirebase: listOfBooksFromFirestore,
                      isUserAvailable: true);
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      );
    } else {
      print("else e girdi connectivity: $isConnected");
      return FutureBuilder(
        future: _sqlHelper.getBookShelf(),
        builder: (context, sqlSnapshot) {
          print("else sql futurebuilder girdi");
          if (sqlSnapshot.connectionState == ConnectionState.done) {
            log(" else sql lenght: ${sqlSnapshot.data!.length.toString()}");
            return defaultTabControllerBuilder(
                listOfBooksFromSql: sqlSnapshot.data, isUserAvailable: false);
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      );
    }
  }

  DefaultTabController defaultTabControllerBuilder(
      {List<BookWorkEditionsModelEntries>? listOfBooksFromFirebase,
      List<BookWorkEditionsModelEntries>? listOfBooksFromSql,
      required isUserAvailable}) {
    List<String?>? listOfBookTitlesFromFirebase = [];
    List<String?>? listOfBookTitlesFromSql = [];
    listOfBooksFromFirebase != null
        ? listOfBookTitlesFromFirebase =
            listOfBooksFromFirebase.map((e) => e.title).toList()
        : null;
    listOfBooksFromSql != null
        ? listOfBookTitlesFromSql =
            listOfBooksFromSql.map((e) => e.title).toList()
        : null;
    if (isUserAvailable == true) {
      insertingProcesses(listOfBookTitlesFromSql, listOfBookTitlesFromFirebase,
          listOfBooksFromSql, listOfBooksFromFirebase);
    }

    return DefaultTabController(
      length: 4,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(195, 129, 84, 1),
          centerTitle: true,
          title: Text("Kitaplığım"),
          bottom: TabBar(
              labelColor: Colors.black87,
              isScrollable: true,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: TextStyle(fontSize: 15),
              tabs: [
                Tab(
                  text: "Tümü",
                ),
                Tab(text: "Şu an okuduklarım"),
                Tab(
                  text: "Okumak istediklerim",
                ),
                Tab(text: "Okuduklarım"),
              ]),
        ),
        body: TabBarView(
          children: [
            tabBarViewItem(
              "",
              listOfBooksFromFirebase,
              listOfBooksFromSql,
            ),
            tabBarViewItem("Şu an okuduklarım", listOfBooksFromFirebase,
                listOfBooksFromSql),
            tabBarViewItem("Okumak istediklerim", listOfBooksFromFirebase,
                listOfBooksFromSql),
            tabBarViewItem(
                "Okuduklarım", listOfBooksFromFirebase, listOfBooksFromSql),
          ],
        ),
      ),
    );
  }

  ListView tabBarViewItem(
    String bookStatus,
    List<BookWorkEditionsModelEntries>? listOfBooksFromFirebase,
    List<BookWorkEditionsModelEntries>? listOfBooksFromSql,
  ) {
    //making a filter list for books(already read, want to read, currently reading)
    List<BookWorkEditionsModelEntries>? listOfTheCurrentBookStatus;
    bookStatus != ""
        ? listOfBooksFromFirebase != null
            ? listOfTheCurrentBookStatus = listOfBooksFromFirebase
                .where((element) => element.bookStatus == bookStatus)
                .toList()
            : listOfTheCurrentBookStatus = listOfBooksFromSql!
                .where(
                  (element) => element.bookStatus == bookStatus,
                )
                .toList()
        : listOfTheCurrentBookStatus =
            listOfBooksFromFirebase ?? listOfBooksFromSql;
    ;

    return bookContentBuilder(listOfTheCurrentBookStatus, listOfBooksFromSql);
  }

  ListView bookContentBuilder(
    List<BookWorkEditionsModelEntries>? listOfTheCurrentBookStatus,
    List<BookWorkEditionsModelEntries>? listOfBooksFromSql,
  ) {
    //we create a list of titles from the books coming from sql
    int indexOfMatching = 0;
    List<String?>? listOfBookTitlesFromSql = [];
    listOfBooksFromSql != null
        ? listOfBookTitlesFromSql =
            listOfBooksFromSql.map((e) => e.title).toList()
        : null;

    print("bookContentBuilder çalıştı");

    return ListView.separated(
        padding: EdgeInsets.all(20),
        itemBuilder: (context, index) {
          //in here we check if the book list from sql has the current book
          indexOfMatching = listOfBookTitlesFromSql!.indexWhere(
              (element) => element == listOfTheCurrentBookStatus[index].title);
          return InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailedEditionInfo(
                        editionInfo: listOfTheCurrentBookStatus[index]),
                  ));
            },
            onLongPress: () async {
              await deleteBook(listOfTheCurrentBookStatus, index)
                  .whenComplete(() {
                setState(() {});
              });
            },
            child: Row(children: [
              listOfTheCurrentBookStatus[index].covers != null
                  ? Expanded(
                      child: Card(
                        elevation: 18,
                        child: listOfTheCurrentBookStatus[index].imageAsByte !=
                                null
                            ? Image.memory(
                                listOfTheCurrentBookStatus[index].imageAsByte!,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset("lib/assets/images/error.png"),
                              )
                            /* if there is a list of books coming from firebase it doesn't
                              have the imageAsByte value and we checked above if the sqlbooklist
                            has the current book if it does
                              ı want to show the book image from local so ı compare 
                            it in here if we have the book in sql show it from local 
                            if it doesn't have it show it from network */
                            : indexOfMatching != -1
                                ? Image.memory(
                                    listOfBooksFromSql![indexOfMatching]
                                        .imageAsByte!,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Image.asset(
                                                "lib/assets/images/error.png"),
                                  )
                                : Image.network(
                                    "https://covers.openlibrary.org/b/id/${listOfTheCurrentBookStatus[index].covers!.first!}-M.jpg"),
                      ),
                    )
                  : Expanded(
                      child: Image.asset("lib/assets/images/nocover.jpg")),
              const SizedBox(
                width: 10,
              ),
              Column(
                children: [
                  SizedBox(
                    width: 200,
                    child: Text(
                      listOfTheCurrentBookStatus[index].title!,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                      width: 200,
                      child: listOfTheCurrentBookStatus[index].numberOfPages !=
                              null
                          ? Text(
                              listOfTheCurrentBookStatus[index]
                                  .numberOfPages
                                  .toString(),
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic),
                              textAlign: TextAlign.center,
                            )
                          : SizedBox.shrink()),
                  SizedBox(
                      width: 150,
                      child:
                          listOfTheCurrentBookStatus[index].publishers != null
                              ? Text(
                                  listOfTheCurrentBookStatus[index]
                                      .publishers!
                                      .first!,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 15),
                                  textAlign: TextAlign.center,
                                )
                              : const SizedBox.shrink()),
                  SizedBox(
                      width: 200,
                      child: Text(
                        listOfTheCurrentBookStatus[index].bookStatus!,
                        style: const TextStyle(
                            color: Colors.white,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ))
                ],
              )
            ]),
          );
        },
        separatorBuilder: (context, index) => Divider(),
        itemCount: listOfTheCurrentBookStatus!.length);
  }

  Future<void> deleteBook(
      List<BookWorkEditionsModelEntries> listOfTheCurrentBookStatus,
      int index) async {
    await _sqlHelper
        .deleteBook(uniqueIdCreater(listOfTheCurrentBookStatus[index]));

    await ref.read(firestoreProvider).deleteDocument(
        referencePath: "usersBooks",
        userId: ref.read(authProvider).currentUser!.uid,
        bookId: uniqueIdCreater(listOfTheCurrentBookStatus[index]).toString());
  }

  Future<void> insertingProcesses(
      List<String?> listOfBookTitlesFromSql,
      List<String?> listOfBookTitlesFromFirebase,
      List<BookWorkEditionsModelEntries>? listOfBooksFromSql,
      List<BookWorkEditionsModelEntries>? listOfBooksFromFirebase) async {
    for (var i = 0; i < listOfBookTitlesFromSql.length; i++) {
      if (!listOfBookTitlesFromFirebase.contains(listOfBookTitlesFromSql[i])) {
        await insertBookToFirebase(listOfBooksFromSql![i]);
      }
    }

    for (var i = 0; i < listOfBookTitlesFromFirebase.length; i++) {
      if (!listOfBookTitlesFromSql.contains(listOfBookTitlesFromFirebase[i])) {
        await insertBookToSql(listOfBooksFromFirebase![i]);
      }
    }
  }

  Future<void> insertBookToSql(BookWorkEditionsModelEntries bookInfo) async {
    if (bookInfo.covers != null) {
      String imageLink =
          "https://covers.openlibrary.org/b/id/${bookInfo.covers!.first}-M.jpg";
      final ByteData data =
          await NetworkAssetBundle(Uri.parse(imageLink)).load(imageLink);
      final Uint8List bytes = data.buffer.asUint8List();

      Uint8List imageAsByte = bytes;
      await _sqlHelper.insertBook(bookInfo, bookInfo.bookStatus!, imageAsByte);
    } else {
      await _sqlHelper.insertBook(bookInfo, bookInfo.bookStatus!, null);
    }
  }

  Future<void> insertBookToFirebase(
      BookWorkEditionsModelEntries bookInfo) async {
    //for uniqueId we are creating a unique int because ı want to avoid duplicates and sqlite only wants an int as id//

    await ref.read(firestoreProvider).setBookData(
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
          "isbn_13": bookInfo.isbn_13
        },
        userId: ref.read(authProvider).currentUser!.uid,
        uniqueBookId: uniqueIdCreater(bookInfo));
  }
}
