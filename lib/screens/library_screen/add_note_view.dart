import 'dart:convert';
import 'dart:developer';

import 'package:book_tracker/const.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class AddNoteView extends ConsumerStatefulWidget {
  const AddNoteView(
      {super.key,
      required this.showDeleteIcon,
      this.bookImage,
      required this.bookInfo,
      this.initialNoteValue = "",
      this.noteId,
      this.isNavigatingFromNotesView = false,
      this.noteDate = ""});

  final bool showDeleteIcon;
  final Image? bookImage;
  final BookWorkEditionsModelEntries bookInfo;
  final String initialNoteValue;
  final int? noteId;
  final bool isNavigatingFromNotesView;
  final String noteDate;

  @override
  ConsumerState<AddNoteView> createState() => _AddNoteViewState();
}

class _AddNoteViewState extends ConsumerState<AddNoteView> {
  final noteFieldController = TextEditingController();
  int oldNoteId = 0;
  String date = "";
  bool hasNoteSaved = false;

  @override
  void initState() {
    initializeDateFormatting('tr');
    if (widget.noteId != null) {
      oldNoteId = widget.noteId!;
    }
    date = DateFormat("dd MMMM yyy H.m").format(DateTime.now());

    noteFieldController.text = widget.initialNoteValue;

    super.initState();
  }

