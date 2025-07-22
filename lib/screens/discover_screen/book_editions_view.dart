import 'package:book_tracker/const.dart';
import 'package:book_tracker/l10n/app_localizations.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/providers/connectivity_provider.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/discover_screen/detailed_edition_info.dart';
import 'package:book_tracker/screens/discover_screen/shimmer_effect_builders/grid_view_books_shimmer.dart';
import 'package:book_tracker/widgets/books_list_error.dart';
import 'package:book_tracker/widgets/new_page_error_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class BookEditionsView extends ConsumerStatefulWidget {
  const BookEditionsView(
      {super.key,
      required this.workId,
      required this.title,
      this.toAddBook = false,
      this.countryCode = ""});

  final String workId;
  final bool toAddBook;
  final String title;
  final String countryCode;

  @override
  ConsumerState<BookEditionsView> createState() => _BookEditionsViewState();
}

class _BookEditionsViewState extends ConsumerState<BookEditionsView> {
  bool isConnected = false;
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
    try {
      isConnected = ref.read(connectivityProvider).isConnected;

      BookWorkEditionsModel editionsModel = await ref
          .read(booksProvider)
          .getBookWorkEditions(widget.workId, pageKey, context,widget.countryCode==""?50:10000);
      List<BookWorkEditionsModelEntries?>? list;
      if(widget.countryCode==""){
        list=editionsModel.entries;
      }
      else{
         list = editionsModel.entries?.where((element) =>
          element?.languages != null &&
          (widget.countryCode == "" ||
              element!.languages!.first!.key!.contains(widget.countryCode)))
        .toList();
      }

      
      final isLastPage = list!.length < 50;
      if (isLastPage) {
        pagingController.appendLastPage(list);
      } else {
        final nextPageKey = pageKey + list.length;
        pagingController.appendPage(list, nextPageKey);
      }
    } catch (e) {
      pagingController.error = e;
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leadingWidth: 50,
        title: Text(
          widget.toAddBook != true
              ? AppLocalizations.of(context)!.bookEditions(widget.title)
              : AppLocalizations.of(context)!.selectAnEdition,
          style: const TextStyle(
            fontWeight: FontWeight.bold,fontSize: 18
          ),
        ),
        leading: IconButton(
            splashRadius: 25,
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_sharp,
              size: 30,
            )),
        automaticallyImplyLeading: false,
        elevation: 5,
      ),
      body: PagedGridView<int, BookWorkEditionsModelEntries?>(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1,
            mainAxisExtent: 250,
            crossAxisSpacing: 25,
            mainAxisSpacing: 25),
        pagingController: pagingController,
        builderDelegate:
            PagedChildBuilderDelegate<BookWorkEditionsModelEntries?>(
          newPageErrorIndicatorBuilder: (context) =>
              newPageErrorIndicatorBuilder(
                  () => pagingController.retryLastFailedRequest(), context),
          firstPageErrorIndicatorBuilder: (context) {
            if (!isConnected) {
              return booksListError(
                true,
                context,
                () {
                  pagingController.retryLastFailedRequest();
                },
              );
            } else {
              return booksListError(false, context, () {
                pagingController.retryLastFailedRequest();
              });
            }
          },
          firstPageProgressIndicatorBuilder: (context) =>
              gridViewBooksShimmerEffectBuilder(),
          itemBuilder: (context, item, index) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: InkWell(
                customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
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
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 15,
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Ink(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                image: item!.covers != null
                                    ? DecorationImage(
                                        image: NetworkImage(
                                            "https://covers.openlibrary.org/b/id/${item.covers!.first}-M.jpg"),
                                        onError: (exception, stackTrace) =>
                                            const AssetImage(
                                                "lib/assets/images/error.png"),
                                        fit: BoxFit.fill,
                                      )
                                    : DecorationImage(
                                        image: const AssetImage(
                                            "lib/assets/images/nocover.jpg"),
                                        onError: (exception, stackTrace) =>
                                            const AssetImage(
                                                "lib/assets/images/error.png"),
                                        fit: BoxFit.fill)),
                          ),
                        ),
                      ),
                      const Spacer(flex: 1),
                      Expanded(
                        flex: 6,
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
                          flex: 3,
                          child: SizedBox(
                            child: Text(
                              maxLines: 1,
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
                        const Expanded(
                          flex: 3,
                          child: SizedBox.shrink(),
                        )
                    ]),
              ),
            );
          },
        ),
        physics: const ClampingScrollPhysics(),
      ),
    );
  }
}
