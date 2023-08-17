import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/screens/discover_screen/detailed_edition_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookEditionsView extends ConsumerWidget {
  const BookEditionsView(
      {super.key, required this.editionsList, required this.title});

  final List<BookWorkEditionsModelEntries?>? editionsList;

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leadingWidth: 50,
          title: Text("$title Baskıları"),
          leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 30,
              )),
          automaticallyImplyLeading: false,
          backgroundColor: const Color.fromRGBO(195, 129, 84, 1),
          elevation: 5,
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: ListView.separated(
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                print(editionsList![index]!.isbn_10);

                return InkWell(
                  onTap: () {
                    print(editionsList![index]!.physicalFormat);
                    print(editionsList![index]!.publishDate);
                    print(editionsList![index]!.publishers);
                    print(editionsList![index]!.sourceRecords);
                    print(editionsList![index]!.type!.key!);
                    print(editionsList![index]!.works!.first!.key!);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailedEditionInfo(
                              editionInfo: editionsList![index]!),
                        ));
                  },
                  child: Row(children: [
                    editionsList![index]!.covers != null
                        ? Expanded(
                            child: Card(
                              elevation: 18,
                              child: Image.network(
                                "https://covers.openlibrary.org/b/id/${editionsList![index]!.covers!.first}-M.jpg",
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset("lib/assets/images/error.png"),
                              ),
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