  @override
  void dispose() {
    noteFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log("${uniqueIdCreater(widget.bookInfo)} unique");
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
            title: Text("Kitaba bir not ekle: ${widget.bookInfo.title}",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            centerTitle: true,
            leadingWidth: 50,
            leading: IconButton(
                splashRadius: 25,
                onPressed: () => Future.delayed(
                      const Duration(milliseconds: 100),
                      () {
                        Navigator.pop(context, hasNoteSaved);
                      },
                    ),
                icon: const Icon(
                  Icons.arrow_back_sharp,
                  size: 30,
                )),
            automaticallyImplyLeading: false,
            elevation: 0,
            actions: [
              widget.showDeleteIcon == true
                  ? IconButton(
                      tooltip: "Notu Sil",
                      onPressed: () async {
                        alertDialogBuilder(context);
                      },
                      icon: const Icon(
                        Icons.delete_forever,
                        size: 30,
                      ),
                      splashRadius: 25,
                    )
                  : const SizedBox.shrink(),
              IconButton(
                splashRadius: 25,
                onPressed: () async {
                  // note update condition
                  if (widget.initialNoteValue != noteFieldController.text &&
                      widget.initialNoteValue != "" &&
                      noteFieldController.text != "") {
                    FocusScope.of(context).unfocus();
                    //deleting the old note from sql if there is any
                    if (widget.noteId != null) {
                      await ref
                          .read(sqlProvider)
                          .deleteNote(oldNoteId, context);
                    }
                    //inserting the note to sql
                    await ref.read(sqlProvider).insertNoteToBook(
                        noteFieldController.text,
                        uniqueIdCreater(widget.bookInfo),
                        context,
                        date);

                    if (ref.read(authProvider).currentUser != null) {
                      if (widget.noteId != null) {
                        //deleting the old note from firebase if there is any
                        ref.read(firestoreProvider).deleteNote(context,
                            referencePath: 'usersBooks',
                            userId: ref.read(authProvider).currentUser!.uid,
                            noteId: oldNoteId.toString());
                      }
                      //inserting the note to firebase
                      ref.read(firestoreProvider).setNoteData(context,
                          collectionPath: 'usersBooks',
                          note: noteFieldController.text,
                          userId: ref.read(authProvider).currentUser!.uid,
                          uniqueBookId: uniqueIdCreater(widget.bookInfo),
                          noteDate: date);
                    }

                    showSnackBar(context, "Not Başarıyla Güncellendi");
                    hasNoteSaved = true;
                    Future.delayed(
                      const Duration(milliseconds: 100),
                      () {
                        Navigator.pop(context, hasNoteSaved);
                      },
                    );
                  }
                  //new note condition
                  else if (widget.initialNoteValue == "" &&
                      noteFieldController.text != "") {
                    FocusScope.of(context).unfocus();
                    //inserting the note to sql and inserting the book to sql if it isn't already
                    await ref.read(sqlProvider).insertNoteToBook(
                        noteFieldController.text,
                        uniqueIdCreater(widget.bookInfo),
                        context,
                        date);

                    await ref.read(sqlProvider).insertBook(
                        widget.bookInfo,
                        widget.bookInfo.bookStatus!,
                        widget.bookInfo.imageAsByte != null
                            ? base64Decode(widget.bookInfo.imageAsByte!)
                            : null,
                        context);

                    if (ref.read(authProvider).currentUser != null) {
                      ref.read(firestoreProvider).setNoteData(context,
                          collectionPath: 'usersBooks',
                          note: noteFieldController.text,
                          userId: ref.read(authProvider).currentUser!.uid,
                          uniqueBookId: uniqueIdCreater(widget.bookInfo),
                          noteDate: date);
                    }

                    showSnackBar(context, "Not Başarıyla Eklendi");
                    hasNoteSaved = true;
                    Future.delayed(
                      const Duration(milliseconds: 100),
                      () {
                        Navigator.pop(context, hasNoteSaved);
                      },
                    );
                    if (widget.isNavigatingFromNotesView == true) {
                      Future.delayed(
                        const Duration(milliseconds: 100),
                        () {
                          Navigator.pop(context, hasNoteSaved);
                        },
                      );
                    }
                  } //no note written and trying to save
                  else if (widget.initialNoteValue == "" &&
                      noteFieldController.text == "") {
                    FocusScope.of(context).unfocus();
                    showSnackBar(context, "Lütfen Önce Bir Not Ekleyin");
                  }
                  //there is initial note but trying to save when its empty
                  else if (widget.initialNoteValue != "" &&
                      noteFieldController.text == "") {
                    FocusScope.of(context).unfocus();
                    showSnackBar(
                        context, "Lütfen Önce Bir Not Ekleyin Yada Notu Silin");
                  } else {
                    FocusScope.of(context).unfocus();
                    Future.delayed(
                      const Duration(milliseconds: 100),
                      () {
                        Navigator.pop(context);
                      },
                    );
                  }
                },
                icon: const Icon(Icons.check_sharp, size: 30),
              )
            ]),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(children: [
            widget.bookImage != null
                ? Expanded(
                    flex: 5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Align(
                        alignment: Alignment.center,
                        child: Hero(
                            tag: uniqueIdCreater(widget.bookInfo),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image(
                                  fit: BoxFit.fitHeight,
                                  image: widget.bookImage!.image,
                                ))),
                      ),
                    ),
                  )
                : Expanded(
                    flex: 5,
                    child: Align(
                        alignment: Alignment.center,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child:
                                Image.asset("lib/assets/images/nocover.jpg"))),
                  ),
            Expanded(
                flex: widget.bookInfo.title!.characters.length > 20 ? 2 : 1,
                child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      widget.bookInfo.title!,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17),
                      textAlign: TextAlign.center,
                    ))),
            Expanded(
              flex: 1,
              child: Text(
                  widget.noteDate != ""
                      ? widget.noteDate
                      : "${DateFormat("dd MMMM yyy H.mm").format(DateTime.now())} ",
                  style: const TextStyle(
                      color: Color(0xFF1B7695), fontWeight: FontWeight.bold)),
            ),
            Expanded(
              flex: 5,
              child: TextFormField(
                controller: noteFieldController,
                decoration: const InputDecoration(
                  hintText: "Notunuzu girin.",
                ),
                maxLines: null,
                minLines: null,
                expands: true,
              ),
            )
          ]),
        ),
      ),
    );
  }

  void showSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 2),
      content: Text(text),
      action: SnackBarAction(label: 'Tamam', onPressed: () {}),
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<dynamic> alertDialogBuilder(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("BookTracker"),
          content: const Text("Bu notu silmek istediğinizden emin misiniz?"),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Vazgeç")),
            TextButton(
                onPressed: () async {
                  await ref
                      .read(sqlProvider)
                      .deleteNote(widget.noteId!, context);
                  if (ref.read(authProvider).currentUser != null) {
                    await ref.read(firestoreProvider).deleteNote(context,
                        referencePath: 'usersBooks',
                        userId: ref.read(authProvider).currentUser!.uid,
                        noteId: widget.noteId.toString());
                  }
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text("Sil"))
          ],
        );
      },
    );
  }
}
