import 'dart:developer';

import 'package:book_tracker/const.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/discover_screen/detailed_edition_info.dart';
import 'package:book_tracker/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:book_tracker/databases/sql_helper.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:transparent_image/transparent_image.dart';

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
            IconButton(
                onPressed: () {},
                icon: Image.asset("lib/assets/images/add_book.png"))
          ],
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
            ? GridView.builder(
                padding: EdgeInsets.all(20),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.6,
                    crossAxisSpacing: 25,
                    mainAxisSpacing: 25),
                itemBuilder: (context, index) {
                  return Column(children: [
                    ShimmerWidget.rectangular(width: 75, height: 100),
                    SizedBox(
                      height: 5,
                    ),
                    ShimmerWidget.rectangular(width: 75, height: 10)
                  ]);
                },
              )
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
        physics: BouncingScrollPhysics(),
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
            onTap: () {
              indexOfMatching = listOfBookIdsFromSql.indexWhere((element) =>
                  element ==
                  uniqueIdCreater(listOfTheCurrentBookStatus[index]));
              print("$indexOfMatching - indexofmatching");
              print(listOfBooksFromSql![indexOfMatching].title);
              print(
                  "${uniqueIdCreater(listOfTheCurrentBookStatus[index]) + index}-libraryscreen");
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailedEditionInfo(
                        editionInfo: listOfTheCurrentBookStatus[index],
                        isNavigatingFromLibrary: true,
                        bookImage: listOfTheCurrentBookStatus[index].covers !=
                                null
                            ? indexOfMatching != -1 &&
                                    listOfBooksFromSql![indexOfMatching]
                                            .covers !=
                                        null
                                ? Image.memory(
                                    listOfBooksFromSql![indexOfMatching]
                                        .imageAsByte!,
                                  )
                                : Image.network(
                                    "https://covers.openlibrary.org/b/id/${listOfTheCurrentBookStatus[index].covers!.first!}-M.jpg")
                            : null),
                  ));
            },
            child: Column(children: [
              listOfTheCurrentBookStatus[index].covers != null
                  ? Expanded(
                      flex: 3,
                      child: Card(
                        elevation: 18,
                        child: listOfTheCurrentBookStatus[index].imageAsByte !=
                                null
                            ? Hero(
                                tag: uniqueIdCreater(
                                    listOfTheCurrentBookStatus[index]),
                                child: Image.memory(
                                  listOfTheCurrentBookStatus[index]
                                      .imageAsByte!,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset(
                                          "lib/assets/images/error.png"),
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
                                    placeholderBuilder:
                                        (context, heroSize, child) =>
                                            SizedBox.shrink(),
                                    tag: uniqueIdCreater(
                                        listOfBooksFromSql![indexOfMatching]),
                                    child: Image.memory(
                                      listOfBooksFromSql![indexOfMatching]
                                          .imageAsByte!,
                                      errorBuilder: (context, error,
                                              stackTrace) =>
                                          Image.asset(
                                              "lib/assets/images/error.png"),
                                    ),
                                  )
                                : Hero(
                                    placeholderBuilder:
                                        (context, heroSize, child) =>
                                            SizedBox.shrink(),
                                    tag: uniqueIdCreater(
                                        listOfTheCurrentBookStatus[index]),
                                    child: FadeInImage.memoryNetwork(
                                      image:
                                          "https://covers.openlibrary.org/b/id/${listOfTheCurrentBookStatus[index].covers!.first!}-M.jpg",
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
                    listOfTheCurrentBookStatus[index].title!,
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
        itemCount: listOfTheCurrentBookStatus!.length);
  }

  Future<void> deleteBook(
      List<BookWorkEditionsModelEntries> listOfTheCurrentBookStatus,
      int index) async {
    await _sqlHelper
        .deleteBook(uniqueIdCreater(listOfTheCurrentBookStatus[index]));

    await ref.read(firestoreProvider).deleteDocument(
        referencePath: "usersBooks",
        userId: ref.read(authProvider).currentUser!.uid,
        bookId: uniqueIdCreater(listOfTheCurrentBookStatus[index]).toString());
  }

  Future<bool> checkForInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      print("connected from mobile");
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      print("connected from wifi");
      return true;
    }

    return false;
  }

  Future<void> insertingProcesses(
      List<BookWorkEditionsModelEntries>? listOfBooksFromSql,
      List<BookWorkEditionsModelEntries>? listOfBooksFromFirebase) async {
    List<int> listOfBookIdsFromFirebase = [];
    List<int> listOfBookIdsFromSql = [];
    listOfBooksFromFirebase != null
        ? listOfBookIdsFromFirebase =
            listOfBooksFromFirebase.map((e) => uniqueIdCreater(e)).toList()
        : null;
    listOfBooksFromSql != null
        ? listOfBookIdsFromSql =
            listOfBooksFromSql.map((e) => uniqueIdCreater(e)).toList()
        : null;

    for (var i = 0; i < listOfBookIdsFromSql.length; i++) {
      if (!listOfBookIdsFromFirebase.contains(listOfBookIdsFromSql[i])) {
        await insertBookToFirebase(listOfBooksFromSql![i]);
      }
    }

    for (var i = 0; i < listOfBookIdsFromFirebase.length; i++) {
      if (!listOfBookIdsFromSql.contains(listOfBookIdsFromFirebase[i])) {
        await insertBookToSql(listOfBooksFromFirebase![i]);
      }
    }
  }

  Future<void> insertBookToSql(BookWorkEditionsModelEntries bookInfo) async {
    if (bookInfo.covers != null) {
      String imageLink =
          "https://covers.openlibrary.org/b/id/${bookInfo.covers!.first}-M.jpg";
      final ByteData data =
          await NetworkAssetBundle(Uri.parse(imageLink)).load(imageLink);
      final Uint8List bytes = data.buffer.asUint8List();

      Uint8List imageAsByte = bytes;
      await _sqlHelper.insertBook(bookInfo, bookInfo.bookStatus!, imageAsByte);
    } else {
      await _sqlHelper.insertBook(bookInfo, bookInfo.bookStatus!, null);
    }
    setState(() {});
  }

  Future<void> insertBookToFirebase(
      BookWorkEditionsModelEntries bookInfo) async {
    //for uniqueId we are creating a unique int because ı want to avoid duplicates and sqlite only wants an int as id//

    await ref.read(firestoreProvider).setBookData(
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
          "isbn_13": bookInfo.isbn_13
        },
        userId: ref.read(authProvider).currentUser!.uid,
        uniqueBookId: uniqueIdCreater(bookInfo));
    setState(() {});
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

    checkForInternetConnection().then((internet) {
      print(internet);
      print("$isConnected -1");
      if (internet == true) {
        if (isConnected == false) {
          setState(() {
            isConnected = true;
          });
        }
        print("$isConnected -2");
      } else {
        if (isConnected == true) {
          setState(() {
            isConnected = false;
          });
        }
        print("$isConnected -3");
      }
    });

    await getSqlBookList();

    if (isUserAvailable == true && isConnected == true) {
      await getFirestoreBookList();
      setState(() {
        isDataLoading = false;
      });
      await insertingProcesses(listOfBooksFromSql, listOfBooksFromFirestore);
    } else {
      setState(() {
        isDataLoading = false;
      });
    }
  }

  Future<void> getFirestoreBookList() async {
    var data = await ref
        .read(firestoreProvider)
        .getBooks("usersBooks", ref.read(authProvider).currentUser!.uid);
    print(data.docs[4].data());

    listOfBooksFromFirestore = data.docs
        .map(
          (e) => BookWorkEditionsModelEntries.fromJson(e.data()),
        )
        .toList();
    print(listOfBooksFromFirestore![4].numberOfPages);

    if (listOfBooksFromFirestore!.length >= listOfBooksFromSql!.length) {
      listOfBooksToShow = data.docs
          .map(
            (e) => BookWorkEditionsModelEntries.fromJson(e.data()),
          )
          .toList();
      print("gösterilen kitaplar firestore");
    }
  }

  Future<void> getSqlBookList() async {
    var data = await _sqlHelper.getBookShelf();

    listOfBooksFromSql = data;
    print("gösterilen kitaplar sql");
    listOfBooksToShow = data;
  }
}
