import 'dart:async';
import 'dart:convert';
import 'package:book_tracker/const.dart';
import 'package:book_tracker/databases/firestore_database.dart';
import 'package:book_tracker/main.dart';
import 'package:book_tracker/models/books_model.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/providers/connectivity_provider.dart';
import 'package:book_tracker/providers/quotes_provider.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/auth_screen/auth_view.dart';
import 'package:book_tracker/screens/discover_screen/detailed_edition_info.dart';
import 'package:book_tracker/screens/discover_screen/search_screen_view.dart';
import 'package:book_tracker/screens/home_screen/detailed_quote_view.dart';
import 'package:book_tracker/screens/home_screen/home_screen_shimmer/home_screen_shimmer.dart';
import 'package:book_tracker/screens/home_screen/home_screen_shimmer/text_shimmer_effect.dart';
import 'package:book_tracker/screens/home_screen/quotes_screen.dart';
import 'package:book_tracker/screens/library_screen/add_book_view.dart';
import 'package:book_tracker/services/analytics_service.dart';
import 'package:book_tracker/widgets/internet_connection_error_dialog.dart';
import 'package:book_tracker/widgets/custom_alert_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:book_tracker/l10n/app_localizations.dart';
import 'home_screen_shimmer/quote_widget_shimmer.dart';

class HomeScreenView extends ConsumerStatefulWidget {
  const HomeScreenView({super.key});

  @override
  ConsumerState<HomeScreenView> createState() => _HomeScreenViewState();
}

