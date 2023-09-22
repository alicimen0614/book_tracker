import 'package:book_tracker/models/authors_works_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/discover_screen/book_info_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class AuthorsBooksScreen extends ConsumerStatefulWidget {
  const AuthorsBooksScreen({super.key, required this.authorKey});

  final String authorKey;

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
    print("fetchdata");
    try {
      var list = await ref
          .read(booksProvider)
          .getAuthorsWorksEntries(widget.authorKey, 25, pageKey);
      final isLastPage = list!.length < 25;
      if (isLastPage) {
        pagingController.appendLastPage(list);
      } else {
        final nextPageKey = pageKey + list.length + 1;
        pagingController.appendPage(list, nextPageKey);
      }
    } catch (e) {
      pagingController.error = e;
      print("$e-1");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 50,
        leading: IconButton(
            splashRadius: 25,
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 30,
            )),
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromRGBO(195, 129, 84, 1),
        elevation: 0,
      ),
      body: PagedGridView<int, AuthorsWorksModelEntries?>(
        physics: BouncingScrollPhysics(),
        pagingController: pagingController,
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.5,
            crossAxisSpacing: 25,
            mainAxisSpacing: 10),
        builderDelegate: PagedChildBuilderDelegate<AuthorsWorksModelEntries?>(
          itemBuilder: (context, item, index) => InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookInfoView(authorBook: item),
                  ));
            },
            child: Column(children: [
              item!.covers != null
                  ? Expanded(
                      flex: 12,
                      child: Image.network(
                        "https://covers.openlibrary.org/b/id/${item.covers!.first}-M.jpg",
                        fit: BoxFit.fill,
                      ),
                    )
                  : Expanded(
                      flex: 12,
                      child: Image.asset("lib/assets/images/nocover.jpg",
                          fit: BoxFit.fill),
                    ),
              Spacer(),
              Expanded(
                  flex: 3,
                  child: Text(
                    textAlign: TextAlign.center,
                    item.title!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )),
            ]),
          ),
        ),
      ),
    );
  }
}
