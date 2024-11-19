import 'package:book_tracker/models/authors_works_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/discover_screen/book_info_view.dart';
import 'package:book_tracker/screens/discover_screen/shimmer_effect_builders/grid_view_books_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AuthorsBooksScreen extends ConsumerStatefulWidget {
  const AuthorsBooksScreen(
      {super.key, required this.authorKey, required this.authorName});

  final String authorKey;
  final String authorName;

  @override
  ConsumerState<AuthorsBooksScreen> createState() => _AuthorsBooksScreenState();
}

class _AuthorsBooksScreenState extends ConsumerState<AuthorsBooksScreen> {
  final PagingController<int, AuthorsWorksModelEntries?> pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    pagingController.addPageRequestListener((pageKey) {
      fetchData(pageKey);
    });
    super.initState();
  }

  void fetchData(int pageKey) async {
    try {
      AuthorsWorksModel worksModel = await ref
          .read(booksProvider)
          .getAuthorsWorks(widget.authorKey, 25, pageKey, context);
      var list = worksModel.entries;

      final isLastPage = list!.length < 25;
      if (isLastPage) {
        pagingController.appendLastPage(list);
      } else {
        final nextPageKey = pageKey + list.length;
        pagingController.appendPage(list, nextPageKey);
      }
    } catch (e) {
      pagingController.error = e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 50,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.authorsBooks(widget.authorName),
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.of(context).size.height / 40),
        ),
        leading: IconButton(
            splashRadius: 25,
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_sharp,
              size: 30,
            )),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: PagedGridView<int, AuthorsWorksModelEntries?>(
        physics: const ClampingScrollPhysics(),
        pagingController: pagingController,
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1,
            crossAxisSpacing: 25,
            mainAxisSpacing: 25,
            mainAxisExtent: 230),
        builderDelegate: PagedChildBuilderDelegate<AuthorsWorksModelEntries?>(
          firstPageProgressIndicatorBuilder: (context) =>
              gridViewBooksShimmerEffectBuilder(),
          itemBuilder: (context, item, index) => InkWell(
            customBorder:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookInfoView(authorBook: item),
                  ));
            },
            child: Column(children: [
              Expanded(
                  flex: 12,
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Ink(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: item!.covers != null
                              ? DecorationImage(
                                  image: NetworkImage(
                                      "https://covers.openlibrary.org/b/id/${item.covers!.first}-M.jpg"),
                                  onError: (exception, stackTrace) =>
                                      const AssetImage(
                                          "lib/assets/images/error.png"),
                                  fit: BoxFit.fill)
                              : DecorationImage(
                                  image: const AssetImage(
                                      "lib/assets/images/nocover.jpg"),
                                  onError: (exception, stackTrace) =>
                                      const AssetImage(
                                          "lib/assets/images/error.png"),
                                  fit: BoxFit.fill)),
                    ),
                  )),
              const Spacer(),
              Expanded(
                  flex: 3,
                  child: Text(
                    textAlign: TextAlign.center,
                    item.title!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.height / 60),
                  )),
            ]),
          ),
        ),
      ),
    );
  }
}
