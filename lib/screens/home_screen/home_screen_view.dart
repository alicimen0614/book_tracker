import 'dart:async';
import 'dart:convert';

import 'package:book_tracker/const.dart';
import 'package:book_tracker/databases/firestore_database.dart';
import 'package:book_tracker/models/books_model.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/providers/quotes_state_provider.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/discover_screen/detailed_edition_info.dart';
import 'package:book_tracker/screens/discover_screen/discover_screen_view.dart';
import 'package:book_tracker/screens/home_screen/detailed_quote_view.dart';
import 'package:book_tracker/screens/home_screen/home_screen_shimmer/home_screen_shimmer.dart';
import 'package:book_tracker/screens/home_screen/home_screen_shimmer/text_shimmer_effect.dart';
import 'package:book_tracker/screens/home_screen/quotes_screen.dart';
import 'package:book_tracker/screens/library_screen/add_book_view.dart';
import 'package:book_tracker/widgets/sign_up_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transparent_image/transparent_image.dart';

import 'home_screen_shimmer/quote_widget_shimmer.dart';

class HomeScreenView extends ConsumerStatefulWidget {
  const HomeScreenView({super.key});

  @override
  ConsumerState<HomeScreenView> createState() => _HomeScreenViewState();
}

class _HomeScreenViewState extends ConsumerState<HomeScreenView> {
  final _scrollControllerCurrReading = ScrollController();
  final _scrollControllerWantToRead = ScrollController();
  final _scrollControllerAlrRead = ScrollController();
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
  Map<String, Timer?> debounceTimers = {}; // Her post için bir zamanlayıcı
  Map<String, bool> pendingLikeStatus = {}; // Son beğeni durumu (beğeni/yok)

  @override
  void initState() {
    if (ref.read(bookStateProvider).listOfBooksToShow == []) {
      ref.read(bookStateProvider.notifier).getPageData();
    }
    ref.read(quotesProvider.notifier).fetchTrendingQuotes();

    super.initState();
  }

