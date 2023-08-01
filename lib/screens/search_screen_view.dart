import 'package:book_tracker/models/books_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/detailed_book_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class SearchScreenView extends ConsumerStatefulWidget {
  const SearchScreenView({super.key, required this.searchValue});
  final String searchValue;

  @override
  ConsumerState<SearchScreenView> createState() => _SearchScreenViewState();
}

class _SearchScreenViewState extends ConsumerState<SearchScreenView> {
  ImageProvider getBookCover(BooksModelDocs? item) {
    print(item!.coverI);
    if (item.coverI != null) {
      return NetworkImage(
          "https://covers.openlibrary.org/b/id/${item.coverI}-M.jpg");
    } else {
      return const AssetImage("lib/assets/images/nocover.jpg");
    }
  }

  bool isLoading = false;
  bool hasMore = true;
  int pageKey = 1;
  List<BooksModelDocs?>? itemList = [];

  final scrollController = ScrollController();
  @override
  void initState() {
    print("initstate çalıştı");
    fetchBooks();
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.offset) {
        fetchBooks();
      }
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant SearchScreenView oldWidget) {
    print("didupdatewidget çalıştı");
    if (widget.searchValue != oldWidget.searchValue) {
      pageKey = 1;
      if (itemList != []) {
        setState(() {
          print(itemList!.first!.authorName);
          itemList!.clear();
        });
      }

      fetchBooks();
      scrollController.addListener(() {
        if (scrollController.position.maxScrollExtent ==
            scrollController.offset) {
          fetchBooks();
        }
      });
    }

    print("didupdatewidget bitirdi");
    super.didUpdateWidget(oldWidget);
  }

  Future fetchBooks() async {
    if (isLoading) return;
    isLoading = true;
    print("${widget.searchValue}---fetchBooks çalıştı");

    var list = await ref
        .read(booksProvider)
        .booksModelDocsList(widget.searchValue, pageKey);

    setState(() {
      pageKey++;
      isLoading = false;
      if (list!.length < 10) {
        hasMore = false;
      }
      itemList!.addAll(list);
    });

    print(itemList);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("search screenview çalıştı");
    print(widget.searchValue);
    setState(() {});
    return Expanded(
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        separatorBuilder: (context, index) {
          return const SizedBox(
            height: 20,
          );
        },
        controller: scrollController,
        itemCount: itemList!.length + 1,
        itemBuilder: (context, index) {
          if (index < itemList!.length) {
            return Padding(
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: cardBuilder(context, itemList![index], index));
          } else {
            return Center(
                child: hasMore
                    ? const CircularProgressIndicator(
                        backgroundColor: Colors.amber,
                      )
                    : const Text("daha fazla veri yok"));
          }
        },
      ),
    );
  }

  Widget cardBuilder(BuildContext context, BooksModelDocs? item, int index) {
    return Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailedBookView(
                      item: item,
                    ),
                  ));
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Ink.image(
                    height: 180,
                    width: 180,
                    alignment: Alignment.center,
                    fit: BoxFit.contain,
                    image: getBookCover(item)),
                const SizedBox(
                  height: 5,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${item?.title!} ",
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      item!.authorName != null
                          ? Text(
                              "${item.authorName!.first}",
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            )
                          : const SizedBox.shrink(),
                      const SizedBox(
                        height: 5,
                      ),
                      item.publishDate != null
                          ? Text(
                              "${item.publishDate!.first}",
                              maxLines: 2,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                            )
                          : const SizedBox.shrink()
                    ],
                  ),
                ),
              ],
            )));
  }
}
