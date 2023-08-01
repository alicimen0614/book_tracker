import 'package:book_tracker/screens/categories_view.dart';
import 'package:book_tracker/screens/search_screen_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

enum PageStatus { search, categories }

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
            child: searchBarBuilder(),
          ),
          pageStatus == PageStatus.search
              ? SearchScreenView(searchValue: searchBarController.text)
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
