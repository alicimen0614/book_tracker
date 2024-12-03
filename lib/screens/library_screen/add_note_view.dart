import 'dart:convert';
import 'package:book_tracker/const.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/services/analytics_service.dart';
import 'package:book_tracker/widgets/custom_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
            title: Text(
                "${AppLocalizations.of(context)!.addNoteToBook}: ${widget.bookInfo.title}",
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height / 50,
                    fontWeight: FontWeight.bold)),
            centerTitle: true,
            leadingWidth: 50,
            leading: IconButton(
                splashRadius: 25,
                onPressed: () async {
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                    Future.delayed(
                      const Duration(milliseconds: 150),
                      () {
                        Navigator.pop(context, hasNoteSaved);
                      },
                    );
                  } else {
                    Navigator.pop(context, hasNoteSaved);
                  }
                },
                icon: const Icon(
                  Icons.arrow_back_sharp,
                  size: 30,
                )),
            automaticallyImplyLeading: false,
            elevation: 0,
            actions: [
              widget.showDeleteIcon == true
                  ? IconButton(
                      tooltip: AppLocalizations.of(context)!.deleteNote,
                      onPressed: () async {
                        alertDialogBuilder(context);
                      },
                      icon: const Icon(
                        Icons.delete,
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
                    AnalyticsService().logEvent(
                        "update_note", {"note_id": widget.noteId ?? ""});
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

                    showSnackBar(context,
                        AppLocalizations.of(context)!.noteSuccessfullyUpdated);
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
                    AnalyticsService().logEvent("add_note", {});
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
                    ref.read(bookStateProvider.notifier).getPageData();
                    showSnackBar(context,
                        AppLocalizations.of(context)!.noteSuccessfullyAdded);
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
                    showSnackBar(context,
                        AppLocalizations.of(context)!.pleaseAddNoteFirst);
                  }
                  //there is initial note but trying to save when its empty
                  else if (widget.initialNoteValue != "" &&
                      noteFieldController.text == "") {
                    FocusScope.of(context).unfocus();
                    showSnackBar(
                        context,
                        AppLocalizations.of(context)!
                            .pleaseAddOrDeleteNoteFirst);
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(children: [
            widget.bookImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Align(
                      alignment: Alignment.center,
                      child: Hero(
                          tag: uniqueIdCreater(widget.bookInfo),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image(
                                height: MediaQuery.of(context).size.height / 3,
                                fit: BoxFit.fitHeight,
                                image: widget.bookImage!.image,
                              ))),
                    ),
                  )
                : Align(
                    alignment: Alignment.center,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset("lib/assets/images/nocover.jpg"))),
            SizedBox(height: MediaQuery.of(context).size.height / 40),
            Align(
                alignment: Alignment.center,
                child: Text(
                  widget.bookInfo.title!,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.height / 60),
                  textAlign: TextAlign.center,
                )),
            SizedBox(height: MediaQuery.of(context).size.height / 40),
            Text(
                widget.noteDate != ""
                    ? widget.noteDate
                    : "${DateFormat("dd MMMM yyy HH.mm").format(DateTime.now())} ",
                style: TextStyle(
                    color: const Color(0xFF1B7695),
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.height / 60)),
            SizedBox(height: MediaQuery.of(context).size.height / 40),
            TextFormField(
              maxLength: 200,
              controller: noteFieldController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.enterYourNote,
              ),
              maxLines: null,
              minLines: null,
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
      action: SnackBarAction(
          label: AppLocalizations.of(context)!.okay, onPressed: () {}),
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<dynamic> alertDialogBuilder(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return CustomAlertDialog(
            title: "VastReads",
            description: AppLocalizations.of(context)!.confirmDeleteNote,
            firstButtonText: AppLocalizations.of(context)!.cancel,
            firstButtonOnPressed: () {
              Navigator.pop(context);
            },
            thirdButtonText: AppLocalizations.of(context)!.delete,
            thirdButtonOnPressed: () async {
              AnalyticsService()
                  .logEvent("delete_note", {"note_id": widget.noteId ?? ""});
              await ref.read(sqlProvider).deleteNote(widget.noteId!, context);
              if (ref.read(authProvider).currentUser != null) {
                await ref.read(firestoreProvider).deleteNote(context,
                    referencePath: 'usersBooks',
                    userId: ref.read(authProvider).currentUser!.uid,
                    noteId: widget.noteId.toString());
              }
              Navigator.pop(context);
              Navigator.pop(context, true);
            });
      },
    );
  }
}
