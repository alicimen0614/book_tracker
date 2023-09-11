import 'package:book_tracker/const.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/screens/library_screen/add_note_view.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class BooksListView extends StatelessWidget {
  const BooksListView({super.key, required this.listOfBooksFromSql});

  final List<BookWorkEditionsModelEntries>? listOfBooksFromSql;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Not eklemek istediğin kitabı seç",
            style: TextStyle(fontSize: 18)),
        leadingWidth: 50,
        leading: IconButton(
            splashRadius: 25,
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 30,
            )),
        backgroundColor: const Color.fromRGBO(195, 129, 84, 1),
        automaticallyImplyLeading: false,
      ),
      body: GridView.builder(
        itemCount: listOfBooksFromSql!.length,
        physics: BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.6,
          crossAxisSpacing: 25,
          mainAxisSpacing: 25,
        ),
        padding: EdgeInsets.all(20),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddNoteView(
                        isNavigatingFromNotesView: true,
                        bookImage:
                            listOfBooksFromSql![index].imageAsByte != null
                                ? Image.memory(
                                    listOfBooksFromSql![index].imageAsByte!)
                                : null,
                        showDeleteIcon: false,
                        bookInfo: listOfBooksFromSql![index]),
                  ));
            },
            child: Column(children: [
              listOfBooksFromSql![index].covers != null
                  ? Expanded(
                      flex: 3,
                      child: Hero(
                        tag: uniqueIdCreater(listOfBooksFromSql![index]),
                        child: Card(
                          color: Colors.transparent,
                          elevation: 10,
                          child: listOfBooksFromSql![index].imageAsByte != null
                              ? Image.memory(
                                  listOfBooksFromSql![index].imageAsByte!,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset(
                                          "lib/assets/images/error.png"),
                                )
                              : FadeInImage.memoryNetwork(
                                  image:
                                      "https://covers.openlibrary.org/b/id/${listOfBooksFromSql![index].covers!.first!}-M.jpg",
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
                      flex: 3,
                      child: Image.asset("lib/assets/images/nocover.jpg")),
              Expanded(
                flex: 1,
                child: SizedBox(
                  width: 200,
                  child: Text(
                    listOfBooksFromSql![index].title!,
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
      ),
    );
  }
}
