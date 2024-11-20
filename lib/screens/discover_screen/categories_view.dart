import 'package:book_tracker/const.dart';
import 'package:book_tracker/screens/discover_screen/detailed_categories_view.dart';
import 'package:flutter/material.dart';

class CategoriesView extends StatelessWidget {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> mainCategoriesNames = getMainCategoriesNames(context);
    return SliverGrid.builder(
      itemCount: Const.mainCategories.length,
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
                      categoryKey: Const.mainCategories[index],
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
                                "lib/assets/images/${Const.mainCategoriesImages[index]}"),
                            onError: (exception, stackTrace) =>
                                const AssetImage("lib/assets/images/error.png"),
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
    );
  }
}
