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
import 'package:flutter/services.dart';
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
    print("library screen init çalıştı");

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
            IconButton(
                tooltip: "Notlar",
                splashRadius: 25,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotesView(
                          listOfBooksFromSql: listOfBooksFromSql,
                        ),
                      ));
                },
                icon: Icon(
                  Icons.library_books,
                  size: 30,
                  color: Colors.white,
                )),
            IconButton(
                tooltip: "Kitap Ekle",
                splashRadius: 25,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddBookView(),
                      )).then((value) async => await getPageData());
                },
                icon: Icon(
                  Icons.add_circle,
                  size: 30,
                ))
          ],
          centerTitle: true,
          title: Text(
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
              labelStyle: TextStyle(
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

  GridView tabBarViewItem(
    String bookStatus,
  ) {
    //making a filter list for books(already read, want to read, currently reading)
    List<BookWorkEditionsModelEntries>? listOfTheCurrentBookStatus;
    bookStatus != ""
        ? listOfTheCurrentBookStatus = listOfBooksToShow!
            .where((element) => element.bookStatus == bookStatus)
            .toList()
        : listOfTheCurrentBookStatus = listOfBooksToShow;
    ;

    return bookContentBuilder(listOfTheCurrentBookStatus, bookStatus);
  }

  GridView bookContentBuilder(
      List<BookWorkEditionsModelEntries>? listOfTheCurrentBookStatus,
      String bookStatus) {
    //we create a list of titles from the books coming from sql
    int indexOfMatching = 0;
    List<int> listOfBookIdsFromSql = [];
    listOfBooksFromSql != null
        ? listOfBookIdsFromSql =
            listOfBooksFromSql!.map((e) => uniqueIdCreater(e)).toList()
        : null;

    print("bookContentBuilder çalıştı");

    return GridView.builder(
        physics: ClampingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.6,
          crossAxisSpacing: 25,
          mainAxisSpacing: 25,
        ),
        padding: EdgeInsets.all(20),
        itemBuilder: (context, index) {
          print(listOfTheCurrentBookStatus[index].publishDate);
          //in here we check if the book list from sql has the current book
          indexOfMatching = listOfBookIdsFromSql.indexWhere((element) =>
              element == uniqueIdCreater(listOfTheCurrentBookStatus[index]));
          return InkWell(
            customBorder:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            onTap: () async {
              indexOfMatching = listOfBookIdsFromSql.indexWhere((element) =>
                  element ==
                  uniqueIdCreater(listOfTheCurrentBookStatus[index]));
              print("$indexOfMatching - indexofmatching");

              print(
                  "${uniqueIdCreater(listOfTheCurrentBookStatus[index]) + index}-libraryscreen");
              final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailedEditionInfo(
                        editionInfo: listOfTheCurrentBookStatus[index],
                        isNavigatingFromLibrary: true,
                        bookImage: listOfTheCurrentBookStatus[index].covers !=
                                null
                            ? indexOfMatching != -1
                                ? Image.memory(
                                    base64Decode(
                                        listOfBooksFromSql![indexOfMatching]
                                            .imageAsByte!),
                                    cacheHeight: 270,
                                    cacheWidth: 180,
                                  )
                                : Image.network(
                                    "https://covers.openlibrary.org/b/id/${listOfTheCurrentBookStatus[index].covers!.first!}-M.jpg")
                            : null),
                  ));
              //if there has been a change in the page we have popped we will get all the info again with new values
              if (result == true) {
                getPageData();
              }
            },
            child: Column(children: [
              listOfTheCurrentBookStatus[index].covers != null
                  ? Expanded(
                      flex: 5,
                      child: Card(
                        color: Colors.transparent,
                        elevation: 0,
                        child: listOfTheCurrentBookStatus[index].imageAsByte !=
                                null
                            ? Hero(
                                tag: uniqueIdCreater(
                                    listOfTheCurrentBookStatus[index]),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.memory(
                                    width: 80,
                                    base64Decode(
                                        listOfTheCurrentBookStatus[index]
                                            .imageAsByte!),
                                    fit: BoxFit.fill,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Image.asset(
                                                "lib/assets/images/error.png"),
                                  ),
                                ),
                              )
                            /* if there is a list of books coming from firebase it doesn't
                              have the imageAsByte value and we checked above if the sqlbooklist
                            has the current book if it does
                              ı want to show the book image from local so ı compare 
                            it in here if we have the book in sql show it from local 
                            if it doesn't have it show it from network */
                            : indexOfMatching != -1
                                ? Hero(
                                    tag: uniqueIdCreater(
                                        listOfBooksFromSql![indexOfMatching]),
                                    child: listOfBooksFromSql![indexOfMatching]
                                                .imageAsByte !=
                                            null
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            child: Image.memory(
                                              base64Decode(listOfBooksFromSql![
                                                      indexOfMatching]
                                                  .imageAsByte!),
                                              width: 80,
                                              fit: BoxFit.fill,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Image.asset(
                                                      "lib/assets/images/error.png"),
                                            ),
                                          )
                                        : ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            child: Image.asset(
                                              "lib/assets/images/nocover.jpg",
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
                    )
                  : Expanded(
                      flex: 5,
                      child: Card(
                        color: Colors.transparent,
                        elevation: 0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.asset(
                            "lib/assets/images/nocover.jpg",
                            fit: BoxFit.fill,
                          ),
                        ),
                      )),
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
        itemCount: listOfTheCurrentBookStatus!.length);
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

  Future<void> insertingProcesses() async {
    List<int> listOfBookIdsFromFirebase = [];
    List<int> listOfBookIdsFromSql = [];
    listOfBooksFromFirestore != null
        ? listOfBookIdsFromFirebase =
            listOfBooksFromFirestore!.map((e) => uniqueIdCreater(e)).toList()
        : null;
    listOfBooksFromSql != null
        ? listOfBookIdsFromSql =
            listOfBooksFromSql!.map((e) => uniqueIdCreater(e)).toList()
        : null;

    for (var i = 0; i < listOfBookIdsFromSql.length; i++) {
      if (!listOfBookIdsFromFirebase.contains(listOfBookIdsFromSql[i])) {
        await insertBookToFirebase(listOfBooksFromSql![i]);
      }
    }

    for (var i = 0; i < listOfBookIdsFromFirebase.length; i++) {
      if (!listOfBookIdsFromSql.contains(listOfBookIdsFromFirebase[i])) {
        print("kitap yazdırıldı => no: $i");
        await insertBookToSql(listOfBooksFromFirestore![i]);
      }
    }
  }

  Future<void> insertBookToSql(BookWorkEditionsModelEntries bookInfo) async {
    if (bookInfo.imageAsByte != null) {
      print("ilk if e girdi");
      if (mounted)
        await _sqlHelper.insertBook(bookInfo, bookInfo.bookStatus!,
            base64Decode(bookInfo.imageAsByte!), context);
      await insertAuthor(bookInfo);
    } else if (bookInfo.imageAsByte == null && bookInfo.covers != null) {
      print("ikinci if e girdi");
      String imageLink =
          "https://covers.openlibrary.org/b/id/${bookInfo.covers!.first}-M.jpg";
      final ByteData data =
          await NetworkAssetBundle(Uri.parse(imageLink)).load(imageLink);
      final Uint8List bytes = data.buffer.asUint8List();

      Uint8List imageAsByte = bytes;
      if (mounted)
        await _sqlHelper.insertBook(
            bookInfo, bookInfo.bookStatus!, imageAsByte, context);
      await insertAuthor(bookInfo);
    } else {
      if (mounted)
        await _sqlHelper.insertBook(
            bookInfo, bookInfo.bookStatus!, null, context);
      await insertAuthor(bookInfo);
    }
  }

  Future<void> insertAuthor(BookWorkEditionsModelEntries bookInfo) async {
    if (bookInfo.authorsNames != null) {
      for (var element in bookInfo.authorsNames!) {
        if (mounted)
          await _sqlHelper.insertAuthors(
              element!, uniqueIdCreater(bookInfo), context);
      }
    }
  }

  Future<void> insertBookToFirebase(
      BookWorkEditionsModelEntries bookInfo) async {
    //for uniqueId we are creating a unique int because ı want to avoid duplicates and sqlite only wants an int as id//

    await ref.read(firestoreProvider).setBookData(
          context,
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
            "isbn_13": bookInfo.isbn_13,
            "authorsNames": bookInfo.authorsNames,
            "description": bookInfo.description
          },
          userId: ref.read(authProvider).currentUser!.uid,
        );
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

    await getSqlBookList();
    print("${isConnected}-1");
    isConnected = await checkForInternetConnection();
    print("${isConnected}-2");

    if (isUserAvailable == true && isConnected == true && mounted) {
      await getFirestoreBookList();

      if (mounted)
        setState(() {
          isDataLoading = false;
        });
      await insertingProcesses();
    } else {
      if (mounted)
        setState(() {
          isDataLoading = false;
        });
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
        print("gösterilen kitaplar firestore");
      }
    }
  }

  Future<void> getSqlBookList() async {
    var data = await _sqlHelper.getBookShelf(context);

    listOfBooksFromSql = data;
    print("gösterilen kitaplar sql");
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
          numberOfPages: element.numberOfPages,
          physicalFormat: element.physicalFormat,
          publishDate: element.publishDate,
          publishers: element.publishers,
          title: element.title,
          works: element.works));

      print(authorData);
    }
    listOfBooksToShow = dummyBooks;
  }
}
