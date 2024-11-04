import 'dart:developer';
import 'package:book_tracker/const.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/models/quote_model.dart';
import 'package:book_tracker/providers/quotes_state_provider.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
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
    initializeDateFormatting('tr');

    date = DateFormat("dd MMMM yyy H.m").format(DateTime.now());

    quoteFieldController.text = widget.initialQuoteValue;

    super.initState();
  }

  @override
  void dispose() {
    quoteFieldController.dispose();
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
            title: Text(
                widget.initialQuoteValue == ""
                    ? "Bir alıntı ekle: ${widget.bookInfo.title}"
                    : "Alıntıyı Düzenle",
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height / 50,
                    fontWeight: FontWeight.bold)),
            centerTitle: true,
            leadingWidth: 50,
            elevation: 0,
            actions: [
              widget.showDeleteIcon == true
                  ? IconButton(
                      tooltip: "Alıntıyı Sil",
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
                  if (quoteFieldController.text == "") {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Lütfen bir alıntı giriniz.")));
                  } else if (quoteFieldController.text ==
                      widget.initialQuoteValue) {
                    Navigator.pop(context);
                  } else if (quoteFieldController.text !=
                          widget.initialQuoteValue &&
                      widget.initialQuoteValue != "") {
                    //updating the quote section
                    alertDialogForUpdateBuilder(context);
                  } else {
                    print(widget.bookInfo.authorsNames);
                    //adding the new quote section
                    Quote quote = Quote(
                        bookAuthorName: widget.bookInfo.authorsNames != null &&
                                widget.bookInfo.authorsNames!.isNotEmpty
                            ? widget.bookInfo.authorsNames!.first
                            : null,
                        quoteText: quoteFieldController.text,
                        bookName: widget.bookInfo.title,
                        userId: ref.read(authProvider).currentUser!.uid,
                        bookCover: widget.bookInfo.covers?.first.toString(),
                        date: DateTime.now().toString(),
                        likes: [],
                        userName:
                            FirebaseAuth.instance.currentUser?.displayName,
                        userPicture:
                            FirebaseAuth.instance.currentUser?.photoURL,
                        likeCount: 0);
                    ref
                        .read(firestoreProvider)
                        .setQuoteData(context, quote: quote.toJson());

                    ref.read(quotesProvider.notifier).fetchRecentQuotes();
                    ref.read(quotesProvider.notifier).fetchTrendingQuotes();
                    ref.read(quotesProvider.notifier).fetchCurrentUsersQuotes();
                    if (widget.isNavigatingFromDetailedEdition) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }

                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Alıntı başarıyla eklendi")));
                  }
                },
                icon: const Icon(Icons.check_sharp, size: 30),
              )
            ]),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(children: [
            SizedBox(height: MediaQuery.of(context).size.height / 40),
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
                        ? DateFormat("dd MMMM yyy H.mm")
                            .format(DateTime.tryParse(widget.quoteDate)!)
                        : "${DateFormat("dd MMMM yyy H.mm").format(DateTime.now())} "
                    : DateFormat("dd MMMM yyy H.mm").format(DateTime.now()),
                style: TextStyle(
                    color: const Color(0xFF1B7695),
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.height / 60)),
            SizedBox(height: MediaQuery.of(context).size.height / 40),
            TextFormField(
              controller: quoteFieldController,
              decoration: const InputDecoration(
                hintText: "Alıntı girin.",
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
          title: const Text("VastReads"),
          content:
              const Text("Bu alıntıyı silmek istediğinizden emin misiniz?"),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Vazgeç")),
            TextButton(
                onPressed: () async {
                  var result = await ref
                      .read(quotesProvider.notifier)
                      .deleteQuote(widget.quoteId);
                  if (result == true) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Alıntı başarıyla silindi.")));
                  } else {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content:
                            Text("Alıntı silinirken bir hata meydana geldi")));
                  }
                },
                child: const Text("Sil"))
          ],
        );
      },
    );
  }

  Future<dynamic> alertDialogForUpdateBuilder(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("VastReads"),
          content:
              const Text("Bu alıntıyı kaydetmek istediğinizden emin misiniz?"),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Vazgeç")),
            TextButton(
                onPressed: () async {
                  ref.read(firestoreProvider).setQuoteData(context,
                      quote: {
                        "quoteText": quoteFieldController.text,
                        "date": DateTime.now().toString()
                      },
                      docId: widget.quoteId);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Alıntı başarıyla güncellendi.")));
                },
                child: const Text("Kaydet"))
          ],
        );
      },
    );
  }
}
