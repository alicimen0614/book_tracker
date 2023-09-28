import 'package:book_tracker/models/books_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/discover_screen/book_info_view.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:transparent_image/transparent_image.dart';

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
  Widget getBookCover(BooksModelDocs? doc) {
    if (doc!.coverI != null) {
      return FadeInImage.memoryNetwork(
        image: "https://covers.openlibrary.org/b/id/${doc.coverI}-M.jpg",
        placeholder: kTransparentImage,
        imageErrorBuilder: (context, error, stackTrace) =>
            Image.asset("lib/assets/images/error.png"),
        fit: BoxFit.fill,
      );
    } else {
      return Image.asset("lib/assets/images/nocover.jpg");
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
    try {
      var categoryBooksModel = await ref
          .read(booksProvider)
          .getCategoryBooks(widget.categoryKey, pageKey);

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
    return SafeArea(
      child: Scaffold(
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
            physics: BouncingScrollPhysics(),
            showNewPageProgressIndicatorAsGridChild: false,
            showNoMoreItemsIndicatorAsGridChild: false,
            pagingController: pagingController,
            builderDelegate: PagedChildBuilderDelegate<BooksModelDocs?>(
              firstPageProgressIndicatorBuilder: (context) =>
                  gridViewBooksShimmerEffectBuilder(),
              itemBuilder: (context, item, index) {
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BookInfoView(searchBook: item),
                          ));
                    },
                    child: Column(children: [
                      Expanded(flex: 12, child: getBookCover(item)),
                      Spacer(),
                      Expanded(
                        flex: 3,
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
      ),
    );
  }
}
