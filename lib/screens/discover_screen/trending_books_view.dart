import 'package:book_tracker/models/trendingbooks_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/discover_screen/book_info_view.dart';
import 'package:book_tracker/screens/discover_screen/shimmer_effect_builders/grid_view_books_shimmer.dart';
import 'package:book_tracker/services/internet_connection_service.dart';
import 'package:book_tracker/widgets/books_list_error.dart';
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
  bool isConnected = false;

  ImageProvider<Object> getBookCover(TrendingBooksWorks? work) {
    if (work!.coverI != null) {
      return NetworkImage(
        "https://covers.openlibrary.org/b/id/${work.coverI}-M.jpg",
      );
    } else {
      return const AssetImage("lib/assets/images/nocover.jpg");
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
    isConnected = await checkForInternetConnection();

    try {
      List<TrendingBooksWorks?>? list = await ref
          .read(booksProvider)
          .getTrendingBooks(widget.date, pageKey, context);
      final isLastPage = list!.length < 10;
      if (isLastPage) {
        pagingController.appendLastPage(list);
      } else {
        final nextPageKey = pageKey + 1;
        pagingController.appendPage(list, nextPageKey);
      }
    } catch (e) {
      pagingController.error = e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leadingWidth: 50,
        title: const Text(
          "Aylık Trend Kitaplar",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_sharp,
              size: 30,
            )),
        automaticallyImplyLeading: false,
        elevation: 5,
      ),
      body: PagedGridView<int, TrendingBooksWorks?>(
          physics: const ClampingScrollPhysics(),
          showNewPageProgressIndicatorAsGridChild: false,
          showNoMoreItemsIndicatorAsGridChild: false,
          pagingController: pagingController,
          builderDelegate: PagedChildBuilderDelegate<TrendingBooksWorks?>(
            firstPageProgressIndicatorBuilder: (context) {
              return gridViewBooksShimmerEffectBuilder();
            },
            firstPageErrorIndicatorBuilder: (context) {
              if (!isConnected) {
                return booksListError(true, context, () {
                  pagingController.retryLastFailedRequest();
                });
              } else {
                return booksListError(false, context, () {
                  pagingController.retryLastFailedRequest();
                });
              }
            },
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
                          builder: (context) => BookInfoView(
                            trendingBook: item,
                          ),
                        ));
                  },
                  child: Column(children: [
                    Expanded(
                        flex: 15,
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Ink(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    onError: (exception, stackTrace) =>
                                        const AssetImage(
                                            "lib/assets/images/error.png"),
                                    image: getBookCover(item),
                                    fit: BoxFit.fill),
                                borderRadius: BorderRadius.circular(15)),
                          ),
                        )),
                    const Spacer(flex: 1),
                    Expanded(
                      flex: 7,
                      child: Text(
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        item!.title!,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.height / 60),
                      ),
                    )
                  ]),
                ),
              );
            },
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              mainAxisExtent:
                  MediaQuery.of(context).size.width > 500 ? 400 : 230,
              crossAxisSpacing:
                  MediaQuery.of(context).size.width > 500 ? 75 : 25,
              mainAxisSpacing: 25)),
    );
  }
}
