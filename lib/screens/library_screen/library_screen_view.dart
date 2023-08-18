import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/discover_screen/detailed_edition_info.dart';
import 'package:flutter/material.dart';
import 'package:book_tracker/databases/sql_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

SqlHelper _sqlHelper = SqlHelper();

class LibraryScreenView extends ConsumerWidget {
  const LibraryScreenView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print("screen build çalıştı");
    return StreamBuilder<List<BookWorkEditionsModelEntries>>(
        stream: ref.read(authProvider).currentUser != null
            ? ref.read(firestoreProvider).getBookList(
                "usersBooks", ref.read(authProvider).currentUser!.uid)
            : null,
        builder: (context, firestoreSnapshot) {
          if (firestoreSnapshot.hasData) {
            print(firestoreSnapshot.connectionState);
            List<BookWorkEditionsModelEntries> booksList =
                firestoreSnapshot.data!;

            return defaultTabControllerBuilder(firestoreSnapshot, ref);
          } else if (firestoreSnapshot.connectionState ==
              ConnectionState.none) {
            return defaultTabControllerBuilder(null, ref);
          } else {
            print(firestoreSnapshot.connectionState);
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
                Tab(
                  text: "Okumak istediklerim",
                ),
                Tab(text: "Okuduklarım"),
                Tab(text: "Şu an okuduklarım")
              ]),
        ),
        body: TabBarView(
          children: [
            tabBarViewItem("", firestoreSnapshot ?? null, ref),
            tabBarViewItem(
                "Okumak istediklerim", firestoreSnapshot ?? null, ref),
            tabBarViewItem("Okuduklarım", firestoreSnapshot ?? null, ref),
            tabBarViewItem("Şu an okuduklarım", firestoreSnapshot ?? null, ref)
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
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<BookWorkEditionsModelEntries> differenceList = [];
            print(snapshot.data!.isNotEmpty);

            if (firestoreSnapshot != null) {
              if (snapshot.data!.isNotEmpty &&
                  firestoreSnapshot.data!.isEmpty) {
                print(" if girdi");
                differenceList = snapshot.data!;
              }

              if (differenceList.isNotEmpty) {
                print("database yazdı");
                for (var element in differenceList) {
                  ref.read(firestoreProvider).setBookData(
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
                      userId: ref.read(authProvider).currentUser!.uid);
                }
              }
            }

            List<BookWorkEditionsModelEntries> listOfTheCurrentBookStatus;
            bookStatus != ""
                ? listOfTheCurrentBookStatus = snapshot.data!
                    .where(
                      (element) => element.bookStatus == bookStatus,
                    )
                    .toList()
                : listOfTheCurrentBookStatus = snapshot.data!;

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
                                  editionInfo:
                                      listOfTheCurrentBookStatus[index]),
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
                                          errorBuilder: (context, error,
                                                  stackTrace) =>
                                              Image.asset(
                                                  "lib/assets/images/error.png"),
                                        )
                                      : Image.network(
                                          "https://covers.openlibrary.org/b/id/${listOfTheCurrentBookStatus![index]!.covers!.first!}-M.jpg"),
                                ),
                              )
                            : Expanded(
                                child: Image.asset(
                                    "lib/assets/images/nocover.jpg")),
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
                                child: listOfTheCurrentBookStatus[index]
                                            .numberOfPages !=
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
                                child: listOfTheCurrentBookStatus[index]
                                            .publishers !=
                                        null
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
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      )
    ]);
  }
}
