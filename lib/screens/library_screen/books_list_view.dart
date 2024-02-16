import 'dart:convert';

import 'package:book_tracker/const.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/screens/library_screen/add_note_view.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class BooksListView extends StatelessWidget {
  const BooksListView({super.key, required this.bookList});

  final List<BookWorkEditionsModelEntries>? bookList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Not eklemek istediğin kitabı seç",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        leadingWidth: 50,
        leading: IconButton(
            splashRadius: 25,
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_sharp,
              size: 30,
            )),
        automaticallyImplyLeading: false,
      ),
      body: bookList!.length != 0
          ? GridView.builder(
              itemCount: bookList!.length,
              physics: ClampingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 25,
                  mainAxisSpacing: 25,
                  mainAxisExtent: 230),
              padding: EdgeInsets.all(20),
              itemBuilder: (context, index) {
                return InkWell(
                  customBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddNoteView(
                              isNavigatingFromNotesView: true,
                              bookImage: bookList![index].imageAsByte != null
                                  ? Image.memory(
                                      base64Decode(
                                          bookList![index].imageAsByte!),
                                      fit: BoxFit.fill,
                                    )
                                  : bookList![index].covers!.first != null
                                      ? Image.network(
                                          "https://covers.openlibrary.org/b/id/${bookList![index].covers!.first!}-M.jpg")
                                      : null,
                              showDeleteIcon: false,
                              bookInfo: bookList![index]),
                        ));
                  },
                  child: Column(children: [
                    bookList![index].covers != null
                        ? Expanded(
                            flex: 10,
                            child: Hero(
                              tag: uniqueIdCreater(bookList![index]),
                              child: bookList![index].imageAsByte != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.memory(
                                        base64Decode(
                                            bookList![index].imageAsByte!),
                                        errorBuilder: (context, error,
                                                stackTrace) =>
                                            Image.asset(
                                                "lib/assets/images/error.png"),
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: FadeInImage.memoryNetwork(
                                        image:
                                            "https://covers.openlibrary.org/b/id/${bookList![index].covers!.first!}-M.jpg",
                                        placeholder: kTransparentImage,
                                        imageErrorBuilder: (context, error,
                                                stackTrace) =>
                                            Image.asset(
                                                "lib/assets/images/error.png"),
                                      ),
                                    ),
                            ),
                          )
                        : Expanded(
                            flex: 10,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset(
                                    "lib/assets/images/nocover.jpg"))),
                    Spacer(),
                    Expanded(
                      flex: 5,
                      child: SizedBox(
                        width: 200,
                        child: Text(
                          bookList![index].title!,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ]),
                );
              },
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "lib/assets/images/shelves.png",
                    width: MediaQuery.of(context).size.width / 2,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.width / 10,
                  ),
                  Text(
                    "Şu anda kitaplığınız boş.",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    "Not eklemek için önce kitap eklemelisiniz.",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