class _HomeScreenViewState extends ConsumerState<HomeScreenView>
    with RouteAware {
  final _scrollControllerCurrReading = ScrollController();
  final _scrollControllerWantToRead = ScrollController();
  final _scrollControllerAlrRead = ScrollController();
  List<BookWorkEditionsModelEntries>? listOfBooksFromSql = [];
  List<int>? listOfBookIdsFromSql = [];
  List<BookWorkEditionsModelEntries>? listOfBooksFromFirebase = [];
  List<BookWorkEditionsModelEntries>? listOfBooksToShow = [];
  final ScrollController _scrollController = ScrollController();
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
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(bookStateProvider).listOfBooksToShow.isEmpty) {
        ref.read(bookStateProvider.notifier).getPageData();
      }
    });

    
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPush() {
    super.didPush();
    // Log when the screen is pushed
    AnalyticsService().firebaseAnalytics.logScreenView(
          screenName: "HomeScreen",
        );
  }

  @override
  Future<void> dispose() async {
    routeObserver.unsubscribe(this);
    _scrollControllerAlrRead.dispose();
    _scrollControllerCurrReading.dispose();
    _scrollControllerWantToRead.dispose();
    _searchBarController.dispose();
    searchBarFocus.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: GestureDetector(
          onTap: () {
            if (searchBarFocus.hasFocus) {
              searchBarFocus.unfocus();
            }
          },
          child: SingleChildScrollView(
            controller: _scrollController,
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
                        ? AppLocalizations.of(context)!.currentlyReadingBooks(
                            ref
                                .watch(bookStateProvider)
                                .listOfBooksCurrentlyReading
                                .length)
                        : AppLocalizations.of(context)!.noCurrentReads,
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
                        ? AppLocalizations.of(context)!.totalBooksToRead(ref
                            .watch(bookStateProvider)
                            .listOfBooksWantToRead
                            .length)
                        : AppLocalizations.of(context)!.noWantedReads,
                    ref.watch(bookStateProvider).listOfBooksWantToRead.length,
                    _scrollControllerWantToRead),
                booksBuilder(
                    ref.watch(bookStateProvider).listOfBooksAlreadyRead,
                    ref
                            .watch(bookStateProvider)
                            .listOfBooksAlreadyRead
                            .isNotEmpty
                        ? AppLocalizations.of(context)!
                            .congratulationsTotalBooksRead(ref
                                .watch(bookStateProvider)
                                .listOfBooksAlreadyRead
                                .length)
                        : AppLocalizations.of(context)!.noFinishedReads,
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  children: [
                    Text(AppLocalizations.of(context)!.quoteCorner,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.height / 40,
                        )),
                    const Spacer(),
                    TextButton(
                        onPressed: () {
                          if (searchBarFocus.hasFocus) {
                            searchBarFocus.unfocus();
                          }
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const QuotesScreen(),
                              ));
                        },
                        child: Text(AppLocalizations.of(context)!.all,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context).size.height / 50,
                            )))
                  ],
                ),
              ),
              SizedBox(
                  height: Const.screenSize.height * 0.47,
                  child: PagedPageView(
                    onPageChanged: (index) {
                      if (index >= 5) {
                        _pageController.animateToPage(0,
                            duration: const Duration(seconds: 2),
                            curve: Curves.fastOutSlowIn);
                      }
                    },
                    pageController: _pageController,
                    pagingController: ref
                        .read(quotesProvider.notifier)
                        .trendingPagingController,
                    scrollDirection: Axis.horizontal,
                    builderDelegate: PagedChildBuilderDelegate(
                      noItemsFoundIndicatorBuilder: (context) =>
                          trendingErrorWidget(context),
                      firstPageProgressIndicatorBuilder: (context) =>
                          quoteWidgetShimmer(context),
                      firstPageErrorIndicatorBuilder: (context) {
                        return trendingErrorWidget(context);
                      },
                      itemBuilder: (context, QuoteEntry quoteEntry, index) {
                        int likeCount = quoteEntry.quote.likes!.length;
                        bool isUserLikedQuote =
                            FirebaseAuth.instance.currentUser != null
                                ? quoteEntry.quote.likes!.contains(
                                    FirebaseAuth.instance.currentUser!.uid)
                                : false;
                        String text = quoteEntry.quote.quoteText!;
                        var textHeight = calculateTextHeight(
                            text,
                            TextStyle(
                              fontSize: MediaQuery.of(context).size.height / 55,
                            ),
                            Const.screenSize.width - 100);

                        return GestureDetector(
                          onDoubleTap: () {
                            likePost(quoteEntry, index);
                          },
                          onTap: () {
                            if (searchBarFocus.hasFocus) {
                              searchBarFocus.unfocus();
                            }
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailedQuoteView(
                                    quoteEntry: quoteEntry,
                                    isTrendingQuotes: true,
                                  ),
                                ));

                            AnalyticsService().logEvent(
                                "click_quote", {"quote_id": quoteEntry.id});
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
                                        quoteEntry.quote.userPicture != null &&
                                                ref
                                                        .read(
                                                            connectivityProvider)
                                                        .isConnected !=
                                                    false
                                            ? CircleAvatar(
                                                backgroundColor: Colors.grey,
                                                backgroundImage: Image.network(
                                                  quoteEntry.quote.userPicture!,
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      Image.asset(
                                                    "lib/assets/images/error.png",
                                                  ),
                                                ).image,
                                              )
                                            : const Icon(
                                                Icons.account_circle_sharp,
                                                size: 45,
                                                color: Color(0xFF1B7695),
                                              ),
                                        SizedBox(
                                          width: Const.minSize,
                                        ),
                                        Text(quoteEntry.quote.userName!,
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
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    55,
                                                fontWeight: FontWeight.w700),
                                            maxLines: 5,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (textHeight > 85)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 15,
                                            ),
                                            child: Text(
                                              AppLocalizations.of(context)!
                                                  .more,
                                              style: const TextStyle(
                                                  color: Color(0xFF1B7695),
                                                  fontWeight: FontWeight.w700),
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
                                  flex: 11,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                              child: quoteEntry
                                                          .quote.imageAsByte !=
                                                      null
                                                  ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      child: Image.memory(
                                                        fit: BoxFit.fill,
                                                        base64Decode(quoteEntry
                                                            .quote
                                                            .imageAsByte!),
                                                        errorBuilder: (context,
                                                                error,
                                                                stackTrace) =>
                                                            Image.asset(
                                                          "lib/assets/images/error.png",
                                                        ),
                                                      ),
                                                    )
                                                  : quoteEntry.quote
                                                              .bookCover !=
                                                          null
                                                      ? ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          child: ref
                                                                  .read(
                                                                      connectivityProvider)
                                                                  .isConnected
                                                              ? CachedNetworkImage(
                                                                  imageUrl:
                                                                      "https://covers.openlibrary.org/b/id/${quoteEntry.quote.bookCover}-M.jpg",
                                                                  fit: BoxFit
                                                                      .fill,
                                                                  errorWidget:
                                                                      (context,
                                                                          error,
                                                                          stackTrace) {
                                                                    return Image
                                                                        .asset(
                                                                      "lib/assets/images/error.png",
                                                                      height:
                                                                          80,
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
                                                                              BorderRadius.circular(15)),
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
                                                                )
                                                              : Image.asset(
                                                                  "lib/assets/images/error.png",
                                                                  height: 80,
                                                                  width: 50,
                                                                ),
                                                        )
                                                      : ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          child: Image.asset(
                                                            "lib/assets/images/nocover.jpg",
                                                            fit: BoxFit.fill,
                                                          ),
                                                        )),
                                        ),
                                        const Spacer(),
                                        Expanded(
                                          flex: 4,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                quoteEntry.quote.bookName!,
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500),
                                                maxLines: 2,
                                              ),
                                              SizedBox(
                                                height: Const.minSize,
                                              ),
                                              if (quoteEntry
                                                      .quote.bookAuthorName !=
                                                  null)
                                                Text(
                                                    quoteEntry
                                                        .quote.bookAuthorName!,
                                                    maxLines: 2,
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold))
                                            ],
                                          ),
                                        ),
                                        const Spacer()
                                      ],
                                    ),
                                  ),
                                ),
                                const Spacer(
                                  flex: 1,
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Divider(
                                    color: Colors.grey.shade400,
                                    endIndent: 15,
                                    indent: 15,
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
                                          icon: AnimatedSwitcher(
                                            duration: const Duration(
                                                milliseconds: 500),
                                            switchInCurve: Curves.bounceOut,
                                            switchOutCurve: Curves.easeIn,
                                            transitionBuilder:
                                                (child, animation) {
                                              return ScaleTransition(
                                                scale: animation,
                                                child: RotationTransition(
                                                  turns: animation,
                                                  child: child,
                                                ),
                                              );
                                            },
                                            child: Icon(
                                                key: ValueKey<bool>(
                                                    isUserLikedQuote),
                                                isUserLikedQuote
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color: isUserLikedQuote
                                                    ? Colors.red
                                                    : const Color.fromARGB(
                                                        196, 0, 0, 0),
                                                size: 30),
                                          ),
                                          onPressed: () {
                                            likePost(quoteEntry, index);
                                          },
                                        ),
                                        const SizedBox(width: 8.0),
                                        Text(isUserLikedQuote && likeCount != 1
                                            ? AppLocalizations.of(context)!
                                                .likedByYouAndOneOther(
                                                    likeCount - 1)
                                            : isUserLikedQuote && likeCount == 1
                                                ? AppLocalizations.of(context)!
                                                    .peopleLiked(likeCount)
                                                : isUserLikedQuote == false &&
                                                        likeCount == 0
                                                    ? AppLocalizations.of(
                                                            context)!
                                                        .noOneLikedYet
                                                    : isUserLikedQuote ==
                                                                false &&
                                                            likeCount != 0
                                                        ? AppLocalizations.of(
                                                                context)!
                                                            .peopleLiked(
                                                                likeCount)
                                                        : ""),
                                      ],
                                    ),
                                  ),
                                ),
                                const Spacer(),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )),
              SmoothPageIndicator(
                controller: _pageController,
                count: 5, // Toplam quote sayısı
                effect: const JumpingDotEffect(
                  activeDotColor: Color(0xFF1B7695),
                  dotColor: Colors.grey,
                  dotHeight: 8,
                  dotWidth: 8,
                  spacing: 8,
                ),
              ),
              SizedBox(
                height: Const.minSize,
              )
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
                                        if (searchBarFocus.hasFocus) {
                                          searchBarFocus.unfocus();
                                        }
                                        AnalyticsService().logEvent(
                                            "click_book_edition", {
                                          "edition_id":
                                              uniqueIdCreater(books[index])
                                        });
                                        var data = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DetailedEditionInfo(
                                                      editionInfo: books[index],
                                                      isNavigatingFromLibrary:
                                                          true,
                                                      bookImage: listOfBookIdsFromSql!
                                                                      .contains(
                                                                          uniqueIdCreater(
                                                                              books[
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
                                                          : books[index]
                                                                          .covers !=
                                                                      null &&
                                                                  books[index]
                                                                          .imageAsByte ==
                                                                      null &&
                                                                  ref
                                                                          .read(
                                                                              connectivityProvider)
                                                                          .isConnected ==
                                                                      true
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
                                                              : books[index].imageAsByte !=
                                                                      null
                                                                  ? Image.memory(
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
                                              books[index].title??"",
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
      height: MediaQuery.of(context).size.height / 2.1,
      child: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 2.5,
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
                AppLocalizations.of(context)!.welcome,
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
            child: Text(
                "${AppLocalizations.of(context)!.areYouReadingABook} \n${AppLocalizations.of(context)!.addBook}",
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
            autofocus: false,
            focusNode: searchBarFocus,
            cursorColor: Colors.black,
            onEditingComplete: () {
              if (searchBarFocus.hasFocus) {
                searchBarFocus.unfocus();
              }
              if (_searchBarController.text != "") {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchScreenView(
                          searchValue: _searchBarController.text),
                    )).then(
                  (value) {
                    if (searchBarFocus.hasFocus) {
                      searchBarFocus.unfocus();
                    }
                  },
                );
              }
            },
            controller: _searchBarController,
            keyboardType: TextInputType.text,
            autocorrect: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(15),
              hintText: AppLocalizations.of(context)!.search,
              focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0xFF1B7695),
                  ),
                  borderRadius: BorderRadius.circular(15)),
              suffixIcon: IconButton(
                onPressed: () {
                  if (searchBarFocus.hasFocus) {
                    searchBarFocus.unfocus();
                  }
                  if (_searchBarController.text != "") {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchScreenView(
                              searchValue: _searchBarController.text),
                        )).then((value) {
                      _searchBarController.clear();
                      if (searchBarFocus.hasFocus) {
                        searchBarFocus.unfocus();
                      }
                    });
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
    if (searchBarFocus.hasFocus) {
      searchBarFocus.unfocus();
    }
    showModalBottomSheet(
      backgroundColor: Colors.grey.shade300,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30))),
      context: context,
      builder: (context) {
        return Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            title: Text(AppLocalizations.of(context)!.addBook,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            titleAlignment: ListTileTitleAlignment.center,
          ),
          const Divider(height: 0),
          ListTile(
            visualDensity: const VisualDensity(vertical: 3),
            onTap: () async {
              Navigator.pop(context);
              await _scrollToTop();

              FocusScope.of(pageContext).requestFocus(searchBarFocus);
            },
            leading: const Icon(
              Icons.search,
              size: 30,
            ),
            title: Text(AppLocalizations.of(context)!.addBookWithSearch,
                style: const TextStyle(fontSize: 20)),
          ),
          const Divider(height: 0),
          ListTile(
            visualDensity: const VisualDensity(vertical: 3),
            onTap: () {
              if (searchBarFocus.hasFocus) {
                searchBarFocus.unfocus();
              }
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
            title: Text(AppLocalizations.of(context)!.addYourBook,
                style: const TextStyle(fontSize: 20)),
          )
        ]);
      },
    );
  }

  void likePost(QuoteEntry quoteEntry, int index) {
    if (FirebaseAuth.instance.currentUser != null) {
      // UI'yi anında güncelle
      updateUILikeStatus(quoteEntry.id, index);

      // Son beğeni durumu kaydet
      pendingLikeStatus[quoteEntry.id] = quoteEntry.quote.likes!
          .contains(FirebaseAuth.instance.currentUser!.uid);

      // Eğer zaten bir zamanlayıcı varsa onu iptal et
      debounceTimers[quoteEntry.id]?.cancel();

      // Yeni bir zamanlayıcı başlat (örneğin 3 saniye sonra Firebase'e gönder)
      debounceTimers[quoteEntry.id] = Timer(const Duration(seconds: 3), () async{
         _commitLikeSafely(quoteEntry.id);
      });
    } else {
      showSignUpDialog();
    }
  }

  void updateUILikeStatus(String quoteId, index) {
    ref.read(quotesProvider.notifier).updateLikedQuote(quoteId, true);
  }

  void showSignUpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return CustomAlertDialog(
          title:  Const.appName,
          description: AppLocalizations.of(context)!.loginToLikePost,
          secondButtonOnPressed: () {
            if (searchBarFocus.hasFocus) {
              searchBarFocus.unfocus();
            }
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const AuthView(formStatusData: FormStatus.register),
                ));
          },
          secondButtonText: AppLocalizations.of(context)!.signUp,
          thirdButtonOnPressed: () {
            if (searchBarFocus.hasFocus) {
              searchBarFocus.unfocus();
            }
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const AuthView(formStatusData: FormStatus.signIn),
                ));
          },
          thirdButtonText: AppLocalizations.of(context)!.signIn,
          firstButtonOnPressed: () {
            Navigator.pop(context);
          },
          firstButtonText: AppLocalizations.of(context)!.close,
        );
      },
    );
  }

  Center trendingErrorWidget(BuildContext context) {
    return Center(
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        SizedBox(
          height: Const.screenSize.height * 0.1,
        ),
        Text(
          AppLocalizations.of(context)!.quotesFailedToLoad,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.height / 50,
          ),
        ),
        Text(
          AppLocalizations.of(context)!.clickToRefresh,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.height / 50,
          ),
        ),
        IconButton(
            color: Theme.of(context).primaryColor,
            iconSize: 30,
            onPressed: () async {
              if (ref.read(connectivityProvider).isConnected == true) {
                ref
                    .read(quotesProvider.notifier)
                    .trendingPagingController
                    .refresh();
              } else {
                internetConnectionErrorDialog(context, false);
              }
            },
            icon: const Icon(Icons.refresh_sharp))
      ]),
    );
  }

  Future<void> _scrollToTop() async {
    await _scrollController.animateTo(
      0.0, // En üst pozisyon
      duration: const Duration(milliseconds: 300), // Animasyon süresi
      curve: Curves.easeInOut, // Animasyon eğrisi
    );
  }
  
 Future<void> _commitLikeSafely(String quoteId) async {
   await FirestoreDatabase().commitLikeToFirebase(
      quoteId, pendingLikeStatus[quoteId]);


  debounceTimers.remove(quoteId);
  pendingLikeStatus.remove(quoteId);
}

}
