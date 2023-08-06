import 'package:book_tracker/models/trendingbooks_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/discover_screen/detailed_categories_view.dart';
import 'package:book_tracker/screens/discover_screen/trending_book_info_view.dart';
import 'package:book_tracker/screens/discover_screen/trending_books_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    isLoading = true;
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

  final List mainCategories = [
    "Classics",
    "Fantasy",
    "Adventure",
    "Contemporary",
    "Romance",
    "Dystopian",
    "Horror",
    "Paranormal",
    "Historical Fiction",
    "Science Fiction",
    "Children's",
    "Academic",
    "Mystery",
    "Thrillers",
    "Memoir",
    "Self-help",
    "Cookbook",
    "Art & Photography",
    "Young Adult",
    "Personal Development",
    "Motivational",
    "Health",
    "History",
    "Travel",
    "Guide",
    "Families & Relationships",
    "Humor",
    "Graphic Novel",
    "Short Story",
    "Biography and Autobiography",
    "Poetry",
    "Religion & Spirituality"
  ];

  final List mainCategoriesImages = [
    "classical.png",
    "fantasy.png",
    "adventure.png",
    "contemporary.png",
    "romance.png",
    "dystopia.png",
    "horror.png",
    "paranormal.png",
    "historicalfiction.png",
    "science-fiction.png",
    "children.png",
    "academic.png",
    "mystery.png",
    "thriller.png",
    "memoirs.png",
    "self-help.png",
    "cooking.png",
    "art.png",
    "youngadult.png",
    "personaldevelopment.png",
    "praying.png",
    "health.png",
    "history.png",
    "travel.png",
    "guide.png",
    "family.png",
    "humor.png",
    "graphicnovel.png",
    "shortstory.png",
    "biography.png",
    "poetry.png",
    "religion.png"
  ];

  @override
  Widget build(BuildContext context) {
    print(items);
    return Expanded(
      child: CustomScrollView(
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
                          categoryName: mainCategories[index]);
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
                    mainCategories[index],
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
                        scrollDirection: Axis.horizontal,
                        itemCount: items!.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(10),
                            child: SizedBox(
                              width: 100,
                              child: InkWell(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(
                                      builder: (context) {
                                        return TrendingBookInfoView(
                                            book: items![index]);
                                      },
                                    ));
                                  },
                                  child: Column(
                                    children: [
                                      Image.network(
                                        "https://covers.openlibrary.org/b/id/${items![index]!.coverI}-S.jpg",
                                        errorBuilder: (context, error,
                                                stackTrace) =>
                                            Image.asset(
                                                "lib/assets/images/error.png"),
                                      ),
                                      Text(
                                        items![index]!.title!,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    ],
                                  )),
                            ),
                          );
                        }))
                : const SizedBox(
                    height: 100,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
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
}