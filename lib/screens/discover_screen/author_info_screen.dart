import 'package:book_tracker/models/authors_model.dart';
import 'package:book_tracker/models/authors_works_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/discover_screen/authors_books_screen.dart';
import 'package:book_tracker/screens/discover_screen/book_info_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transparent_image/transparent_image.dart';

class AuthorInfoScreen extends ConsumerStatefulWidget {
  AuthorInfoScreen({super.key, required this.authorKey});

  final String authorKey;

  @override
  ConsumerState<AuthorInfoScreen> createState() => _DetailedEditionInfoState();
}

class _DetailedEditionInfoState extends ConsumerState<AuthorInfoScreen> {
  AuthorsModel authorsModel = AuthorsModel();
  bool isLoading = false;
  List<AuthorsWorksModelEntries?>? authorsWorks = [];
  int? authorsWorksSize;
  @override
  void initState() {
    getPageData();
    super.initState();
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
        backgroundColor: const Color.fromRGBO(195, 129, 84, 1),
        body: isLoading != true
            ? SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      authorsModel.photos != null
                          ? Align(
                              alignment: Alignment.center,
                              child: Container(
                                  decoration:
                                      BoxDecoration(color: Colors.transparent),
                                  height: 200,
                                  width: 150,
                                  child: FadeInImage.memoryNetwork(
                                      placeholder: kTransparentImage,
                                      image:
                                          "https://covers.openlibrary.org/a/id/${authorsModel.photos!.first}-M.jpg")),
                            )
                          : Align(
                              alignment: Alignment.center,
                              child:
                                  Image.asset("lib/assets/images/nocover.jpg")),
                      SizedBox(
                        height: 20,
                      ),
                      authorInfoBodyBuilder(context)
                    ],
                  ),
                ),
              )
            : Center(
                child: CircularProgressIndicator(),
              ));
  }

  void modalBottomSheetBuilderForPopUpMenu(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.grey.shade300,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30))),
      context: context,
      builder: (context) {
        return Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: Icon(
              Icons.info,
              size: 30,
            ),
            title: Text("Bilgi", style: TextStyle(fontSize: 20)),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.share,
              size: 30,
            ),
            title: Text("Paylaş", style: TextStyle(fontSize: 20)),
          )
        ]);
      },
    );
  }

  Expanded authorInfoBodyBuilder(BuildContext context) {
    return Expanded(
      child: Scrollbar(
        thickness: 2,
        radius: Radius.circular(20),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Yazar Adı",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              Divider(color: Colors.transparent, thickness: 0),
              SizedBox(
                width: MediaQuery.sizeOf(context).width - 40,
                child: Text(
                  authorsModel.name!,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
              if (authorsModel.bio != null)
                Divider(color: Colors.transparent, thickness: 0),
              if (authorsModel.bio != null)
                Text(
                  "Biyografi",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              if (authorsModel.bio != null)
                Divider(color: Colors.transparent, thickness: 0),
              if (authorsModel.bio != null)
                SizedBox(
                  width: MediaQuery.sizeOf(context).width - 40,
                  child: Text(
                    authorsModel.bio!,
                    style: const TextStyle(fontSize: 17),
                  ),
                ),
              if (authorsModel.birthDate != null)
                Divider(color: Colors.transparent, thickness: 0),
              if (authorsModel.birthDate != null)
                Text(
                  "Doğum Tarihi",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              if (authorsModel.birthDate != null)
                Divider(color: Colors.transparent, thickness: 0),
              if (authorsModel.birthDate != null)
                SizedBox(
                  width: MediaQuery.sizeOf(context).width - 40,
                  child: Text(
                    authorsModel.birthDate!,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
              if (authorsModel.deathDate != null)
                Divider(color: Colors.transparent, thickness: 0),
              if (authorsModel.deathDate != null)
                Text(
                  "Ölüm Tarihi",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              if (authorsModel.deathDate != null)
                Divider(color: Colors.transparent, thickness: 0),
              if (authorsModel.deathDate != null)
                SizedBox(
                    width: MediaQuery.sizeOf(context).width - 40,
                    child: Text(
                      authorsModel.deathDate!,
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 17),
                    )),
              Divider(color: Colors.transparent, thickness: 0),
              Text(
                "Yazara Ait Kitaplar",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              Divider(color: Colors.transparent, thickness: 0),
              SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) => Container(
                            height: 100,
                            width: 100,
                            child: InkWell(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BookInfoView(
                                          authorBook: authorsWorks![index]),
                                    )),
                                child: Column(
                                  children: [
                                    authorsWorks![index]!.covers != null
                                        ? Expanded(
                                            flex: 2,
                                            child: Image.network(
                                                "https://covers.openlibrary.org/b/id/${authorsWorks![index]!.covers!.first}-M.jpg"),
                                          )
                                        : Expanded(
                                            flex: 2,
                                            child: Image.asset(
                                              "lib/assets/images/nocover.jpg",
                                            ),
                                          ),
                                    Expanded(
                                        flex: 1,
                                        child: Text(
                                          textAlign: TextAlign.center,
                                          authorsWorks![index]!.title!,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ))
                                  ],
                                )),
                          ),
                      itemCount: authorsWorks!.length >= 5
                          ? 5
                          : authorsWorks!.length)),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AuthorsBooksScreen(authorKey: widget.authorKey),
                          ));
                    },
                    child: Text(
                      "${authorsWorksSize} Kitabın Tümünü Görüntüle",
                      style: TextStyle(color: Colors.amberAccent.shade200),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future getPageData() async {
    setState(() {
      isLoading = true;
    });
    await getAuthorInfo();
    await getAuthorsWorks();
    await getAuthorsWorksSize();

    setState(() {
      isLoading = false;
    });
  }

  Future<AuthorsModel> getAuthorInfo() async {
    return authorsModel =
        await ref.read(booksProvider).getAuthorInfo(widget.authorKey, false);
  }

  Future<List<AuthorsWorksModelEntries?>?> getAuthorsWorks() async {
    return authorsWorks = await ref
        .read(booksProvider)
        .getAuthorsWorksEntries(widget.authorKey, 5, 0);
  }

  Future<int?> getAuthorsWorksSize() async {
    return authorsWorksSize =
        await ref.read(booksProvider).getAuthorsWorksSize(widget.authorKey);
  }
}
