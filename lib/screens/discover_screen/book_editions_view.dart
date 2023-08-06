import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:flutter/material.dart';

class BookEditionsView extends StatelessWidget {
  const BookEditionsView(
      {super.key, required this.editionsList, required this.title});

  final List<BookWorkEditionsModelEntries?>? editionsList;

  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text("$title Baskıları"),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: ListView.separated(
              itemBuilder: (context, index) {
                return InkWell(
                  child: Row(children: [
                    editionsList![index]!.covers != null
                        ? Expanded(
                            child: Image.network(
                              "https://covers.openlibrary.org/b/id/${editionsList![index]!.covers!.first}-M.jpg",
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset("lib/assets/images/error.png"),
                            ),
                          )
                        : Expanded(
                            child:
                                Image.asset("lib/assets/images/nocover.jpg")),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(
                      children: [
                        SizedBox(
                          width: 200,
                          child: Text(
                            editionsList![index]!.title!,
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(
                            width: 200,
                            child: editionsList![index]!.numberOfPages != null
                                ? Text(
                                    editionsList![index]!
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
                            child: editionsList![index]!.publishers != null
                                ? Text(
                                    editionsList![index]!.publishers!.first!,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 15),
                                    textAlign: TextAlign.center,
                                  )
                                : const SizedBox.shrink())
                      ],
                    )
                  ]),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(
                    height: 20,
                  ),
              itemCount: editionsList!.length),
        ),
      ),
    );
  }
}
