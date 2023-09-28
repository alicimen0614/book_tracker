import 'dart:convert';

import 'package:book_tracker/const.dart';
import 'package:book_tracker/models/books_model.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/discover_screen/detailed_edition_info.dart';
import 'package:book_tracker/screens/discover_screen/discover_screen_view.dart';
import 'package:book_tracker/screens/home_screen/home_screen_shimmer.dart';
import 'package:book_tracker/screens/library_screen/add_book_view.dart';
import 'package:book_tracker/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreenView extends ConsumerStatefulWidget {
  const HomeScreenView({super.key});

  @override
  ConsumerState<HomeScreenView> createState() => _HomeScreenViewState();
}

class _HomeScreenViewState extends ConsumerState<HomeScreenView>
    with AutomaticKeepAliveClientMixin<HomeScreenView> {
  bool isLoading = true;
  List<BookWorkEditionsModelEntries> allBooks = [];

  List<BookWorkEditionsModelEntries> listOfBooksCurrentlyReading = [];
  List<BookWorkEditionsModelEntries> listOfBooksWantToRead = [];
  List<BookWorkEditionsModelEntries> listOfBooksAlreadyRead = [];

  TextEditingController _searchBarController = TextEditingController();
  List<BooksModelDocs?>? docs = [];
  List<BookWorkEditionsModelEntries?>? editionList = [];
  String userName = "Kullanıcı";
  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    if (ref.read(authProvider).currentUser != null) {
      userName = ref.read(authProvider).currentUser!.displayName!;
    }
    getPageData();

    super.initState();
  }

  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              appBarBuilder(),
              isLoading != true
                  ? booksBuilder(listOfBooksCurrentlyReading,
                      "Şu anda ${listOfBooksCurrentlyReading.length} kitap okuyorsunuz")
                  : Padding(
                      padding: EdgeInsets.all(15),
                      child: homeScreenShimmer(context),
                    ),
              isLoading != true
                  ? booksBuilder(listOfBooksWantToRead,
                      "Toplamda ${listOfBooksWantToRead.length} okumak istediğiniz kitap var")
                  : homeScreenShimmer(context),
              isLoading != true
                  ? booksBuilder(listOfBooksAlreadyRead,
                      "Tebrikler toplamda ${listOfBooksAlreadyRead.length} kitap okudunuz")
                  : homeScreenShimmer(context),
            ],
          ),
        ));
  }

  Padding booksBuilder(List<BookWorkEditionsModelEntries> books, String text) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Container(
          height: 250,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Color(0xFFF7E6C4)),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Text(text,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                ),
                Expanded(
                  flex: 6,
                  child: Container(
                    child: ListView.separated(
                      physics: BouncingScrollPhysics(),
                      separatorBuilder: (context, index) => VerticalDivider(
                          color: Colors.transparent, thickness: 0),
                      scrollDirection: Axis.horizontal,
                      itemCount: books.length,
                      itemBuilder: (context, index) => Container(
                        decoration: BoxDecoration(),
                        height: 220,
                        width: 100,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailedEditionInfo(
                                      editionInfo: books[index],
                                      isNavigatingFromLibrary: true,
                                      bookImage: books[index].imageAsByte !=
                                              null
                                          ? Image.memory(base64Decode(
                                              books[index].imageAsByte!))
                                          : Image.asset(
                                              "lib/assets/images/nocover.jpg")),
                                ));
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                flex: 10,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: books[index].imageAsByte != null
                                      ? Hero(
                                          tag: uniqueIdCreater(books[index]),
                                          child: Image.memory(
                                            base64Decode(
                                                books[index].imageAsByte!),
                                            fit: BoxFit.fill,
                                          ),
                                        )
                                      : Image.asset(
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
                      ),
                    ),
                  ),
                ),
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
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
            cursorColor: Colors.black,
            onEditingComplete: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DiscoverScreenView(
                        searchValue: _searchBarController.text),
                  ));
            },
            controller: _searchBarController,
            keyboardType: TextInputType.text,
            autocorrect: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.all(15),
              hintText: "Search",
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFF1B7695),
                  ),
                  borderRadius: BorderRadius.circular(15)),
              suffixIcon: IconButton(
                onPressed: (() {}),
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
    allBooks = await ref.read(sqlProvider).getBookShelf();

    for (var element in allBooks) {
      if (element.bookStatus == "Şu an okuduklarım") {
        listOfBooksCurrentlyReading.add(element);
      } else if (element.bookStatus == "Okumak istediklerim") {
        listOfBooksWantToRead.add(element);
      } else {
        listOfBooksAlreadyRead.add(element);
      }
    }
  }

  void modalBottomSheetBuilderForPopUpMenu(BuildContext context) {
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
          Divider(),
          ListTile(
            leading: Icon(
              Icons.search,
              size: 30,
            ),
            title: Text("Arama ile", style: TextStyle(fontSize: 20)),
          ),
          Divider(),
          ListTile(
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
