import 'dart:convert';

import 'package:book_tracker/const.dart';
import 'package:book_tracker/models/books_model.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/discover_screen/detailed_edition_info.dart';
import 'package:book_tracker/screens/discover_screen/discover_screen_view.dart';
import 'package:book_tracker/screens/home_screen/home_screen_shimmer/home_screen_shimmer.dart';
import 'package:book_tracker/screens/home_screen/home_screen_shimmer/text_shimmer_effect.dart';
import 'package:book_tracker/screens/library_screen/add_book_view.dart';
import 'package:book_tracker/services/internet_connection_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transparent_image/transparent_image.dart';

class HomeScreenView extends ConsumerStatefulWidget {
  const HomeScreenView({super.key});

  @override
  ConsumerState<HomeScreenView> createState() => _HomeScreenViewState();
}

class _HomeScreenViewState extends ConsumerState<HomeScreenView> {
  final _scrollControllerCurrReading = ScrollController();
  final _scrollControllerWantToRead = ScrollController();
  final _scrollControllerAlrRead = ScrollController();

  bool isLoading = true;
  List<BookWorkEditionsModelEntries>? listOfBooksFromSql = [];
  List<int>? listOfBookIdsFromSql = [];
  List<BookWorkEditionsModelEntries>? listOfBooksFromFirebase = [];
  List<BookWorkEditionsModelEntries>? listOfBooksToShow = [];

  bool isConnected = false;

  FocusNode searchBarFocus = FocusNode();

  List<BookWorkEditionsModelEntries> listOfBooksCurrentlyReading = [];
  List<BookWorkEditionsModelEntries> listOfBooksWantToRead = [];
  List<BookWorkEditionsModelEntries> listOfBooksAlreadyRead = [];

  final TextEditingController _searchBarController = TextEditingController();
  List<BooksModelDocs?>? docs = [];
  List<BookWorkEditionsModelEntries?>? editionList = [];
  String userName = "";

  @override
  void initState() {
    if (ref.read(authProvider).currentUser != null &&
        ref.read(authProvider).currentUser!.displayName != null) {
      userName = ref.read(authProvider).currentUser!.displayName!;
    }
    getPageData();

    super.initState();
  }

