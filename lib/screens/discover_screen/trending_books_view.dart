import 'dart:developer';

import 'package:book_tracker/models/trendingbooks_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/discover_screen/trending_book_info_view.dart';
import 'package:book_tracker/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:transparent_image/transparent_image.dart';

class TrendingBooksView extends ConsumerStatefulWidget {
  const TrendingBooksView({super.key, required this.date});

  final String date;

  @override
  ConsumerState<TrendingBooksView> createState() => _TrendingBooksViewState();
}

class _TrendingBooksViewState extends ConsumerState<TrendingBooksView> {
  List<TrendingBooksWorks?>? itemList = [];
  Widget getBookCover(TrendingBooksWorks? work) {
    if (work!.coverI != null) {
      log("https://covers.openlibrary.org/b/id/${work.coverI}-M.jpg");
      return FadeInImage.memoryNetwork(
        placeholder: kTransparentImage,
        image: "https://covers.openlibrary.org/b/id/${work.coverI}-M.jpg",
        imageErrorBuilder: (context, error, stackTrace) =>
            Image.asset("lib/assets/images/error.png"),
      );
    } else {
      return Image.asset("lib/assets/images/nocover.jpg");
    }
  }

  final PagingController<int, TrendingBooksWorks?> pagingController =
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
          .trendingBookDocsList(widget.date, pageKey);
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
          centerTitle: true,
          leadingWidth: 50,
          title: Text("${widget.date} Trending Books"),
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
        body: PagedGridView<int, TrendingBooksWorks?>(
            physics: BouncingScrollPhysics(),
            showNewPageProgressIndicatorAsGridChild: false,
            showNoMoreItemsIndicatorAsGridChild: false,
            pagingController: pagingController,
            builderDelegate: PagedChildBuilderDelegate<TrendingBooksWorks?>(
              firstPageProgressIndicatorBuilder: (context) {
                return shimmerEffectBuilder();
              },
              itemBuilder: (context, item, index) {
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TrendingBookInfoView(
                              trendingBook: item,
                            ),
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

  SizedBox shimmerEffectBuilder() {
    return SizedBox(
      height: 500,
      width: 500,
      child: GridView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: 12,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 25,
            childAspectRatio: 0.5,
            mainAxisSpacing: 25),
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.all(10),
          child: Column(children: [
            ShimmerWidget.rectangular(width: 180, height: 150),
            SizedBox(
              height: 5,
            ),
            ShimmerWidget.rectangular(width: 180, height: 10)
          ]),
        ),
      ),
    );
  }
}
