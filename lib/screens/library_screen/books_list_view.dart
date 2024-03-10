import 'dart:convert';

import 'package:book_tracker/const.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/discover_screen/shimmer_effect_builders/grid_view_books_shimmer.dart';
import 'package:book_tracker/screens/library_screen/add_note_view.dart';
import 'package:book_tracker/services/internet_connection_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BooksListView extends ConsumerStatefulWidget {
  const BooksListView({super.key});

  @override
  ConsumerState<BooksListView> createState() => _BooksListViewState();
}

class _BooksListViewState extends ConsumerState<BooksListView> {
  bool isConnected = false;
  bool isLoading = false;
  List<BookWorkEditionsModelEntries>? bookListFromFirebase = [];
  List<BookWorkEditionsModelEntries>? bookListFromSql = [];
  List<BookWorkEditionsModelEntries>? bookListToShow = [];
  List<int>? listOfBookIdsFromSql;

  @override
  void initState() {
    getPageData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Not eklemek istediğin kitabı seç",
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
      body: isLoading == false
          ? bookListToShow!.isNotEmpty
              ? GridView.builder(
                  padding: const EdgeInsets.all(5.0),
                  itemCount: bookListToShow!.length,
                  physics: const ClampingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1,
                      crossAxisSpacing: 25,
                      mainAxisSpacing: 25,
                      mainAxisExtent: 230),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: InkWell(
                        customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddNoteView(
                                    isNavigatingFromNotesView: true,
                                    bookImage: listOfBookIdsFromSql!.contains(
                                                    uniqueIdCreater(
                                                        bookListToShow![
                                                            index])) ==
                                                true &&
                                            bookListToShow![index].covers !=
                                                null
                                        ? Image.memory(
                                            base64Decode(getImageAsByte(
                                                bookListFromSql,
                                                bookListToShow![index])),
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Image.asset(
                                              "lib/assets/images/error.png",
                                            ),
                                          )
                                        : bookListToShow![index].covers !=
                                                    null &&
                                                bookListToShow![index]
                                                        .imageAsByte ==
                                                    null
                                            ? Image.network(
                                                "https://covers.openlibrary.org/b/id/${bookListToShow![index].covers!.first!}-M.jpg",
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    Image.asset(
                                                  "lib/assets/images/error.png",
                                                ),
                                              )
                                            : bookListToShow![index]
                                                        .imageAsByte !=
                                                    null
                                                ? Image.memory(
                                                    base64Decode(
                                                        bookListToShow![index]
                                                            .imageAsByte!),
                                                    width: 90,
                                                    fit: BoxFit.fill,
                                                  )
                                                : null,
                                    showDeleteIcon: false,
                                    bookInfo: bookListToShow![index]),
                              ));
                        },
                        child: Column(children: [
                          Expanded(
                            flex: 15,
                            child: Hero(
                                tag: uniqueIdCreater(bookListToShow![index]),
                                child: Material(
                                  color: Colors.transparent,
                                  child: Ink(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        image: DecorationImage(
                                          fit: BoxFit.fill,
                                          onError: (exception, stackTrace) =>
                                              const AssetImage(
                                                  "lib/assets/images/error.png"),
                                          image: listOfBookIdsFromSql!.contains(
                                                          uniqueIdCreater(
                                                              bookListToShow![
                                                                  index])) ==
                                                      true &&
                                                  bookListToShow![index]
                                                          .covers !=
                                                      null
                                              ? Image.memory(
                                                  base64Decode(getImageAsByte(
                                                      bookListFromSql,
                                                      bookListToShow![index])),
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      Image.asset(
                                                          "lib/assets/images/error.png"),
                                                  fit: BoxFit.fill,
                                                ).image
                                              : bookListToShow![index].covers !=
                                                          null &&
                                                      bookListToShow![index]
                                                              .imageAsByte ==
                                                          null
                                                  ? NetworkImage(
                                                      "https://covers.openlibrary.org/b/id/${bookListToShow![index].covers!.first!}-M.jpg",
                                                    )
                                                  : bookListToShow![index]
                                                              .imageAsByte !=
                                                          null
                                                      ? Image.memory(
                                                          base64Decode(
                                                              bookListToShow![
                                                                      index]
                                                                  .imageAsByte!),
                                                          width: 90,
                                                          fit: BoxFit.fill,
                                                        ).image
                                                      : Image.asset(
                                                          "lib/assets/images/nocover.jpg",
                                                        ).image,
                                        )),
                                    padding: EdgeInsets.zero,
                                  ),
                                )),
                          ),
                          const Spacer(),
                          Expanded(
                            flex: 7,
                            child: SizedBox(
                              width: 200,
                              child: Text(
                                bookListToShow![index].title!,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ]),
                      ),
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
                      const Text(
                        "Şu anda kitaplığınız boş.",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      const Text(
                        "Not eklemek için önce kitap eklemelisiniz.",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      )
                    ],
                  ),
                )
          : gridViewBooksShimmerEffectBuilder(),
    );
  }

  void getPageData() async {
    setState(() {
      isLoading = true;
    });

    await getBooks();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> getBooks() async {
    isConnected = await checkForInternetConnection();
    if (isConnected == true && ref.read(authProvider).currentUser != null) {
      var data = await ref.read(firestoreProvider).getBooks(
          "usersBooks", ref.read(authProvider).currentUser!.uid, context);
      if (data != null) {
        bookListFromFirebase = data.docs
            .map(
              (e) => BookWorkEditionsModelEntries.fromJson(e.data()),
            )
            .toList();

        bookListToShow = bookListFromFirebase;
      }
    }
    bookListFromSql = await ref.read(sqlProvider).getBookShelf(context);
    if (bookListFromSql != null) {
      listOfBookIdsFromSql =
          bookListFromSql!.map((e) => uniqueIdCreater(e)).toList();
    }

    if (bookListFromSql != null) {
      if (bookListFromSql!.length > bookListFromFirebase!.length) {
        bookListToShow = bookListFromSql;
      }
    }
  }
}
