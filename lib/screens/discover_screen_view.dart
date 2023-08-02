import 'package:book_tracker/models/trendingbooks_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/categories_view.dart';
import 'package:book_tracker/screens/search_screen_view.dart';
import 'package:book_tracker/screens/trending_books_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

enum PageStatus { search, categories, trending }

class DiscoverScreenView extends ConsumerStatefulWidget {
  const DiscoverScreenView({
    super.key,
  });

  @override
  ConsumerState<DiscoverScreenView> createState() => _DiscoverScreenViewState();
}

class _DiscoverScreenViewState extends ConsumerState<DiscoverScreenView> {
  PageStatus pageStatus = PageStatus.categories;
  TextEditingController searchBarController = TextEditingController();
  @override
  void dispose() {
    searchBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("çalıştı");

    return SafeArea(
      child: Scaffold(
          body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          pageStatus == PageStatus.categories ||
                  pageStatus == PageStatus.trending
              ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
                      child: searchBarBuilder(),
                    ),
                  ],
                )
              : Row(mainAxisSize: MainAxisSize.min, children: [
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 4, 5),
                      child: searchBarBuilder(),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: TextButton(
                          onPressed: () {
                            setState(() {
                              pageStatus = PageStatus.categories;
                              searchBarController.clear();
                            });
                          },
                          child: Text("Vazgeç")),
                    ),
                  )
                ]),
          pageStatus == PageStatus.search
              ? SearchScreenView(searchValue: searchBarController.text)
              : pageStatus == PageStatus.trending
                  ? TrendingBooksView(date: "monthly")
                  : CategoriesView()
        ],
      )),
    );
  }

  Row searchBarBuilder() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onEditingComplete: () {
              setState(() {
                pageStatus = PageStatus.search;

                SearchScreenView(searchValue: searchBarController.text);
              });
            },
            controller: searchBarController,
            keyboardType: TextInputType.text,
            autocorrect: true,
            cursorColor: Color.fromRGBO(242, 190, 34, 1),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(15),
              hintText: "Search",
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.teal.shade700,
                  ),
                  borderRadius: BorderRadius.circular(50)),
              suffixIcon: IconButton(
                onPressed: (() {
                  setState(() {
                    pageStatus = PageStatus.search;
                    SearchScreenView(searchValue: searchBarController.text);
                  });
                }),
                icon: Icon(
                  Icons.search,
                  size: 35,
                  color: Colors.teal,
                ),
              ),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
            ),
          ),
        ),
      ],
    );
  }
}
