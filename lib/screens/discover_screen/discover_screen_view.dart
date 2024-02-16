import 'package:book_tracker/screens/discover_screen/categories_view.dart';
import 'package:book_tracker/screens/discover_screen/search_screen_view.dart';
import 'package:book_tracker/screens/discover_screen/trending_books_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

enum PageStatus { search, categories, trending }

class DiscoverScreenView extends ConsumerStatefulWidget {
  const DiscoverScreenView({super.key, this.searchValue = ""});
  final String searchValue;

  @override
  ConsumerState<DiscoverScreenView> createState() => _DiscoverScreenViewState();
}

class _DiscoverScreenViewState extends ConsumerState<DiscoverScreenView>
    with AutomaticKeepAliveClientMixin<DiscoverScreenView> {
  @override
  bool get wantKeepAlive => true;
  PageStatus pageStatus = PageStatus.categories;
  TextEditingController searchBarController = TextEditingController();

  @override
  void initState() {
    print("discover screen init çalıştı");

    if (widget.searchValue != "") {
      pageStatus = PageStatus.search;
      searchBarController.text = widget.searchValue;
    }
    super.initState();
  }

  void dispose() {
    searchBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print("çalıştı");

    return SafeArea(
      child: Scaffold(
          body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pageStatus == PageStatus.categories)
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 4, 5),
                child: searchBarBuilder(),
              )
            else if (widget.searchValue != "")
              Row(mainAxisSize: MainAxisSize.min, children: [
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
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Vazgeç",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                  ),
                )
              ])
            else
              Row(mainAxisSize: MainAxisSize.min, children: [
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
                        child: Text(
                          "Vazgeç",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                  ),
                )
              ]),
            pageStatus == PageStatus.search || widget.searchValue != ""
                ? SearchScreenView(
                    searchValue: widget.searchValue == "" ||
                            searchBarController.text != widget.searchValue
                        ? searchBarController.text
                        : widget.searchValue)
                : pageStatus == PageStatus.trending
                    ? TrendingBooksView(date: "monthly")
                    : CategoriesView()
          ],
        ),
      )),
    );
  }

  Row searchBarBuilder() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onEditingComplete: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
              setState(() {
                print("setstate girdi");

                pageStatus = PageStatus.search;
              });
            },
            controller: searchBarController,
            keyboardType: TextInputType.text,
            autocorrect: true,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(15),
              hintText: "Ara",
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color(0xFF1B7695),
                  ),
                  borderRadius: BorderRadius.circular(15)),
              suffixIcon: IconButton(
                onPressed: (() {
                  setState(() {
                    pageStatus = PageStatus.search;
                  });
                }),
                icon: Icon(
                  Icons.search,
                  size: 35,
                  color: Color(0xFF1B7695),
                ),
              ),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
            ),
          ),
        ),
      ],
    );
  }
}
