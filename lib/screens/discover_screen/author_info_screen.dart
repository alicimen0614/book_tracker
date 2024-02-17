import 'package:book_tracker/models/authors_model.dart';
import 'package:book_tracker/models/authors_works_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/discover_screen/authors_books_screen.dart';
import 'package:book_tracker/screens/discover_screen/book_info_view.dart';
import 'package:book_tracker/screens/discover_screen/shimmer_effect_builders/author_info_body_shimmer.dart';
import 'package:book_tracker/services/internet_connection_service.dart';
import 'package:book_tracker/widgets/error_snack_bar.dart';
import 'package:book_tracker/widgets/internet_connection_error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transparent_image/transparent_image.dart';

import 'shimmer_effect_builders/author_image_and_details_shimmer.dart';

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
  bool biographyShowMore = false;
  bool isConnected = false;
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
                Icons.arrow_back_sharp,
                size: 30,
                color: Colors.white,
              )),
          automaticallyImplyLeading: false,
          elevation: 0,
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isLoading != true
                  ? authorImageAndDetailsBuilder()
                  : authorImageAndDetailsShimmerBuilder(context),
              isLoading != true
                  ? authorInfoBodyBuilder(context)
                  : authorInfoBodyShimmerBuilder(context)
            ],
          ),
        ));
  }

  Container authorImageAndDetailsBuilder() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Color(0xFF1B7695),
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50))),
      child: Column(
        children: [
          authorsModel.photos != null
              ? Align(
                  alignment: Alignment.center,
                  child: Container(
                      decoration: BoxDecoration(color: Colors.transparent),
                      height: 200,
                      width: 150,
                      child: FadeInImage.memoryNetwork(
                          imageErrorBuilder: (context, error, stackTrace) =>
                              Image.asset("lib/assets/images/error.png"),
                          placeholder: kTransparentImage,
                          image:
                              "https://covers.openlibrary.org/a/id/${authorsModel.photos!.first}-M.jpg")),
                )
              : Align(
                  alignment: Alignment.center,
                  child: Image.asset("lib/assets/images/nocover.jpg")),
          SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(50)),
            width: MediaQuery.sizeOf(context).width - 30,
            height: 50,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 150,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Doğum Tarihi",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                            authorsModel.birthDate != null
                                ? "${authorsModel.birthDate}"
                                : "-",
                            textAlign: TextAlign.center)
                      ],
                    ),
                  ),
                  VerticalDivider(),
                  SizedBox(
                    width: 150,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Ölüm Tarihi",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          authorsModel.deathDate != null
                              ? authorsModel.deathDate!
                              : "-",
                          style: const TextStyle(),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                ]),
          ),
        ],
      ),
    );
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
    String textAsString = "";
    if (authorsModel.bio != null) {
      textAsString = authorsModel.bio!.replaceRange(0, 26, "");
    }

    return Expanded(
      child: Scrollbar(
        thickness: 2,
        radius: Radius.circular(20),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          physics: ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Yazar Adı",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Divider(color: Colors.transparent, thickness: 0),
              if (authorsModel.name != null)
                SizedBox(
                  width: MediaQuery.sizeOf(context).width - 40,
                  child: Text(
                    authorsModel.name!,
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),
              Divider(color: Colors.transparent, thickness: 0),
              if (authorsModel.bio != null)
                Divider(color: Colors.transparent, thickness: 0),
              if (authorsModel.bio != null)
                Text(
                  "Biyografi",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              if (authorsModel.bio != null)
                Divider(color: Colors.transparent, thickness: 0),
              if (authorsModel.bio != null)
                SizedBox(
                  width: MediaQuery.sizeOf(context).width - 40,
                  child: Text(
                    authorsModel.bio!.startsWith("{")
                        ? textAsString.replaceRange(
                            textAsString.length - 1, textAsString.length, "")
                        : authorsModel.bio!,
                    style: const TextStyle(fontSize: 15),
                    maxLines: biographyShowMore != true ? 5 : null,
                  ),
                ),
              if (authorsModel.bio != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                      onPressed: () {
                        setState(() {
                          biographyShowMore = !biographyShowMore;
                        });
                      },
                      child: biographyShowMore != true
                          ? Text("Daha fazla göster")
                          : Text("Daha az göster")),
                ),
              if (authorsModel.birthDate != null)
                Divider(color: Colors.transparent, thickness: 0),
              Text(
                "Yazara Ait Kitaplar",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Divider(color: Colors.transparent, thickness: 0),
              SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: ListView.separated(
                      separatorBuilder: (context, index) => SizedBox(
                            width: 10,
                          ),
                      physics: ClampingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) => Container(
                            height: 100,
                            width: 80,
                            child: InkWell(
                                customBorder: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BookInfoView(
                                          authorBook: authorsWorks![index]),
                                    )),
                                child: Column(
                                  children: [
                                    Expanded(
                                        flex: 10,
                                        child: Padding(
                                          padding: EdgeInsets.all(5),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: Ink(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  image: authorsWorks![index]!
                                                              .covers !=
                                                          null
                                                      ? DecorationImage(
                                                          image: NetworkImage(
                                                              "https://covers.openlibrary.org/b/id/${authorsWorks![index]!.covers!.first}-M.jpg"),
                                                          onError: (exception,
                                                                  stackTrace) =>
                                                              AssetImage(
                                                                  "lib/assets/images/error.png"),
                                                          fit: BoxFit.fill)
                                                      : DecorationImage(
                                                          image: AssetImage(
                                                              "lib/assets/images/nocover.jpg"),
                                                          onError: (exception,
                                                                  stackTrace) =>
                                                              AssetImage(
                                                                  "lib/assets/images/error.png"))),
                                            ),
                                          ),
                                        )),
                                    Expanded(
                                        flex: 4,
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
                            builder: (context) => AuthorsBooksScreen(
                                authorKey: widget.authorKey,
                                authorName: authorsModel.name!),
                          ));
                    },
                    child: Text(
                      "${authorsWorksSize} Kitabın Tümünü Görüntüle",
                      style: TextStyle(
                          color: Color(0xFF1B7695),
                          fontWeight: FontWeight.bold),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future getPageData() async {
    isConnected = await checkForInternetConnection();
    setState(() {
      isLoading = true;
    });
    if (isConnected == true) {
      try {
        await getAuthorInfo();
        await getAuthorsWorks();
      } catch (e) {
        if (mounted) errorSnackBar(context, e.toString());
      }
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      internetConnectionErrorDialog(context, true);
    }
  }

  Future<AuthorsModel> getAuthorInfo() async {
    return authorsModel = await ref
        .read(booksProvider)
        .getAuthorInfo(widget.authorKey, false, context);
  }

  Future<List<AuthorsWorksModelEntries?>?> getAuthorsWorks() async {
    AuthorsWorksModel authorsWorksModel;
    authorsWorksModel = await ref
        .read(booksProvider)
        .getAuthorsWorks(widget.authorKey, 5, 0, context);

    authorsWorks = authorsWorksModel.entries;
    authorsWorksSize = authorsWorksModel.size;
    return authorsWorks;
  }
}
