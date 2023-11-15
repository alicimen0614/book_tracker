import 'package:book_tracker/models/authors_works_model.dart';
import 'package:book_tracker/models/books_model.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/models/bookswork_model.dart';
import 'package:book_tracker/models/trendingbooks_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/discover_screen/author_info_screen.dart';
import 'package:book_tracker/screens/discover_screen/book_editions_view.dart';
import 'package:book_tracker/screens/discover_screen/detailed_categories_view.dart';
import 'package:book_tracker/screens/discover_screen/detailed_edition_info.dart';
import 'package:book_tracker/services/internet_connection_service.dart';
import 'package:book_tracker/widgets/internet_connection_error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sealed_languages/sealed_languages.dart';
import 'package:transparent_image/transparent_image.dart';

import 'shimmer_effect_builders/book_info_view_shimmer.dart';

class BookInfoView extends ConsumerStatefulWidget {
  const BookInfoView(
      {super.key, this.trendingBook, this.searchBook, this.authorBook});

  final TrendingBooksWorks? trendingBook;
  final BooksModelDocs? searchBook;
  final AuthorsWorksModelEntries? authorBook;

  @override
  ConsumerState<BookInfoView> createState() => _BookInfoViewState();
}

class _BookInfoViewState extends ConsumerState<BookInfoView> {
  var mainBook;
  bool isDataLoading = false;
  List<BookWorkEditionsModelEntries?>? editionsList = [];
  bool textShowMoreForDescription = false;
  BookWorkModel? bookWorkModel = BookWorkModel();
  bool textShowMoreForFirstSentence = false;
  int? bookEditionsSize;
  bool isConnected = false;

