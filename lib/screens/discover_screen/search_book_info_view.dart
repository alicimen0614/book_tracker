import 'package:book_tracker/models/books_model.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/models/bookswork_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/discover_screen/book_editions_view.dart';
import 'package:book_tracker/screens/discover_screen/detailed_categories_view.dart';
import 'package:book_tracker/screens/discover_screen/detailed_edition_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sealed_languages/sealed_languages.dart';

class SearchBookInfoView extends ConsumerStatefulWidget {
  const SearchBookInfoView({super.key, required this.book});

  final BooksModelDocs? book;

  @override
  ConsumerState<SearchBookInfoView> createState() => _SearchBookInfoViewState();
}

class _SearchBookInfoViewState extends ConsumerState<SearchBookInfoView> {
  bool textShowMore = false;
  bool textShowMoreForFirstSentence = false;
  @override
  Widget build(
    BuildContext context,
  ) {
    print(widget.book!.language);
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        leadingWidth: 50,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 30,
            )),
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromRGBO(195, 129, 84, 1),
        elevation: 5,
      ),
      body: FutureBuilder(
          future: ref
              .read(booksProvider)
              .bookEditionsEntriesList(widget.book!.key!),
          builder: (context, editionsSnapshot) {
            if (editionsSnapshot.hasData) {
              return FutureBuilder(
                  future: ref
                      .read(booksProvider)
                      .getBooksWorkModel(widget.book!.key!),
                  builder: (context, workSnapshot) {
                    if (workSnapshot.hasData) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                        child: Column(
                          children: [
                            bookInfoBarBuilder(workSnapshot),
                            const SizedBox(
                              height: 15,
                            ),
                            bookInfoBodyBuilder(workSnapshot, editionsSnapshot),
                          ],
                        ),
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  });
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    ));
  }

  Expanded bookInfoBodyBuilder(AsyncSnapshot<BookWorkModel> workSnapshot,
      AsyncSnapshot<List<BookWorkEditionsModelEntries?>?> editionsSnapshot) {
    bool isThereMoreEditionsThanFive = editionsSnapshot.data!.length > 5;
    print(isThereMoreEditionsThanFive);
    int itemCount = editionsSnapshot.data!.length;

    print("$itemCount-1");

    return Expanded(
      child: Scrollbar(
        thickness: 2,
        radius: Radius.circular(20),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            workSnapshot.data!.description != null
                ? descriptionInfoBuilder(workSnapshot)
                : const SizedBox.shrink(),
            widget.book!.language != null
                ? availableLanguagesBuilder()
                : SizedBox.shrink(),
            workSnapshot.data!.firstSentence != null
                ? firstSentenceBuilder(workSnapshot)
                : const SizedBox.shrink(),
            isThereMoreEditionsThanFive == true
                ? editionsBuilder(editionsSnapshot, 5)
                : editionsBuilder(editionsSnapshot, itemCount)
          ]),
        ),
      ),
    );
  }

  Column availableLanguagesBuilder() {
    return Column(
      children: [
        Row(
          children: [
            const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Mevcut Diller",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                )),
            SizedBox(
              width: 5,
            ),
            Tooltip(
                showDuration: Duration(seconds: 3),
                triggerMode: TooltipTriggerMode.tap,
                message: "Buradaki diller mevcut tüm dilleri göstermeyebilir.",
                child: Icon(Icons.info_outline))
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          height: 16,
          width: double.infinity,
          child: ListView.separated(
            physics: BouncingScrollPhysics(),
            separatorBuilder: (context, index) => SizedBox(
              width: 10,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: widget.book!.language!.length,
            itemBuilder: (context, index) {
              /* Some of the language codes coming from the api didn't match with the codes in the package but they matched with the bibliographiccode
                      so ı've searched within the list of languages that matches the language code coming from api and the package's bibliographiccode */
              int indexOfBibliographicCode = NaturalLanguage.list.indexWhere(
                  (element) =>
                      widget.book!.language![index]!.toUpperCase() ==
                      element.bibliographicCode);

              if (NaturalLanguage.maybeFromValue(
                      widget.book!.language![index]!.toUpperCase()) !=
                  null) {
                String country = NaturalLanguage.maybeFromValue(
                  widget.book!.language![index]!.toUpperCase(),
                )!
                    .name;
                return Text(country);
              } else if (indexOfBibliographicCode != -1) {
                return Text(
                    NaturalLanguage.list[indexOfBibliographicCode].name);
              } else {
                return Text(widget.book!.language![index]!);
              }
            },
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Column editionsBuilder(
      AsyncSnapshot<List<BookWorkEditionsModelEntries?>?> editionsSnapshot,
      int itemCount) {
    return Column(
      children: [
        const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Baskılar",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            )),
        const SizedBox(
          height: 10,
        ),
        Container(
          width: double.infinity,
          height: 100,
          child: ListView.separated(
            physics: BouncingScrollPhysics(),
            separatorBuilder: (context, index) => SizedBox(
              width: 10,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: itemCount,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailedEditionInfo(
                          editionInfo: editionsSnapshot.data![index]!,
                          isNavigatingFromLibrary: false,
                          bookImage: Image.network(
                              "https://covers.openlibrary.org/b/id/${editionsSnapshot.data![index]!.covers!.first}-M.jpg"),
                        ),
                      ));
                },
                child: Column(children: [
                  Expanded(
                      child: editionsSnapshot.data![index]!.covers != null
                          ? Image.network(
                              "https://covers.openlibrary.org/b/id/${editionsSnapshot.data![index]!.covers!.first}-M.jpg",
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset("lib/assets/images/error.png"),
                            )
                          : Image.asset("lib/assets/images/nocover.jpg")),
                  SizedBox(
                    width: 75,
                    child: Text(
                      editionsSnapshot.data![index]!.title!,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),
                  )
                ]),
              );
            },
          ),
        ),
        Align(
            alignment: Alignment.centerRight,
            child: TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return BookEditionsView(
                        editionsList: editionsSnapshot.data,
                        title: widget.book!.title!,
                      );
                    },
                  ));
                },
                child: Text(
                    "${editionsSnapshot.data!.length} Baskının Tümünü Görüntüle")))
      ],
    );
  }

  Column firstSentenceBuilder(AsyncSnapshot<BookWorkModel> workSnapshot) {
    return Column(
      children: [
        const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "İlk Cümle",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            )),
        const SizedBox(
          height: 10,
        ),
        Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            child: textShowMoreForFirstSentence == false
                ? Text(
                    workSnapshot.data!.firstSentence!.value!,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  )
                : Text(
                    workSnapshot.data!.firstSentence!.value!,
                  )),
        Align(
          alignment: Alignment.topRight,
          child: TextButton(
              onPressed: () {
                setState(() {
                  textShowMoreForFirstSentence = !textShowMoreForFirstSentence;
                });
              },
              child: textShowMoreForFirstSentence == false
                  ? const Text("Daha fazla")
                  : const Text("Daha az")),
        ),
      ],
    );
  }

  Column descriptionInfoBuilder(AsyncSnapshot<BookWorkModel> snapshot) {
    String textAsString = snapshot.data!.description!.replaceRange(0, 26, "");
    return Column(
      children: [
        const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Açıklama",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            )),
        const SizedBox(
          height: 10,
        ),
        Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            child: textShowMore == false
                ? Text(
                    /* There is an issue with the api that is the description comes sometimes as String and sometimes as Map<String,Dynamic> with
                  type and value properties to fix this ı've made a easy solution that is first ı've converted the variable to String on my
                  model if it was a map it was starting with  "{type: /type/text, value: " so it is 26 characters and ı used replaceRange
                  method and if it was a map that is coming from api "{type: /type/text, value: " was being deleted and the last character "}" 
                  was also being deleted*/
                    snapshot.data!.description!.startsWith("{")
                        ? textAsString.replaceRange(
                            textAsString.length - 1, textAsString.length, "")
                        : snapshot.data!.description!,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  )
                : Text(
                    snapshot.data!.description!.startsWith("{")
                        ? textAsString.replaceRange(
                            textAsString.length - 1, textAsString.length, "")
                        : snapshot.data!.description!,
                  )),
        Align(
          alignment: Alignment.topRight,
          child: TextButton(
              onPressed: () {
                setState(() {
                  textShowMore = !textShowMore;
                });
              },
              child: textShowMore == false
                  ? const Text("Daha fazla")
                  : const Text("Daha az")),
        ),
      ],
    );
  }

  Row bookInfoBarBuilder(AsyncSnapshot<BookWorkModel> snapshot) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.teal,
            child: snapshot.data!.covers != null
                ? Image.network(
                    "https://covers.openlibrary.org/b/id/${snapshot.data!.covers!.first!}-M.jpg",
                    errorBuilder: (context, error, stackTrace) =>
                        Image.asset("lib/assets/images/error.png"),
                  )
                : Image.asset("lib/assets/images/nocover.jpg"),
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                  child: Text(
                    widget.book!.title!,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ),
              Text(widget.book!.authorName!.first!,
                  style: const TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 10),
              Container(
                height: 50,
                width: 200,
                child: snapshot.data!.subjects != null
                    ? ListView.builder(
                        physics: BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data!.subjects!.length,
                        itemBuilder: (context, index) {
                          return TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DetailedCategoriesView(
                                              categoryName: snapshot
                                                  .data!.subjects![index]!),
                                    ));
                              },
                              child: Text(snapshot.data!.subjects![index]!));
                        })
                    : const SizedBox.shrink(),
              )
            ],
          ),
        )
      ],
    );
  }
}
