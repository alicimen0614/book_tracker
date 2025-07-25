import 'package:book_tracker/const.dart';
import 'package:book_tracker/l10n/app_localizations.dart';
import 'package:book_tracker/models/authors_model.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/providers/connectivity_provider.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/discover_screen/shimmer_effect_builders/detailed_edition_view_shimmer.dart';
import 'package:book_tracker/screens/home_screen/add_quote_screen.dart';
import 'package:book_tracker/screens/library_screen/add_book_view.dart';
import 'package:book_tracker/screens/library_screen/add_note_view.dart';
import 'package:book_tracker/screens/user_screen/alert_for_data_source.dart';
import 'package:book_tracker/services/analytics_service.dart';
import 'package:book_tracker/widgets/custom_alert_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';

enum BookStatus { wantToRead, currentlyReading, alreadyRead }

class DetailedEditionInfo extends ConsumerStatefulWidget {
  const DetailedEditionInfo(
      {super.key,
      required this.editionInfo,
      required this.isNavigatingFromLibrary,
      required this.bookImage,
      this.indexOfEdition = 0});

  final bool isNavigatingFromLibrary;
  final BookWorkEditionsModelEntries editionInfo;
  final Image? bookImage;
  final int indexOfEdition;

  @override
  ConsumerState<DetailedEditionInfo> createState() =>
      _DetailedEditionInfoState();
}

class _DetailedEditionInfoState extends ConsumerState<DetailedEditionInfo> {
  bool descriptionShowMore = false;
  List<String> authorsNames = [];
  bool isLoading = false;
  bool onProgress = false;
  bool isConnected = false;
  Map doesBookAlreadyExist = {};
  bool doesBookAlreadyExistOnSql = false;
  bool doesBookAlreadyExistOnFirestore = false;
  bool isBookBeingInserted = false;
  List<Map<String, dynamic>>? notesList = [];
  bool? didStatusChanged;
  String bookStatusAsString = "";
  bool hasChangeMade = false;
  BannerAd? _banner;
  InterstitialAd? _interstitialAd;
  BookStatus? bookStatus;

  @override
  void initState() {
    if (widget.isNavigatingFromLibrary) {
      bookStatusAsString = widget.editionInfo.bookStatus!;
    }
    bookStatus = widget.editionInfo.bookStatus != null
        ? widget.editionInfo.bookStatus! == "Okumak istediklerim"
            ? BookStatus.wantToRead
            : widget.editionInfo.bookStatus! == "Şu an okuduklarım"
                ? BookStatus.currentlyReading
                : BookStatus.alreadyRead
        : BookStatus.wantToRead;
    getPageData();
    _createBannerAd();
    _createInterstitialAd();
    doesBookAlreadyExist =
        checkIfAlreadyExist(uniqueIdCreater(widget.editionInfo));

    super.initState();
  }

