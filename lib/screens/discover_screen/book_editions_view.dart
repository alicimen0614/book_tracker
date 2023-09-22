import 'package:book_tracker/const.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/discover_screen/detailed_edition_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:transparent_image/transparent_image.dart';

class BookEditionsView extends ConsumerStatefulWidget {
  const BookEditionsView(
      {super.key, required this.workId, required this.title});

  final String workId;

  final String title;

  @override
  ConsumerState<BookEditionsView> createState() => _BookEditionsViewState();
}

class _BookEditionsViewState extends ConsumerState<BookEditionsView> {
  final PagingController<int, BookWorkEditionsModelEntries?> pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    pagingController.addPageRequestListener((pageKey) {
      fetchData(pageKey);
    });
    super.initState();
  }

  void fetchData(int pageKey) async {
    print("fetchdata");
    try {
      var list = await ref
          .read(booksProvider)
          .bookEditionsEntriesList(widget.workId, pageKey);
      final isLastPage = list!.length < 50;
      if (isLastPage) {
        pagingController.appendLastPage(list);
      } else {
        final nextPageKey = pageKey + list.length + 1;
        pagingController.appendPage(list, nextPageKey);
      }
    } catch (e) {
      pagingController.error = e;
      print("$e-1");
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leadingWidth: 50,
          title: Text("${widget.title} Baskıları"),
          leading: IconButton(
              splashRadius: 25,
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 30,
              )),
          automaticallyImplyLeading: false,
          backgroundColor: const Color.fromRGBO(195, 129, 84, 1),
          elevation: 5,
        ),
        body: PagedGridView<int, BookWorkEditionsModelEntries?>(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.6,
          ),
          pagingController: pagingController,
          builderDelegate:
              PagedChildBuilderDelegate<BookWorkEditionsModelEntries?>(
            itemBuilder: (context, item, index) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailedEditionInfo(
                            editionInfo: item,
                            isNavigatingFromLibrary: false,
                            bookImage: item.covers != null
                                ? Image.network(
                                    "https://covers.openlibrary.org/b/id/${item.covers!.first}-M.jpg",
                                  )
                                : null,
                            indexOfEdition: index,
                          ),
                        ));
                  },
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        item!.covers != null
                            ? Expanded(
                                flex: 40,
                                child: Card(
                                  margin: EdgeInsets.zero,
                                  color: Colors.transparent,
                                  elevation: 10,
                                  child: Hero(
                                    tag: uniqueIdCreater(item) + index,
                                    child: FadeInImage.memoryNetwork(
                                      fit: BoxFit.fill,
                                      image:
                                          "https://covers.openlibrary.org/b/id/${item.covers!.first}-M.jpg",
                                      placeholder: kTransparentImage,
                                      imageErrorBuilder:
                                          (context, error, stackTrace) =>
                                              Image.asset(
                                        "lib/assets/images/error.png",
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Expanded(
                                flex: 40,
                                child: Image.asset(
                                  "lib/assets/images/nocover.jpg",
                                  fit: BoxFit.fill,
                                )),
                        Spacer(),
                        Expanded(
                          flex: 10,
                          child: SizedBox(
                            child: Text(
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              item.title!,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        if (item.languages != null)
                          Expanded(
                            flex: 8,
                            child: SizedBox(
                              child: Text(
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                countryNameCreater(item),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        if (item.languages == null)
                          Expanded(
                            child: SizedBox.shrink(),
                            flex: 8,
                          )
                      ]),
                ),
              );
            },
          ),
          physics: BouncingScrollPhysics(),
        ),
      ),
    );
  }
}
