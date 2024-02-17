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
  bool isConnected = false;
  bool isLoading = true;
  List<TrendingBooksWorks?>? items = [];

  final customCacheManager = CacheManager(
    Config("customCacheKey",
        maxNrOfCacheObjects: 25, stalePeriod: Duration(days: 15)),
  );
  @override
  void initState() {
    getTrendingBooks();
    super.initState();
  }

  Future<void> getTrendingBooks() async {
    setState(() {
      isLoading = true;
    });
    try {
      isConnected = await checkForInternetConnection();
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
      print("categories view hata $e");
    }

    print(items);
  }

  @override
  Widget build(BuildContext context) {
    print(items);
    return Expanded(
      child: CustomScrollView(
        physics: ClampingScrollPhysics(),
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
                                  AssetImage("lib/assets/images/error.png"),
                            )),
                      )),
                  const SizedBox(
                    width: double.infinity,
                    height: 10,
                  ),
                  Spacer(),
                  Expanded(
                    flex: 4,
                    child: Text(
                      mainCategoriesNames[index],
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
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
                  const Text(
                    "Trendler",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  TextButton(
                      child: const Text(
                        "Daha fazla",
                        style: TextStyle(fontWeight: FontWeight.bold),
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
            isLoading == false
                ? Container(
                    height: 120,
                    width: double.infinity,
                    child: ListView.builder(
                        physics: ClampingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: items?.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(10),
                            child: SizedBox(
                              width: 85,
                              child: InkWell(
                                  borderRadius: BorderRadius.circular(15),
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(
                                      builder: (context) {
                                        return BookInfoView(
                                            trendingBook: items?[index]);
                                      },
                                    ));
                                  },
                                  child: Column(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          child: CachedNetworkImage(
                                            fit: BoxFit.fill,
                                            width: 60,
                                            imageUrl:
                                                "https://covers.openlibrary.org/b/id/${items?[index]?.coverI}-M.jpg",
                                            placeholder: (context, url) =>
                                                ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: Transform.scale(
                                                scale: 0.3,
                                                child: Center(
                                                    child:
                                                        CircularProgressIndicator()),
                                              ),
                                            ),
                                            cacheManager: customCacheManager,
                                            errorWidget: (context, url,
                                                    error) =>
                                                Image.asset(
                                                    "lib/assets/images/error.png"),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: items != null
                                            ? Text(
                                                items![index]!.title!,
                                                overflow: TextOverflow.ellipsis,
                                              )
                                            : SizedBox.shrink(),
                                      )
                                    ],
                                  )),
                            ),
                          );
                        }))
                : categoriesViewShimmerEffect(),
            const Text(
              "Kategoriler",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }
}
