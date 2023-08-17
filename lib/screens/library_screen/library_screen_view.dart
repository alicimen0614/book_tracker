import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/screens/discover_screen/detailed_edition_info.dart';
import 'package:flutter/material.dart';
import 'package:book_tracker/databases/sql_helper.dart';

SqlHelper _sqlHelper = SqlHelper();

class LibraryScreenView extends StatelessWidget {
  const LibraryScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    print("screen build çalıştı");
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
            tabBarViewItem(""),
            tabBarViewItem("Okumak istediklerim"),
            tabBarViewItem("Okuduklarım"),
            tabBarViewItem("Şu an okuduklarım")
          ],
        ),
      ),
    );
  }

  Column tabBarViewItem(String bookStatus) {
    return Column(children: [
      SizedBox(
        width: 15,
      ),
      FutureBuilder(
        future: _sqlHelper.getBookShelf(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
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
                    print("${listOfTheCurrentBookStatus[index].imageAsByte}");
                    print(" ${listOfTheCurrentBookStatus[index].title}");
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
                                  child: Image.memory(
                                    listOfTheCurrentBookStatus[index]
                                        .imageAsByte!,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Image.asset(
                                                "lib/assets/images/error.png"),
                                  ),
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