  @override
  void initState() {
    mainBook = widget.searchBook != null
        ? widget.searchBook
        : widget.trendingBook != null
            ? widget.trendingBook
            : widget.authorBook;
    getPageData();
    super.initState();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
        appBar: AppBar(
          leadingWidth: 50,
          title: Text(
            "Kitap Detayı",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_sharp,
                size: 30,
              )),
          automaticallyImplyLeading: false,
          elevation: 0,
        ),
        body: isDataLoading == false
            ? Column(
                children: [
                  bookInfoBarBuilder(),
                  bookInfoBodyBuilder(),
                ],
              )
            : shimmerEffectForBookInfoView(context));
  }

  Expanded bookInfoBodyBuilder() {
    bool isThereMoreEditionsThanFive = editionsList!.length > 5;
    print(isThereMoreEditionsThanFive);
    int itemCount = editionsList!.length;
    print("$itemCount-1");
    return Expanded(
      child: Scrollbar(
        thickness: 3,
        radius: Radius.circular(20),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
          physics: BouncingScrollPhysics(),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            bookWorkModel?.description != null
                ? descriptionInfoBuilder()
                : const SizedBox.shrink(),
            if ((mainBook.runtimeType == TrendingBooksWorks &&
                    mainBook.language != null) ||
                (mainBook.runtimeType == BooksModelDocs &&
                    mainBook.language != null))
              availableLanguagesBuilder(),
            if (mainBook.runtimeType == BooksModelDocs &&
                mainBook.firstSentence != null &&
                bookWorkModel?.firstSentence == null)
              firstSentenceBuilder(mainBook.firstSentence!.first!),
            if (bookWorkModel?.firstSentence != null)
              firstSentenceBuilder(bookWorkModel!.firstSentence!.value!),
            if (isConnected == true)
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
                      color: Colors.black,
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
          height: 20,
          width: double.infinity,
          child: ListView.separated(
            physics: BouncingScrollPhysics(),
            separatorBuilder: (context, index) => SizedBox(
              width: 10,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: mainBook!.language!.length,
            itemBuilder: (context, index) {
              /* Some of the language codes coming from the api didn't match with the codes in the package but they matched with the bibliographiccode
                      so ı've searched within the list of languages that matches the language code coming from api and the package's bibliographiccode */
              int indexOfBibliographicCode = NaturalLanguage.list.indexWhere(
                  (element) =>
                      mainBook!.language![index]!.toUpperCase() ==
                      element.bibliographicCode);

              if (NaturalLanguage.maybeFromValue(
                      mainBook!.language![index]!.toUpperCase() as String) !=
                  null) {
                String country = NaturalLanguage.maybeFromValue(
                  mainBook!.language![index]!.toUpperCase() as String,
                )!
                    .name;
                return Text(country);
              } else if (indexOfBibliographicCode != -1) {
                return Text(
                    NaturalLanguage.list[indexOfBibliographicCode].name);
              } else {
                return Text(mainBook!.language![index]!);
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
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            )),
        const SizedBox(
          height: 10,
        ),
        Container(
          width: double.infinity,
          height: 150,
          child: ListView.separated(
            physics: BouncingScrollPhysics(),
            separatorBuilder: (context, index) => SizedBox(
              width: 10,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: itemCount,
            itemBuilder: (context, index) {
              return InkWell(
                customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailedEditionInfo(
                          editionInfo: editionsList![index]!,
                          isNavigatingFromLibrary: false,
                          bookImage: editionsList![index]!.covers != null
                              ? Image.network(
                                  "https://covers.openlibrary.org/b/id/${editionsList![index]!.covers!.first}-M.jpg",
                                )
                              : null,
                          indexOfEdition: index,
                        ),
                      ));
                },
                child: Column(children: [
                  Expanded(
                      flex: 10,
                      child: Ink(
                        width: 70,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            image: editionsList![index]!.covers != null
                                ? DecorationImage(
                                    image: NetworkImage(
                                        "https://covers.openlibrary.org/b/id/${editionsList![index]!.covers!.first}-M.jpg"),
                                    fit: BoxFit.fill)
                                : DecorationImage(
                                    image: AssetImage(
                                        "lib/assets/images/nocover.jpg"))),
                      )),
                  Spacer(),
                  Expanded(
                    flex: 4,
                    child: SizedBox(
                      width: 75,
                      child: Text(
                        editionsList![index]!.title!,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
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
                        workId: mainBook.key,
                        title: mainBook!.title!,
                      );
                    },
                  ));
                },
                child: Text(
                  "${bookEditionsSize} Baskının Tümünü Görüntüle",
                  style: TextStyle(fontWeight: FontWeight.bold),
                )))
      ],
    );
  }

  Column firstSentenceBuilder(String firstSentence) {
    return Column(
      children: [
        const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "İlk Cümle",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            )),
        const SizedBox(
          height: 10,
        ),
        textShowMoreForFirstSentence == false
            ? Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  firstSentence,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : Text(firstSentence),
        Align(
          alignment: Alignment.topRight,
          child: TextButton(
              onPressed: () {
                setState(() {
                  textShowMoreForFirstSentence = !textShowMoreForFirstSentence;
                });
              },
              child: textShowMoreForFirstSentence == false
                  ? const Text(
                      "Daha fazla",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  : const Text(
                      "Daha az",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
        ),
      ],
    );
  }

  Column descriptionInfoBuilder() {
    String textAsString = bookWorkModel!.description!.replaceRange(0, 26, "");

    return Column(
      children: [
        const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Açıklama",
              style: TextStyle(
                  color: Colors.black,
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
            child: textShowMoreForDescription == false
                ? Text(
                    /* There is an issue with the api that is the description comes sometimes as String and sometimes as Map<String,Dynamic> with
                  type and value properties to fix this ı've made a easy solution that is first ı've converted the variable to String on my
                  model if it was a map it was starting with  "{type: /type/text, value: " so it is 26 characters and ı used replaceRange
                  method and if it was a map that is coming from api "{type: /type/text, value: " was being deleted and the last character "}" 
                  was also being deleted*/
                    bookWorkModel!.description!.startsWith("{")
                        ? textAsString.replaceRange(
                            textAsString.length - 1, textAsString.length, "")
                        : bookWorkModel!.description!,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  )
                : Text(
                    bookWorkModel!.description!.startsWith("{")
                        ? textAsString.replaceRange(
                            textAsString.length - 1, textAsString.length, "")
                        : bookWorkModel!.description!,
                  )),
        Align(
          alignment: Alignment.topRight,
          child: TextButton(
              onPressed: () {
                setState(() {
                  textShowMoreForDescription = !textShowMoreForDescription;
                });
              },
              child: textShowMoreForDescription == false
                  ? const Text(
                      "Daha fazla",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  : const Text(
                      "Daha az",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
        ),
      ],
    );
  }

  Container bookInfoBarBuilder() {
    return Container(
      height: MediaQuery.of(context).size.height / 4,
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50))),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 8,
                  child: Container(
                    height: MediaQuery.of(context).size.height / 5,
                    color: Colors.transparent,
                    child: bookWorkModel?.covers != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: FadeInImage.memoryNetwork(
                              fit: BoxFit.fill,
                              image:
                                  "https://covers.openlibrary.org/b/id/${bookWorkModel?.covers!.first}-M.jpg",
                              placeholder: kTransparentImage,
                              imageErrorBuilder: (context, error, stackTrace) =>
                                  Image.asset("lib/assets/images/error.png"),
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child:
                                Image.asset("lib/assets/images/nocover.jpg")),
                  ),
                ),
                Spacer(),
                Expanded(
                  flex: 16,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: SizedBox(
                          child: Text(
                            mainBook!.title!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      if ((mainBook.runtimeType == TrendingBooksWorks &&
                              mainBook.authorName != null) ||
                          (mainBook.runtimeType == BooksModelDocs &&
                              mainBook.authorName != null))
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Spacer(),
                            Expanded(
                              flex: 5,
                              child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AuthorInfoScreen(
                                                  authorKey: mainBook!
                                                      .authorKey.first),
                                        ));
                                  },
                                  child: SizedBox(
                                    child: Text(
                                      mainBook!.authorName!.first!,
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                  )),
                            ),
                            Expanded(
                              flex: 1,
                              child: Tooltip(
                                  showDuration: Duration(seconds: 3),
                                  triggerMode: TooltipTriggerMode.tap,
                                  message:
                                      "Yazar hakkında bilgi almak için ismine tıklayın",
                                  child: Icon(Icons.info_outline)),
                            ),
                            Spacer()
                          ],
                        ),
                      const SizedBox(height: 10),
                      Container(
                        height: 30,
                        child: bookWorkModel?.subjects != null
                            ? Scrollbar(
                                thickness: 3,
                                radius: Radius.circular(20),
                                child: ListView.separated(
                                    separatorBuilder: (context, index) =>
                                        VerticalDivider(
                                            color: Colors.transparent,
                                            thickness: 0),
                                    physics: BouncingScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: bookWorkModel!.subjects!.length,
                                    itemBuilder: (context, index) {
                                      return TextButton(
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.all(5),
                                            backgroundColor:
                                                Colors.grey.shade300,
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      DetailedCategoriesView(
                                                          categoryName:
                                                              bookWorkModel!
                                                                      .subjects![
                                                                  index]!,
                                                          categoryKey:
                                                              bookWorkModel!
                                                                      .subjects![
                                                                  index]!),
                                                ));
                                          },
                                          child: Text(
                                            "#${bookWorkModel?.subjects![index]!}",
                                            style:
                                                TextStyle(color: Colors.black),
                                          ));
                                    }),
                              )
                            : const SizedBox.shrink(),
                      )
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getPageData() async {
    isConnected = await checkForInternetConnection();
    setState(() {
      isDataLoading = true;
    });
    if (isConnected == true) {
      await getBookEditionEntriesList();
      await getBookWorkModel();
    } else {
      internetConnectionErrorDialog(context);
    }
    if (mounted) {
      setState(() {
        isDataLoading = false;
      });
    }
  }

  Future<void> getBookEditionEntriesList() async {
    BookWorkEditionsModel? editionsModel;

    editionsModel = await ref
        .read(booksProvider)
        .getBookWorkEditions(mainBook!.key, 0, context, 5);

    if (editionsModel == null) {}

    editionsList = editionsModel?.entries;

    bookEditionsSize = editionsModel?.size;
  }

  Future<void> getBookWorkModel() async {
    bookWorkModel =
        await ref.read(booksProvider).getWorkDetail(mainBook!.key!, context);
  }
}
