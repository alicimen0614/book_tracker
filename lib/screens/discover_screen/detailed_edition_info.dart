import 'package:book_tracker/const.dart';
import 'package:book_tracker/models/authors_model.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/discover_screen/shimmer_effect_builders/detailed_edition_view_shimmer.dart';
import 'package:book_tracker/screens/home_screen/add_quote_screen.dart';
import 'package:book_tracker/screens/library_screen/add_book_view.dart';
import 'package:book_tracker/screens/library_screen/add_note_view.dart';
import 'package:book_tracker/screens/user_screen/alert_for_data_source.dart';
import 'package:book_tracker/services/internet_connection_service.dart';
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

  List<Map<String, dynamic>>? notesList = [];
  bool doesBookHasSameStatus = false;
  String bookStatusAsString = "";
  bool hasChangeMade = false;
  BannerAd? _banner;
  InterstitialAd? _interstitialAd;

  BookStatus bookStatus = BookStatus.wantToRead;

  @override
  void initState() {
    if (widget.isNavigatingFromLibrary) {
      bookStatusAsString = widget.editionInfo.bookStatus!;
    }
    getPageData();
    _createBannerAd();
    _createInterstitialAd();

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
          bottomNavigationBar: _banner == null
              ? Container()
              : Container(
                  height: 52,
                  child: AdWidget(ad: _banner!),
                ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            actions: [
              widget.editionInfo.isbn_13 != null ||
                      widget.editionInfo.isbn_10 != null
                  ? IconButton(
                      onPressed: () {
                        launchUrl(Uri.parse(
                            "https://www.goodreads.com/search?q=${widget.editionInfo.isbn_13 ?? widget.editionInfo.isbn_10}"));
                      },
                      icon: Image.asset("lib/assets/images/goodreads_icon.png",
                          height: 30),
                      splashRadius: 25)
                  : const SizedBox.shrink(),
              widget.isNavigatingFromLibrary == true
                  ? IconButton(
                      tooltip: "Alıntı Ekle",
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
                      tooltip: "Not Ekle",
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
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              bookCoverAndDetailsBuilder(context),
              isLoading != true
                  ? editionInfoBodyBuilder(context)
                  : detailedEditionInfoShimmerBuilder(context)
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
                                  height: 250,
                                  width: 180,
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
                                      height: 290,
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
                    "Yayın Tarihi",
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
                  Text("Sayfa Sayısı",
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
                  Text("Dil",
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
                    Navigator.pop(context);
                    await bookStatusDialog(context);
                  },
                  leading: const Icon(
                    Icons.shelves,
                    size: 30,
                  ),
                  title: Text("Rafa ekle",
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height / 40)),
                )
              : const SizedBox.shrink(),
          widget.isNavigatingFromLibrary == false
              ? const Divider(height: 0)
              : const SizedBox.shrink(),
          widget.isNavigatingFromLibrary == true
              ? ListTile(
                  title: Text("Kitap durumunu değiştir",
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
                  onTap: () {
                    Navigator.pop(context);
                    bookStatusDialog(context,
                            initialBookStatus: widget.editionInfo.bookStatus ==
                                    "Okumak istediklerim"
                                ? BookStatus.wantToRead
                                : widget.editionInfo.bookStatus ==
                                        "Şu an okuduklarım"
                                    ? BookStatus.currentlyReading
                                    : BookStatus.alreadyRead)
                        .then((didChanged) {
                      getNewStatus(uniqueIdCreater(widget.editionInfo))
                          .then((value) {
                        if (value != null) {
                          setState(() {
                            bookStatus = value == "Okumak istediklerim"
                                ? BookStatus.wantToRead
                                : value == "Şu an okuduklarım"
                                    ? BookStatus.currentlyReading
                                    : BookStatus.alreadyRead;
                            bookStatusAsString = value;
                          });
                        }
                      });
                    });
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
                  title: Text("Kitabı düzenle",
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
            title: Text("Bilgi",
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height / 40)),
          ),
          const Divider(height: 0),
          widget.isNavigatingFromLibrary != false
              ? ListTile(
                  visualDensity: const VisualDensity(vertical: 3),
                  onTap: () async {
                    hasChangeMade = true;
                    await deleteAuthorsFromSql(widget.editionInfo);
                    await deleteNote(widget.editionInfo);
                    deleteBook(widget.editionInfo);

                    Navigator.pop(context);
                    Navigator.pop(context, hasChangeMade);

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      duration: const Duration(seconds: 2),
                      content: const Text('Kitap başarıyla silindi.'),
                      action: SnackBarAction(label: 'Tamam', onPressed: () {}),
                      behavior: SnackBarBehavior.floating,
                    ));
                  },
                  leading: const Icon(
                    Icons.delete,
                    size: 30,
                  ),
                  title: Text("Sil",
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
      {BookStatus? initialBookStatus}) {
    if (initialBookStatus != null) {
      bookStatus = initialBookStatus;
    }

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
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Yeni kitap durumunu seçiniz.",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              ListTile(
                                title: GestureDetector(
                                  child: const Text("Okumak istediklerim"),
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
                                  child: const Text("Şu an okuduklarım"),
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
                                  child: const Text("Okuduklarım"),
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
                                      child: const Text("Vazgeç")),
                                  TextButton(
                                      onPressed: () async {
                                        _showInterstitialAd();

                                        setState(() {
                                          onProgress = true;
                                        });
                                        doesBookAlreadyExist =
                                            await checkIfAlreadyExist(
                                                uniqueIdCreater(
                                                    widget.editionInfo));
                                        doesBookAlreadyExistOnFirestore =
                                            doesBookAlreadyExist[
                                                "doesBookExistOnFirestore"];
                                        doesBookAlreadyExistOnSql =
                                            doesBookAlreadyExist[
                                                "doesBookExistOnSql"];

                                        doesBookHasSameStatus =
                                            checkIfBookHasSameStatus(
                                                bookStatus, initialBookStatus);

                                        if (widget.editionInfo.covers != null &&
                                            (doesBookAlreadyExistOnFirestore !=
                                                    true ||
                                                doesBookAlreadyExistOnSql !=
                                                    true) &&
                                            doesBookHasSameStatus != true) {
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
                                        } else if (widget.editionInfo.covers ==
                                                null &&
                                            (doesBookAlreadyExistOnFirestore !=
                                                    true ||
                                                doesBookAlreadyExistOnSql !=
                                                    true) &&
                                            doesBookHasSameStatus != true) {
                                          await insertToSqlDatabase(
                                              null, context);
                                          if (ref
                                                  .read(authProvider)
                                                  .currentUser !=
                                              null) {
                                            await insertToFirestore();
                                          }
                                        } else if ((doesBookAlreadyExistOnFirestore ==
                                                    true ||
                                                doesBookAlreadyExistOnSql ==
                                                    true) &&
                                            doesBookHasSameStatus == false) {
                                          hasChangeMade = true;
                                          updateBookStatus(
                                              uniqueIdCreater(
                                                  widget.editionInfo),
                                              bookStatus,
                                              doesBookAlreadyExistOnFirestore,
                                              doesBookAlreadyExistOnSql);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            duration:
                                                const Duration(seconds: 3),
                                            content: const Text(
                                                'Kitap durumu başarıyla güncellendi.'),
                                            action: SnackBarAction(
                                                label: 'Tamam',
                                                onPressed: () {}),
                                            behavior: SnackBarBehavior.floating,
                                          ));
                                        } else {
                                          hasChangeMade = false;
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            duration:
                                                const Duration(seconds: 1),
                                            content: const Text(
                                                'Bu kitap zaten kitaplığınızda mevcut.'),
                                            action: SnackBarAction(
                                                label: 'Tamam',
                                                onPressed: () {}),
                                            behavior: SnackBarBehavior.floating,
                                          ));
                                        }

                                        setState(() {
                                          onProgress = false;
                                        });

                                        Navigator.pop(context);
                                      },
                                      child: const Text("Onayla"))
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
              content: const Text('Kitap başarıyla kitaplığına eklendi.'),
              action: SnackBarAction(label: 'Tamam', onPressed: () {}),
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

  Expanded editionInfoBodyBuilder(BuildContext context) {
    String descriptionText = "";
    if (widget.editionInfo.description != null) {
      descriptionText = widget.editionInfo.description!.startsWith("{")
          ? widget.editionInfo.description!.replaceRange(0, 26, "")
          : widget.editionInfo.description!;
    }
    return Expanded(
      child: Scrollbar(
        thickness: 3,
        radius: const Radius.circular(20),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Başlık",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: MediaQuery.of(context).size.height / 50,
                    fontWeight: FontWeight.bold),
              ),
              const Divider(color: Colors.transparent, thickness: 0),
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
                const Divider(color: Colors.transparent, thickness: 0),
              if ((widget.editionInfo.authorsNames != null &&
                      widget.editionInfo.authorsNames!.isNotEmpty) ||
                  authorsNames.isNotEmpty)
                Text(
                  "Yazarlar",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.height / 50,
                      fontWeight: FontWeight.bold),
                ),
              if ((widget.editionInfo.authorsNames != null &&
                      widget.editionInfo.authorsNames!.isNotEmpty) ||
                  authorsNames.isNotEmpty)
                const Divider(color: Colors.transparent, thickness: 0),
              if (widget.editionInfo.authorsNames == null &&
                  authorsNames.isNotEmpty)
                SizedBox(
                    height: widget.editionInfo.authors!.length * 25,
                    child: ListView.separated(
                      separatorBuilder: (context, index) => const SizedBox(
                        height: 5,
                      ),
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.editionInfo.authors!.length,
                      itemBuilder: (context, index) => Text(
                        authorsNames[index],
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height / 60),
                      ),
                    )),
              if (widget.editionInfo.authorsNames != null &&
                  authorsNames.isEmpty)
                SizedBox(
                    height: widget.editionInfo.authorsNames!.length * 25,
                    child: ListView.separated(
                      separatorBuilder: (context, index) => const SizedBox(
                        height: 5,
                      ),
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.editionInfo.authorsNames!.length,
                      itemBuilder: (context, index) => Text(
                        widget.editionInfo.authorsNames![index]!,
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height / 60),
                      ),
                    )),
              if (widget.editionInfo.description != null)
                const Divider(color: Colors.transparent, thickness: 0),
              if (widget.editionInfo.description != null)
                Text(
                  "Açıklama",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.height / 50,
                      fontWeight: FontWeight.bold),
                ),
              if (widget.editionInfo.description != null)
                const Divider(color: Colors.transparent, thickness: 0),
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
                              fontSize:
                                  MediaQuery.of(context).size.height / 60),
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
                              fontSize:
                                  MediaQuery.of(context).size.height / 60),
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
                          ? Text("Daha fazla göster",
                              style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.height / 60))
                          : Text("Daha az göster",
                              style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.height /
                                      60))),
                ),
              if (widget.editionInfo.publishers != null)
                const Divider(color: Colors.transparent, thickness: 0),
              if (widget.editionInfo.publishers != null)
                Text(
                  "Yayıncı",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.height / 50,
                      fontWeight: FontWeight.bold),
                ),
              if (widget.editionInfo.publishers != null)
                const Divider(color: Colors.transparent, thickness: 0),
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
                const Divider(color: Colors.transparent, thickness: 0),
              if (widget.editionInfo.physical_format != null)
                Text(
                  "Kitap formatı",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.height / 50,
                      fontWeight: FontWeight.bold),
                ),
              if (widget.editionInfo.physical_format != null)
                const Divider(color: Colors.transparent, thickness: 0),
              if (widget.editionInfo.physical_format != null)
                SizedBox(
                  width: MediaQuery.sizeOf(context).width - 40,
                  child: widget.editionInfo.physical_format == "paperback" ||
                          widget.editionInfo.physical_format == "Paperback"
                      ? Text(
                          "Ciltsiz",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.height / 60,
                          ),
                        )
                      : widget.editionInfo.physical_format == "hardcover" ||
                              widget.editionInfo.physical_format == "Hardcover"
                          ? Text(
                              "Ciltli",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize:
                                    MediaQuery.of(context).size.height / 60,
                              ),
                            )
                          : widget.editionInfo.physical_format == "E-book" ||
                                  widget.editionInfo.physical_format == "Ebook"
                              ? Text(
                                  "E-kitap",
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
                const Divider(color: Colors.transparent, thickness: 0),
              if (widget.editionInfo.isbn_10 != null)
                Text(
                  "Isbn 10",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.height / 50,
                      fontWeight: FontWeight.bold),
                ),
              if (widget.editionInfo.isbn_10 != null)
                const Divider(color: Colors.transparent, thickness: 0),
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
                const Divider(color: Colors.transparent, thickness: 0),
              if (widget.editionInfo.isbn_13 != null)
                Text(
                  "Isbn 13",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.height / 50,
                      fontWeight: FontWeight.bold),
                ),
              if (widget.editionInfo.isbn_13 != null)
                const Divider(color: Colors.transparent, thickness: 0),
              if (widget.editionInfo.isbn_13 != null)
                SizedBox(
                    width: MediaQuery.sizeOf(context).width - 40,
                    child: Text(
                      widget.editionInfo.isbn_13!.first!,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: MediaQuery.of(context).size.height / 60),
                    )),
              if (widget.editionInfo.bookStatus != null)
                const Divider(color: Colors.transparent, thickness: 0),
              if (widget.editionInfo.bookStatus != null)
                Text(
                  "Kitap durumu",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.height / 50,
                      fontWeight: FontWeight.bold),
                ),
              if (widget.editionInfo.bookStatus != null)
                const Divider(color: Colors.transparent, thickness: 0),
              if (widget.editionInfo.bookStatus != null)
                SizedBox(
                    width: MediaQuery.sizeOf(context).width - 40,
                    child: Text(
                      bookStatusAsString,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: MediaQuery.of(context).size.height / 60),
                    )),
              if (notesList != null)
                const Divider(color: Colors.transparent, thickness: 0),
              if (notesList!.isEmpty != true)
                Text(
                  "Notlar",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.height / 50,
                      fontWeight: FontWeight.bold),
                ),
              if (notesList!.isEmpty != true)
                const Divider(color: Colors.transparent, thickness: 0),
              if (notesList!.isEmpty != true) notesBuilder()
            ],
          ),
        ),
      ),
    );
  }

  Future getPageData() async {
    isConnected = await checkForInternetConnection();

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
        separatorBuilder: (context, index) =>
            const Divider(color: Colors.transparent, thickness: 0),
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
              height: 200,
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

  Future<Map> checkIfAlreadyExist(int bookId) async {
    bool doesBookExistOnSql = false;
    bool doesBookExistOnFirestore = false;
    List<int>? bookIdsFromSql = [];
    List<BookWorkEditionsModelEntries>? booksListFromSql =
        await ref.read(sqlProvider).getBookShelf();
    List<BookWorkEditionsModelEntries>? booksListFromFirestore = [];
    List<int>? bookIdsFromFirestore = [];

    if (isConnected == true && ref.read(authProvider).currentUser != null) {
      var data = await ref
          .read(firestoreProvider)
          .getBooks("usersBooks", ref.read(authProvider).currentUser!.uid);
      if (data != null) {
        booksListFromFirestore = data.docs
            .map(
              (e) => BookWorkEditionsModelEntries.fromJson(e.data()),
            )
            .toList();

        bookIdsFromFirestore =
            booksListFromFirestore.map((e) => uniqueIdCreater(e)).toList();
      }
    }
    if (booksListFromSql != null) {
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

  bool checkIfBookHasSameStatus(
      BookStatus chosenStatus, BookStatus? oldStatus) {
    if (chosenStatus == oldStatus) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> getNotes(int bookId) async {
    notesList = await ref.read(sqlProvider).getNotes(context, bookId: bookId);
  }

  Future<String?> getNewStatus(int bookId) async {
    return await ref.read(sqlProvider).getNewStatus(context, bookId);
  }

  void _createBannerAd() {
    _banner = BannerAd(
        size: AdSize.getInlineAdaptiveBannerAdSize(
            Const.screenSize.width.floor(), 50),
        adUnitId: 'ca-app-pub-1939809254312142/9271243251',
        listener: bannerAdListener,
        request: const AdRequest())
      ..load();
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
