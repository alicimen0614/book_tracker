import 'dart:convert';

import 'package:book_tracker/const.dart';
import 'package:book_tracker/l10n/app_localizations.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/models/quote_model.dart';
import 'package:book_tracker/providers/quotes_provider.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/services/analytics_service.dart';
import 'package:book_tracker/widgets/custom_alert_dialog.dart';
import 'package:book_tracker/widgets/delete_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AddQuoteScreen extends ConsumerStatefulWidget {
  const AddQuoteScreen(
      {super.key,
      required this.showDeleteIcon,
      this.bookImage,
      required this.bookInfo,
      this.initialQuoteValue = "",
      this.quoteDate = "",
      this.quoteId = "",
      required this.isNavigatingFromDetailedEdition});

  final bool showDeleteIcon;
  final Image? bookImage;
  final BookWorkEditionsModelEntries bookInfo;
  final String initialQuoteValue;
  final String quoteId;
  final String quoteDate;
  final bool isNavigatingFromDetailedEdition;

  @override
  ConsumerState<AddQuoteScreen> createState() => _AddNoteViewState();
}

class _AddNoteViewState extends ConsumerState<AddQuoteScreen> {
  final quoteFieldController = TextEditingController();
  String date = "";

  @override
  void initState() {
    super.initState();
    date = DateFormat("dd MMMM yyy H.m").format(DateTime.now());

    quoteFieldController.text = widget.initialQuoteValue;


    
  }

  @override
  void dispose() {
    quoteFieldController.dispose();
    super.dispose();
  }

  Future<List<String>> loadForbiddenWords() async {
    String jsonString = await DefaultAssetBundle.of(context).loadString('lib/assets/karaliste.json');
    final jsonData = jsonDecode(jsonString);
    return List<String>.from(jsonData['blacklist']);
  }

  Future<bool> doesContainForbiddenWords(String text) async{
    List<String> blacklist= await loadForbiddenWords();
   for (String word in blacklist) {
      RegExp regex = RegExp(r'\b' + RegExp.escape(word) + r'\b', caseSensitive: false);
      if (regex.hasMatch(text)) {
        return true;
      }
    }
   
    RegExp extraRegex = RegExp(r'\b[sS][ıiI1][çcC][aA][yY][ıiI1][mM]\b', caseSensitive: false);
    if (extraRegex.hasMatch(text)) {
      return true;
    }
    return false;
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
                widget.initialQuoteValue == ""
                    ? "${AppLocalizations.of(context)!.addQuote}: ${widget.bookInfo.title}"
                    : AppLocalizations.of(context)!.editQuote,
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height / 50,
                    fontWeight: FontWeight.bold)),
            centerTitle: true,
            leadingWidth: 50,
            elevation: 0,
            actions: [
              widget.showDeleteIcon == true
                  ? IconButton(
                      tooltip: AppLocalizations.of(context)!.deleteQuote,
                      onPressed: () async {
                        showDialog(context: context, builder: (context) => DeleteDialog(quoteId: widget.quoteId),);
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
                  if (quoteFieldController.text == "") {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            AppLocalizations.of(context)!.pleaseEnterQuote)));
                  } else if (quoteFieldController.text ==
                      widget.initialQuoteValue) {
                    Navigator.pop(context);
                  } else if (quoteFieldController.text !=
                          widget.initialQuoteValue &&
                      widget.initialQuoteValue != "") {
                    //updating the quote section
                     AnalyticsService().logEvent("update_quote", {
                     "new_content": quoteFieldController.text,"old_content":widget.initialQuoteValue
                    });
                    alertDialogForUpdateBuilder(context);
                  } else {
                    AnalyticsService().logEvent("add_quote", {
                     "content": quoteFieldController.text
                    });
                    //adding the new quote section

                    Quote quote = Quote(
                        bookAuthorName: widget.bookInfo.authorsNames != null &&
                                widget.bookInfo.authorsNames!.isNotEmpty
                            ? widget.bookInfo.authorsNames!.first
                            : null,
                        quoteText: quoteFieldController.text,
                        imageAsByte: widget.bookInfo.imageAsByte,
                        bookName: widget.bookInfo.title,
                        userId: ref.read(authProvider).currentUser!.uid,
                        bookCover: widget.bookInfo.covers?.first.toString(),
                        date: DateTime.now().toString(),
                        likes: [],
                        userName:
                            FirebaseAuth.instance.currentUser?.displayName,
                        userPicture:
                            FirebaseAuth.instance.currentUser?.photoURL,
                        likeCount: 0,isbnData: widget.bookInfo.isbn_13?.first ?? widget.bookInfo.isbn_10?.first??"");

                        if(await doesContainForbiddenWords(quoteFieldController.text)){
                          showSnackBar(context, AppLocalizations.of(context)!.quoteContainsForbiddenWords);
                          AnalyticsService().logEvent("quote_forbidden_word", {
                     "content": quoteFieldController.text,
                     "isbn_info": widget.bookInfo.isbn_10?.first ?? widget.bookInfo.isbn_13?.first??"",
                     "user_info": {
                       "user_id": ref.read(authProvider).currentUser!.uid,
                       "user_name": FirebaseAuth.instance.currentUser?.displayName,
                       "user_picture": FirebaseAuth.instance.currentUser?.photoURL
                     }

                    });
                          return;
                        }
                    ref
                        .read(firestoreProvider)
                        .setQuoteData(context, quote: quote.toJson());

                    ref
                        .read(quotesProvider.notifier)
                        .trendingPagingController
                        .refresh();
                    ref
                        .read(quotesProvider.notifier)
                        .recentPagingController
                        .refresh();
                    ref
                        .read(quotesProvider.notifier)
                        .currentUsersPagingController
                        .refresh();
                    if (widget.isNavigatingFromDetailedEdition) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(AppLocalizations.of(context)!
                            .quoteSuccessfullyAdded)));
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
                                fit: BoxFit.fitHeight,
                                image: widget.bookImage!.image,
                                height: MediaQuery.of(context).size.height / 3,
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
                widget.quoteDate != ""
                    ? DateTime.tryParse(widget.quoteDate) != null
                        ? DateFormat("dd MMMM yyy HH.mm")
                            .format(DateTime.tryParse(widget.quoteDate)!)
                        : "${DateFormat("dd MMMM yyy HH.mm").format(DateTime.now())} "
                    : DateFormat("dd MMMM yyy HH.mm").format(DateTime.now()),
                style: TextStyle(
                    color: const Color(0xFF1B7695),
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.height / 60)),
            SizedBox(height: MediaQuery.of(context).size.height / 40),
            TextFormField(
              maxLength: 600,
              controller: quoteFieldController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.enterQuote,
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


  Future<dynamic> alertDialogForUpdateBuilder(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text( Const.appName),
          content: Text(AppLocalizations.of(context)!.confirmSaveQuote),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(AppLocalizations.of(context)!.cancel)),
            TextButton(
                onPressed: () async {
                  AnalyticsService()
                      .logEvent("update_quote", {"quote_id": widget.quoteId});
                  ref.read(firestoreProvider).setQuoteData(context,
                      quote: {
                        "quoteText": quoteFieldController.text,
                        "date": DateTime.now().toString()
                      },
                      docId: widget.quoteId);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(AppLocalizations.of(context)!
                          .quoteSuccessfullyUpdated)));
                },
                child: Text(AppLocalizations.of(context)!.save))
          ],
        );
      },
    );
  }
}
