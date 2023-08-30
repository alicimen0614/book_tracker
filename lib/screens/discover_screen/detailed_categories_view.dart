import 'package:book_tracker/models/categorybooks_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/discover_screen/book_info_view.dart';
import 'package:book_tracker/widgets/shimmer_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:transparent_image/transparent_image.dart';

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
  List<CategoryBooksWorks?>? itemList = [];
  Widget getBookCover(CategoryBooksWorks? work) {
    if (work!.coverId != null) {
      return FadeInImage.memoryNetwork(
        image: "https://covers.openlibrary.org/b/id/${work.coverId}-M.jpg",
        placeholder: kTransparentImage,
        imageErrorBuilder: (context, error, stackTrace) =>
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
          .categoryBookWorksList(widget.categoryKey, pageKey);
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
          leadingWidth: 50,
          title: Text(widget.categoryName),
          centerTitle: true,
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
        body: PagedGridView<int, CategoryBooksWorks?>(
            showNewPageProgressIndicatorAsGridChild: false,
            showNoMoreItemsIndicatorAsGridChild: false,
            pagingController: pagingController,
            builderDelegate: PagedChildBuilderDelegate<CategoryBooksWorks?>(
              firstPageProgressIndicatorBuilder: (context) =>
                  shimmerEffectBuilder(),
              itemBuilder: (context, item, index) {
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BookInfoView(categoryBook: item),
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

  Container shimmerEffectBuilder() {
    return Container(
      height: 500,
      width: 500,
      child: GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.5,
            crossAxisSpacing: 25,
            mainAxisSpacing: 50),
        itemBuilder: (context, index) => Column(children: [
          ShimmerWidget.rectangular(width: 100, height: 170),
          SizedBox(
            height: 5,
          ),
          ShimmerWidget.rectangular(width: 90, height: 10),
          SizedBox(
            height: 5,
          ),
          ShimmerWidget.rectangular(width: 70, height: 7)
        ]),
      ),
    );
  }
}
