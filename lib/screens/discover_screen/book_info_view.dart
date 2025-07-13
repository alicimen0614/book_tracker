import 'package:book_tracker/l10n/app_localizations.dart';
import 'package:book_tracker/models/authors_works_model.dart';
import 'package:book_tracker/models/books_model.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/models/bookswork_model.dart';
import 'package:book_tracker/models/trendingbooks_model.dart';
import 'package:book_tracker/providers/connectivity_provider.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/discover_screen/author_info_screen.dart';
import 'package:book_tracker/screens/discover_screen/book_editions_view.dart';
import 'package:book_tracker/screens/discover_screen/detailed_categories_view.dart';
import 'package:book_tracker/screens/discover_screen/detailed_edition_info.dart';
import 'package:book_tracker/widgets/internet_connection_error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sealed_languages/sealed_languages.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';
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
    mainBook = widget.searchBook ?? widget.trendingBook ?? widget.authorBook;
    getPageData();
    super.initState();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            if (mainBook.key != null)
              IconButton(
                  tooltip: AppLocalizations.of(context)!.reviewOnOpenLibrary,
                  onPressed: () {
                    launchUrl(
                        Uri.parse("https://openlibrary.org/${mainBook.key}"));
                  },
                  icon: Image.asset("lib/assets/images/openlibrary.png",
                      height: 30),
                  splashRadius: 25),
            IconButton(
                tooltip: AppLocalizations.of(context)!.addToShelf,
                splashRadius: 25,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return BookEditionsView(
                        workId: mainBook.key,
                        title: mainBook!.title!,
                        toAddBook: true,
                      );
                    },
                  ));
                },
                icon: const Icon(
                  Icons.add_circle,
                  size: 35,
                ))
          ],
          leadingWidth: 50,
          title: Text(
            AppLocalizations.of(context)!.bookDetail,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.of(context).size.height / 40),
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
     bool isThereMoreEditionsThanFive=false;
     int itemCount=0;
    if(editionsList!=null){
      isThereMoreEditionsThanFive=editionsList!.length > 5;
      itemCount = editionsList!.length;
    }
   
    
    return Expanded(
      child: Scrollbar(
        thickness: 3,
        radius: const Radius.circular(20),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
          physics: const ClampingScrollPhysics(),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            (bookWorkModel?.description != null &&
                    bookWorkModel?.description != "<Nothing>")
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
                  ? itemCount != 0
                      ? editionsBuilder(5)
                      : const SizedBox.shrink()
                  : itemCount != 0
                      ? editionsBuilder(itemCount)
                      : const SizedBox.shrink()
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
            Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppLocalizations.of(context)!.availableLanguages,
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.height / 50),
                )),
            const SizedBox(
              width: 5,
            ),
            Tooltip(
              showDuration: const Duration(seconds: 3),
              triggerMode: TooltipTriggerMode.tap,
              message: AppLocalizations.of(context)!.limitedLanguagesDisplayed,
              child: const Icon(Icons.info_outline, color: Colors.black),
            )
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          height: 20,
          width: double.infinity,
          child: ListView.separated(
            physics: const ClampingScrollPhysics(),
            separatorBuilder: (context, index) => const SizedBox(
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
                return Text(
                  country,
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height / 60),
                );
              } else if (indexOfBibliographicCode != -1) {
                return Text(
                  NaturalLanguage.list[indexOfBibliographicCode].name,
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height / 60),
                );
              } else {
                return Text(
                  mainBook!.language![index]!,
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height / 60),
                );
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
        Align(
            alignment: Alignment.centerLeft,
            child: Text(
              AppLocalizations.of(context)!.editions,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.height / 50),
            )),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.width > 500 ? 300 : 150,
          child: ListView.separated(
            physics: const ClampingScrollPhysics(),
            separatorBuilder: (context, index) => const SizedBox(
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
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset(
                                    "lib/assets/images/error.png",
                                  ),
                                )
                              : null,
                          indexOfEdition: index,
                        ),
                      ));
                },
                child: Column(children: [
                  Expanded(
                      flex: 10,
                      child: Material(
                        color: Colors.transparent,
                        child: Ink(
                          width: MediaQuery.of(context).size.width > 500
                              ? 150
                              : 70,
                          height: MediaQuery.of(context).size.width > 500
                              ? 500
                              : 150,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: editionsList![index]!.covers != null
                                  ? DecorationImage(
                                      image: NetworkImage(
                                          "https://covers.openlibrary.org/b/id/${editionsList![index]!.covers!.first}-M.jpg"),
                                      onError: (exception, stackTrace) =>
                                          const AssetImage(
                                              "lib/assets/images/error.png"),
                                      fit: BoxFit.fill)
                                  : DecorationImage(
                                      image: const AssetImage(
                                          "lib/assets/images/nocover.jpg"),
                                      onError: (exception, stackTrace) =>
                                          const AssetImage(
                                              "lib/assets/images/error.png"),
                                    )),
                        ),
                      )),
                  const Spacer(),
                  Expanded(
                    flex: 4,
                    child: SizedBox(
                      width: 80,
                      child: Text(
                        editionsList![index]!.title!,
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height / 60),
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
                  AppLocalizations.of(context)!
                      .viewAllEditions(bookEditionsSize!),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.height / 60),
                )))
      ],
    );
  }

  Column firstSentenceBuilder(String firstSentence) {
    return Column(
      children: [
        Align(
            alignment: Alignment.centerLeft,
            child: Text(
              AppLocalizations.of(context)!.firstSentence,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.height / 50),
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
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height / 60),
                ),
              )
            : Text(
                firstSentence,
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height / 60),
              ),
        Align(
          alignment: Alignment.topRight,
          child: TextButton(
              onPressed: () {
                setState(() {
                  textShowMoreForFirstSentence = !textShowMoreForFirstSentence;
                });
              },
              child: textShowMoreForFirstSentence == false
                  ? Text(
                      AppLocalizations.of(context)!.showMore,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.height / 60),
                    )
                  : Text(
                      AppLocalizations.of(context)!.showLess,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.height / 60),
                    )),
        ),
      ],
    );
  }

  Column descriptionInfoBuilder() {
    String textAsString = bookWorkModel!.description!.replaceRange(0, 26, "");

    return Column(
      children: [
        Align(
            alignment: Alignment.centerLeft,
            child: Text(
              AppLocalizations.of(context)!.description,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.height / 50),
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
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height / 60),
                  )
                : Text(
                    bookWorkModel!.description!.startsWith("{")
                        ? textAsString.replaceRange(
                            textAsString.length - 1, textAsString.length, "")
                        : bookWorkModel!.description!,
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height / 60),
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
                  ? Text(
                      AppLocalizations.of(context)!.showMore,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.height / 60),
                    )
                  : Text(
                      AppLocalizations.of(context)!.showLess,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.height / 60),
                    )),
        ),
      ],
    );
  }

  Container bookInfoBarBuilder() {
    return Container(
      height: MediaQuery.of(context).size.width > 500
          ? MediaQuery.of(context).size.height / 2.5
          : MediaQuery.of(context).size.height / 3.5,
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: const BorderRadius.only(
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
                  flex: 10,
                  child: Container(
                    height: MediaQuery.of(context).size.width > 500
                        ? MediaQuery.of(context).size.height / 3
                        : MediaQuery.of(context).size.height / 4.2,
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
                            child: Image.asset(
                              "lib/assets/images/nocover.jpg",
                              fit: BoxFit.fill,
                            )),
                  ),
                ),
                const Spacer(),
                Expanded(
                  flex: 16,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: FittedBox(
                          child: Text(
                            mainBook!.title!,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context).size.height / 40,
                            ),
                          ),
                        ),
                      ),
                      if ((mainBook.runtimeType == TrendingBooksWorks &&
                              mainBook.authorName != null) ||
                          (mainBook.runtimeType == BooksModelDocs &&
                              mainBook.authorName != null))
                        TextButton(
                            style: TextButton.styleFrom(
                                backgroundColor: Colors.grey.shade300),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AuthorInfoScreen(
                                        authorKey: mainBook!.authorKey.first),
                                  ));
                            },
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.center,
                              child: Text(
                                mainBook!.authorName!.first!,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        MediaQuery.of(context).size.height /
                                            50),
                              ),
                            )),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 30,
                        child: bookWorkModel?.subjects != null
                            ? Scrollbar(
                                thickness: 3,
                                radius: const Radius.circular(20),
                                child: ListView.separated(
                                    separatorBuilder: (context, index) =>
                                        const VerticalDivider(
                                            color: Colors.transparent,
                                            thickness: 0),
                                    physics: const ClampingScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: bookWorkModel!.subjects!.length,
                                    itemBuilder: (context, index) {
                                      return TextButton(
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.all(5),
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
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    60),
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
          ],
        ),
      ),
    );
  }

  Future<void> getPageData() async {
    isConnected = ref.read(connectivityProvider).isConnected;
    setState(() {
      isDataLoading = true;
    });
    if (isConnected == true) {
      await getBookEditionEntriesList();
      await getBookWorkModel();
    } else {
      internetConnectionErrorDialog(context, false);
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
