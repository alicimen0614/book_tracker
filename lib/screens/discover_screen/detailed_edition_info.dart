import 'package:book_tracker/const.dart';
import 'package:book_tracker/models/authors_model.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/library_screen/add_note_view.dart';
import 'package:book_tracker/widgets/bottom_navigation_bar_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  BookStatus bookStatus = BookStatus.wantToRead;

  @override
  void initState() {
    if (widget.editionInfo.authors != null) {
      getPageData();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(
        "${uniqueIdCreater(widget.editionInfo) + widget.indexOfEdition} - detailed edition info");
    print(widget.editionInfo.title.hashCode);
    print(bookStatus);
    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          actions: [
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
                          ));
                    },
                    icon: Icon(
                      Icons.library_add_outlined,
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
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_sharp,
                size: 30,
              )),
          backgroundColor: Color(0xFF1B7695),
          elevation: 0,
        ),
        bottomNavigationBar: widget.isNavigatingFromLibrary == false
            ? bottomAppBarBuilder(context)
            : null,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            bookCoverAndDetailsBuilder(context),
            isLoading != true
                ? editionInfoBodyBuilder(context)
                : Center(
                    child: CircularProgressIndicator(),
                  )
          ],
        ));
  }

  BottomAppBar bottomAppBarBuilder(BuildContext context) {
    return BottomAppBar(
      elevation: 0,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade900),
              onPressed: () async {
                await ref.read(sqlProvider).deleteDatabasef();
              },
              icon: Icon(Icons.shopping_cart),
              label: Text("Kitapçılar")),
          ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown.shade600),
              onPressed: () async {
                bookStatusDialog(context);
              },
              icon: Icon(Icons.shelves),
              label: Text("Rafa ekle"))
        ],
      ),
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
                                  height: 250,
                                  fit: BoxFit.fill,
                                  image: widget.bookImage!.image,
                                ),
                              )
                            : Image.asset("lib/assets/images/nocover.jpg"))),
              )
            : Align(
                alignment: Alignment.center,
                child: Hero(
                  tag: uniqueIdCreater(widget.editionInfo),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset("lib/assets/images/nocover.jpg")),
                )),
        SizedBox(
          height: 10,
        ),
        Container(
          decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(15)),
          width: MediaQuery.sizeOf(context).width - 50,
          height: 50,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            SizedBox(
              width: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Yayın Tarihi",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                      widget.editionInfo.publishDate != null
                          ? "${widget.editionInfo.publishDate}"
                          : "-",
                      textAlign: TextAlign.center),
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
                      widget.editionInfo.numberOfPages != null
                          ? "${widget.editionInfo.numberOfPages}"
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
          widget.isNavigatingFromLibrary != false
              ? ListTile(
                  onTap: () async {
                    await deleteAuthorsFromSql(widget.editionInfo);
                    await deleteNote(widget.editionInfo);
                    await deleteBook(widget.editionInfo).whenComplete(() {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BottomNavigationBarController(
                                currentIndexParam: 2),
                          ),
                          (route) => false);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: Duration(seconds: 2),
                        content: const Text('Kitap başarıyla silindi.'),
                        action:
                            SnackBarAction(label: 'Tamam', onPressed: () {}),
                        behavior: SnackBarBehavior.floating,
                      ));
                    });
                  },
                  leading: Icon(
                    Icons.delete,
                    size: 30,
                  ),
                  title: Text("Sil", style: TextStyle(fontSize: 20)),
                )
              : SizedBox.shrink(),
          widget.isNavigatingFromLibrary != false
              ? Divider()
              : SizedBox.shrink(),
          ListTile(
            leading: Icon(
              Icons.info,
              size: 30,
            ),
            title: Text("Bilgi", style: TextStyle(fontSize: 20)),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.share,
              size: 30,
            ),
            title: Text("Paylaş", style: TextStyle(fontSize: 20)),
          )
        ]);
      },
    );
  }

  Future<void> deleteBook(BookWorkEditionsModelEntries bookInfo) async {
    await ref.read(sqlProvider).deleteBook(uniqueIdCreater(bookInfo));
    if (ref.read(authProvider).currentUser != null) {
      await ref.read(firestoreProvider).deleteBook(
          referencePath: "usersBooks",
          userId: ref.read(authProvider).currentUser!.uid,
          bookId: uniqueIdCreater(bookInfo).toString());
    }
  }

  Future<void> deleteNote(BookWorkEditionsModelEntries bookInfo) async {
    ref.read(sqlProvider).deleteNotesFromBook(uniqueIdCreater(bookInfo));
    if (ref.read(authProvider).currentUser != null) {
      await ref.read(firestoreProvider).deleteNotes(
          referencePath: "usersBooks",
          userId: ref.read(authProvider).currentUser!.uid,
          bookId: uniqueIdCreater(bookInfo));
    }
  }

  Future<void> deleteAuthorsFromSql(
      BookWorkEditionsModelEntries bookInfo) async {
    ref.read(sqlProvider).deleteAuthors(uniqueIdCreater(bookInfo));
  }

  Future<dynamic> bookStatusDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
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
                              title: Text("Okumak istediklerim"),
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
                              title: Text("Şu an okuduklarım"),
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
                              title: Text("Okuduklarım"),
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
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
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

                                      if (widget.editionInfo.covers != null) {
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
                                      } else {
                                        await insertToSqlDatabase(
                                            null, context);
                                        if (ref
                                                .read(authProvider)
                                                .currentUser !=
                                            null) {
                                          await insertToFirestore();
                                        }
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
                      ));
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
          collectionPath: "usersBooks",
          bookAsMap: {
            "title": editionInfo.title,
            "numberOfPages": editionInfo.numberOfPages,
            "covers": editionInfo.covers != null ? coverList : null,
            "bookStatus": bookStatus == BookStatus.alreadyRead
                ? "Okuduklarım"
                : bookStatus == BookStatus.currentlyReading
                    ? "Şu an okuduklarım"
                    : "Okumak istediklerim",
            "publishers": editionInfo.publishers,
            "physicalFormat": editionInfo.physicalFormat,
            "publishDate": editionInfo.publishDate,
            "isbn_10": editionInfo.isbn_10,
            "isbn_13": editionInfo.isbn_13,
            "authorsNames": authorsNames,
            "description": editionInfo.description
          },
          userId: ref.read(authProvider).currentUser!.uid,
        );
  }

  Future<void> insertToSqlDatabase(
      Uint8List? imageAsByte, BuildContext context) async {
    for (var element in authorsNames) {
      await ref
          .read(sqlProvider)
          .insertAuthors(element, uniqueIdCreater(widget.editionInfo));
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
            imageAsByte)
        .whenComplete(() => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: Duration(seconds: 1),
              content: const Text('Kitap başarıyla kitaplığına eklendi.'),
              action: SnackBarAction(label: 'Tamam', onPressed: () {}),
              behavior: SnackBarBehavior.floating,
            )));
  }

  Future<Uint8List> readNetworkImage(String imageUrl) async {
    final ByteData data =
        await NetworkAssetBundle(Uri.parse(imageUrl)).load(imageUrl);
    final Uint8List bytes = data.buffer.asUint8List();
    return bytes;
  }

  Expanded editionInfoBodyBuilder(BuildContext context) {
    print(widget.editionInfo.isbn_10);
    return Expanded(
      child: Scrollbar(
        thickness: 3,
        radius: Radius.circular(20),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          physics: BouncingScrollPhysics(),
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
              if (widget.editionInfo.authors != null ||
                  widget.editionInfo.authorsNames != null)
                Divider(color: Colors.transparent, thickness: 0),
              if (widget.editionInfo.authors != null ||
                  widget.editionInfo.authorsNames != null)
                Text(
                  "Yazarlar",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              if (widget.editionInfo.authors != null ||
                  widget.editionInfo.authorsNames != null)
                Divider(color: Colors.transparent, thickness: 0),
              if (widget.editionInfo.authors != null)
                SizedBox(
                    height: widget.editionInfo.authors!.length * 20,
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
              if (widget.editionInfo.authorsNames != null)
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
                          widget.editionInfo.description!,
                          style: const TextStyle(fontSize: 15),
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        )
                      : Text(
                          widget.editionInfo.description!,
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
              if (widget.editionInfo.physicalFormat != null)
                Divider(color: Colors.transparent, thickness: 0),
              if (widget.editionInfo.physicalFormat != null)
                Text(
                  "Kitap formatı",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              if (widget.editionInfo.physicalFormat != null)
                Divider(color: Colors.transparent, thickness: 0),
              if (widget.editionInfo.physicalFormat != null)
                SizedBox(
                  width: MediaQuery.sizeOf(context).width - 40,
                  child: widget.editionInfo.physicalFormat == "paperback"
                      ? Text(
                          "Ciltsiz",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        )
                      : widget.editionInfo.physicalFormat == "hardcover" ||
                              widget.editionInfo.physicalFormat == "Hardcover"
                          ? Text(
                              "Ciltli",
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            )
                          : widget.editionInfo.physicalFormat == "E-book"
                              ? Text("E-kitap")
                              : Text(widget.editionInfo.physicalFormat!),
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
                      widget.editionInfo.bookStatus!,
                      style: const TextStyle(color: Colors.black, fontSize: 15),
                    )),
            ],
          ),
        ),
      ),
    );
  }

  Future getPageData() async {
    setState(() {
      isLoading = true;
    });

    if (widget.editionInfo.authors != null) {
      await getAuthorsNames();
    }
    setState(() {
      isLoading = false;
    });
  }

  Future getAuthorsNames() async {
    List<String> authorsNamesList = [];
    for (var element in widget.editionInfo.authors!) {
      AuthorsModel author =
          await ref.read(booksProvider).getAuthorInfo(element!.key!, true);
      if (author.name != null) {
        authorsNamesList.add(author.name!);
      } else if (author.personalName != null) {
        authorsNamesList.add(author.personalName!);
      } else if (author.alternateNames != null) {
        authorsNamesList.add(author.alternateNames!.first!);
      }
    }

    return authorsNames = authorsNamesList;
  }
}