  @override
  Future<void> dispose() async {
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
                quoteCornerBuilder(),
                booksBuilder(
                    ref.watch(bookStateProvider).listOfBooksCurrentlyReading,
                    ref
                            .watch(bookStateProvider)
                            .listOfBooksCurrentlyReading
                            .isNotEmpty
                        ? "Şu anda ${ref.watch(bookStateProvider).listOfBooksCurrentlyReading.length} kitap okuyorsunuz."
                        : "Şu anda okuduğunuz kitap bulunmamakta.",
                    ref
                        .watch(bookStateProvider)
                        .listOfBooksCurrentlyReading
                        .length,
                    _scrollControllerCurrReading),
                booksBuilder(
                    ref.watch(bookStateProvider).listOfBooksWantToRead,
                    ref
                            .watch(bookStateProvider)
                            .listOfBooksWantToRead
                            .isNotEmpty
                        ? "Toplamda ${ref.watch(bookStateProvider).listOfBooksWantToRead.length} okumak istediğiniz kitap var."
                        : "Şu anda okumak istediğiniz kitap bulunmamakta.",
                    ref.watch(bookStateProvider).listOfBooksWantToRead.length,
                    _scrollControllerWantToRead),
                booksBuilder(
                    ref.watch(bookStateProvider).listOfBooksAlreadyRead,
                    ref
                            .watch(bookStateProvider)
                            .listOfBooksAlreadyRead
                            .isNotEmpty
                        ? "Tebrikler toplamda ${ref.watch(bookStateProvider).listOfBooksAlreadyRead.length} kitap okudunuz."
                        : "Şu anda bitirdiğiniz kitap bulunmamakta.",
                    ref.watch(bookStateProvider).listOfBooksAlreadyRead.length,
                    _scrollControllerAlrRead)
              ],
            ),
          ),
        ));
  }

  Padding quoteCornerBuilder() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: const Color(0xFFF7E6C4)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  children: [
                    Text("Alıntı Köşesi",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.height / 40,
                        )),
                    const Spacer(),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const QuotesScreen(),
                              ));
                        },
                        child: Text("Tümü",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context).size.height / 50,
                            )))
                  ],
                ),
              ),
              ref.watch(quotesProvider).isTrendingLoading == false
                  ? Container(
                      height: Const.screenSize.height * 0.47,
                      child: PageView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          final quoteId = ref
                              .watch(quotesProvider)
                              .trendingQuotes
                              .keys
                              .toList()[index];
                          int likeCount = ref
                              .watch(quotesProvider)
                              .trendingQuotes[quoteId]!
                              .likes!
                              .length;
                          bool isUserLikedQuote = FirebaseAuth
                                      .instance.currentUser !=
                                  null
                              ? ref
                                  .watch(quotesProvider)
                                  .trendingQuotes[quoteId]!
                                  .likes!
                                  .contains(
                                      FirebaseAuth.instance.currentUser!.uid)
                              : false;
                          String text = ref
                              .read(quotesProvider)
                              .trendingQuotes[quoteId]!
                              .quoteText!;
                          var textHeight = calculateTextHeight(
                              text,
                              TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height / 55,
                              ),
                              Const.screenSize.width - 100);

                          return GestureDetector(
                            onDoubleTap: () {
                              likePost(quoteId, index);
                            },
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailedQuoteView(
                                      quote: ref
                                          .read(quotesProvider)
                                          .trendingQuotes[quoteId]!,
                                      quoteId: quoteId,
                                      isTrendingQuotes: true,
                                    ),
                                  ));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: const Color(0xFFF7E6C4),
                              ),
                              width: Const.screenSize.width - 30,
                              child: Column(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Row(
                                        children: [
                                          ref
                                                      .read(quotesProvider)
                                                      .trendingQuotes[quoteId]!
                                                      .userPicture !=
                                                  null
                                              ? CircleAvatar(
                                                  backgroundColor: Colors.grey,
                                                  backgroundImage: NetworkImage(
                                                      ref
                                                          .read(quotesProvider)
                                                          .trendingQuotes[
                                                              quoteId]!
                                                          .userPicture!),
                                                )
                                              : const Icon(
                                                  Icons.account_circle_sharp,
                                                  size: 45,
                                                  color: Color(0xFF1B7695),
                                                ),
                                          SizedBox(
                                            width: Const.minSize,
                                          ),
                                          Text(
                                              ref
                                                  .read(quotesProvider)
                                                  .trendingQuotes[quoteId]!
                                                  .userName!,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    50,
                                              )),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Spacer(
                                    flex: 2,
                                  ),
                                  Expanded(
                                    flex: textHeight > 85 ? 17 : 13,
                                    child: Card(
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(25)),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      color: Colors.white,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15, vertical: 10),
                                            child: Text(
                                              text,
                                              style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .height /
                                                          55,
                                                  fontWeight: FontWeight.w700),
                                              maxLines: 5,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (textHeight > 85)
                                            const Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 15,
                                              ),
                                              child: Text(
                                                "Daha fazla",
                                                style: TextStyle(
                                                    color: Color(0xFF1B7695),
                                                    fontWeight:
                                                        FontWeight.w700),
                                                textAlign: TextAlign.end,
                                              ),
                                            )
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Spacer(
                                    flex: 2,
                                  ),
                                  Expanded(
                                    flex: 10,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 8,
                                            child: Container(
                                                child: ref
                                                            .read(
                                                                quotesProvider)
                                                            .trendingQuotes[
                                                                quoteId]!
                                                            .imageAsByte !=
                                                        null
                                                    ? ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                        child: Image.memory(
                                                          fit: BoxFit.fill,
                                                          base64Decode(ref
                                                              .read(
                                                                  quotesProvider)
                                                              .trendingQuotes[
                                                                  quoteId]!
                                                              .imageAsByte!),
                                                          errorBuilder: (context,
                                                                  error,
                                                                  stackTrace) =>
                                                              Image.asset(
                                                            "lib/assets/images/error.png",
                                                          ),
                                                        ),
                                                      )
                                                    : ref
                                                                .read(
                                                                    quotesProvider)
                                                                .trendingQuotes[
                                                                    quoteId]!
                                                                .bookCover !=
                                                            null
                                                        ? ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                            child:
                                                                CachedNetworkImage(
                                                              imageUrl:
                                                                  "https://covers.openlibrary.org/b/id/${ref.read(quotesProvider).trendingQuotes[quoteId]!.bookCover}-M.jpg",
                                                              fit: BoxFit.fill,
                                                              errorWidget:
                                                                  (context,
                                                                      error,
                                                                      stackTrace) {
                                                                return Image
                                                                    .asset(
                                                                  "lib/assets/images/error.png",
                                                                  height: 80,
                                                                  width: 50,
                                                                );
                                                              },
                                                              placeholder:
                                                                  (context,
                                                                      url) {
                                                                return Container(
                                                                  decoration: BoxDecoration(
                                                                      color: Colors
                                                                          .grey
                                                                          .shade400,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              15)),
                                                                  child:
                                                                      const Center(
                                                                    child:
                                                                        CircularProgressIndicator(
                                                                      strokeWidth:
                                                                          2,
                                                                      strokeAlign:
                                                                          -10,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          )
                                                        : ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        15),
                                                            child: Image.asset(
                                                              "lib/assets/images/nocover.jpg",
                                                              fit: BoxFit.fill,
                                                            ),
                                                          )),
                                          ),
                                          const Spacer(),
                                          Expanded(
                                            flex: 10,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(ref
                                                    .read(quotesProvider)
                                                    .trendingQuotes[quoteId]!
                                                    .bookName!),
                                                if (ref
                                                        .read(quotesProvider)
                                                        .trendingQuotes[
                                                            quoteId]!
                                                        .bookAuthorName !=
                                                    null)
                                                  Text(ref
                                                      .read(quotesProvider)
                                                      .trendingQuotes[quoteId]!
                                                      .bookAuthorName!)
                                              ],
                                            ),
                                          ),
                                          const Spacer(
                                            flex: 20,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Spacer(
                                    flex: 2,
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Divider(
                                      color: Colors.grey.shade400,
                                      endIndent: 10,
                                      indent: 10,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            padding: EdgeInsets.zero,
                                            splashColor: Colors.black,
                                            visualDensity: const VisualDensity(
                                                horizontal: -4, vertical: -4),
                                            icon: Icon(
                                                isUserLikedQuote
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color: isUserLikedQuote
                                                    ? Colors.red
                                                    : const Color.fromARGB(
                                                        196, 0, 0, 0),
                                                size: 30),
                                            onPressed: () {
                                              likePost(quoteId, index);
                                            },
                                          ),
                                          const SizedBox(width: 8.0),
                                          Text(isUserLikedQuote &&
                                                  likeCount != 1
                                              ? "Siz ve ${likeCount - 1} diğer kişi bunu beğendi."
                                              : isUserLikedQuote &&
                                                      likeCount == 1
                                                  ? "$likeCount kişi beğendi."
                                                  : isUserLikedQuote == false &&
                                                          likeCount == 0
                                                      ? "Henüz kimse beğenmedi."
                                                      : isUserLikedQuote ==
                                                                  false &&
                                                              likeCount != 0
                                                          ? "$likeCount kişi bunu beğendi."
                                                          : ""),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Spacer()
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : quoteWidgetShimmer(context)
            ],
          )),
    );
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
                ref.watch(bookStateProvider).isLoading != true
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
                ref.watch(bookStateProvider).isLoading != true &&
                        lenghtOfBooks != 0
                    ? Expanded(
                        flex: 17,
                        child: Scrollbar(
                          thickness: 2,
                          radius: const Radius.circular(20),
                          controller: scrollController,
                          thumbVisibility: true,
                          child: ListView.separated(
                              padding: const EdgeInsets.all(5),
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
                                                                      uniqueIdCreater(books[
                                                                          index])) ==
                                                                  true &&
                                                              books[index]
                                                                      .covers !=
                                                                  null &&
                                                              books[index]
                                                                      .imageAsByte !=
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
                                          ref
                                              .read(bookStateProvider.notifier)
                                              .getPageData();
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
                                                  : books[index]
                                                              .imageAsByte !=
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
                                                                      uniqueIdCreater(books[
                                                                          index])) ==
                                                                  true &&
                                                              books[index]
                                                                      .covers !=
                                                                  null &&
                                                              books[index]
                                                                      .imageAsByte !=
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
                    : ref.watch(bookStateProvider).isLoading == true
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
      height: MediaQuery.of(context).size.height / 1.9,
      child: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 2.2,
            decoration: const BoxDecoration(
                color: Color(0xFF1B7695),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(100),
                    bottomRight: Radius.circular(100))),
          ),
          Positioned(
              left: 15,
              top: 60,
              child: Text(
                "Hoş geldin :)",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.height / 40,
                    color: Colors.white),
              )),
          Positioned(
            top: 100,
            left: 15,
            right: 15,
            child: searchBarBuilder(),
          ),
          Positioned(
            top: 170,
            left: 15,
            right: 15,
            child: Text("Bir kitap mı okuyorsun? \nKitap ekle",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.height / 40,
                    color: Colors.white)),
          ),
          Positioned(
            bottom: 0,
            left: 120,
            right: 100,
            child: Container(
                height: MediaQuery.of(context).size.height / 5.2,
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
                if (value == true) {
                  ref.read(bookStateProvider.notifier).getPageData();
                }
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

  void likePost(String quoteId, int index) {
    if (FirebaseAuth.instance.currentUser != null) {
      // UI'yi anında güncelle
      updateUILikeStatus(quoteId, index);

      // Son beğeni durumu kaydet
      pendingLikeStatus[quoteId] = ref
          .read(quotesProvider)
          .trendingQuotes[quoteId]!
          .likes!
          .contains(FirebaseAuth.instance.currentUser!.uid);

      // Eğer zaten bir zamanlayıcı varsa onu iptal et
      debounceTimers[quoteId]?.cancel();

      // Yeni bir zamanlayıcı başlat (örneğin 3 saniye sonra Firebase'e gönder)
      debounceTimers[quoteId] = Timer(const Duration(seconds: 3), () {
        FirestoreDatabase()
            .commitLikeToFirebase(quoteId, pendingLikeStatus[quoteId], context);

        debounceTimers.remove(quoteId);
        pendingLikeStatus.remove(quoteId);
      });
    } else {
      showSignUpDialog();
    }
  }

  void updateUILikeStatus(String quoteId, index) {
    ref.read(quotesProvider.notifier).updateLikedQuote(quoteId, true);
    print(
        "Post $quoteId UI güncellendi: ${ref.read(quotesProvider).trendingQuotes[quoteId]!.likes!.contains(FirebaseAuth.instance.currentUser!.uid) ? 'Beğenildi' : 'Beğeni geri alındı'}");
  }

  void showSignUpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return const SignUpDialog();
      },
    );
  }
}
