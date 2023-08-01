import 'package:book_tracker/models/books_model.dart';
import 'package:flutter/material.dart';

class DetailedBookView extends StatefulWidget {
  const DetailedBookView({super.key, this.item});
  final BooksModelDocs? item;

  @override
  State<DetailedBookView> createState() => _DetailedBookViewState();
}

class _DetailedBookViewState extends State<DetailedBookView> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(slivers: [
          SliverAppBar(
            toolbarHeight: 62,
            backgroundColor: Colors.teal.shade400,
            expandedHeight: 250,
            leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back)),
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
                expandedTitleScale: 1,
                title: Text(widget.item!.title!,
                    style: TextStyle(color: Colors.white)),
                centerTitle: false,
                background: getImage(selectedIndex)),
            forceElevated: true,
          ),
          widget.item!.isbn != null
              ? SliverList(
                  delegate: SliverChildBuilderDelegate(
                  childCount: widget.item!.isbn!.length,
                  (context, index) {
                    return Padding(
                      padding: EdgeInsets.all(5),
                      child: ListTile(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                        leading: Image.network(
                            imageLinkCreater(widget.item!.isbn![index]!, "M")),
                        title: Text(widget.item!.isbn![index]!),
                      ),
                    );
                  },
                ))
              : SliverFillRemaining()
        ]),
      ),
    );
  }

  Image getImage(int index) {
    if (widget.item!.isbn != null) {
      return Image.network(imageLinkCreater(widget.item!.isbn![index]!, "L"));
    } else {
      return Image.asset("lib/assets/images/nocover.jpg");
    }
  }
}

imageLinkCreater(String isbn, String imageSize) {
  String imageLink =
      'https://covers.openlibrary.org/b/isbn/$isbn-$imageSize.jpg';
  return imageLink;
}
