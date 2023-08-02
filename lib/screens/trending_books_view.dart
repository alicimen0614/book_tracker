import 'dart:developer';

import 'package:book_tracker/models/categorybooks_model.dart';
import 'package:book_tracker/models/trendingbooks_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class TrendingBooksView extends ConsumerStatefulWidget {
  const TrendingBooksView({super.key, required this.date});

  final String date;

  @override
  ConsumerState<TrendingBooksView> createState() => _TrendingBooksViewState();
}

class _TrendingBooksViewState extends ConsumerState<TrendingBooksView> {
  List<TrendingBooksWorks?>? itemList = [];
  Image getBookCover(TrendingBooksWorks? work) {
    if (work!.coverI != null) {
      log("https://covers.openlibrary.org/b/id/${work.coverI}-M.jpg");
      return Image.network(
          "https://covers.openlibrary.org/b/id/${work.coverI}-M.jpg");
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
          title: Text("${widget.date} Trending Books"),
          centerTitle: true,
        ),
        body: PagedGridView<int, TrendingBooksWorks?>(
            pagingController: pagingController,
            builderDelegate: PagedChildBuilderDelegate<TrendingBooksWorks?>(
              itemBuilder: (context, item, index) {
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: InkWell(
                    onTap: () {},
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
