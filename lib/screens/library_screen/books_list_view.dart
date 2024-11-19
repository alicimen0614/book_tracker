import 'dart:convert';

import 'package:book_tracker/const.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/discover_screen/shimmer_effect_builders/grid_view_books_shimmer.dart';
import 'package:book_tracker/screens/home_screen/add_quote_screen.dart';
import 'package:book_tracker/screens/library_screen/add_note_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BooksListView extends ConsumerStatefulWidget {
  const BooksListView({super.key, required this.isNotes});

  final bool isNotes;
  @override
  ConsumerState<BooksListView> createState() => _BooksListViewState();
}

class _BooksListViewState extends ConsumerState<BooksListView> {
  List<BookWorkEditionsModelEntries>? bookListFromFirebase = [];
  List<BookWorkEditionsModelEntries>? bookListFromSql = [];
  List<BookWorkEditionsModelEntries>? bookListToShow = [];
  List<int>? listOfBookIdsFromSql;

  @override
  void initState() {
    getBookIds();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bookListFromFirebase =
        ref.watch(bookStateProvider).listOfBooksFromFirestore;

    bookListFromSql = ref.watch(bookStateProvider).listOfBooksFromSql;

    bookListToShow = ref.watch(bookStateProvider).listOfBooksToShow;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
            widget.isNotes == true
                ? AppLocalizations.of(context)!.selectBookToAddNote
                : AppLocalizations.of(context)!.selectBookToAddQuote,
            style: TextStyle(
                fontSize: MediaQuery.of(context).size.height / 40,
                fontWeight: FontWeight.bold)),
        leadingWidth: 50,
        leading: IconButton(
            splashRadius: 25,
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_sharp,
              size: 30,
            )),
        automaticallyImplyLeading: false,
      ),
      body: ref.watch(bookStateProvider).isLoading == false
          ? bookListToShow!.isNotEmpty
              ? GridView.builder(
                  padding: const EdgeInsets.all(5.0),
                  itemCount: bookListToShow!.length,
                  physics: const ClampingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1,
                      crossAxisSpacing: 25,
                      mainAxisSpacing: 25,
                      mainAxisExtent: 230),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: InkWell(
                        customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        onTap: () {
                          widget.isNotes == true
                              ? Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddNoteView(
                                        isNavigatingFromNotesView: true,
                                        bookImage: listOfBookIdsFromSql!
                                                        .contains(
                                                            uniqueIdCreater(
                                                                bookListToShow![
                                                                    index])) ==
                                                    true &&
                                                bookListToShow![index].covers !=
                                                    null &&
                                                bookListToShow![index]
                                                        .imageAsByte !=
                                                    null
                                            ? Image.memory(
                                                base64Decode(getImageAsByte(
                                                    bookListFromSql,
                                                    bookListToShow![index])),
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    Image.asset(
                                                  "lib/assets/images/error.png",
                                                ),
                                              )
                                            : bookListToShow![index].covers !=
                                                        null &&
                                                    bookListToShow![index]
                                                            .imageAsByte ==
                                                        null
                                                ? Image.network(
                                                    "https://covers.openlibrary.org/b/id/${bookListToShow![index].covers!.first!}-M.jpg",
                                                    errorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        Image.asset(
                                                      "lib/assets/images/error.png",
                                                    ),
                                                  )
                                                : bookListToShow![index]
                                                            .imageAsByte !=
                                                        null
                                                    ? Image.memory(
                                                        base64Decode(
                                                            bookListToShow![
                                                                    index]
                                                                .imageAsByte!),
                                                        width: 90,
                                                        fit: BoxFit.fill,
                                                      )
                                                    : null,
                                        showDeleteIcon: false,
                                        bookInfo: bookListToShow![index]),
                                  ))
                              : Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddQuoteScreen(
                                            isNavigatingFromDetailedEdition:
                                                false,
                                            showDeleteIcon: false,
                                            bookInfo: bookListToShow![index],
                                            bookImage: listOfBookIdsFromSql!.contains(
                                                            uniqueIdCreater(
                                                                bookListToShow![
                                                                    index])) ==
                                                        true &&
                                                    bookListToShow![index]
                                                            .covers !=
                                                        null &&
                                                    bookListToShow![index]
                                                            .imageAsByte !=
                                                        null
                                                ? Image.memory(
                                                    base64Decode(getImageAsByte(
                                                        bookListFromSql,
                                                        bookListToShow![
                                                            index])),
                                                    errorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        Image.asset(
                                                      "lib/assets/images/error.png",
                                                    ),
                                                  )
                                                : bookListToShow![index]
                                                                .covers !=
                                                            null &&
                                                        bookListToShow![index]
                                                                .imageAsByte ==
                                                            null
                                                    ? Image.network(
                                                        "https://covers.openlibrary.org/b/id/${bookListToShow![index].covers!.first!}-M.jpg",
                                                        errorBuilder: (context,
                                                                error,
                                                                stackTrace) =>
                                                            Image.asset(
                                                          "lib/assets/images/error.png",
                                                        ),
                                                      )
                                                    : bookListToShow![index]
                                                                .imageAsByte !=
                                                            null
                                                        ? Image.memory(
                                                            base64Decode(
                                                                bookListToShow![
                                                                        index]
                                                                    .imageAsByte!),
                                                            width: 90,
                                                            fit: BoxFit.fill,
                                                          )
                                                        : null,
                                          )));
                        },
                        child: Column(children: [
                          Expanded(
                            flex: 15,
                            child: Hero(
                                tag: uniqueIdCreater(bookListToShow![index]),
                                child: Material(
                                  color: Colors.transparent,
                                  child: Ink(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        image: DecorationImage(
                                          fit: BoxFit.fill,
                                          onError: (exception, stackTrace) =>
                                              const AssetImage(
                                                  "lib/assets/images/error.png"),
                                          image: listOfBookIdsFromSql!.contains(
                                                          uniqueIdCreater(
                                                              bookListToShow![
                                                                  index])) ==
                                                      true &&
                                                  bookListToShow![index]
                                                          .covers !=
                                                      null &&
                                                  bookListToShow![index]
                                                          .imageAsByte !=
                                                      null
                                              ? Image.memory(
                                                  base64Decode(getImageAsByte(
                                                      bookListFromSql,
                                                      bookListToShow![index])),
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      Image.asset(
                                                          "lib/assets/images/error.png"),
                                                  fit: BoxFit.fill,
                                                ).image
                                              : bookListToShow![index].covers !=
                                                          null &&
                                                      bookListToShow![index]
                                                              .imageAsByte ==
                                                          null
                                                  ? NetworkImage(
                                                      "https://covers.openlibrary.org/b/id/${bookListToShow![index].covers!.first!}-M.jpg",
                                                    )
                                                  : bookListToShow![index]
                                                              .imageAsByte !=
                                                          null
                                                      ? Image.memory(
                                                          base64Decode(
                                                              bookListToShow![
                                                                      index]
                                                                  .imageAsByte!),
                                                          width: 90,
                                                          fit: BoxFit.fill,
                                                        ).image
                                                      : Image.asset(
                                                          "lib/assets/images/nocover.jpg",
                                                        ).image,
                                        )),
                                    padding: EdgeInsets.zero,
                                  ),
                                )),
                          ),
                          const Spacer(),
                          Expanded(
                            flex: 7,
                            child: SizedBox(
                              width: 200,
                              child: Text(
                                bookListToShow![index].title!,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ]),
                      ),
                    );
                  },
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "lib/assets/images/shelves.png",
                        width: MediaQuery.of(context).size.width / 2,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.width / 10,
                      ),
                      Text(
                        AppLocalizations.of(context)!.emptyLibraryMessage,
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height / 40,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 60,
                      ),
                      Text(
                        widget.isNotes == true
                            ? AppLocalizations.of(context)!.addBookBeforeNote
                            : AppLocalizations.of(context)!.addBookBeforeQuote,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height / 40,
                            color: Colors.grey),
                      )
                    ],
                  ),
                )
          : gridViewBooksShimmerEffectBuilder(),
    );
  }

  Future<void> getBookIds() async {
    if (bookListFromSql != null) {
      listOfBookIdsFromSql =
          bookListFromSql!.map((e) => uniqueIdCreater(e)).toList();
    }
  }
}
