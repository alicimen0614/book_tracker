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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  List<BookWorkEditionsModelEntries>? allBooks = [];
  FocusNode searchBarFocus = FocusNode();

  List<BookWorkEditionsModelEntries> listOfBooksCurrentlyReading = [];
  List<BookWorkEditionsModelEntries> listOfBooksWantToRead = [];
  List<BookWorkEditionsModelEntries> listOfBooksAlreadyRead = [];

  TextEditingController _searchBarController = TextEditingController();
  List<BooksModelDocs?>? docs = [];
  List<BookWorkEditionsModelEntries?>? editionList = [];
  String userName = "Kullanıcı";

  @override
  void initState() {
    print("home screen init çalıştı");
    if (ref.read(authProvider).currentUser != null) {
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
            physics: ClampingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                appBarBuilder(),
                booksBuilder(
                    listOfBooksCurrentlyReading,
                    listOfBooksCurrentlyReading.length != 0
                        ? "Şu anda ${listOfBooksCurrentlyReading.length} kitap okuyorsunuz"
                        : "Şu anda okuduğunuz kitap bulunmamakta.",
                    listOfBooksCurrentlyReading.length,
                    _scrollControllerCurrReading),
                booksBuilder(
                    listOfBooksWantToRead,
                    listOfBooksWantToRead.length != 0
                        ? "Toplamda ${listOfBooksWantToRead.length} okumak istediğiniz kitap var"
                        : "Şu anda okumak istediğiniz kitap bulunmamakta.",
                    listOfBooksWantToRead.length,
                    _scrollControllerWantToRead),
                booksBuilder(
                    listOfBooksAlreadyRead,
                    listOfBooksAlreadyRead.length != 0
                        ? "Tebrikler toplamda ${listOfBooksAlreadyRead.length} kitap okudunuz"
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
      padding: EdgeInsets.all(15),
      child: Container(
          height: 250,
          width: double.infinity,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Color(0xFFF7E6C4)),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isLoading != true
                    ? Expanded(
                        flex: 2,
                        child: Text(text,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            )))
                    : textShimmerEffect(
                        context, MediaQuery.of(context).size.width / 2),
                Spacer(),
                isLoading != true && lenghtOfBooks != 0
                    ? Expanded(
                        flex: 17,
                        child: Scrollbar(
                          thickness: 2,
                          radius: Radius.circular(20),
                          controller: scrollController,
                          thumbVisibility: true,
                          child: Container(
                            child: ListView.separated(
                                controller: scrollController,
                                physics: ClampingScrollPhysics(),
                                separatorBuilder: (context, index) =>
                                    VerticalDivider(
                                        color: Colors.transparent,
                                        thickness: 0),
                                scrollDirection: Axis.horizontal,
                                itemCount: books.length,
                                itemBuilder: (context, index) => Container(
                                      height: 220,
                                      width: 100,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => DetailedEditionInfo(
                                                    editionInfo: books[index],
                                                    isNavigatingFromLibrary:
                                                        true,
                                                    bookImage: books[index]
                                                                .imageAsByte !=
                                                            null
                                                        ? Image.memory(
                                                            base64Decode(books[
                                                                    index]
                                                                .imageAsByte!))
                                                        : Image.asset(
                                                            "lib/assets/images/nocover.jpg")),
                                              ));
                                        },
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Expanded(
                                              flex: 10,
                                              child: books[index].imageAsByte !=
                                                      null
                                                  ? Hero(
                                                      tag: uniqueIdCreater(
                                                          books[index]),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                        child: Image.memory(
                                                          base64Decode(books[
                                                                  index]
                                                              .imageAsByte!),
                                                          fit: BoxFit.fill,
                                                          width: 90,
                                                        ),
                                                      ),
                                                    )
                                                  : ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      child: Image.asset(
                                                          width: 90,
                                                          fit: BoxFit.fill,
                                                          "lib/assets/images/nocover.jpg"),
                                                    ),
                                            ),
                                            Spacer(),
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                books[index].title!,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                textAlign: TextAlign.center,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    )),
                          ),
                        ),
                      )
                    : isLoading == true
                        ? Expanded(
                            flex: 17,
                            child: Container(
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
                                  child: Container(
                                      height:
                                          MediaQuery.sizeOf(context).width / 3,
                                      child: Image.asset(
                                          "lib/assets/images/library.png")),
                                ),
                              )
                            : SizedBox.shrink(),
                lenghtOfBooks == 0
                    ? Spacer(
                        flex: 2,
                      )
                    : SizedBox.shrink()
              ],
            ),
          )),
    );
  }

  Container appBarBuilder() {
    return Container(
      height: 380,
      child: Stack(
        children: [
          Container(
            height: 330,
            decoration: BoxDecoration(
                color: Color(0xFF1B7695),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(100),
                    bottomRight: Radius.circular(100))),
          ),
          Positioned(
              child: Text(
                "Merhaba, $userName",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.white),
              ),
              left: 15,
              top: 60),
          Positioned(
            child: searchBarBuilder(),
            top: 100,
            left: 15,
            right: 15,
          ),
          Positioned(
            child: Text("Bir kitap mı okuyorsun? \nKitap ekle",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.white)),
            bottom: 170,
            left: 15,
            right: 15,
          ),
          Positioned(
            child: Container(
                height: 150,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("lib/assets/images/add_book.png"))),
                child: InkWell(
                  onTap: () {
                    modalBottomSheetBuilderForPopUpMenu(context);
                  },
                )),
            bottom: 0,
            left: 120,
            right: 100,
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
              contentPadding: EdgeInsets.all(15),
              hintText: "Ara",
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
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
                        ));
                  }
                },
                icon: Icon(
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
    allBooks = await ref.read(sqlProvider).getBookShelf(context);
    if (allBooks != null) {
      for (var element in allBooks!) {
        if (element.bookStatus == "Şu an okuduklarım") {
          listOfBooksCurrentlyReading.add(element);
        } else if (element.bookStatus == "Okumak istediklerim") {
          listOfBooksWantToRead.add(element);
        } else {
          listOfBooksAlreadyRead.add(element);
        }
      }
    }
  }

  void modalBottomSheetBuilderForPopUpMenu(BuildContext pageContext) {
    showModalBottomSheet(
      backgroundColor: Colors.grey.shade300,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30))),
      context: context,
      builder: (context) {
        return Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            title: Text("Kitap ekle",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            titleAlignment: ListTileTitleAlignment.center,
          ),
          Divider(height: 0),
          ListTile(
            visualDensity: VisualDensity(vertical: 3),
            onTap: () {
              Navigator.pop(context);
              FocusScope.of(pageContext).requestFocus(searchBarFocus);
            },
            leading: Icon(
              Icons.search,
              size: 30,
            ),
            title: Text("Arama ile", style: TextStyle(fontSize: 20)),
          ),
          Divider(height: 0),
          ListTile(
            visualDensity: VisualDensity(vertical: 3),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddBookView(),
                )),
            leading: Icon(
              Icons.keyboard,
              size: 30,
            ),
            title: Text("Kendin ekle", style: TextStyle(fontSize: 20)),
          )
        ]);
      },
    );
  }
}
