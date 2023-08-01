import 'package:flutter/material.dart';

class CategoriesView extends StatelessWidget {
  CategoriesView({super.key});

  final List mainCategories = [
    "Fiction",
    "Non-Fiction",
    "Novel",
    "Romance",
    "Self-Help Books",
    "Children’s Books",
    "Biography",
    "Autobiography",
    "Text-books",
    "Political Books",
    "Academic Books",
    "Mystery",
    "Thrillers",
    "Poetry Books",
    "Spiritual Books",
    "Cook Books",
    "Art Books",
    "Young Adult Books",
    "History Books"
  ];

  final List mainCategoriesImages = [
    "science-fiction.png",
    "science-fiction.png",
    "science-fiction.png",
    "romance.png",
    "romance.png",
    "children.png",
    "autobiography.png",
    "biography.png",
    "autobiography.png",
    "politician.png",
    "academic.png",
    "mystery.png",
    "thriller.png",
    "poetry.png",
    "praying.png",
    "cooking.png",
    "art.png",
    "autobiography.png",
    "history.png"
  ];

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: GridView.builder(
      physics: BouncingScrollPhysics(),
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
              child: Column(children: [
                Image.asset("lib/assets/images/${mainCategoriesImages[index]}"),
                Text(mainCategories[index])
              ]),
            ),
          ),
        );
      },
    ));
  }
}
