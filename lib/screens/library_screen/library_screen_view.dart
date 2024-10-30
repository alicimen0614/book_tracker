import 'dart:convert';
import 'package:book_tracker/const.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/discover_screen/detailed_edition_info.dart';
import 'package:book_tracker/screens/home_screen/quotes_view.dart';
import 'package:book_tracker/screens/library_screen/add_book_view.dart';
import 'package:book_tracker/screens/library_screen/books_list_view.dart';
import 'package:book_tracker/screens/library_screen/notes_view.dart';
import 'package:flutter/material.dart';
import 'package:book_tracker/databases/sql_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transparent_image/transparent_image.dart';
import 'shimmer_effects/library_screen_shimmer.dart';

SqlHelper _sqlHelper = SqlHelper();

class LibraryScreenView extends ConsumerStatefulWidget {
  const LibraryScreenView({super.key});

  @override
  ConsumerState<LibraryScreenView> createState() => _LibraryScreenViewState();
}

class _LibraryScreenViewState extends ConsumerState<LibraryScreenView> {
  @override
  void initState() {
    if (ref.read(bookStateProvider).listOfBooksToShow == []) {
      ref.read(bookStateProvider.notifier).getPageData();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              tooltip: "Alıntılarım",
              splashRadius: 25,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const QuotesView()));
              },
              icon: const CircleAvatar(
                maxRadius: 15,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.format_quote_rounded,
                  size: 25,
                  color: Color(0xFF1B7695),
                ),
              )),
          actions: [
            ref.watch(bookStateProvider).isLoading == false
                ? IconButton(
                    tooltip: "Notlarım",
                    splashRadius: 25,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotesView(
                                bookListFromFirebase: ref
                                    .watch(bookStateProvider)
                                    .listOfBooksFromFirestore,
                                bookListFromSql: ref
                                    .watch(bookStateProvider)
                                    .listOfBooksFromSql),
                          ));
                    },
                    icon: const Icon(
                      Icons.library_books,
                      size: 30,
                      color: Colors.white,
                    ))
                : const SizedBox.shrink(),
            IconButton(
                tooltip: "Ekle",
                splashRadius: 25,
                onPressed: () {
                  modalBottomSheetBuilderForAddIcon(context);

                  /* Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddBookView(),
                      )).then((value) async {
                    if (value == true) {
                      await ref.watch(bookStateProvider.notifier).getPageData();
                    }
                  }); */
                },
                icon: const Icon(
                  Icons.add_circle,
                  size: 35,
                ))
          ],
          centerTitle: true,
          title: Text(
            "Kitaplığım",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.of(context).size.height / 40),
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
        body: ref.watch(bookStateProvider).isLoading == true
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
        ? listOfTheCurrentBookStatus = ref
            .watch(bookStateProvider)
            .listOfBooksToShow
            .where((element) => element.bookStatus == bookStatus)
            .toList()
        : listOfTheCurrentBookStatus =
            ref.watch(bookStateProvider).listOfBooksToShow;

    return bookContentBuilder(listOfTheCurrentBookStatus, bookStatus);
  }

  Widget bookContentBuilder(
      List<BookWorkEditionsModelEntries>? listOfTheCurrentBookStatus,
      String bookStatus) {
    //we create a list of ids of the books coming from sql
    List<int> listOfBookIdsFromSql = [];
    ref.watch(bookStateProvider).listOfBooksFromSql != []
        ? listOfBookIdsFromSql = ref
            .watch(bookStateProvider)
            .listOfBooksFromSql
            .map((e) => uniqueIdCreater(e))
            .toList()
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
                                        null &&
                                    listOfTheCurrentBookStatus[index]
                                            .imageAsByte !=
                                        null
                                ? Image.memory(
                                    width: 80,
                                    base64Decode(getImageAsByte(
                                        ref
                                            .watch(bookStateProvider)
                                            .listOfBooksFromSql,
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
                    await ref.watch(bookStateProvider.notifier).getPageData();
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
                                      null &&
                                  listOfTheCurrentBookStatus[index]
                                          .imageAsByte !=
                                      null
                              ? Hero(
                                  tag: uniqueIdCreater(
                                      listOfTheCurrentBookStatus[index]),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.memory(
                                      width: 80,
                                      base64Decode(getImageAsByte(
                                          ref
                                              .watch(bookStateProvider)
                                              .listOfBooksFromSql,
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
    await _sqlHelper
        .deleteBook(uniqueIdCreater(listOfTheCurrentBookStatus[index]));

    await ref.read(firestoreProvider).deleteBook(context,
        referencePath: "usersBooks",
        userId: ref.read(authProvider).currentUser!.uid,
        bookId: uniqueIdCreater(listOfTheCurrentBookStatus[index]).toString());
  }

  void modalBottomSheetBuilderForAddIcon(BuildContext pageContext) {
    showModalBottomSheet(
      backgroundColor: Colors.grey.shade300,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30))),
      context: context,
      builder: (context) {
        return Column(mainAxisSize: MainAxisSize.min, children: [
          const ListTile(
            title: Text("Ekle",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            titleAlignment: ListTileTitleAlignment.center,
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
                if (value == true) {
                  ref.read(bookStateProvider.notifier).getPageData();
                }
              });
            },
            leading: const Icon(
              Icons.keyboard,
              size: 30,
            ),
            title: const Text("Kendi kitabını ekle",
                style: TextStyle(fontSize: 20)),
          ),
          const Divider(height: 0),
          ListTile(
            visualDensity: const VisualDensity(vertical: 3),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BooksListView(isNotes: true),
                  ));
            },
            leading: const Icon(
              Icons.post_add,
              size: 30,
            ),
            title:
                const Text("Kitabına not ekle", style: TextStyle(fontSize: 20)),
          ),
          const Divider(height: 0),
          ListTile(
            visualDensity: const VisualDensity(vertical: 3),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BooksListView(isNotes: false),
                  ));
            },
            leading: const Icon(
              Icons.library_add_outlined,
              size: 30,
            ),
            title: const Text("Kitabına alıntı ekle",
                style: TextStyle(fontSize: 20)),
          )
        ]);
      },
    );
  }
}
