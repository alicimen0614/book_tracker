import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/models/bookswork_model.dart';
import 'package:book_tracker/models/trendingbooks_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/discover_screen/book_editions_view.dart';
import 'package:book_tracker/screens/discover_screen/detailed_categories_view.dart';
import 'package:book_tracker/screens/discover_screen/detailed_edition_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sealed_languages/sealed_languages.dart';

class TrendingBookInfoView extends ConsumerStatefulWidget {
  const TrendingBookInfoView({super.key, required this.book});

  final TrendingBooksWorks? book;

  @override
  ConsumerState<TrendingBookInfoView> createState() =>
      _TrendingBookInfoViewState();
}

class _TrendingBookInfoViewState extends ConsumerState<TrendingBookInfoView> {
  bool isDataLoading = false;
  List<BookWorkEditionsModelEntries?>? editionsList = [];
  bool textShowMore = false;
  BookWorkModel bookWorkModel = BookWorkModel();

  @override
  void initState() {
    getPageData();
    super.initState();
  }

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
            body: isDataLoading == false
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                    child: Column(
                      children: [
                        bookInfoBarBuilder(),
                        const SizedBox(
                          height: 15,
                        ),
                        bookInfoBodyBuilder(),
                      ],
                    ),
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  )));
  }

  Expanded bookInfoBodyBuilder() {
    bool isThereMoreEditionsThanFive = editionsList!.length > 5;
    print(isThereMoreEditionsThanFive);
    int itemCount = editionsList!.length;
    print("$itemCount-1");
    return Expanded(
      child: Scrollbar(
        thickness: 2,
        radius: Radius.circular(20),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            bookWorkModel.description != null
                ? descriptionInfoBuilder()
                : const SizedBox.shrink(),
            widget.book!.language != null
                ? availableLanguagesBuilder()
                : SizedBox.shrink(),
            bookWorkModel.firstSentence != null
                ? firstSentenceBuilder()
                : const SizedBox.shrink(),
            isThereMoreEditionsThanFive == true
                ? editionsBuilder(5)
                : editionsBuilder(itemCount)
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

  Column editionsBuilder(int itemCount) {
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
                          editionInfo: editionsList![index]!,
                          isNavigatingFromLibrary: false,
                        ),
                      ));
                },
                child: Column(children: [
                  Expanded(
                      child: editionsList![index]!.covers != null
                          ? Image.network(
                              "https://covers.openlibrary.org/b/id/${editionsList![index]!.covers!.first}-M.jpg",
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset("lib/assets/images/error.png"),
                            )
                          : Image.asset("lib/assets/images/nocover.jpg")),
                  SizedBox(
                    width: 75,
                    child: Text(
                      editionsList![index]!.title!,
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
                        editionsList: editionsList!,
                        title: widget.book!.title!,
                      );
                    },
                  ));
                },
                child:
                    Text("${editionsList!.length} Baskının Tümünü Görüntüle")))
      ],
    );
  }

  Column firstSentenceBuilder() {
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
        Text(bookWorkModel.firstSentence!.value!),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }

  Column descriptionInfoBuilder() {
    String textAsString = bookWorkModel.description!.replaceRange(0, 26, "");

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
                    bookWorkModel.description!.startsWith("{")
                        ? textAsString.replaceRange(
                            textAsString.length - 1, textAsString.length, "")
                        : bookWorkModel.description!,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  )
                : Text(
                    bookWorkModel.description!.startsWith("{")
                        ? textAsString.replaceRange(
                            textAsString.length - 1, textAsString.length, "")
                        : bookWorkModel.description!,
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

  Row bookInfoBarBuilder() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.teal,
            child: Image.network(
              "https://covers.openlibrary.org/b/id/${widget.book!.coverI}-M.jpg",
              errorBuilder: (context, error, stackTrace) =>
                  Image.asset("lib/assets/images/error.png"),
            ),
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
                child: bookWorkModel.subjects != null
                    ? ListView.builder(
                        physics: BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: bookWorkModel.subjects!.length,
                        itemBuilder: (context, index) {
                          return TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DetailedCategoriesView(
                                              categoryName: bookWorkModel
                                                  .subjects![index]!),
                                    ));
                              },
                              child: Text(bookWorkModel.subjects![index]!));
                        })
                    : const SizedBox.shrink(),
              )
            ],
          ),
        )
      ],
    );
  }

  Future<void> getPageData() async {
    setState(() {
      isDataLoading = true;
    });

    await getBookEditionEntriesList();
    await getBookWorkModel();

    setState(() {
      isDataLoading = false;
    });
  }

  Future<void> getBookEditionEntriesList() async {
    editionsList = await ref
        .read(booksProvider)
        .bookEditionsEntriesList(widget.book!.key!);
  }

  Future<void> getBookWorkModel() async {
    bookWorkModel =
        await ref.read(booksProvider).getBooksWorkModel(widget.book!.key!);
  }
}
