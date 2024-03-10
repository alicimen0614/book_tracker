import 'dart:convert';

import 'package:book_tracker/const.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/discover_screen/detailed_edition_info.dart';
import 'package:book_tracker/screens/library_screen/add_book_view.dart';
import 'package:book_tracker/screens/library_screen/notes_view.dart';
import 'package:book_tracker/services/internet_connection_service.dart';
import 'package:flutter/material.dart';
import 'package:book_tracker/databases/sql_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:transparent_image/transparent_image.dart';

import 'shimmer_effects/library_screen_shimmer.dart';

SqlHelper _sqlHelper = SqlHelper();

class LibraryScreenView extends ConsumerStatefulWidget {
  const LibraryScreenView({super.key});

  @override
  ConsumerState<LibraryScreenView> createState() => _LibraryScreenViewState();
}

class _LibraryScreenViewState extends ConsumerState<LibraryScreenView> {
  bool isDataLoading = false;
  ConnectivityResult connectivityResult = ConnectivityResult.none;
  bool isConnected = false;
  bool isUserAvailable = false;
  List<BookWorkEditionsModelEntries>? listOfBooksFromFirestore = [];
  List<BookWorkEditionsModelEntries>? listOfBooksFromSql = [];
  List<BookWorkEditionsModelEntries>? listOfBooksToShow = [];

