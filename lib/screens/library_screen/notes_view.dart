import 'dart:convert';

import 'package:book_tracker/const.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/library_screen/add_note_view.dart';
import 'package:book_tracker/screens/library_screen/books_list_view.dart';
import 'package:book_tracker/screens/library_screen/shimmer_effects/notes_view_shimmer.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotesView extends ConsumerStatefulWidget {
  const NotesView({super.key, required this.listOfBooksFromSql});

  final List<BookWorkEditionsModelEntries>? listOfBooksFromSql;

  @override
  ConsumerState<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends ConsumerState<NotesView> {
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
                      builder: (context) => BooksListView(
                          listOfBooksFromSql: widget.listOfBooksFromSql),
                    )).then((value) => getPageData()),
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
            ? ListView.separated(
                physics: BouncingScrollPhysics(),
                separatorBuilder: (context, index) => SizedBox(
                  height: 15,
                ),
                padding: EdgeInsets.all(15),
                itemCount: notesToShow.length,
                itemBuilder: (context, index) => InkWell(
                    customBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    onTap: () {
                      String? getImage = widget.listOfBooksFromSql!
                              .firstWhere((element) =>
                                  uniqueIdCreater(element) ==
                                  notesToShow[index]['bookId'])
                              .imageAsByte ??
                          null;
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddNoteView(
                                  noteId: notesToShow[index]['id'],
                                  initialNoteValue: notesToShow[index]['note'],
                                  bookImage: getImage != null
                                      ? Image.memory(
                                          base64Decode(getImage),
                                          fit: BoxFit.fill,
                                        )
                                      : null,
                                  showDeleteIcon: true,
                                  bookInfo: widget.listOfBooksFromSql!
                                      .firstWhere((element) =>
                                          uniqueIdCreater(element) ==
                                          notesToShow[index]['bookId'])))).then(
                          (value) => getPageData());
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white60,
                          borderRadius: BorderRadius.circular(25)),
                      height: 125,
                      child: ListTile(
                        title: Text(widget.listOfBooksFromSql!
                            .firstWhere((element) =>
                                uniqueIdCreater(element) ==
                                notesToShow[index]['bookId'])
                            .title!),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: widget.listOfBooksFromSql!
                                      .firstWhere((element) =>
                                          uniqueIdCreater(element) ==
                                          notesToShow[index]['bookId'])
                                      .imageAsByte !=
                                  null
                              ? Image.memory(
                                  fit: BoxFit.fill,
                                  base64Decode(widget.listOfBooksFromSql!
                                      .firstWhere((element) =>
                                          uniqueIdCreater(element) ==
                                          notesToShow[index]['bookId'])
                                      .imageAsByte!))
                              : Image.asset("lib/assets/images/nocover.jpg"),
                        ),
                        subtitle: SizedBox(
                          child: Text(notesToShow[index]['note'],
                              maxLines: 5, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    )),
              )
            : notesViewShimmerEffect());
  }

  Future<void> getPageData() async {
    setState(() {
      isLoading = true;
    });

    checkForInternetConnection().then((internet) {
      print(internet);
      print("$isConnected -1");
      if (internet == true) {
        if (isConnected == false) {
          setState(() {
            isConnected = true;
          });
        }
        print("$isConnected -2");
      } else {
        if (isConnected == true) {
          setState(() {
            isConnected = false;
          });
        }
        print("$isConnected -3");
      }
    });

    await getNotesFromSql();

    if (isConnected != false && ref.read(authProvider).currentUser != null) {
      await getNotesFromFirestore();
      await insertingProcesses();
    }

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

  Future<bool> checkForInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      print("connected from mobile");
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      print("connected from wifi");
      return true;
    }

    return false;
  }

  Future<void> insertingProcesses() async {
    List<int?>? listOfNoteIdsFromSql = [];
    List<int?>? listOfNoteIdsFromFirestore = [];
    if (notesFromFirestore != null) {
      notesFromFirestore!.isEmpty != true
          ? listOfNoteIdsFromFirestore =
              notesFromFirestore!.map((e) => int.parse(e['id'])).toList()
          : null;
    }
    if (notesFromSql != null) {
      notesFromSql!.isEmpty != true
          ? listOfNoteIdsFromSql =
              notesFromSql!.map((e) => e['id'] as int).toList()
          : null;
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
        uniqueBookId: noteFromSql['bookId']);
  }

  Future<void> insertNoteToSql(Map<String, dynamic> noteFromFirestore) async {
    await ref.read(sqlProvider).insertNoteToBook(
        noteFromFirestore['note'], noteFromFirestore['bookId'], context);
  }
}
