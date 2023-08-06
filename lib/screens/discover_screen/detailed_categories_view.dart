import 'package:book_tracker/models/categorybooks_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/discover_screen/category_book_info_view.dart.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class DetailedCategoriesView extends ConsumerStatefulWidget {
  const DetailedCategoriesView({super.key, required this.categoryName});

  final String categoryName;

  @override
  ConsumerState<DetailedCategoriesView> createState() =>
      _DetailedCategoriesViewState();
}

class _DetailedCategoriesViewState
    extends ConsumerState<DetailedCategoriesView> {
  List<CategoryBooksWorks?>? itemList = [];
  Image getBookCover(CategoryBooksWorks? work) {
    if (work!.coverId != null) {
      return Image.network(
        "https://covers.openlibrary.org/b/id/${work.coverId}-M.jpg",
        errorBuilder: (context, error, stackTrace) =>
            Image.asset("lib/assets/images/error.png"),
      );
    } else {
      return Image.asset("lib/assets/images/nocover.jpg");
    }
  }

  final PagingController<int, CategoryBooksWorks?> pagingController =
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
      var list = await ref
          .read(booksProvider)
          .categoryBookWorksList(widget.categoryName, pageKey);
      final isLastPage = list!.length < 20;
      if (isLastPage) {
        pagingController.appendLastPage(list);
      } else {
        final nextPageKey = pageKey + list.length;
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
          centerTitle: true,
          title: Text(widget.categoryName),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
        ),
        body: PagedGridView<int, CategoryBooksWorks?>(
            pagingController: pagingController,
            builderDelegate: PagedChildBuilderDelegate<CategoryBooksWorks?>(
              itemBuilder: (context, item, index) {
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CategoryBookInfoView(book: item),
                          ));
                    },
                    child: Column(children: [
                      getBookCover(item),
                      SizedBox(
                        height: 5,
                      ),
                      Flexible(
                        child: Text(
                          item!.title!,
                          overflow: TextOverflow.clip,
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
                mainAxisExtent: 250,
                crossAxisSpacing: 25,
                mainAxisSpacing: 25)),
      ),
    );
  }
}