  @override
  void initState() {
    getPageData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            isDataLoading == false
                ? IconButton(
                    tooltip: "Notlar",
                    splashRadius: 25,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotesView(
                                bookListFromFirebase: listOfBooksFromFirestore,
                                bookListFromSql: listOfBooksFromSql),
                          ));
                    },
                    icon: const Icon(
                      Icons.library_books,
                      size: 30,
                      color: Colors.white,
                    ))
                : const SizedBox.shrink(),
            IconButton(
                tooltip: "Kitap Ekle",
                splashRadius: 25,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddBookView(),
                      )).then((value) async {
                    if (value == true) await getPageData();
                  });
                },
                icon: const Icon(
                  Icons.add_circle,
                  size: 30,
                ))
          ],
          centerTitle: true,
          title: const Text(
            "Kitaplığım",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
              tabAlignment: TabAlignment.start,
              unselectedLabelColor: Colors.white60,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              isScrollable: true,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: const TextStyle(
                fontSize: 15,
                fontFamily: "Nunito Sans",
                fontWeight: FontWeight.bold,
              ),
              tabs: [
                Tab(
                  text: "Tümü",
                  icon: Image.asset(
                    "lib/assets/images/books.png",
                    height: 30,
                  ),
                ),
                Tab(
                    text: "Şu an okuduklarım",
                    icon: Image.asset(
                      "lib/assets/images/reading.png",
                      height: 30,
                    )),
                Tab(
                    text: "Okumak istediklerim",
                    icon: Image.asset(
                      "lib/assets/images/want_to_read.png",
                      height: 30,
                    )),
                Tab(
                    text: "Okuduklarım",
                    icon: Image.asset(
                      "lib/assets/images/alreadyread.png",
                      height: 30,
                    )),
              ]),
        ),
        body: isDataLoading == true
            ? libraryScreenShimmerEffect()
            : TabBarView(
                children: [
                  tabBarViewItem(
                    "",
                  ),
                  tabBarViewItem("Şu an okuduklarım"),
                  tabBarViewItem("Okumak istediklerim"),
                  tabBarViewItem("Okuduklarım"),
                ],
              ),
      ),
    );
  }

  Widget tabBarViewItem(
    String bookStatus,
  ) {
    //making a filter list for books(already read, want to read, currently reading)
    List<BookWorkEditionsModelEntries>? listOfTheCurrentBookStatus;
    bookStatus != ""
        ? listOfTheCurrentBookStatus = listOfBooksToShow!
            .where((element) => element.bookStatus == bookStatus)
            .toList()
        : listOfTheCurrentBookStatus = listOfBooksToShow;
    // ignore: empty_statements
    ;

    return bookContentBuilder(listOfTheCurrentBookStatus, bookStatus);
  }

  Widget bookContentBuilder(
      List<BookWorkEditionsModelEntries>? listOfTheCurrentBookStatus,
      String bookStatus) {
    //we create a list of ids of the books coming from sql
    List<int> listOfBookIdsFromSql = [];
    listOfBooksFromSql != null
        ? listOfBookIdsFromSql =
            listOfBooksFromSql!.map((e) => uniqueIdCreater(e)).toList()
        : null;

    return listOfTheCurrentBookStatus!.isNotEmpty
        ? GridView.builder(
            physics: const ClampingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.6,
              crossAxisSpacing: 25,
              mainAxisSpacing: 25,
            ),
            padding: const EdgeInsets.all(20),
            itemBuilder: (context, index) {
              return InkWell(
                customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                onTap: () async {
                  final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailedEditionInfo(
                            editionInfo: listOfTheCurrentBookStatus[index],
                            isNavigatingFromLibrary: true,
                            bookImage: listOfBookIdsFromSql.contains(
                                            uniqueIdCreater(
                                                listOfTheCurrentBookStatus[
                                                    index])) ==
                                        true &&
                                    listOfTheCurrentBookStatus[index].covers !=
                                        null
                                ? Image.memory(
                                    width: 80,
                                    base64Decode(getImageAsByte(
                                        listOfBooksFromSql,
                                        listOfTheCurrentBookStatus[index])),
                                    fit: BoxFit.fill,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Image.asset(
                                                "lib/assets/images/error.png"),
                                  )
                                : listOfTheCurrentBookStatus[index].covers !=
                                            null &&
                                        listOfTheCurrentBookStatus[index]
                                                .imageAsByte ==
                                            null
                                    ? Image.network(
                                        "https://covers.openlibrary.org/b/id/${listOfTheCurrentBookStatus[index].covers!.first!}-M.jpg",
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Image.asset(
                                          "lib/assets/images/error.png",
                                        ),
                                      )
                                    : listOfTheCurrentBookStatus[index]
                                                .imageAsByte !=
                                            null
                                        ? Image.memory(
                                            base64Decode(
                                                listOfTheCurrentBookStatus[
                                                        index]
                                                    .imageAsByte!),
                                            width: 90,
                                            fit: BoxFit.fill,
                                          )
                                        : null),
                      ));
                  //if there has been a change in the page we have popped we will get all the info again with new values
                  if (result == true) {
                    getPageData();
                  }
                },
                child: Column(children: [
                  Expanded(
                    flex: 5,
                    child: Card(
                      color: Colors.transparent,
                      elevation: 0,
                      child: listOfTheCurrentBookStatus[index].covers == null &&
                              listOfTheCurrentBookStatus[index].imageAsByte ==
                                  null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.asset(
                                "lib/assets/images/nocover.jpg",
                                fit: BoxFit.fill,
                              ),
                            )
                          /* if there is a list of books coming from firebase it doesn't have the imageAsByte value and
                            we are checking here if the current book exist in sql if it does this means the book has imageAsByte
                            value and I want to show the book image from local so I compare it in here if we have the book in 
                            sql show it from local if it doesn't have it show it from network */
                          : listOfBookIdsFromSql.contains(uniqueIdCreater(
                                          listOfTheCurrentBookStatus[index])) ==
                                      true &&
                                  listOfTheCurrentBookStatus[index].covers !=
                                      null
                              ? Hero(
                                  tag: uniqueIdCreater(
                                      listOfTheCurrentBookStatus[index]),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.memory(
                                      width: 80,
                                      base64Decode(getImageAsByte(
                                          listOfBooksFromSql,
                                          listOfTheCurrentBookStatus[index])),
                                      fit: BoxFit.fill,
                                      errorBuilder: (context, error,
                                              stackTrace) =>
                                          Image.asset(
                                              "lib/assets/images/error.png"),
                                    ),
                                  ),
                                )
                              : listOfTheCurrentBookStatus[index].imageAsByte !=
                                      null
                                  ? Hero(
                                      tag: uniqueIdCreater(
                                          listOfTheCurrentBookStatus[index]),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Image.memory(
                                          base64Decode(
                                              listOfTheCurrentBookStatus[index]
                                                  .imageAsByte!),
                                          width: 90,
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    )
                                  : Hero(
                                      tag: uniqueIdCreater(
                                          listOfTheCurrentBookStatus[index]),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: FadeInImage.memoryNetwork(
                                          width: 80,
                                          image:
                                              "https://covers.openlibrary.org/b/id/${listOfTheCurrentBookStatus[index].covers!.first!}-M.jpg",
                                          placeholder: kTransparentImage,
                                          fit: BoxFit.fill,
                                          imageErrorBuilder: (context, error,
                                                  stackTrace) =>
                                              Image.asset(
                                                  "lib/assets/images/error.png"),
                                        ),
                                      ),
                                    ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      width: 200,
                      child: Text(
                        listOfTheCurrentBookStatus[index].title!,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ]),
              );
            },
            itemCount: listOfTheCurrentBookStatus.length)
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
              ],
            ),
          );
  }

  Future<void> deleteBook(
      List<BookWorkEditionsModelEntries> listOfTheCurrentBookStatus,
      int index) async {
    await _sqlHelper.deleteBook(
        uniqueIdCreater(listOfTheCurrentBookStatus[index]), context);

    await ref.read(firestoreProvider).deleteBook(context,
        referencePath: "usersBooks",
        userId: ref.read(authProvider).currentUser!.uid,
        bookId: uniqueIdCreater(listOfTheCurrentBookStatus[index]).toString());
  }

  Future<void> getPageData() async {
    setState(() {
      isDataLoading = true;
    });

    if (ref.read(authProvider).currentUser != null) {
      isUserAvailable = true;
    } else {
      isUserAvailable = false;
    }
    if (mounted) await getSqlBookList();
    isConnected = await checkForInternetConnection();

    if (isUserAvailable == true && isConnected == true && mounted) {
      await getFirestoreBookList();

      if (mounted) {
        setState(() {
          isDataLoading = false;
        });
      }
      // error handling yap
    } else {
      if (mounted) {
        setState(() {
          isDataLoading = false;
        });
      }
    }
  }

  Future<void> getFirestoreBookList() async {
    var data = await ref.read(firestoreProvider).getBooks(
        "usersBooks", ref.read(authProvider).currentUser!.uid, context);

    if (data != null) {
      listOfBooksFromFirestore = data.docs
          .map(
            (e) => BookWorkEditionsModelEntries.fromJson(e.data()),
          )
          .toList();

      if (listOfBooksFromFirestore!.length > listOfBooksFromSql!.length) {
        listOfBooksToShow = data.docs
            .map(
              (e) => BookWorkEditionsModelEntries.fromJson(e.data()),
            )
            .toList();
      }
    }
  }

  Future<void> getSqlBookList() async {
    var data = await _sqlHelper.getBookShelf(context);

    listOfBooksFromSql = data;
    List<BookWorkEditionsModelEntries>? dummyBooks = [];
    //get authors from sql and insert into booksToShow list
    for (var element in listOfBooksFromSql!) {
      var authorData =
          await _sqlHelper.getAuthors(uniqueIdCreater(element), context);
      dummyBooks.add(BookWorkEditionsModelEntries(
          authorsNames: authorData,
          bookStatus: element.bookStatus,
          covers: element.covers,
          description: element.description,
          imageAsByte: element.imageAsByte,
          isbn_10: element.isbn_10,
          isbn_13: element.isbn_13,
          languages: element.languages,
          number_of_pages: element.number_of_pages,
          physical_format: element.physical_format,
          publish_date: element.publish_date,
          publishers: element.publishers,
          title: element.title,
          works: element.works));
    }
    listOfBooksToShow = dummyBooks;
  }
}