  @override
  void dispose() {
    _banner?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).size.width);
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, hasChangeMade);
        return Future(() => true);
      },
      child: Scaffold(
          floatingActionButton: widget.isNavigatingFromLibrary == false &&  (doesBookAlreadyExist["doesBookExistOnSql"] == false ||
                              doesBookAlreadyExist[
                                      "doesBookExistOnFirestore"] ==
                                  false)
              ? FloatingActionButton(
                  onPressed: () async {
                    doesBookAlreadyExist =
        checkIfAlreadyExist(uniqueIdCreater(widget.editionInfo));
                    await bookStatusDialog(context, toUpdate:  (doesBookAlreadyExist["doesBookExistOnSql"] == false ||
                              doesBookAlreadyExist[
                                      "doesBookExistOnFirestore"] ==
                                  false)?false:true);
                    
                  },
                  backgroundColor: const Color(0xFF1B7695),
                  tooltip: AppLocalizations.of(context)!.addToShelf,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 30,
                  ),
                )
              : null,
          bottomNavigationBar: _banner == null
              ? Container()
              : SizedBox(
                  height: 52,
                  child: AdWidget(ad: _banner!),
                ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                  pinned: true,
                  expandedHeight: Const.screenSize.height * 0.52,
                  toolbarHeight: Const.screenSize.height * 0.06,
                  actions: [
                    if (widget.editionInfo.isbn_13 != null ||
                        widget.editionInfo.isbn_10 != null)
                      IconButton(
                          tooltip:
                              AppLocalizations.of(context)!.reviewOnGoodReads,
                          onPressed: () {
                            launchUrl(Uri.parse(
                                "https://www.goodreads.com/search?q=${widget.editionInfo.isbn_13 ?? widget.editionInfo.isbn_10}"));
                          },
                          icon: Image.asset(
                              "lib/assets/images/goodreads_icon.png",
                              height: 30),
                          splashRadius: 25),
                    if (widget.editionInfo.isbn_13 != null ||
                        widget.editionInfo.isbn_10 != null)
                      IconButton(
                          tooltip:
                              AppLocalizations.of(context)!.reviewOnOpenLibrary,
                          onPressed: () {
                            launchUrl(Uri.parse(
                                "https://openlibrary.org/isbn/${widget.editionInfo.isbn_13 ?? widget.editionInfo.isbn_10}"));
                          },
                          icon: Image.asset("lib/assets/images/openlibrary.png",
                              height: 30),
                          splashRadius: 25),
                    widget.isNavigatingFromLibrary == true &&
                            FirebaseAuth.instance.currentUser != null
                        ? IconButton(
                            tooltip: AppLocalizations.of(context)!.addQuote,
                            splashRadius: 25,
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddQuoteScreen(
                                        isNavigatingFromDetailedEdition: true,
                                        showDeleteIcon: false,
                                        bookInfo: widget.editionInfo,
                                        bookImage: widget.bookImage),
                                  ));
                            },
                            icon: const Icon(
                              Icons.library_add_outlined,
                              size: 30,
                              color: Colors.white,
                            ))
                        : const SizedBox.shrink(),
                    widget.isNavigatingFromLibrary == true
                        ? IconButton(
                            tooltip: AppLocalizations.of(context)!.addNote,
                            splashRadius: 25,
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddNoteView(
                                        showDeleteIcon: false,
                                        bookInfo: widget.editionInfo,
                                        bookImage: widget.bookImage),
                                  )).then((value) {
                                if (value == true) getPageData();
                              });
                            },
                            icon: const Icon(
                              Icons.post_add_rounded,
                              size: 34,
                              color: Colors.white,
                            ))
                        : const SizedBox.shrink(),
                    IconButton(
                        color: Colors.white,
                        splashRadius: 25,
                        onPressed: () {
                          modalBottomSheetBuilderForPopUpMenu(context);
                        },
                        icon: const Icon(
                          Icons.more_vert_sharp,
                          size: 30,
                        ))
                  ],
                  leadingWidth: 50,
                  leading: IconButton(
                      color: Colors.white,
                      splashRadius: 25,
                      onPressed: () =>
                          //we are checking if we changed the book status on database and returning the result as true or false after popping we
                          //are in the library_screen_view if the value is true we call the getPageData() and get all the info with new changed data
                          Navigator.pop(context, hasChangeMade),
                      icon: const Icon(
                        Icons.arrow_back_sharp,
                        size: 30,
                      )),
                  backgroundColor: const Color(0xFF1B7695),
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: bookCoverAndDetailsBuilder(context),
                  )),
              SliverToBoxAdapter(
                child: isLoading != true
                    ? editionInfoBodyBuilder(context)
                    : detailedEditionInfoShimmerBuilder(context),
              )
            ],
          )),
    );
  }

  Container bookCoverAndDetailsBuilder(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50)),
        color: Color(0xFF1B7695),
      ),
      child: Column(children: [
        SizedBox(
          height: Const.screenSize.height * 0.11,
        ),
        widget.editionInfo.covers != null ||
                widget.editionInfo.imageAsByte != null
            ? Align(
                alignment: Alignment.center,
                child: Card(
                    elevation: 0,
                    color: Colors.transparent,
                    child: Hero(
                        tag: uniqueIdCreater(widget.editionInfo) +
                            widget.indexOfEdition,
                        child: widget.bookImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image(
                                  height: Const.screenSize.height * 0.28,
                                  width: Const.screenSize.width * 0.4,
                                  fit: BoxFit.fill,
                                  image: widget.bookImage!.image,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset("lib/assets/images/error.png",
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              2),
                                ),
                              )
                            : widget.editionInfo.covers != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image(
                                      height: Const.screenSize.height * 0.28,
                                      image: NetworkImage(
                                          "https://covers.openlibrary.org/b/id/${widget.editionInfo.covers!.first}-M.jpg"),
                                      errorBuilder: (context, error,
                                              stackTrace) =>
                                          Image.asset(
                                              "lib/assets/images/error.png",
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2),
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.asset(
                                        "lib/assets/images/nocover.jpg")))),
              )
            : Align(
                alignment: Alignment.center,
                child: Hero(
                  tag: uniqueIdCreater(widget.editionInfo),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        "lib/assets/images/nocover.jpg",
                      )),
                )),
        const SizedBox(
          height: 25,
        ),
        Container(
          decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(50)),
          width: MediaQuery.sizeOf(context).width - 30,
          height: MediaQuery.of(context).size.height / 12,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.publishDate,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.height / 50),
                  ),
                  Text(
                    widget.editionInfo.publish_date != null
                        ? "${widget.editionInfo.publish_date}"
                        : "-",
                    maxLines: 1,
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height / 60),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const VerticalDivider(),
            SizedBox(
              width: MediaQuery.of(context).size.width / 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppLocalizations.of(context)!.pageCount,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.height / 50)),
                  Text(
                    widget.editionInfo.number_of_pages != null
                        ? "${widget.editionInfo.number_of_pages}"
                        : "-",
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height / 60),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            ),
            const VerticalDivider(),
            SizedBox(
              width: MediaQuery.of(context).size.width / 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppLocalizations.of(context)!.language,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.height / 50)),
                  Text(
                    widget.editionInfo.languages != null
                        ? countryNameCreater(widget.editionInfo)
                        : "-",
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height / 60),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          ]),
        ),
        const SizedBox(
          height: 10,
        ),
      ]),
    );
  }

  void modalBottomSheetBuilderForPopUpMenu(BuildContext context) {
    doesBookAlreadyExist =
        checkIfAlreadyExist(uniqueIdCreater(widget.editionInfo));
    showModalBottomSheet(
      backgroundColor: Colors.grey.shade300,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30))),
      context: context,
      builder: (context) {
        return Column(mainAxisSize: MainAxisSize.min, children: [
          widget.isNavigatingFromLibrary == false
              ? ListTile(
                  visualDensity: const VisualDensity(vertical: 3),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30))),
                  onTap: () async {
                    if (doesBookAlreadyExist["doesBookExistOnSql"] == true ||
                        doesBookAlreadyExist["doesBookExistOnFirestore"]) {
                      await alertDialogForDeletionBuilder(context);
                    } else {
                      Navigator.pop(context);
                      await bookStatusDialog(context, toUpdate: false);
                    }
                  },
                  leading: const Icon(
                    Icons.shelves,
                    size: 30,
                  ),
                  title: Text(
                      doesBookAlreadyExist["doesBookExistOnSql"] == true ||
                              doesBookAlreadyExist[
                                      "doesBookExistOnFirestore"] ==
                                  true
                          ? AppLocalizations.of(context)!.removeFromShelf
                          : AppLocalizations.of(context)!.addToShelf,
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height / 40)),
                )
              : const SizedBox.shrink(),
          widget.isNavigatingFromLibrary == false
              ? const Divider(height: 0)
              : const SizedBox.shrink(),
          widget.isNavigatingFromLibrary == true
              ? ListTile(
                  title: Text(AppLocalizations.of(context)!.changeBookStatus,
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height / 40)),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30))),
                  leading: const Icon(
                    Icons.menu_book_rounded,
                    size: 30,
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    bool hasChangeMade = await bookStatusDialog(context,
                        initialBookStatus: widget.editionInfo.bookStatus ==
                                "Okumak istediklerim"
                            ? BookStatus.wantToRead
                            : widget.editionInfo.bookStatus ==
                                    "Şu an okuduklarım"
                                ? BookStatus.currentlyReading
                                : BookStatus.alreadyRead,
                        toUpdate: true);
                    if (hasChangeMade == true) {
                      setState(() {
                        bookStatusAsString = bookStatus == BookStatus.wantToRead
                            ? "Okumak istediklerim"
                            : bookStatus == BookStatus.currentlyReading
                                ? "Şu an okuduklarım"
                                : "Okuduklarım";
                      });
                    }
                  },
                  visualDensity: const VisualDensity(vertical: 3),
                )
              : const SizedBox.shrink(),
          widget.isNavigatingFromLibrary == true
              ? const Divider(
                  height: 0,
                )
              : const SizedBox.shrink(),
          widget.isNavigatingFromLibrary == true
              ? ListTile(
                  onTap: () async {
                    var isChanged = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddBookView(
                                  bookImage: widget.bookImage,
                                  physical_format:
                                      widget.editionInfo.physical_format,
                                  covers: widget.editionInfo.covers,
                                  title: widget.editionInfo.title,
                                  authorName:
                                      widget.editionInfo.authorsNames != null
                                          ? widget.editionInfo.authorsNames!
                                                      .isEmpty ==
                                                  false
                                              ? widget.editionInfo.authorsNames!
                                                  .first
                                              : null
                                          : null,
                                  bookStatus: bookStatusAsString,
                                  isbn10: widget.editionInfo.isbn_10 != null
                                      ? widget.editionInfo.isbn_10!.first!
                                      : widget.editionInfo.isbn_13?.first,
                                  pageNumber:
                                      widget.editionInfo.number_of_pages,
                                  publisher:
                                      widget.editionInfo.publishers?.first,
                                  publishDate: widget.editionInfo.publish_date,
                                  bookId: uniqueIdCreater(widget.editionInfo),
                                  toUpdate: true,
                                )));
                    if (isChanged == true) {
                      Navigator.pop(context, true);
                    }
                  },
                  visualDensity: const VisualDensity(vertical: 3),
                  leading: const Icon(
                    Icons.edit_document,
                    size: 30,
                  ),
                  title: Text(AppLocalizations.of(context)!.editBook,
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height / 40)),
                )
              : const SizedBox.shrink(),
          const Divider(
            height: 0,
          ),
          ListTile(
            visualDensity: const VisualDensity(vertical: 3),
            onTap: () async {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AlertForDataSource()));
            },
            leading: const Icon(
              Icons.info_outline,
              size: 30,
            ),
            title: Text(AppLocalizations.of(context)!.information,
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height / 40)),
          ),
          const Divider(height: 0),
          widget.isNavigatingFromLibrary != false
              ? ListTile(
                  visualDensity: const VisualDensity(vertical: 3),
                  onTap: () async {
                    AnalyticsService().logEvent("delete_book",
                        {"book_id": uniqueIdCreater(widget.editionInfo)});
                    hasChangeMade = true;
                    await deleteAuthorsFromSql(widget.editionInfo);
                    await deleteNote(widget.editionInfo);
                    deleteBook(widget.editionInfo);

                    Navigator.pop(context);
                    Navigator.pop(context, hasChangeMade);

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      duration: const Duration(seconds: 2),
                      content: Text(AppLocalizations.of(context)!
                          .bookSuccessfullyDeleted),
                      action: SnackBarAction(
                          label: AppLocalizations.of(context)!.okay,
                          onPressed: () {}),
                      behavior: SnackBarBehavior.floating,
                    ));
                  },
                  leading: const Icon(
                    Icons.delete,
                    size: 30,
                  ),
                  title: Text(AppLocalizations.of(context)!.delete,
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height / 40)),
                )
              : const SizedBox.shrink(),
          widget.isNavigatingFromLibrary != false
              ? const Divider(
                  height: 0,
                )
              : const SizedBox.shrink(),
        ]);
      },
    );
  }

  Future<void> deleteBook(BookWorkEditionsModelEntries bookInfo) async {
    await ref.read(sqlProvider).deleteBook(
          uniqueIdCreater(bookInfo),
        );
    if (ref.read(authProvider).currentUser != null) {
      await ref.read(firestoreProvider).deleteBook(context,
          referencePath: "usersBooks",
          userId: ref.read(authProvider).currentUser!.uid,
          bookId: uniqueIdCreater(bookInfo).toString());
    }
  }

  Future<void> deleteNote(BookWorkEditionsModelEntries bookInfo) async {
    ref.read(sqlProvider).deleteNotesFromBook(uniqueIdCreater(bookInfo));
    if (ref.read(authProvider).currentUser != null) {
      await ref.read(firestoreProvider).deleteNotes(context,
          referencePath: "usersBooks",
          userId: ref.read(authProvider).currentUser!.uid,
          bookId: uniqueIdCreater(bookInfo));
    }
  }

  Future<void> deleteAuthorsFromSql(
      BookWorkEditionsModelEntries bookInfo) async {
    ref.read(sqlProvider).deleteAuthors(uniqueIdCreater(bookInfo));
  }

  Future<dynamic> bookStatusDialog(BuildContext mainContext,
      {BookStatus? initialBookStatus, required bool toUpdate}) {
    if (initialBookStatus != null) {
      if (initialBookStatus != bookStatus) {
      } else {
        bookStatus = initialBookStatus;
      }
    }

    doesBookAlreadyExist =
        checkIfAlreadyExist(uniqueIdCreater(widget.editionInfo));

    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Center(
              child: Dialog(
                  alignment: Alignment.center,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  child: onProgress != true
                      ? Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                toUpdate == true
                                    ? AppLocalizations.of(context)!
                                        .selectNewBookStatus
                                    : AppLocalizations.of(context)!
                                        .selectStatusForBook,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              ListTile(
                                title: GestureDetector(
                                  child: Text(
                                      AppLocalizations.of(context)!.wantToRead),
                                  onTap: () => setState(() {
                                    bookStatus = BookStatus.wantToRead;
                                  }),
                                ),
                                leading: Radio<BookStatus>(
                                  value: BookStatus.wantToRead,
                                  groupValue: bookStatus,
                                  onChanged: (BookStatus? value) {
                                    setState(() {
                                      bookStatus = value!;
                                    });
                                  },
                                ),
                              ),
                              ListTile(
                                title: GestureDetector(
                                  child: Text(AppLocalizations.of(context)!
                                      .currentlyReading),
                                  onTap: () => setState(() {
                                    bookStatus = BookStatus.currentlyReading;
                                  }),
                                ),
                                leading: Radio<BookStatus>(
                                  value: BookStatus.currentlyReading,
                                  groupValue: bookStatus,
                                  onChanged: (BookStatus? value) {
                                    setState(() {
                                      bookStatus = value!;
                                    });
                                  },
                                ),
                              ),
                              ListTile(
                                title: GestureDetector(
                                  child: Text(AppLocalizations.of(context)!
                                      .alreadyRead),
                                  onTap: () => setState(() {
                                    bookStatus = BookStatus.alreadyRead;
                                  }),
                                ),
                                leading: Radio<BookStatus>(
                                  value: BookStatus.alreadyRead,
                                  groupValue: bookStatus,
                                  onChanged: (BookStatus? value) {
                                    setState(() {
                                      bookStatus = value!;
                                    });
                                  },
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text(AppLocalizations.of(context)!
                                          .cancel)),
                                  TextButton(
                                      onPressed: () async {
                                        setState(() {
                                          onProgress = true;
                                        });

                                        doesBookAlreadyExistOnFirestore =
                                            doesBookAlreadyExist[
                                                "doesBookExistOnFirestore"];
                                        doesBookAlreadyExistOnSql =
                                            doesBookAlreadyExist[
                                                "doesBookExistOnSql"];
                                        if (widget.editionInfo.bookStatus !=
                                            null) {
                                          didStatusChanged =
                                              checkIfStatusChanged(bookStatus!,
                                                  initialBookStatus);
                                        }

                                        if (widget.editionInfo.covers != null &&
                                          toUpdate==false) {
                                          AnalyticsService()
                                              .logEvent('add_to_shelf', {
                                            'book_isbn': widget.editionInfo
                                                    .isbn_10?.first ??
                                                widget.editionInfo.isbn_13
                                                    ?.first ??
                                                "",
                                            'shelf': '$bookStatus'
                                          });

                                          Uint8List? base64AsString =
                                              await readNetworkImage(
                                                  "https://covers.openlibrary.org/b/id/${widget.editionInfo.covers!.first}-M.jpg");
                                          await insertToSqlDatabase(
                                              base64AsString, context);
                                          if (ref
                                                  .read(authProvider)
                                                  .currentUser !=
                                              null) {
                                            await insertToFirestore();
                                          }

                                          ref
                                              .read(bookStateProvider.notifier)
                                              .getPageData();
                                          
                                          setState(() {
                                            bookStatusAsString = bookStatus ==
                                                BookStatus.wantToRead
                                                ? "Okumak istediklerim"
                                                : bookStatus ==
                                                        BookStatus
                                                            .currentlyReading
                                                    ? "Şu an okuduklarım"
                                                    : "Okuduklarım";
                                          });
                                        } else if (widget.editionInfo.covers ==
                                                null &&
                                            toUpdate==false) {
                                          AnalyticsService()
                                              .logEvent('add_to_shelf', {
                                            'book_isbn': widget.editionInfo
                                                    .isbn_10?.first ??
                                                widget.editionInfo.isbn_13
                                                    ?.first ??
                                                "",
                                            'shelf': '$bookStatus'
                                          });
                                          await insertToSqlDatabase(
                                              null, context);
                                          if (ref
                                                  .read(authProvider)
                                                  .currentUser !=
                                              null) {
                                            await insertToFirestore();
                                          }
                                          ref
                                              .read(bookStateProvider.notifier)
                                              .getPageData();
                                               setState(() {
                                            bookStatusAsString = bookStatus ==
                                                BookStatus.wantToRead
                                                ? "Okumak istediklerim"
                                                : bookStatus ==
                                                        BookStatus
                                                            .currentlyReading
                                                    ? "Şu an okuduklarım"
                                                    : "Okuduklarım";
                                          });
                                        } else if ( toUpdate==true) {
                                          AnalyticsService()
                                              .logEvent('change_status', {
                                            'book_isbn': widget.editionInfo
                                                    .isbn_10?.first ??
                                                widget.editionInfo.isbn_13
                                                    ?.first ??
                                                "",
                                            'old_status':
                                                widget.editionInfo.bookStatus ??
                                                    "",
                                            'new_status': '$bookStatus'
                                          });
                                          hasChangeMade = true;
                                          updateBookStatus(
                                              uniqueIdCreater(
                                                  widget.editionInfo),
                                              bookStatus!,
                                              doesBookAlreadyExistOnFirestore,
                                              doesBookAlreadyExistOnSql);
                                            
                                          setState(() {
                                            bookStatusAsString = bookStatus ==
                                                BookStatus.wantToRead
                                                ? "Okumak istediklerim"
                                                : bookStatus ==
                                                        BookStatus
                                                            .currentlyReading
                                                    ? "Şu an okuduklarım"
                                                    : "Okuduklarım";
                                          });

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            duration:
                                                const Duration(seconds: 3),
                                            content: Text(AppLocalizations.of(
                                                    context)!
                                                .bookStatusUpdatedSuccessfully),
                                            action: SnackBarAction(
                                                label: AppLocalizations.of(
                                                        context)!
                                                    .okay,
                                                onPressed: () {}),
                                            behavior: SnackBarBehavior.floating,
                                          ));
                                        }
                                        if (initialBookStatus != null) {
                                          _showInterstitialAd();
                                        }

                                        setState(() {
                                          onProgress = false;
                                        });
                                        
                                        Navigator.pop(context, hasChangeMade);
                                      },
                                      child: Text(AppLocalizations.of(context)!
                                          .confirm))
                                ],
                              )
                            ],
                          ),
                        )
                      : const SizedBox(
                          width: 200,
                          height: 200,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: CircularProgressIndicator(),
                              ),
                            ],
                          ),
                        )),
            );
          },
        );
      },
    );
  }

  Future<void> insertToFirestore() async {
    BookWorkEditionsModelEntries editionInfo = widget.editionInfo;

    List<int?>? coverList = [];
    editionInfo.covers != null
        ? coverList = [editionInfo.covers!.first]
        : coverList = null;

    return await ref.read(firestoreProvider).setBookData(
          context,
          collectionPath: "usersBooks",
          bookAsMap: {
            "title": editionInfo.title,
            "number_of_pages": editionInfo.number_of_pages,
            "covers": editionInfo.covers != null ? coverList : null,
            "bookStatus": bookStatus == BookStatus.alreadyRead
                ? "Okuduklarım"
                : bookStatus == BookStatus.currentlyReading
                    ? "Şu an okuduklarım"
                    : "Okumak istediklerim",
            "publishers": editionInfo.publishers,
            "physical_format": editionInfo.physical_format,
            "publish_date": editionInfo.publish_date,
            "isbn_10": editionInfo.isbn_10,
            "isbn_13": editionInfo.isbn_13,
            "authorsNames": authorsNames,
            "description": editionInfo.description,
            "languages": editionInfo.languages?.first?.key
          },
          userId: ref.read(authProvider).currentUser!.uid,
        );
  }

  Future<void> insertToSqlDatabase(
      Uint8List? imageAsByte, BuildContext context) async {
    for (var element in authorsNames) {
      await ref
          .read(sqlProvider)
          .insertAuthors(element, uniqueIdCreater(widget.editionInfo), context);
    }

    await ref
        .read(sqlProvider)
        .insertBook(
            widget.editionInfo,
            bookStatus == BookStatus.alreadyRead
                ? "Okuduklarım"
                : bookStatus == BookStatus.currentlyReading
                    ? "Şu an okuduklarım"
                    : "Okumak istediklerim",
            imageAsByte,
            context)
        .whenComplete(() => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: const Duration(seconds: 1),
              content: Text(
                  AppLocalizations.of(context)!.bookSuccessfullyAddedToLibrary),
              action: SnackBarAction(
                  label: AppLocalizations.of(context)!.okay, onPressed: () {}),
              behavior: SnackBarBehavior.floating,
            )));
  }

  Future<void> updateBookStatus(
      int bookId,
      BookStatus newBookStatus,
      bool doesBookAlreadyExistOnFirestore,
      bool doesBookAlreadyExistOnSql) async {
    if (doesBookAlreadyExistOnSql == true) {
      await ref.read(sqlProvider).updateBook(
          bookId,
          newBookStatus == BookStatus.alreadyRead
              ? "Okuduklarım"
              : newBookStatus == BookStatus.currentlyReading
                  ? "Şu an okuduklarım"
                  : "Okumak istediklerim",
          context);
    }

    if (ref.read(authProvider).currentUser != null &&
        isConnected != false &&
        doesBookAlreadyExistOnFirestore == true) {
      ref.read(firestoreProvider).updateBookStatus(context,
          collectionPath: 'usersBooks',
          newBookStatus: newBookStatus == BookStatus.alreadyRead
              ? "Okuduklarım"
              : newBookStatus == BookStatus.currentlyReading
                  ? "Şu an okuduklarım"
                  : "Okumak istediklerim",
          userId: ref.read(authProvider).currentUser!.uid,
          uniqueBookId: bookId);
    }
  }

  Future<Uint8List?> readNetworkImage(String imageUrl) async {
    try {
      final ByteData data =
          await NetworkAssetBundle(Uri.parse(imageUrl)).load(imageUrl);
      final Uint8List bytes = data.buffer.asUint8List();
      return bytes;
    } catch (e) {
      return null;
    }
  }

  Scrollbar editionInfoBodyBuilder(BuildContext context) {
    String? joinedText;
    if (widget.editionInfo.authorsNames != null && authorsNames.isEmpty) {
      joinedText = widget.editionInfo.authorsNames!.join("\n");
    }
    if (widget.editionInfo.authorsNames == null && authorsNames.isNotEmpty) {
      joinedText = authorsNames.join("\n");
    }

    String descriptionText = "";
    if (widget.editionInfo.description != null) {
      descriptionText = widget.editionInfo.description!.startsWith("{")
          ? widget.editionInfo.description!.replaceRange(0, 26, "")
          : widget.editionInfo.description!;
    }
    return Scrollbar(
      thickness: 3,
      radius: const Radius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.title,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: MediaQuery.of(context).size.height / 50,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: Const.minSize,
            ),
            SizedBox(
              width: MediaQuery.sizeOf(context).width - 40,
              child: Text(
                widget.editionInfo.title!,
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height / 60),
              ),
            ),
            if ((widget.editionInfo.authorsNames != null &&
                    widget.editionInfo.authorsNames!.isNotEmpty) ||
                authorsNames.isNotEmpty)
              SizedBox(
                height: Const.minSize,
              ),
            if ((widget.editionInfo.authorsNames != null &&
                    widget.editionInfo.authorsNames!.isNotEmpty) ||
                authorsNames.isNotEmpty)
              Text(
                AppLocalizations.of(context)!.authors,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: MediaQuery.of(context).size.height / 50,
                    fontWeight: FontWeight.bold),
              ),
            if ((widget.editionInfo.authorsNames != null &&
                    widget.editionInfo.authorsNames!.isNotEmpty) ||
                authorsNames.isNotEmpty)
              SizedBox(
                height: Const.minSize,
              ),
            if (widget.editionInfo.authorsNames == null &&
                authorsNames.isNotEmpty)
              Text(
                joinedText!,
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height / 60),
              ),
            if ((widget.editionInfo.authorsNames != null &&
                    widget.editionInfo.authorsNames!.isNotEmpty) &&
                authorsNames.isEmpty)
              Text(
                joinedText!,
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height / 60),
              ),
            if (widget.editionInfo.description != null)
              SizedBox(
                height: Const.minSize,
              ),
            if (widget.editionInfo.description != null)
              Text(
                AppLocalizations.of(context)!.description,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: MediaQuery.of(context).size.height / 50,
                    fontWeight: FontWeight.bold),
              ),
            if (widget.editionInfo.description != null)
              SizedBox(
                height: Const.minSize,
              ),
            if (widget.editionInfo.description != null)
              SizedBox(
                width: MediaQuery.sizeOf(context).width - 40,
                child: descriptionShowMore == false
                    ? Text(
                        widget.editionInfo.description!.startsWith("{")
                            ? descriptionText.replaceRange(
                                descriptionText.length - 1,
                                descriptionText.length,
                                "")
                            : descriptionText,
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height / 60),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      )
                    : Text(
                        widget.editionInfo.description!.startsWith("{")
                            ? descriptionText.replaceRange(
                                descriptionText.length - 1,
                                descriptionText.length,
                                "")
                            : descriptionText,
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height / 60),
                      ),
              ),
            if (widget.editionInfo.description != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                    onPressed: () {
                      setState(() {
                        descriptionShowMore = !descriptionShowMore;
                      });
                    },
                    child: descriptionShowMore == false
                        ? Text(AppLocalizations.of(context)!.showMore,
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height / 60))
                        : Text(AppLocalizations.of(context)!.showLess,
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height / 60))),
              ),
            if (widget.editionInfo.publishers != null)
              SizedBox(
                height: Const.minSize,
              ),
            if (widget.editionInfo.publishers != null)
              Text(
                AppLocalizations.of(context)!.publisher,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: MediaQuery.of(context).size.height / 50,
                    fontWeight: FontWeight.bold),
              ),
            if (widget.editionInfo.publishers != null)
              SizedBox(
                height: Const.minSize,
              ),
            if (widget.editionInfo.publishers != null)
              SizedBox(
                  width: MediaQuery.sizeOf(context).width - 40,
                  child: Text(
                    widget.editionInfo.publishers!.first!,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: MediaQuery.of(context).size.height / 60),
                  )),
            if (widget.editionInfo.physical_format != null)
              SizedBox(
                height: Const.minSize,
              ),
            if (widget.editionInfo.physical_format != null)
              Text(
                AppLocalizations.of(context)!.bookFormat,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: MediaQuery.of(context).size.height / 50,
                    fontWeight: FontWeight.bold),
              ),
            if (widget.editionInfo.physical_format != null)
              SizedBox(
                height: Const.minSize,
              ),
            if (widget.editionInfo.physical_format != null)
              SizedBox(
                width: MediaQuery.sizeOf(context).width - 40,
                child: widget.editionInfo.physical_format == "paperback" ||
                        widget.editionInfo.physical_format == "Paperback"
                    ? Text(
                        AppLocalizations.of(context)!.paperback,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: MediaQuery.of(context).size.height / 60,
                        ),
                      )
                    : widget.editionInfo.physical_format == "hardcover" ||
                            widget.editionInfo.physical_format == "Hardcover"
                        ? Text(
                            AppLocalizations.of(context)!.hardcover,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: MediaQuery.of(context).size.height / 60,
                            ),
                          )
                        : widget.editionInfo.physical_format == "E-book" ||
                                widget.editionInfo.physical_format == "Ebook"
                            ? Text(
                                AppLocalizations.of(context)!.ebook,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize:
                                      MediaQuery.of(context).size.height / 60,
                                ),
                              )
                            : Text(
                                widget.editionInfo.physical_format!,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize:
                                      MediaQuery.of(context).size.height / 60,
                                ),
                              ),
              ),
            if (widget.editionInfo.isbn_10 != null)
              SizedBox(
                height: Const.minSize,
              ),
            if (widget.editionInfo.isbn_10 != null)
              Text(
                "Isbn 10",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: MediaQuery.of(context).size.height / 50,
                    fontWeight: FontWeight.bold),
              ),
            if (widget.editionInfo.isbn_10 != null)
              SizedBox(
                height: Const.minSize,
              ),
            if (widget.editionInfo.isbn_10 != null)
              SizedBox(
                  width: MediaQuery.sizeOf(context).width - 40,
                  child: Text(
                    widget.editionInfo.isbn_10!.first!,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: MediaQuery.of(context).size.height / 60),
                  )),
            if (widget.editionInfo.isbn_13 != null)
              SizedBox(
                height: Const.minSize,
              ),
            if (widget.editionInfo.isbn_13 != null)
              Text(
                "Isbn 13",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: MediaQuery.of(context).size.height / 50,
                    fontWeight: FontWeight.bold),
              ),
            if (widget.editionInfo.isbn_13 != null)
              SizedBox(
                height: Const.minSize,
              ),
            if (widget.editionInfo.isbn_13 != null)
              SizedBox(
                  width: MediaQuery.sizeOf(context).width - 40,
                  child: Text(
                    widget.editionInfo.isbn_13!.first!,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: MediaQuery.of(context).size.height / 60),
                  )),
            if (widget.editionInfo.bookStatus != null ||(doesBookAlreadyExist["doesBookExistOnSql"] == true ||doesBookAlreadyExist["doesBookExistOnFirestore"] == true))
              SizedBox(
                height: Const.minSize,
              ),
            if (widget.editionInfo.bookStatus != null ||(doesBookAlreadyExist["doesBookExistOnSql"] == true ||doesBookAlreadyExist["doesBookExistOnFirestore"] == true))
              Text(
                AppLocalizations.of(context)!.bookStatus,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: MediaQuery.of(context).size.height / 50,
                    fontWeight: FontWeight.bold),
              ),
            if (widget.editionInfo.bookStatus != null ||(doesBookAlreadyExist["doesBookExistOnSql"] == true ||doesBookAlreadyExist["doesBookExistOnFirestore"] == true))
              SizedBox(
                height: Const.minSize,
              ),
            if (widget.editionInfo.bookStatus != null ||(doesBookAlreadyExist["doesBookExistOnSql"] == true ||doesBookAlreadyExist["doesBookExistOnFirestore"] == true))
              SizedBox(
                  width: MediaQuery.sizeOf(context).width - 40,
                  child: Text(
                    bookStatusAsString == "Okumak istediklerim"
                        ? AppLocalizations.of(context)!.wantToRead
                        : bookStatusAsString == "Şu an okuduklarım"
                            ? AppLocalizations.of(context)!.currentlyReading
                            : AppLocalizations.of(context)!.alreadyRead,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: MediaQuery.of(context).size.height / 60),
                  )),
            if (notesList != null)
              SizedBox(
                height: Const.minSize,
              ),
            if (notesList!.isEmpty != true)
              Text(
                AppLocalizations.of(context)!.notes,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: MediaQuery.of(context).size.height / 50,
                    fontWeight: FontWeight.bold),
              ),
            if (notesList!.isEmpty != true) notesBuilder()
          ],
        ),
      ),
    );
  }

  Future getPageData() async {
    doesBookAlreadyExist =
        checkIfAlreadyExist(uniqueIdCreater(widget.editionInfo));
    isConnected = ref.read(connectivityProvider).isConnected;

    setState(() {
      isLoading = true;
    });

    if (widget.editionInfo.authors != null && isConnected != false) {
      await getAuthorsNames();
    }
    await getNotes(uniqueIdCreater(widget.editionInfo));
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget notesBuilder() {
    return SizedBox(
      height:
          (200 * notesList!.length).toDouble() + (15 * notesList!.length - 1),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (context, index) => SizedBox(
          height: Const.minSize,
        ),
        itemCount: notesList!.length,
        itemBuilder: (context, index) => InkWell(
            customBorder:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            onTap: () {
              Image? getImage = widget.bookImage;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddNoteView(
                            noteId: notesList![index]['id'],
                            initialNoteValue: notesList![index]['note'],
                            bookImage: getImage ??
                                (widget.editionInfo.covers != null
                                    ? Image(
                                        image: NetworkImage(
                                            "https://covers.openlibrary.org/b/id/${widget.editionInfo.covers!.first!}-M.jpg"),
                                        errorBuilder: (context, error,
                                                stackTrace) =>
                                            Image.asset(
                                                "lib/assets/images/error.png"),
                                      )
                                    : null),
                            showDeleteIcon: true,
                            bookInfo: widget.editionInfo,
                            noteDate: notesList![index]['noteDate'],
                          ))).then((value) => getPageData());
            },
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(25)),
              height: Const.screenSize.height * 0.2,
              width: MediaQuery.sizeOf(context).width - 40,
              child: ListTile(
                title: Text((index + 1).toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height / 60)),
                subtitle: Text(notesList![index]['note'],
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height / 60)),
              ),
            )),
      ),
    );
  }

  Future getAuthorsNames() async {
    List<String> authorsNamesList = [];
    for (var element in widget.editionInfo.authors!) {
      AuthorsModel? author = await ref
          .read(booksProvider)
          .getAuthorInfo(element!.key!, true, context);
      if (author != null) {
        if (author.name != null) {
          authorsNamesList.add(author.name!);
        } else if (author.personalName != null) {
          authorsNamesList.add(author.personalName!);
        } else if (author.alternateNames != null) {
          authorsNamesList.add(author.alternateNames!.first!);
        }
      }
    }

    return authorsNames = authorsNamesList;
  }

  Map<String, dynamic> checkIfAlreadyExist(int bookId) {
    bool doesBookExistOnSql = false;
    bool doesBookExistOnFirestore = false;
    List<int>? bookIdsFromSql = [];
    List<BookWorkEditionsModelEntries>? booksListFromSql =
        ref.read(bookStateProvider).listOfBooksFromSql;
    List<BookWorkEditionsModelEntries>? booksListFromFirestore =
        ref.read(bookStateProvider).listOfBooksFromFirestore;
    List<int>? bookIdsFromFirestore = [];


    if (ref.read(authProvider).currentUser != null &&
        booksListFromFirestore != []) {
      bookIdsFromFirestore =
          booksListFromFirestore.map((e) => uniqueIdCreater(e)).toList();
    }
    if (booksListFromSql != []) {
      bookIdsFromSql = booksListFromSql.map((e) => uniqueIdCreater(e)).toList();
    }

    if (bookIdsFromFirestore.contains(bookId)) {
      doesBookExistOnFirestore = true;
    }
    if (bookIdsFromSql.contains(bookId)) {
      doesBookExistOnSql = true;
    }

    return {
      "doesBookExistOnSql": doesBookExistOnSql,
      "doesBookExistOnFirestore": doesBookExistOnFirestore
    };
  }

  bool checkIfStatusChanged(BookStatus chosenStatus, BookStatus? oldStatus) {
    if (chosenStatus == oldStatus) {
      return false;
    } else {
      return true;
    }
  }

  Future<void> getNotes(int bookId) async {
    notesList = await ref.read(sqlProvider).getNotes(context, bookId: bookId);
  }

  Future<String?> getNewStatus(int bookId) async {
    return await ref.read(sqlProvider).getNewStatus(context, bookId);
  }

  Future<dynamic> alertDialogForDeletionBuilder(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return CustomAlertDialog(
            title: Const.appName,
            description: AppLocalizations.of(context)!.confirmDeleteBook,
            firstButtonText: AppLocalizations.of(context)!.close,
            firstButtonOnPressed: () {
              Navigator.pop(context);
            },
            thirdButtonText: AppLocalizations.of(context)!.delete,
            thirdButtonOnPressed: () async {
              AnalyticsService().logEvent('remove_from_shelf', {
                'book_isbn': widget.editionInfo.isbn_10?.first ??
                    widget.editionInfo.isbn_13?.first ??
                    "",
                'shelf': '$bookStatus'
              });
              await deleteAuthorsFromSql(widget.editionInfo);
              await deleteNote(widget.editionInfo);
              deleteBook(widget.editionInfo);

              ref.read(bookStateProvider.notifier).getPageData();
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                duration: const Duration(seconds: 1),
                content:
                    Text(AppLocalizations.of(context)!.bookSuccessfullyDeleted),
                action: SnackBarAction(
                    label: AppLocalizations.of(context)!.okay,
                    onPressed: () {}),
                behavior: SnackBarBehavior.floating,
              ));
            });
      },
    );
  }

  void _createBannerAd() {
    _banner = BannerAd(
        size: AdSize.getInlineAdaptiveBannerAdSize(
            Const.screenSize.width.floor(), 50),
        adUnitId: 'ca-app-pub-1939809254312142/9271243251',
        listener: bannerAdListener,
        request: const AdRequest())
      ..load();
    AnalyticsService().logAdImpression("bannerAd");
  }

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: "ca-app-pub-1939809254312142/8112374131",
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) => _interstitialAd = ad,
          onAdFailedToLoad: (error) => _interstitialAd = null,
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();

          _createInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _createInterstitialAd();
        },
      );
      _interstitialAd!.show();
      AnalyticsService().logAdImpression("InterstitialAd");

      _interstitialAd = null;
    }
  }

  final BannerAdListener bannerAdListener = BannerAdListener(
    onAdLoaded: (ad) => debugPrint("adloaded"),
    onAdFailedToLoad: (ad, error) {
      ad.dispose();
      debugPrint("adfailed to load");
    },
    onAdOpened: (ad) => debugPrint("ad opened"),
  );
}
