import 'dart:developer';

import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/discover_screen/detailed_edition_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:book_tracker/databases/sql_helper.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

SqlHelper _sqlHelper = SqlHelper();

class LibraryScreenView extends ConsumerWidget {
  const LibraryScreenView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print("libraryscreen build çalıştı");
    return StreamBuilder<List<BookWorkEditionsModelEntries>>(
        stream: ref.read(authProvider).currentUser != null
            ? ref.read(firestoreProvider).getBookList(
                "usersBooks", ref.read(authProvider).currentUser!.uid)
            : null,
        builder: (context, firestoreSnapshot) {
          if (firestoreSnapshot.hasData) {
            //if there is a user logged in
            return defaultTabControllerBuilder(firestoreSnapshot, ref);
          } else if (firestoreSnapshot.connectionState ==
              ConnectionState.none) {
            //if there is no user logged in
            return defaultTabControllerBuilder(null, ref);
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  DefaultTabController defaultTabControllerBuilder(
      AsyncSnapshot<List<BookWorkEditionsModelEntries>>? firestoreSnapshot,
      WidgetRef ref) {
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
            tabBarViewItem("", firestoreSnapshot ?? null, ref),
            tabBarViewItem("Şu an okuduklarım", firestoreSnapshot ?? null, ref),
            tabBarViewItem(
                "Okumak istediklerim", firestoreSnapshot ?? null, ref),
            tabBarViewItem("Okuduklarım", firestoreSnapshot ?? null, ref),
          ],
        ),
      ),
    );
  }

  Column tabBarViewItem(
      String bookStatus,
      AsyncSnapshot<List<BookWorkEditionsModelEntries>>? firestoreSnapshot,
      WidgetRef ref) {
    return Column(children: [
      SizedBox(
        width: 15,
      ),
      FutureBuilder(
        future: _sqlHelper.getBookShelf(),
        builder: (context, sqlBooksSnapshot) {
          if (sqlBooksSnapshot.hasData) {
            List<BookWorkEditionsModelEntries>?
                bookListFromSqlWithoutImageAsByte = [];
            creatingBookListWithoutImageAsByte(
                sqlBooksSnapshot, bookListFromSqlWithoutImageAsByte);

            //if there are no user available firestoreSnapshot will be null
            if (firestoreSnapshot != null &&
                checkIfEqual(bookListFromSqlWithoutImageAsByte,
                        firestoreSnapshot.data) !=
                    true) {
              insertBooksToFirebase(sqlBooksSnapshot.data!, ref);
            }
            //making a filter list for books(already read, want to read, currently reading)
            List<BookWorkEditionsModelEntries> listOfTheCurrentBookStatus;
            bookStatus != ""
                ? listOfTheCurrentBookStatus = sqlBooksSnapshot.data!
                    .where(
                      (element) => element.bookStatus == bookStatus,
                    )
                    .toList()
                : listOfTheCurrentBookStatus = sqlBooksSnapshot.data!;

            return FutureBuilder(
                future: (firestoreSnapshot != null &&
                        checkIfEqual(bookListFromSqlWithoutImageAsByte,
                                firestoreSnapshot.data) !=
                            true)
                    ? insertBooksToSql(firestoreSnapshot.data!)
                    : null,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    print("${snapshot.connectionState} hasdata");

                    return bookContentBuilder(firestoreSnapshot!.data!);
                    //sent new items if connection state is done
                  } else if (snapshot.connectionState == ConnectionState.none) {
                    print(snapshot.connectionState);
                    return bookContentBuilder(listOfTheCurrentBookStatus);
                  } else {
                    print(snapshot.connectionState);
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                });
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      )
    ]);
  }

  Expanded bookContentBuilder(
      List<BookWorkEditionsModelEntries> listOfTheCurrentBookStatus) {
    return Expanded(
      child: ListView.separated(
          padding: EdgeInsets.all(20),
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailedEditionInfo(
                          editionInfo: listOfTheCurrentBookStatus[index]),
                    ));
              },
              child: Row(children: [
                listOfTheCurrentBookStatus[index].covers != null
                    ? Expanded(
                        child: Card(
                          elevation: 18,
                          child: listOfTheCurrentBookStatus[index]
                                      .imageAsByte !=
                                  null
                              ? Image.memory(
                                  listOfTheCurrentBookStatus[index]
                                      .imageAsByte!,
                                  errorBuilder: (context, error, stackTrace) =>
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
                        child:
                            listOfTheCurrentBookStatus[index].numberOfPages !=
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
          itemCount: listOfTheCurrentBookStatus.length),
    );
  }

  void creatingBookListWithoutImageAsByte(
      AsyncSnapshot<List<BookWorkEditionsModelEntries>> sqlBooksSnapshot,
      List<BookWorkEditionsModelEntries> bookListFromSqlWithoutImageAsByte) {
    for (var element in sqlBooksSnapshot.data!) {
      bookListFromSqlWithoutImageAsByte.add(BookWorkEditionsModelEntries(
          bookStatus: element.bookStatus,
          covers: element.covers,
          isbn_10: element.isbn_10,
          isbn_13: element.isbn_13,
          numberOfPages: element.numberOfPages,
          publishDate: element.publishDate,
          publishers: element.publishers,
          physicalFormat: element.physicalFormat,
          title: element.title));
    }
  }

  bool checkIfEqual(
      List<BookWorkEditionsModelEntries>? bookListFromSqlWithoutImageAsByte,
      List<BookWorkEditionsModelEntries>? firestoreData) {
    List<String?>? titleListFromSqlWithoutImageAsByte;
    List<String?>? firestoreTitleData;
    titleListFromSqlWithoutImageAsByte = bookListFromSqlWithoutImageAsByte!
        .map(
          (element) => element.title,
        )
        .toList();

    firestoreTitleData = firestoreData!
        .map(
          (element) => element.title,
        )
        .toList();

    titleListFromSqlWithoutImageAsByte.sort();
    firestoreTitleData.sort();
    print(listEquals(titleListFromSqlWithoutImageAsByte, firestoreTitleData));

    return listEquals(titleListFromSqlWithoutImageAsByte, firestoreTitleData);
  }

  Future<void> insertBooksToSql(
      List<BookWorkEditionsModelEntries> booksListFromFirebase) async {
    for (var element in booksListFromFirebase) {
      if (element.covers != null) {
        String imageLink =
            "https://covers.openlibrary.org/b/id/${element.covers!.first}-M.jpg";
        final ByteData data =
            await NetworkAssetBundle(Uri.parse(imageLink)).load(imageLink);
        final Uint8List bytes = data.buffer.asUint8List();

        Uint8List imageAsByte = bytes;
        await _sqlHelper.insertBook(element, element.bookStatus!, imageAsByte);
      } else {
        await _sqlHelper.insertBook(element, element.bookStatus!, null);
      }
    }
  }

  void insertBooksToFirebase(
      List<BookWorkEditionsModelEntries> sqlBooksSnapshotData,
      WidgetRef ref) async {
    if (sqlBooksSnapshotData.isNotEmpty) {
      print("database yazdı");
      for (var element in sqlBooksSnapshotData) {
        //for uniqueId we are creating a unique int because ı want to avoid duplicates and sqlite only wants an int as id//
        int uniqueId;
        if (element.isbn_10 != null &&
            int.tryParse(element.isbn_10!.first!) != null) {
          uniqueId = int.parse(element.isbn_10!.first!);
        } else if (element.isbn_13 != null &&
            int.tryParse(element.isbn_13!.first!) != null) {
          uniqueId = int.parse(element.isbn_13!.first!);
        } else if (element.publishers != null) {
          uniqueId = int.parse(
              "${element.title.hashCode}${element.publishers!.first.hashCode}");
        } else {
          uniqueId = int.parse("${element.title.hashCode}");
        }
        await ref.read(firestoreProvider).setBookData(
            collectionPath: "usersBooks",
            bookAsMap: {
              "title": element.title,
              "numberOfPages": element.numberOfPages,
              "covers": element.covers,
              "bookStatus": element.bookStatus,
              "publishers": element.publishers,
              "physicalFormat": element.physicalFormat,
              "publishDate": element.publishDate,
              "isbn_10": element.isbn_10,
              "isbn_13": element.isbn_13
            },
            userId: ref.read(authProvider).currentUser!.uid,
            uniqueBookId: uniqueId);
      }
    }
  }
}
