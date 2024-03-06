import 'dart:convert';

import 'package:book_tracker/const.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/library_screen/add_note_view.dart';
import 'package:book_tracker/screens/library_screen/books_list_view.dart';
import 'package:book_tracker/screens/library_screen/shimmer_effects/notes_view_shimmer.dart';
import 'package:book_tracker/services/internet_connection_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotesView extends ConsumerStatefulWidget {
  const NotesView(
      {super.key,
      required this.bookListFromSql,
      required this.bookListFromFirebase});

  final List<BookWorkEditionsModelEntries>? bookListFromSql;
  final List<BookWorkEditionsModelEntries>? bookListFromFirebase;

  @override
  ConsumerState<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends ConsumerState<NotesView> {
  List<BookWorkEditionsModelEntries>? bookListToShow;
  List<int> BookIdsListFromSql = [];
  List<int> BookIdsListToShow = [];

  List<Map<String, dynamic>>? notesFromSql = [];
  List<Map<String, dynamic>>? notesFromFirestore = [];
  List<Map<String, dynamic>> notesToShow = [];

  bool isLoading = true;

  bool isConnected = false;
  @override
  void initState() {
    getPageData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Notlarım",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leadingWidth: 50,
          actions: [
            IconButton(
                splashRadius: 25,
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BooksListView(),
                    )).then((value) => value == true ? getPageData() : null),
                icon: const Icon(
                  Icons.add_to_photos_rounded,
                  size: 30,
                ))
          ],
          leading: IconButton(
              splashRadius: 25,
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_sharp,
                size: 30,
              )),
        ),
        body: isLoading == false
            ? notesToShow.length != 0
                ? ListView.separated(
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    separatorBuilder: (context, index) => SizedBox(
                          height: 15,
                        ),
                    padding: EdgeInsets.all(15),
                    itemCount: notesToShow.length,
                    itemBuilder: (context, index) {
                      BookWorkEditionsModelEntries book =
                          BookWorkEditionsModelEntries();
                      BookIdsListToShow.contains(
                                  notesToShow[index]['bookId']) ==
                              true
                          ? book = bookListToShow!.firstWhere((element) =>
                              uniqueIdCreater(element) ==
                              notesToShow[index]['bookId'])
                          : null;
                      return BookIdsListToShow.contains(
                                  notesToShow[index]['bookId']) ==
                              true
                          ? InkWell(
                              customBorder: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25)),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AddNoteView(
                                              noteId: notesToShow[index]['id']
                                                          .runtimeType ==
                                                      String
                                                  ? int.parse(
                                                      notesToShow[index]['id'])
                                                  : notesToShow[index]['id'],
                                              initialNoteValue:
                                                  notesToShow[index]['note'],
                                              bookImage: BookIdsListFromSql
                                                              .contains(
                                                                  uniqueIdCreater(
                                                                      book)) ==
                                                          true &&
                                                      book.covers != null
                                                  ? Image.memory(
                                                      base64Decode(
                                                        getImageAsByte(
                                                            widget
                                                                .bookListFromSql,
                                                            book),
                                                      ),
                                                      errorBuilder: (context,
                                                              error,
                                                              stackTrace) =>
                                                          Image.asset(
                                                        "lib/assets/images/error.png",
                                                      ),
                                                    )
                                                  : book.covers != null &&
                                                          book.imageAsByte ==
                                                              null
                                                      ? Image.network(
                                                          "https://covers.openlibrary.org/b/id/${book.covers!.first}-M.jpg",
                                                          errorBuilder: (context,
                                                                  error,
                                                                  stackTrace) =>
                                                              Image.asset(
                                                                  "lib/assets/images/error.png"),
                                                        )
                                                      : book.imageAsByte != null
                                                          ? Image.memory(
                                                              base64Decode(book
                                                                  .imageAsByte!),
                                                              width: 90,
                                                              fit: BoxFit.fill,
                                                            )
                                                          : Image.asset(
                                                              "lib/assets/images/nocover.jpg"),
                                              showDeleteIcon: true,
                                              bookInfo: book,
                                              noteDate: notesToShow[index]
                                                  ['noteDate'],
                                            ))).then((value) {
                                  if (value == true) {
                                    getNotesFromSql();
                                    getPageData();
                                  }
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white60,
                                    borderRadius: BorderRadius.circular(25)),
                                height: 125,
                                child: ListTile(
                                  title: Text(book.title!),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: BookIdsListFromSql.contains(
                                                    uniqueIdCreater(book)) ==
                                                true &&
                                            book.covers != null
                                        ? Image.memory(
                                            width: 40,
                                            height: 100,
                                            fit: BoxFit.fill,
                                            base64Decode(getImageAsByte(
                                                widget.bookListFromSql, book)),
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Image.asset(
                                              "lib/assets/images/error.png",
                                            ),
                                          )
                                        : book.covers != null &&
                                                book.imageAsByte == null
                                            ? Image.network(
                                                width: 40,
                                                height: 100,
                                                fit: BoxFit.fill,
                                                "https://covers.openlibrary.org/b/id/${book.covers!.first}-M.jpg",
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    Image.asset(
                                                        "lib/assets/images/error.png"),
                                              )
                                            : book.imageAsByte != null
                                                ? Image.memory(
                                                    width: 40,
                                                    height: 100,
                                                    base64Decode(
                                                        book.imageAsByte!),
                                                    fit: BoxFit.fill,
                                                  )
                                                : Image.asset(
                                                    "lib/assets/images/nocover.jpg",
                                                    fit: BoxFit.fill,
                                                  ),
                                  ),
                                  subtitle: SizedBox(
                                    child: Text(notesToShow[index]['note'],
                                        maxLines: 5,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ),
                              ))
                          : SizedBox.shrink();
                    })
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "lib/assets/images/nonotesfound.png",
                          width: MediaQuery.of(context).size.width / 1.2,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.width / 10,
                        ),
                        Text(
                          "Not bulunamadı.",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        )
                      ],
                    ),
                  )
            : notesViewShimmerEffect());
  }

  Future<void> getPageData() async {
    setState(() {
      isLoading = true;
    });

    widget.bookListFromSql != null
        ? BookIdsListFromSql =
            widget.bookListFromSql!.map((e) => uniqueIdCreater(e)).toList()
        : null;

    isConnected = await checkForInternetConnection();
    if (isConnected != false && ref.read(authProvider).currentUser != null) {
      bookListToShow = widget.bookListFromFirebase;
      await getNotesFromFirestore();
      BookIdsListToShow =
          bookListToShow!.map((e) => uniqueIdCreater(e)).toList();
      await insertingProcesses();
    } else {
      bookListToShow = widget.bookListFromSql;
      BookIdsListToShow =
          bookListToShow!.map((e) => uniqueIdCreater(e)).toList();
      await getNotesFromSql();
    }

    BookIdsListToShow = bookListToShow!.map((e) => uniqueIdCreater(e)).toList();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> getNotesFromSql() async {
    notesFromSql = await ref.read(sqlProvider).getNotes(context);
    if (notesFromSql != null) {
      notesToShow = notesFromSql!;
    }
    print("notlar sqlden gösteriliyor");
  }

  Future<void> getNotesFromFirestore() async {
    var data = await ref.read(firestoreProvider).getNotes(
        "usersBooks", ref.read(authProvider).currentUser!.uid, context);

    if (data != null) {
      notesFromFirestore = data.docs
          .map(
            (e) => e.data(),
          )
          .toList();
      if (notesFromFirestore != null) {
        notesToShow = notesFromFirestore!;
      }
    }

    print("notlar firestoredan gösteriliyor");
  }

  Future<void> insertingProcesses() async {
    List<int?>? listOfNoteIdsFromSql = [];
    List<int?> listOfNoteIdsFromFirestore = [];
    if (notesFromFirestore != null) {
      notesFromFirestore!.isEmpty != true
          ? listOfNoteIdsFromFirestore =
              notesFromFirestore!.map((e) => int.parse(e['id'])).toList()
          : null;
      print("notesFromFirestore : $notesFromFirestore");
      print("listOfNoteIdsFromFirestore: $listOfNoteIdsFromFirestore");
    }
    if (notesFromSql != null) {
      notesFromSql!.isEmpty != true
          ? listOfNoteIdsFromSql =
              notesFromSql!.map((e) => e['id'] as int).toList()
          : null;

      print("notesFromSql : $notesFromSql");
      print("listOfNoteIdsFromSql: $listOfNoteIdsFromSql");
    }

    if (notesFromSql != null) {
      for (var i = 0; i < listOfNoteIdsFromSql.length; i++) {
        if (!listOfNoteIdsFromFirestore.contains(listOfNoteIdsFromSql[i])) {
          await insertNoteToFirebase(notesFromSql![i]);
        }
      }
    }

    if (notesFromFirestore != null) {
      for (var i = 0; i < listOfNoteIdsFromFirestore.length; i++) {
        if (!listOfNoteIdsFromSql.contains(listOfNoteIdsFromFirestore[i])) {
          await insertNoteToSql(notesFromFirestore![i]);
        }
      }
    }
  }

  Future<void> insertNoteToFirebase(Map<String, dynamic> noteFromSql) async {
    await ref.read(firestoreProvider).setNoteData(context,
        collectionPath: 'usersBooks',
        note: noteFromSql['note'],
        userId: ref.read(authProvider).currentUser!.uid,
        uniqueBookId: noteFromSql['bookId'],
        noteDate: noteFromSql['noteDate']);
  }

  Future<void> insertNoteToSql(Map<String, dynamic> noteFromFirestore) async {
    await ref.read(sqlProvider).insertNoteToBook(noteFromFirestore['note'],
        noteFromFirestore['bookId'], context, noteFromFirestore['noteDate']);
  }
}
