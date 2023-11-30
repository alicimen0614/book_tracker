import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/discover_screen/book_info_view.dart';
import 'package:book_tracker/screens/discover_screen/shimmer_effect_builders/grid_view_books_shimmer.dart';
import 'package:book_tracker/services/internet_connection_service.dart';
import 'package:book_tracker/widgets/books_list_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../models/books_model.dart';

class SearchScreenView extends ConsumerStatefulWidget {
  const SearchScreenView({super.key, required this.searchValue});
  final String searchValue;

  @override
  ConsumerState<SearchScreenView> createState() => _SearchScreenViewState();
}

class _SearchScreenViewState extends ConsumerState<SearchScreenView> {
  ImageProvider getBookCover(BooksModelDocs? item) {
    print(item!.language);
    print(item.coverI);
    if (item.coverI != null) {
      return NetworkImage(
          "https://covers.openlibrary.org/b/id/${item.coverI}-M.jpg");
    } else {
      return const AssetImage("lib/assets/images/nocover.jpg");
    }
  }

  bool isLoading = false;
  bool hasMore = true;
  bool isConnected = false;
  List<BooksModelDocs?>? list;
  final PagingController<int, BooksModelDocs?> pagingController =
      PagingController(firstPageKey: 1);
  @override
  void initState() {
    pagingController.addPageRequestListener((pageKey) {
      fetchBooks(pageKey);
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant SearchScreenView oldWidget) {
    print("didupdatewidget çalıştı");
    if (widget.searchValue != oldWidget.searchValue) {
      if (list != null) {
        list!.clear();
      }

      pagingController.refresh();

      setState(() {});
      print("didupdatewidget if girdi");
      pagingController.addPageRequestListener((pageKey) {
        fetchBooks(pageKey);
      });
    }

    print("didupdatewidget bitirdi");
    super.didUpdateWidget(oldWidget);
  }

  void fetchBooks(int pageKey) async {
    print("${widget.searchValue}---fetchBooks çalıştı");
    isConnected = await checkForInternetConnection();

    try {
      var searchModelAsJson = await ref
          .read(booksProvider)
          .getBooksFromApi(widget.searchValue, pageKey, "q", context);

      var searchModel = BooksModel.fromJson(searchModelAsJson);

      var list = searchModel.docs;

      final isLastPage = list!.length < 10;
      if (isLastPage) {
        pagingController.appendLastPage(list);
      } else {
        final nextPageKey = pageKey + 1;
        pagingController.appendPage(list, nextPageKey);
      }
    } catch (e) {
      pagingController.error = e;
      print("$e-1");
    }
  }

  @override
  Widget build(BuildContext context) {
    print("search screenview çalıştı");
    print(widget.searchValue);

    return Expanded(
      child: PagedGridView<int, BooksModelDocs?>(
          showNewPageProgressIndicatorAsGridChild: false,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: 25,
              mainAxisExtent: 250,
              mainAxisSpacing: 25),
          pagingController: pagingController,
          physics: const ClampingScrollPhysics(),
          builderDelegate: PagedChildBuilderDelegate<BooksModelDocs?>(
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
                  child: cardBuilder(context, item, index));
            },
          )),
    );
  }

  Widget cardBuilder(BuildContext context, BooksModelDocs? item, int index) {
    return Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: InkWell(
            customBorder:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookInfoView(searchBook: item),
                  ));
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  flex: 18,
                  child: Padding(
                    padding: EdgeInsets.all(5),
                    child: Ink(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: getBookCover(item), fit: BoxFit.fill),
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ),
                Spacer(
                  flex: 1,
                ),
                Expanded(
                  flex: 6,
                  child: Text(
                    "${item?.title!} ",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (item!.authorName != null)
                  Expanded(
                    flex: 6,
                    child: SizedBox(
                      child: Text(
                        "${item.authorName!.first}",
                        style: const TextStyle(
                            color: Colors.grey, fontStyle: FontStyle.italic),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                if (item.authorName == null)
                  Expanded(flex: 6, child: SizedBox.shrink())
              ],
            )));
  }
}
