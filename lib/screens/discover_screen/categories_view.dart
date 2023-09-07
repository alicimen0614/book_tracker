import 'package:book_tracker/const.dart';
import 'package:book_tracker/models/trendingbooks_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/discover_screen/detailed_categories_view.dart';
import 'package:book_tracker/screens/discover_screen/book_info_view.dart';
import 'package:book_tracker/screens/discover_screen/trending_books_view.dart';
import 'package:book_tracker/widgets/shimmer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transparent_image/transparent_image.dart';

class CategoriesView extends ConsumerStatefulWidget {
  const CategoriesView({super.key});

  @override
  ConsumerState<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends ConsumerState<CategoriesView> {
  bool isLoading = true;
  List<TrendingBooksWorks?>? items = [];
  @override
  void initState() {
    getTrendingBooks();
    super.initState();
  }

  Future<void> getTrendingBooks() async {
    setState(() {
      isLoading = true;
    });
    items = await ref
        .read(booksProvider)
        .trendingBookDocsList("monthly", 1)
        .whenComplete(() {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
    print(items);
  }

  @override
  Widget build(BuildContext context) {
    print(items);
    return Expanded(
      child: CustomScrollView(
        physics: BouncingScrollPhysics(),
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
        physics: const BouncingScrollPhysics(),
        itemCount: mainCategories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisSpacing: 50,
          crossAxisSpacing: 25,
          mainAxisExtent: 250,
          childAspectRatio: 0.1,
          crossAxisCount: 2,
        ),
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
                  Image.asset(
                      "lib/assets/images/${mainCategoriesImages[index]}"),
                  const SizedBox(
                    width: double.infinity,
                    height: 10,
                  ),
                  Text(
                    mainCategoriesNames[index],
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        overflow: TextOverflow.fade),
                    textAlign: TextAlign.center,
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
                      child: const Text("Daha fazla"),
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
                    height: 100,
                    width: double.infinity,
                    child: ListView.builder(
                        physics: BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: items!.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(10),
                            child: SizedBox(
                              width: 85,
                              child: InkWell(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(
                                      builder: (context) {
                                        return BookInfoView(
                                            trendingBook: items![index]);
                                      },
                                    ));
                                  },
                                  child: Column(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: FadeInImage.memoryNetwork(
                                          image:
                                              "https://covers.openlibrary.org/b/id/${items![index]!.coverI}-S.jpg",
                                          placeholder: kTransparentImage,
                                          imageErrorBuilder: (context, error,
                                                  stackTrace) =>
                                              Image.asset(
                                                  "lib/assets/images/error.png"),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          items![index]!.title!,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )
                                    ],
                                  )),
                            ),
                          );
                        }))
                : shimmerEffectBuilder(),
            const Text(
              "Kategoriler",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(
              height: 5,
            )
          ],
        ),
      ),
    );
  }

  Container shimmerEffectBuilder() {
    return Container(
      height: 100,
      width: double.infinity,
      child: ListView.separated(
          scrollDirection: Axis.horizontal,
          separatorBuilder: (context, index) => SizedBox(
                width: 25,
              ),
          itemCount: 10,
          itemBuilder: (context, index) => SizedBox(
              width: 85,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(children: [
                  ShimmerWidget.rectangular(width: 40, height: 58),
                  SizedBox(
                    height: 5,
                  ),
                  ShimmerWidget.rectangular(width: 75, height: 10)
                ]),
              ))),
    );
  }
}
