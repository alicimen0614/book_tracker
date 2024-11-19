import 'package:book_tracker/const.dart';
import 'package:book_tracker/screens/discover_screen/categories_view.dart';
import 'package:book_tracker/screens/discover_screen/search_screen_view.dart';
import 'package:book_tracker/screens/discover_screen/trending_books_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    if (widget.searchValue != "") {
      pageStatus = PageStatus.search;
      searchBarController.text = widget.searchValue;
    }
    super.initState();
  }

  @override
  void dispose() {
    searchBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
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
            Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25)),
                  color: Color(0xFF1B7695)),
              padding: const EdgeInsets.fromLTRB(10, 10, 4, 5),
              height: Const.screenSize.height * 0.15,
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
                  padding: const EdgeInsets.only(right: 4),
                  child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: FittedBox(
                        child: Text(
                          AppLocalizations.of(context)!.cancel,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
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
                  padding: const EdgeInsets.only(right: 4),
                  child: TextButton(
                      onPressed: () {
                        setState(() {
                          pageStatus = PageStatus.categories;
                          searchBarController.clear();
                        });
                      },
                      child: FittedBox(
                        child: Text(
                          AppLocalizations.of(context)!.cancel,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
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
                  ? const TrendingBooksView(date: "monthly")
                  : const CategoriesView()
        ],
      ),
    ));
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
                pageStatus = PageStatus.search;
              });
            },
            controller: searchBarController,
            cursorColor: Colors.black,
            keyboardType: TextInputType.text,
            autocorrect: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(15),
              hintText: AppLocalizations.of(context)!.search,
              focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0xFF1B7695),
                  ),
                  borderRadius: BorderRadius.circular(15)),
              suffixIcon: IconButton(
                onPressed: (() {
                  setState(() {
                    pageStatus = PageStatus.search;
                  });
                }),
                icon: const Icon(
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
