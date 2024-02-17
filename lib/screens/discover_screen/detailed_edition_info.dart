import 'package:book_tracker/const.dart';
import 'package:book_tracker/models/authors_model.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/discover_screen/shimmer_effect_builders/detailed_edition_view_shimmer.dart';
import 'package:book_tracker/screens/library_screen/add_note_view.dart';
import 'package:book_tracker/services/internet_connection_service.dart';
import 'package:book_tracker/widgets/bottom_navigation_bar_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

enum BookStatus { wantToRead, currentlyReading, alreadyRead }

class DetailedEditionInfo extends ConsumerStatefulWidget {
  DetailedEditionInfo(
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
  bool doesBookAlreadyExist = false;
  List<Map<String, dynamic>>? notesList = [];
  bool doesBookHasSameStatus = false;
  String bookStatusAsString = "";
  bool hasStatusChanged = false;

  BookStatus bookStatus = BookStatus.wantToRead;

  @override
  void initState() {
    if (widget.isNavigatingFromLibrary)
      bookStatusAsString = widget.editionInfo.bookStatus!;
    getPageData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(
        "${uniqueIdCreater(widget.editionInfo) + widget.indexOfEdition} - detailed edition info");
    print(widget.editionInfo.title.hashCode);
    print(bookStatus);
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context, hasStatusChanged);
        return Future(() => true);
      },
      child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            actions: [
              widget.editionInfo.isbn_13 != null ||
                      widget.editionInfo.isbn_10 != null
                  ? IconButton(
                      onPressed: () {
                        launchUrl(Uri.parse(
                            "https://www.goodreads.com/search?q=${widget.editionInfo.isbn_13 != null ? widget.editionInfo.isbn_13 : widget.editionInfo.isbn_10}"));
                      },
                      icon: Image.asset("lib/assets/images/goodreads_icon.png",
                          height: 30),
                      splashRadius: 25)
                  : SizedBox.shrink(),
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
                          print(value);
                          if (value == true) getPageData();
                        });
                      },
                      icon: Icon(
                        Icons.library_add_rounded,
                        size: 30,
                        color: Colors.white,
                      ))
                  : SizedBox.shrink(),
              IconButton(
                  color: Colors.white,
                  splashRadius: 25,
                  onPressed: () {
                    modalBottomSheetBuilderForPopUpMenu(context);
                  },
                  icon: Icon(
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
                    Navigator.pop(context, hasStatusChanged),
                icon: const Icon(
                  Icons.arrow_back_sharp,
                  size: 30,
                )),
            backgroundColor: Color(0xFF1B7695),
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(50), bottomRight: Radius.circular(50)),
        color: Color(0xFF1B7695),
      ),
      child: Column(children: [
        widget.editionInfo.covers != null
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
                                borderRadius:
                                    BorderRadiusDirectional.circular(15),
                                child: Image(
                                  height: 290,
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
                                    borderRadius:
                                        BorderRadiusDirectional.circular(15),
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
        SizedBox(
          height: 25,
        ),
        Container(
          decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(50)),
          width: MediaQuery.sizeOf(context).width - 30,
          height: 50,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            SizedBox(
              width: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Yayın Tarihi",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  FittedBox(
                    child: Text(
                      widget.editionInfo.publish_date != null
                          ? "${widget.editionInfo.publish_date}"
                          : "-",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            VerticalDivider(),
            SizedBox(
              width: 110,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Sayfa Sayısı",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                      widget.editionInfo.number_of_pages != null
                          ? "${widget.editionInfo.number_of_pages}"
                          : "-",
                      textAlign: TextAlign.center)
                ],
              ),
            ),
            VerticalDivider(),
            SizedBox(
              width: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Dil",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    widget.editionInfo.languages != null
                        ? countryNameCreater(widget.editionInfo)
                        : "-",
                    style: const TextStyle(),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          ]),
        ),
        SizedBox(
          height: 10,
        ),
      ]),
    );
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
          widget.isNavigatingFromLibrary == false
              ? ListTile(
                  visualDensity: VisualDensity(vertical: 3),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30))),
                  onTap: () {
                    Navigator.pop(context);
                    bookStatusDialog(context);
                  },
                  leading: Icon(
                    Icons.shelves,
                    size: 30,
                  ),
                  title: Text("Rafa ekle", style: TextStyle(fontSize: 20)),
                )
              : SizedBox.shrink(),
          widget.isNavigatingFromLibrary == false
              ? Divider(height: 0)
              : SizedBox.shrink(),
          widget.isNavigatingFromLibrary == true
              ? ListTile(
                  title: Text("Kitap durumunu değiştir",
                      style: TextStyle(fontSize: 20)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30))),
                  leading: Icon(
                    Icons.menu_book,
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
                        .then((value) {
                      getNewStatus(uniqueIdCreater(widget.editionInfo))
                          .then((value) {
                        if (value != null) {
                          setState(() {
                            bookStatusAsString = value;
                            hasStatusChanged = true;
                          });
                        }
                      });
                    });
                  },
                  visualDensity: VisualDensity(vertical: 3),
                )
              : SizedBox.shrink(),
          widget.isNavigatingFromLibrary == true
              ? Divider(
                  height: 0,
                )
              : SizedBox.shrink(),
          ListTile(
            visualDensity: VisualDensity(vertical: 3),
            leading: Icon(
              Icons.info,
              size: 30,
            ),
            title: Text("Bilgi", style: TextStyle(fontSize: 20)),
          ),
          Divider(height: 0),
          widget.isNavigatingFromLibrary != false
              ? ListTile(
                  visualDensity: VisualDensity(vertical: 3),
                  onTap: () async {
                    await deleteAuthorsFromSql(widget.editionInfo);
                    await deleteNote(widget.editionInfo);
                    deleteBook(widget.editionInfo);
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BottomNavigationBarController(),
                        ),
                        (route) => false);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      duration: Duration(seconds: 2),
                      content: const Text('Kitap başarıyla silindi.'),
                      action: SnackBarAction(label: 'Tamam', onPressed: () {}),
                      behavior: SnackBarBehavior.floating,
                    ));
                  },
                  leading: Icon(
                    Icons.delete,
                    size: 30,
                  ),
                  title: Text("Sil", style: TextStyle(fontSize: 20)),
                )
              : SizedBox.shrink(),
          widget.isNavigatingFromLibrary != false
              ? Divider(
                  height: 0,
                )
              : SizedBox.shrink(),
        ]);
      },
    );
  }

  Future<void> deleteBook(BookWorkEditionsModelEntries bookInfo) async {
    await ref.read(sqlProvider).deleteBook(uniqueIdCreater(bookInfo), context);
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
                  alignment: Alignment.centerRight,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  child: onProgress != true
                      ? Padding(
                          padding: EdgeInsets.all(15),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Kitaplıktaki durumunu seçiniz.",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              ListTile(
                                title: GestureDetector(
                                  child: Text("Okumak istediklerim"),
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
                                  child: Text("Şu an okuduklarım"),
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
                                  child: Text("Okuduklarım"),
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
                                        setState(() {
                                          onProgress = true;
                                        });
                                        doesBookAlreadyExist =
                                            await checkIfAlreadyExist(
                                                uniqueIdCreater(
                                                    widget.editionInfo));

                                        doesBookHasSameStatus =
                                            checkIfBookHasSameStatus(
                                                bookStatus, initialBookStatus);

                                        if (widget.editionInfo.covers != null &&
                                            doesBookAlreadyExist != true &&
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
                                            doesBookAlreadyExist != true &&
                                            doesBookHasSameStatus != true) {
                                          await insertToSqlDatabase(
                                              null, context);
                                          if (ref
                                                  .read(authProvider)
                                                  .currentUser !=
                                              null) {
                                            await insertToFirestore();
                                          }
                                        } else if (doesBookAlreadyExist ==
                                                true &&
                                            doesBookHasSameStatus == false) {
                                          updateBookStatus(
                                              uniqueIdCreater(
                                                  widget.editionInfo),
                                              bookStatus);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            duration: Duration(seconds: 1),
                                            content: const Text(
                                                'Kitap durumu başarıyla güncellendi.'),
                                            action: SnackBarAction(
                                                label: 'Tamam',
                                                onPressed: () {}),
                                            behavior: SnackBarBehavior.floating,
                                          ));
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            duration: Duration(seconds: 1),
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
                      : Container(
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
            "languages": editionInfo.languages != null
                ? editionInfo.languages!.first!.key
                : null
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
              duration: Duration(seconds: 1),
              content: const Text('Kitap başarıyla kitaplığına eklendi.'),
              action: SnackBarAction(label: 'Tamam', onPressed: () {}),
              behavior: SnackBarBehavior.floating,
            )));
  }

  Future<void> updateBookStatus(int bookId, BookStatus newBookStatus) async {
    await ref.read(sqlProvider).updateBook(
        bookId,
        newBookStatus == BookStatus.alreadyRead
            ? "Okuduklarım"
            : newBookStatus == BookStatus.currentlyReading
                ? "Şu an okuduklarım"
                : "Okumak istediklerim",
        context);

    if (ref.read(authProvider).currentUser != null && isConnected != false) {
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
      descriptionText = widget.editionInfo.description!.replaceRange(0, 26, "");
    }
    print(widget.editionInfo.isbn_10);
    return Expanded(
      child: Scrollbar(
        thickness: 3,
        radius: Radius.circular(20),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          physics: ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Başlık",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              Divider(color: Colors.transparent, thickness: 0),
              SizedBox(
                width: MediaQuery.sizeOf(context).width - 40,
                child: Text(
                  widget.editionInfo.title!,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              if ((widget.editionInfo.authorsNames != null &&
                      widget.editionInfo.authorsNames!.isNotEmpty) ||
                  authorsNames.isNotEmpty)
                Divider(color: Colors.transparent, thickness: 0),
              if ((widget.editionInfo.authorsNames != null &&
                      widget.editionInfo.authorsNames!.isNotEmpty) ||
                  authorsNames.isNotEmpty)
                Text(
                  "Yazarlar",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              if ((widget.editionInfo.authorsNames != null &&
                      widget.editionInfo.authorsNames!.isNotEmpty) ||
                  authorsNames.isNotEmpty)
                Divider(color: Colors.transparent, thickness: 0),
              if (widget.editionInfo.authorsNames == null &&
                  authorsNames.isNotEmpty)
                SizedBox(
                    height: widget.editionInfo.authors!.length * 25,
                    child: ListView.separated(
                      separatorBuilder: (context, index) => SizedBox(
                        height: 5,
                      ),
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: widget.editionInfo.authors!.length,
                      itemBuilder: (context, index) => Text(
                        authorsNames[index],
                        style: TextStyle(fontSize: 15),
                      ),
                    )),
              if (widget.editionInfo.authorsNames != null &&
                  authorsNames.isEmpty)
                SizedBox(
                    height: widget.editionInfo.authorsNames!.length * 20,
                    child: ListView.separated(
                      separatorBuilder: (context, index) => SizedBox(
                        height: 5,
                      ),
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: widget.editionInfo.authorsNames!.length,
                      itemBuilder: (context, index) =>
                          Text(widget.editionInfo.authorsNames![index]!),
                    )),
              if (widget.editionInfo.description != null)
                Divider(color: Colors.transparent, thickness: 0),
              if (widget.editionInfo.description != null)
                Text(
                  "Açıklama",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              if (widget.editionInfo.description != null)
                Divider(color: Colors.transparent, thickness: 0),
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
                          style: const TextStyle(fontSize: 15),
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
                          style: const TextStyle(fontSize: 15),
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
                          ? Text("Daha fazla göster")
                          : Text("Daha az göster")),
                ),
              if (widget.editionInfo.publishers != null)
                Divider(color: Colors.transparent, thickness: 0),
              if (widget.editionInfo.publishers != null)
                Text(
                  "Yayıncı",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              if (widget.editionInfo.publishers != null)
                Divider(color: Colors.transparent, thickness: 0),
              if (widget.editionInfo.publishers != null)
                SizedBox(
                    width: MediaQuery.sizeOf(context).width - 40,
                    child: Text(
                      widget.editionInfo.publishers!.first!,
                      style: const TextStyle(color: Colors.black, fontSize: 15),
                    )),
              if (widget.editionInfo.physical_format != null)
                Divider(color: Colors.transparent, thickness: 0),
              if (widget.editionInfo.physical_format != null)
                Text(
                  "Kitap formatı",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              if (widget.editionInfo.physical_format != null)
                Divider(color: Colors.transparent, thickness: 0),
              if (widget.editionInfo.physical_format != null)
                SizedBox(
                  width: MediaQuery.sizeOf(context).width - 40,
                  child: widget.editionInfo.physical_format == "paperback" ||
                          widget.editionInfo.physical_format == "Paperback"
                      ? Text(
                          "Ciltsiz",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        )
                      : widget.editionInfo.physical_format == "hardcover" ||
                              widget.editionInfo.physical_format == "Hardcover"
                          ? Text(
                              "Ciltli",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            )
                          : widget.editionInfo.physical_format == "E-book" ||
                                  widget.editionInfo.physical_format == "Ebook"
                              ? Text("E-kitap")
                              : Text(widget.editionInfo.physical_format!),
                ),
              if (widget.editionInfo.isbn_10 != null)
                Divider(color: Colors.transparent, thickness: 0),
              if (widget.editionInfo.isbn_10 != null)
                Text(
                  "Isbn 10",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              if (widget.editionInfo.isbn_10 != null)
                Divider(color: Colors.transparent, thickness: 0),
              if (widget.editionInfo.isbn_10 != null)
                SizedBox(
                    width: MediaQuery.sizeOf(context).width - 40,
                    child: Text(
                      widget.editionInfo.isbn_10!.first!,
                      style: const TextStyle(color: Colors.black, fontSize: 15),
                    )),
              if (widget.editionInfo.isbn_13 != null)
                Divider(color: Colors.transparent, thickness: 0),
              if (widget.editionInfo.isbn_13 != null)
                Text(
                  "Isbn 13",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              if (widget.editionInfo.isbn_13 != null)
                Divider(color: Colors.transparent, thickness: 0),
              if (widget.editionInfo.isbn_13 != null)
                SizedBox(
                    width: MediaQuery.sizeOf(context).width - 40,
                    child: Text(
                      widget.editionInfo.isbn_13!.first!,
                      style: const TextStyle(color: Colors.black, fontSize: 15),
                    )),
              if (widget.editionInfo.bookStatus != null)
                Divider(color: Colors.transparent, thickness: 0),
              if (widget.editionInfo.bookStatus != null)
                Text(
                  "Kitap durumu",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              if (widget.editionInfo.bookStatus != null)
                Divider(color: Colors.transparent, thickness: 0),
              if (widget.editionInfo.bookStatus != null)
                SizedBox(
                    width: MediaQuery.sizeOf(context).width - 40,
                    child: Text(
                      bookStatusAsString,
                      style: const TextStyle(color: Colors.black, fontSize: 15),
                    )),
              if (notesList != null)
                Divider(color: Colors.transparent, thickness: 0),
              if (notesList!.isEmpty != true)
                Text(
                  "Notlar",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              if (notesList!.isEmpty != true)
                Divider(color: Colors.transparent, thickness: 0),
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
    return Container(
      height:
          (200 * notesList!.length).toDouble() + (15 * notesList!.length - 1),
      child: ListView.separated(
        physics: NeverScrollableScrollPhysics(),
        separatorBuilder: (context, index) =>
            Divider(color: Colors.transparent, thickness: 0),
        itemCount: notesList!.length,
        itemBuilder: (context, index) => InkWell(
            customBorder:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            onTap: () {
              Image? getImage = widget.bookImage ?? null;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddNoteView(
                            noteId: notesList![index]['id'],
                            initialNoteValue: notesList![index]['note'],
                            bookImage: getImage != null
                                ? getImage
                                : widget.editionInfo.covers != null
                                    ? Image(
                                        image: NetworkImage(
                                            "https://covers.openlibrary.org/b/id/${widget.editionInfo.covers!.first!}-M.jpg"),
                                        errorBuilder: (context, error,
                                                stackTrace) =>
                                            Image.asset(
                                                "lib/assets/images/error.png"),
                                      )
                                    : null,
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
                title:
                    Text((index + 1).toString(), textAlign: TextAlign.center),
                subtitle: Text(notesList![index]['note'],
                    maxLines: 5, overflow: TextOverflow.ellipsis),
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

  Future<bool> checkIfAlreadyExist(int bookId) async {
    List<int>? bookIds = [];
    List<BookWorkEditionsModelEntries>? booksList =
        await ref.read(sqlProvider).getBookShelf(context);
    if (booksList != null) {
      bookIds = booksList.map((e) => uniqueIdCreater(e)).toList();

      return bookIds.contains(bookId);
    }
    return false;
  }

  bool checkIfBookHasSameStatus(
      BookStatus chosenStatus, BookStatus? oldStatus) {
    if (chosenStatus == oldStatus) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> getNotes(int bookId) async {
    notesList = await ref.read(sqlProvider).getNotes(context, bookId: bookId);
  }

  Future<String?> getNewStatus(int bookId) async {
    return await ref.read(sqlProvider).getNewStatus(context, bookId);
  }
}
