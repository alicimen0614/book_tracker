import 'dart:developer';

import 'package:book_tracker/const.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddNoteView extends ConsumerStatefulWidget {
  const AddNoteView(
      {super.key,
      required this.showDeleteIcon,
      this.bookImage,
      required this.bookInfo,
      this.initialNoteValue = "",
      this.noteId,
      this.isNavigatingFromNotesView = false});

  final bool showDeleteIcon;
  final Image? bookImage;
  final BookWorkEditionsModelEntries bookInfo;
  final String initialNoteValue;
  final int? noteId;
  final bool isNavigatingFromNotesView;

  @override
  ConsumerState<AddNoteView> createState() => _AddNoteViewState();
}

class _AddNoteViewState extends ConsumerState<AddNoteView> {
  final noteFieldController = TextEditingController();
  int oldNoteId = 0;

  @override
  void initState() {
    if (widget.noteId != null) {
      oldNoteId = widget.noteId!;
    }

    print(oldNoteId);
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
                style: TextStyle(fontSize: 16)),
            centerTitle: true,
            leadingWidth: 50,
            leading: IconButton(
                splashRadius: 25,
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 30,
                )),
            automaticallyImplyLeading: false,
            backgroundColor: const Color.fromRGBO(195, 129, 84, 1),
            elevation: 0,
            actions: [
              widget.showDeleteIcon == true
                  ? IconButton(
                      tooltip: "Notu Sil",
                      onPressed: () async {
                        alertDialogBuilder(context);
                      },
                      icon: Icon(
                        Icons.delete_forever,
                        size: 30,
                      ),
                      splashRadius: 25,
                    )
                  : SizedBox.shrink(),
              IconButton(
                splashRadius: 25,
                onPressed: () async {
                  if (widget.initialNoteValue != noteFieldController.text &&
                      widget.initialNoteValue != "") {
                    //deleting the old note from sql if there is any
                    if (widget.noteId != null) {
                      await ref.read(sqlProvider).deleteNote(oldNoteId);
                    }
                    //inserting the note to sql
                    await ref.read(sqlProvider).insertNoteToBook(
                        noteFieldController.text,
                        uniqueIdCreater(widget.bookInfo));

                    if (ref.read(authProvider).currentUser != null) {
                      if (widget.noteId != null) {
                        //deleting the old note from firebase if there is any
                        await ref.read(firestoreProvider).deleteNote(
                            referencePath: 'usersBooks',
                            userId: ref.read(authProvider).currentUser!.uid,
                            noteId: oldNoteId.toString());
                      }
                      //inserting the note to firebase
                      await ref.read(firestoreProvider).setNoteData(
                          collectionPath: 'usersBooks',
                          note: noteFieldController.text,
                          userId: ref.read(authProvider).currentUser!.uid,
                          uniqueBookId: uniqueIdCreater(widget.bookInfo));
                    }

                    showSnackBar(context, "Not Başarıyla Güncellendi");
                    Navigator.pop(context);
                  } else if (widget.initialNoteValue == "" &&
                      noteFieldController.text != "") {
                    //inserting the note to sql
                    await ref.read(sqlProvider).insertNoteToBook(
                        noteFieldController.text,
                        uniqueIdCreater(widget.bookInfo));

                    await ref.read(firestoreProvider).setNoteData(
                        collectionPath: 'usersBooks',
                        note: noteFieldController.text,
                        userId: ref.read(authProvider).currentUser!.uid,
                        uniqueBookId: uniqueIdCreater(widget.bookInfo));

                    showSnackBar(context, "Not Başarıyla Eklendi");
                    Navigator.pop(context);
                    if (widget.isNavigatingFromNotesView == true) {
                      Navigator.pop(context);
                    }
                  } else if (widget.initialNoteValue == "" &&
                      noteFieldController.text == "") {
                    showSnackBar(context, "Lütfen Önce Bir Not Ekleyin");
                  } else {
                    Navigator.pop(context);
                  }
                },
                icon: Icon(Icons.check_sharp, size: 30),
              )
            ]),
        body: Padding(
          padding: EdgeInsets.all(15),
          child: Column(children: [
            widget.bookImage != null
                ? Expanded(
                    flex: 5,
                    child: Align(
                      alignment: Alignment.center,
                      child: Card(
                          color: Colors.transparent,
                          elevation: 18,
                          child: Hero(
                              tag: uniqueIdCreater(widget.bookInfo),
                              child: widget.bookImage!)),
                    ),
                  )
                : Expanded(
                    flex: 5,
                    child: Align(
                        alignment: Alignment.center,
                        child: Image.asset("lib/assets/images/nocover.jpg")),
                  ),
            Expanded(
                flex: 1,
                child: Align(
                    alignment: Alignment.center,
                    child: Text(widget.bookInfo.title!))),
            Expanded(
              flex: 1,
              child: Text(
                  "${DateTime.now().day.toString()} ${monthsInYearInTurkish[DateTime.now().month]} ${DateTime.now().year} ${DateTime.now().toLocal().hour}:${DateTime.now().minute} ",
                  style: TextStyle(color: Colors.blue)),
            ),
            Expanded(
              flex: 5,
              child: TextFormField(
                controller: noteFieldController,
                decoration: InputDecoration(
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
      duration: Duration(seconds: 2),
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
                  await ref.read(sqlProvider).deleteNote(widget.noteId!);
                  if (ref.read(authProvider).currentUser != null) {
                    await ref.read(firestoreProvider).deleteNote(
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
