import 'package:book_tracker/models/books_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/discover_screen/book_info_view.dart';
import 'package:book_tracker/services/internet_connection_service.dart';
import 'package:book_tracker/widgets/books_list_error.dart';
import 'package:book_tracker/widgets/new_page_error_indicator.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'shimmer_effect_builders/grid_view_books_shimmer.dart';

class DetailedCategoriesView extends ConsumerStatefulWidget {
  const DetailedCategoriesView(
      {super.key, required this.categoryKey, required this.categoryName});

  final String categoryKey;
  final String categoryName;

  @override
  ConsumerState<DetailedCategoriesView> createState() =>
      _DetailedCategoriesViewState();
}

class _DetailedCategoriesViewState
    extends ConsumerState<DetailedCategoriesView> {
  bool isConnected = false;
  ImageProvider<Object> getBookCover(BooksModelDocs? doc) {
    if (doc!.coverI != null) {
      return NetworkImage(
        "https://covers.openlibrary.org/b/id/${doc.coverI}-M.jpg",
      );
    } else {
      return NetworkImage("lib/assets/images/nocover.jpg");
    }
  }

  final PagingController<int, BooksModelDocs?> pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    pagingController.addPageRequestListener((pageKey) {
      fetchData(pageKey);
    });
    super.initState();
  }

  void fetchData(int pageKey) async {
    print("fetchdata");
    isConnected = await checkForInternetConnection();
    try {
      Map<String, dynamic>? categoryBooksModelAsJson = await ref
          .read(booksProvider)
          .getBooksFromApi(widget.categoryKey, pageKey, "subject", context);
      if (categoryBooksModelAsJson != null) {}

      BooksModel? categoryBooksModel =
          BooksModel.fromJson(categoryBooksModelAsJson!);

      var list = categoryBooksModel.docs;
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
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 50,
        title: Text(widget.categoryName,
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_sharp,
              size: 30,
            )),
        automaticallyImplyLeading: false,
        elevation: 5,
      ),
      body: PagedGridView<int, BooksModelDocs?>(
          physics: ClampingScrollPhysics(),
          showNewPageProgressIndicatorAsGridChild: false,
          showNoMoreItemsIndicatorAsGridChild: false,
          pagingController: pagingController,
          builderDelegate: PagedChildBuilderDelegate<BooksModelDocs?>(
            newPageErrorIndicatorBuilder: (context) =>
                newPageErrorIndicatorBuilder(
                    () => pagingController.retryLastFailedRequest()),
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
                padding: const EdgeInsets.all(10),
                child: InkWell(
                  customBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookInfoView(searchBook: item),
                        ));
                  },
                  child: Column(children: [
                    Expanded(
                        flex: 15,
                        child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Ink(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                image: DecorationImage(
                                    onError: (exception, stackTrace) =>
                                        AssetImage(
                                            "lib/assets/images/error.png"),
                                    image: getBookCover(item),
                                    fit: BoxFit.fill)),
                            padding: EdgeInsets.zero,
                          ),
                        )),
                    Spacer(
                      flex: 1,
                    ),
                    Expanded(
                      flex: 7,
                      child: Text(
                        style: TextStyle(fontWeight: FontWeight.bold),
                        item!.title!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                        textAlign: TextAlign.center,
                      ),
                    )
                  ]),
                ),
              );
            },
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              mainAxisExtent: 230,
              crossAxisSpacing: 25,
              mainAxisSpacing: 25)),
    );
  }
}