  @override
  void dispose() {
    _scrollControllerAlrRead.dispose();
    _scrollControllerCurrReading.dispose();
    _scrollControllerWantToRead.dispose();
    _searchBarController.dispose();
    searchBarFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                appBarBuilder(),
                booksBuilder(
                    listOfBooksCurrentlyReading,
                    listOfBooksCurrentlyReading.isNotEmpty
                        ? "Şu anda ${listOfBooksCurrentlyReading.length} kitap okuyorsunuz."
                        : "Şu anda okuduğunuz kitap bulunmamakta.",
                    listOfBooksCurrentlyReading.length,
                    _scrollControllerCurrReading),
                booksBuilder(
                    listOfBooksWantToRead,
                    listOfBooksWantToRead.isNotEmpty
                        ? "Toplamda ${listOfBooksWantToRead.length} okumak istediğiniz kitap var."
                        : "Şu anda okumak istediğiniz kitap bulunmamakta.",
                    listOfBooksWantToRead.length,
                    _scrollControllerWantToRead),
                booksBuilder(
                    listOfBooksAlreadyRead,
                    listOfBooksAlreadyRead.isNotEmpty
                        ? "Tebrikler toplamda ${listOfBooksAlreadyRead.length} kitap okudunuz."
                        : "Şu anda bitirdiğiniz kitap bulunmamakta.",
                    listOfBooksAlreadyRead.length,
                    _scrollControllerAlrRead)
              ],
            ),
          ),
        ));
  }

  Padding booksBuilder(List<BookWorkEditionsModelEntries> books, String text,
      int lenghtOfBooks, ScrollController scrollController) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: const Color(0xFFF7E6C4)),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isLoading != true
                    ? Expanded(
                        flex: 2,
                        child: FittedBox(
                          child: Text(text,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.height / 50,
                              )),
                        ))
                    : textShimmerEffect(
                        context, MediaQuery.of(context).size.width / 1.2),
                const Spacer(),
                isLoading != true && lenghtOfBooks != 0
                    ? Expanded(
                        flex: 17,
                        child: Scrollbar(
                          thickness: 2,
                          radius: const Radius.circular(20),
                          controller: scrollController,
                          thumbVisibility: true,
                          child: ListView.separated(
                              padding: EdgeInsets.all(5),
                              controller: scrollController,
                              physics: const ClampingScrollPhysics(),
                              separatorBuilder: (context, index) =>
                                  const VerticalDivider(
                                      color: Colors.transparent, thickness: 0),
                              scrollDirection: Axis.horizontal,
                              itemCount: books.length,
                              itemBuilder: (context, index) => SizedBox(
                                    height: 220,
                                    width: 100,
                                    child: InkWell(
                                      onTap: () async {
                                        var data = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DetailedEditionInfo(
                                                      editionInfo: books[index],
                                                      isNavigatingFromLibrary:
                                                          true,
                                                      bookImage: listOfBookIdsFromSql!.contains(
                                                                      uniqueIdCreater(
                                                                          books[
                                                                              index])) ==
                                                                  true &&
                                                              books[index]
                                                                      .covers !=
                                                                  null
                                                          ? Image.memory(
                                                              base64Decode(
                                                                  getImageAsByte(
                                                                      listOfBooksFromSql,
                                                                      books[
                                                                          index])),
                                                              errorBuilder: (context,
                                                                      error,
                                                                      stackTrace) =>
                                                                  Image.asset(
                                                                "lib/assets/images/error.png",
                                                              ),
                                                            )
                                                          : books[index].covers !=
                                                                      null &&
                                                                  books[index]
                                                                          .imageAsByte ==
                                                                      null
                                                              ? Image.network(
                                                                  "https://covers.openlibrary.org/b/id/${books[index].covers!.first!}-M.jpg",
                                                                  errorBuilder: (context,
                                                                          error,
                                                                          stackTrace) =>
                                                                      Image
                                                                          .asset(
                                                                    "lib/assets/images/error.png",
                                                                  ),
                                                                )
                                                              : books[index]
                                                                          .imageAsByte !=
                                                                      null
                                                                  ? Image
                                                                      .memory(
                                                                      base64Decode(
                                                                          books[index]
                                                                              .imageAsByte!),
                                                                      width: 90,
                                                                      fit: BoxFit
                                                                          .fill,
                                                                    )
                                                                  : null),
                                            ));
                                        if (data == true) {
                                          listOfBooksToShow!.clear();
                                          listOfBooksAlreadyRead.clear();
                                          listOfBooksCurrentlyReading.clear();
                                          listOfBooksWantToRead.clear();
                                          await getPageData();
                                        }
                                      },
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Expanded(
                                              flex: 10,
                                              child: books[index].covers ==
                                                          null &&
                                                      books[index]
                                                              .imageAsByte ==
                                                          null
                                                  ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      child: Image.asset(
                                                          width: 90,
                                                          fit: BoxFit.fill,
                                                          "lib/assets/images/nocover.jpg"),
                                                    )
                                                  : books[index].imageAsByte !=
                                                          null
                                                      ? Hero(
                                                          tag: uniqueIdCreater(
                                                              books[index]),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                            child: Image.memory(
                                                              base64Decode(books[
                                                                      index]
                                                                  .imageAsByte!),
                                                              width: 90,
                                                              fit: BoxFit.fill,
                                                            ),
                                                          ),
                                                        )
                                                      : listOfBookIdsFromSql!.contains(
                                                                      uniqueIdCreater(
                                                                          books[
                                                                              index])) ==
                                                                  true &&
                                                              books[index]
                                                                      .covers !=
                                                                  null
                                                          ? Hero(
                                                              tag: uniqueIdCreater(
                                                                  books[index]),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15),
                                                                child: Image
                                                                    .memory(
                                                                  base64Decode(
                                                                      getImageAsByte(
                                                                          listOfBooksFromSql,
                                                                          books[
                                                                              index])),
                                                                  fit: BoxFit
                                                                      .fill,
                                                                  width: 90,
                                                                  errorBuilder: (context,
                                                                          error,
                                                                          stackTrace) =>
                                                                      Image
                                                                          .asset(
                                                                    "lib/assets/images/error.png",
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          : Hero(
                                                              tag: uniqueIdCreater(
                                                                  books[index]),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15),
                                                                child: FadeInImage
                                                                    .memoryNetwork(
                                                                  width: 90,
                                                                  image:
                                                                      "https://covers.openlibrary.org/b/id/${books[index].covers!.first!}-M.jpg",
                                                                  placeholder:
                                                                      kTransparentImage,
                                                                  fit: BoxFit
                                                                      .fill,
                                                                  imageErrorBuilder: (context,
                                                                          error,
                                                                          stackTrace) =>
                                                                      Image.asset(
                                                                          "lib/assets/images/error.png"),
                                                                ),
                                                              ),
                                                            )),
                                          const Spacer(),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              books[index].title!,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height /
                                                          60),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  )),
                        ),
                      )
                    : isLoading == true
                        ? Expanded(
                            flex: 17,
                            child: SizedBox(
                                width: double.infinity,
                                height: 250,
                                child: homeScreenShimmer(context)),
                          )
                        : lenghtOfBooks == 0
                            ? Expanded(
                                flex: 5,
                                child: InkWell(
                                  onTap: () =>
                                      modalBottomSheetBuilderForPopUpMenu(
                                          context),
                                  child: SizedBox(
                                      height:
                                          MediaQuery.sizeOf(context).width / 3,
                                      child: Image.asset(
                                          "lib/assets/images/library.png")),
                                ),
                              )
                            : const SizedBox.shrink(),
                lenghtOfBooks == 0
                    ? const Spacer(
                        flex: 2,
                      )
                    : const SizedBox.shrink()
              ],
            ),
          )),
    );
  }

  SizedBox appBarBuilder() {
    return SizedBox(
      height: 380,
      child: Stack(
        children: [
          Container(
            height: 330,
            decoration: const BoxDecoration(
                color: Color(0xFF1B7695),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(100),
                    bottomRight: Radius.circular(100))),
          ),
          Positioned(
              left: 15,
              top: 60,
              child: FittedBox(
                child: Text(
                  "Merhaba $userName",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.white),
                ),
              )),
          Positioned(
            top: 100,
            left: 15,
            right: 15,
            child: searchBarBuilder(),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height / 4.8,
            left: 15,
            right: 15,
            child: const Text("Bir kitap mı okuyorsun? \nKitap ekle",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.white)),
          ),
          Positioned(
            bottom: 0,
            left: 120,
            right: 100,
            child: Container(
                height: 150,
                decoration: BoxDecoration(
                    image: DecorationImage(
                  image: const AssetImage("lib/assets/images/add_book.png"),
                  onError: (exception, stackTrace) =>
                      const AssetImage("lib/assets/images/error.png"),
                )),
                child: InkWell(
                  onTap: () {
                    modalBottomSheetBuilderForPopUpMenu(context);
                  },
                )),
          )
        ],
      ),
    );
  }

  Row searchBarBuilder() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            focusNode: searchBarFocus,
            cursorColor: Colors.black,
            onEditingComplete: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
              if (_searchBarController.text != "") {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiscoverScreenView(
                          searchValue: _searchBarController.text),
                    ));
              }
            },
            controller: _searchBarController,
            keyboardType: TextInputType.text,
            autocorrect: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(15),
              hintText: "Ara",
              focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0xFF1B7695),
                  ),
                  borderRadius: BorderRadius.circular(15)),
              suffixIcon: IconButton(
                onPressed: () {
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                  if (_searchBarController.text != "") {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DiscoverScreenView(
                              searchValue: _searchBarController.text),
                        )).then((value) => _searchBarController.clear());
                  }
                },
                icon: const Icon(
                  Icons.search,
                  size: 35,
                  color: Color(0xFF1B7695),
                ),
              ),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            ),
          ),
        ),
      ],
    );
  }

  Future getPageData() async {
    setState(() {
      isLoading = true;
    });
    await getFilteredBooks();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> getFilteredBooks() async {
    isConnected = await checkForInternetConnection();
    if (isConnected == true && ref.read(authProvider).currentUser != null) {
      var data = await ref.read(firestoreProvider).getBooks(
          "usersBooks", ref.read(authProvider).currentUser!.uid, context);
      if (data != null) {
        listOfBooksFromFirebase = data.docs
            .map(
              (e) => BookWorkEditionsModelEntries.fromJson(e.data()),
            )
            .toList();

        listOfBooksToShow = listOfBooksFromFirebase;
      }
    }
    listOfBooksFromSql = await ref.read(sqlProvider).getBookShelf(context);
    if (listOfBooksFromSql != null) {
      listOfBookIdsFromSql =
          listOfBooksFromSql!.map((e) => uniqueIdCreater(e)).toList();
    }

    if (listOfBooksFromSql != null) {
      if (listOfBooksFromSql!.length > listOfBooksFromFirebase!.length) {
        listOfBooksToShow = listOfBooksFromSql;
      }
    }

    for (var element in listOfBooksToShow!) {
      if (element.bookStatus == "Şu an okuduklarım") {
        listOfBooksCurrentlyReading.add(element);
      } else if (element.bookStatus == "Okumak istediklerim") {
        listOfBooksWantToRead.add(element);
      } else {
        listOfBooksAlreadyRead.add(element);
      }
    }
  }

  void modalBottomSheetBuilderForPopUpMenu(BuildContext pageContext) {
    showModalBottomSheet(
      backgroundColor: Colors.grey.shade300,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30))),
      context: context,
      builder: (context) {
        return Column(mainAxisSize: MainAxisSize.min, children: [
          const ListTile(
            title: Text("Kitap ekle",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            titleAlignment: ListTileTitleAlignment.center,
          ),
          const Divider(height: 0),
          ListTile(
            visualDensity: const VisualDensity(vertical: 3),
            onTap: () {
              Navigator.pop(context);
              FocusScope.of(pageContext).requestFocus(searchBarFocus);
            },
            leading: const Icon(
              Icons.search,
              size: 30,
            ),
            title: const Text("Arama ile", style: TextStyle(fontSize: 20)),
          ),
          const Divider(height: 0),
          ListTile(
            visualDensity: const VisualDensity(vertical: 3),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddBookView(),
                  )).then((value) async {
                if (value == true) await getPageData();
              });
            },
            leading: const Icon(
              Icons.keyboard,
              size: 30,
            ),
            title: const Text("Kendin ekle", style: TextStyle(fontSize: 20)),
          )
        ]);
      },
    );
  }
}
