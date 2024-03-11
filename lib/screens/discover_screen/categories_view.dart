import 'package:book_tracker/const.dart';
import 'package:book_tracker/models/trendingbooks_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/discover_screen/detailed_categories_view.dart';
import 'package:book_tracker/screens/discover_screen/book_info_view.dart';
import 'package:book_tracker/screens/discover_screen/shimmer_effect_builders/categories_view_shimmer.dart';
import 'package:book_tracker/screens/discover_screen/trending_books_view.dart';
import 'package:book_tracker/services/internet_connection_service.dart';
import 'package:book_tracker/widgets/error_snack_bar.dart';
import 'package:book_tracker/widgets/internet_connection_error_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoriesView extends ConsumerStatefulWidget {
  const CategoriesView({super.key});

  @override
  ConsumerState<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends ConsumerState<CategoriesView> {
  bool isConnected = true;
  bool isLoading = true;
  List<TrendingBooksWorks?>? items = [];

  final customCacheManager = CacheManager(
    Config("customCacheKey",
        maxNrOfCacheObjects: 25, stalePeriod: const Duration(days: 15)),
  );
  @override
  void initState() {
    getTrendingBooks();
    super.initState();
  }

  Future<void> getTrendingBooks() async {
    isConnected = await checkForInternetConnection();

    setState(() {
      isLoading = true;
    });
    try {
      if (isConnected == true) {
        items = await ref
            .read(booksProvider)
            .getTrendingBooks("monthly", 1, context)
            .whenComplete(() {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        });
      } else {
        items = [];
        internetConnectionErrorDialog(context, false);
      }
    } catch (e) {
      if (mounted) errorSnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: <Widget>[
          scrollableTrendingBuilder(context),
          categoriesGridViewBuilder(),
        ],
      ),
    );
  }

  SliverToBoxAdapter categoriesGridViewBuilder() {
    return SliverToBoxAdapter(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        itemCount: mainCategories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: 25,
            mainAxisExtent: 230,
            childAspectRatio: 1,
            crossAxisCount: 2,
            mainAxisSpacing: 25),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return DetailedCategoriesView(
                        categoryKey: mainCategories[index],
                        categoryName: mainCategoriesNames[index],
                      );
                    },
                  ));
                },
                child: Column(children: [
                  Expanded(
                      flex: 10,
                      child: Ink(
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            image: DecorationImage(
                              image: AssetImage(
                                  "lib/assets/images/${mainCategoriesImages[index]}"),
                              onError: (exception, stackTrace) =>
                                  const AssetImage(
                                      "lib/assets/images/error.png"),
                            )),
                      )),
                  const SizedBox(
                    width: double.infinity,
                    height: 10,
                  ),
                  const Spacer(),
                  Expanded(
                    flex: 4,
                    child: Text(
                      mainCategoriesNames[index],
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.height / 50,
                          overflow: TextOverflow.fade),
                      textAlign: TextAlign.center,
                    ),
                  )
                ]),
              ),
            ),
          );
        },
      ),
    );
  }

  SliverToBoxAdapter scrollableTrendingBuilder(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Trendler",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.height / 40,
                    ),
                  ),
                  TextButton(
                      child: Text(
                        "Daha fazla",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.height / 60,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return const TrendingBooksView(
                              date: "Monthly",
                            );
                          },
                        ));
                      })
                ],
              ),
            ),
            if (isLoading == true && isConnected == true)
              categoriesViewShimmerEffect(),
            if (isConnected == false) trendingErrorWidget(context),
            if (isLoading == false && isConnected == true)
              trendingBooksWidget(),
            Text(
              "Kategoriler",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.of(context).size.height / 40,
              ),
            ),
            const SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }

  Center trendingErrorWidget(BuildContext context) {
    return Center(
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text(
          "Bir hata meydana geldi.",
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.height / 50,
          ),
        ),
        Text(
          "Lütfen yenilemek için tıklayın.",
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.height / 50,
          ),
        ),
        IconButton(
            color: Theme.of(context).primaryColor,
            iconSize: 30,
            onPressed: () async {
              isConnected = await checkForInternetConnection();
              setState(() {
                isLoading = true;
              });
              getTrendingBooks();
            },
            icon: const Icon(Icons.refresh_sharp))
      ]),
    );
  }

  SizedBox trendingBooksWidget() {
    return SizedBox(
        height: MediaQuery.of(context).size.height / 4.7,
        width: double.infinity,
        child: ListView.builder(
            physics: const ClampingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: items?.length,
            itemBuilder: (context, index) {
              return SizedBox(
                width: 120,
                child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return BookInfoView(trendingBook: items?[index]);
                        },
                      ));
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
                      child: Column(
                        children: [
                          Expanded(
                            flex: 10,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: CachedNetworkImage(
                                fit: BoxFit.fill,
                                width: 80,
                                imageUrl:
                                    "https://covers.openlibrary.org/b/id/${items?[index]?.coverI}-M.jpg",
                                placeholder: (context, url) => ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Transform.scale(
                                    scale: 0.3,
                                    child: const Center(
                                        child: CircularProgressIndicator()),
                                  ),
                                ),
                                cacheManager: customCacheManager,
                                errorWidget: (context, url, error) =>
                                    Image.asset("lib/assets/images/error.png"),
                              ),
                            ),
                          ),
                          const Spacer(),
                          Expanded(
                            flex: 4,
                            child: items != null
                                ? Text(
                                    items![index]!.title!,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.height /
                                                60),
                                  )
                                : const SizedBox.shrink(),
                          )
                        ],
                      ),
                    )),
              );
            }));
  }
}
