import 'package:book_tracker/const.dart';
import 'package:book_tracker/models/authors_model.dart';
import 'package:book_tracker/models/authors_works_model.dart';
import 'package:book_tracker/providers/connectivity_provider.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/discover_screen/authors_books_screen.dart';
import 'package:book_tracker/screens/discover_screen/book_info_view.dart';
import 'package:book_tracker/screens/discover_screen/shimmer_effect_builders/author_info_body_shimmer.dart';
import 'package:book_tracker/widgets/error_snack_bar.dart';
import 'package:book_tracker/widgets/internet_connection_error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'shimmer_effect_builders/author_image_and_details_shimmer.dart';

class AuthorInfoScreen extends ConsumerStatefulWidget {
  const AuthorInfoScreen({super.key, required this.authorKey});

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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
                pinned: true,
                expandedHeight: Const.screenSize.height * 0.52,
                toolbarHeight: Const.screenSize.height * 0.06,
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
                flexibleSpace: FlexibleSpaceBar(
                  background: isLoading != true
                      ? authorImageAndDetailsBuilder()
                      : authorImageAndDetailsShimmerBuilder(context),
                )),
            SliverToBoxAdapter(
                child: isLoading != true
                    ? authorInfoBodyBuilder(context)
                    : authorInfoBodyShimmerBuilder(context)),
          ],
        ));
  }

  Container authorImageAndDetailsBuilder() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
          color: Color(0xFF1B7695),
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50))),
      child: Column(
        children: [
          SizedBox(
            height: Const.screenSize.height * 0.11,
          ),
          authorsModel.photos != null
              ? Align(
                  alignment: Alignment.center,
                  child: Container(
                      decoration:
                          const BoxDecoration(color: Colors.transparent),
                      child: FadeInImage.memoryNetwork(
                        imageErrorBuilder: (context, error, stackTrace) =>
                            Image.asset("lib/assets/images/error.png"),
                        placeholder: kTransparentImage,
                        image:
                            "https://covers.openlibrary.org/a/id/${authorsModel.photos!.first}-M.jpg",
                        height: MediaQuery.of(context).size.height / 3.5,
                        width: MediaQuery.of(context).size.height / 4.5,
                        fit: BoxFit.fill,
                      )),
                )
              : Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    "lib/assets/images/nocover.jpg",
                    height: MediaQuery.of(context).size.height / 3.5,
                    width: MediaQuery.of(context).size.height / 4.5,
                    fit: BoxFit.fill,
                  )),
          const SizedBox(
            height: 10,
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(50)),
            width: MediaQuery.sizeOf(context).width - 30,
            height: MediaQuery.of(context).size.height / 12,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 150,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppLocalizations.of(context)!.birthDate,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.height / 50)),
                        FittedBox(
                          child: Text(
                              authorsModel.birthDate != null
                                  ? "${authorsModel.birthDate}"
                                  : "-",
                              textAlign: TextAlign.center),
                        )
                      ],
                    ),
                  ),
                  const VerticalDivider(),
                  SizedBox(
                    width: 150,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppLocalizations.of(context)!.deathDate,
                            maxLines: 1,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.height / 50)),
                        FittedBox(
                          child: Text(
                            authorsModel.deathDate != null
                                ? authorsModel.deathDate!
                                : "-",
                            style: const TextStyle(),
                            textAlign: TextAlign.center,
                          ),
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

  Scrollbar authorInfoBodyBuilder(BuildContext context) {
    String textAsString = "";
    if (authorsModel.bio != null) {
      textAsString = authorsModel.bio!.replaceRange(0, 26, "");
    }

    return Scrollbar(
      thickness: 2,
      radius: const Radius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.authorName,
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height / 50,
                  fontWeight: FontWeight.bold),
            ),
            const Divider(color: Colors.transparent, thickness: 0),
            if (authorsModel.name != null)
              SizedBox(
                width: MediaQuery.sizeOf(context).width - 40,
                child: Text(
                  authorsModel.name!,
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height / 60,
                  ),
                ),
              ),
            const Divider(color: Colors.transparent, thickness: 0),
            if (authorsModel.bio != null)
              const Divider(color: Colors.transparent, thickness: 0),
            if (authorsModel.bio != null)
              Text(
                AppLocalizations.of(context)!.biography,
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height / 50,
                    fontWeight: FontWeight.bold),
              ),
            if (authorsModel.bio != null)
              const Divider(color: Colors.transparent, thickness: 0),
            if (authorsModel.bio != null)
              SizedBox(
                width: MediaQuery.sizeOf(context).width - 40,
                child: Text(
                  authorsModel.bio!.startsWith("{")
                      ? textAsString.replaceRange(
                          textAsString.length - 1, textAsString.length, "")
                      : authorsModel.bio!,
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height / 60),
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
                        ? Text(
                            AppLocalizations.of(context)!.showMore,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.height / 60),
                          )
                        : Text(AppLocalizations.of(context)!.showLess,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.height / 60))),
              ),
            if (authorsModel.birthDate != null)
              const Divider(color: Colors.transparent, thickness: 0),
            Text(
              AppLocalizations.of(context)!.booksByAuthor,
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height / 50,
                  fontWeight: FontWeight.bold),
            ),
            const Divider(color: Colors.transparent, thickness: 0),
            SizedBox(
                height: MediaQuery.of(context).size.width > 500 ? 300 : 150,
                width: double.infinity,
                child: ListView.separated(
                    separatorBuilder: (context, index) => const SizedBox(
                          width: 10,
                        ),
                    physics: const ClampingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) => SizedBox(
                          height: MediaQuery.of(context).size.width > 500
                              ? 250
                              : 100,
                          width: MediaQuery.of(context).size.width > 500
                              ? 150
                              : 80,
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
                                        padding: const EdgeInsets.all(5),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: Ink(
                                            width: MediaQuery.of(context)
                                                        .size
                                                        .width >
                                                    500
                                                ? 150
                                                : 70,
                                            height: MediaQuery.of(context)
                                                        .size
                                                        .width >
                                                    500
                                                ? 500
                                                : 150,
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
                                                            const AssetImage(
                                                                "lib/assets/images/error.png"),
                                                        fit: BoxFit.fill)
                                                    : DecorationImage(
                                                        image: const AssetImage(
                                                            "lib/assets/images/nocover.jpg"),
                                                        onError: (exception,
                                                                stackTrace) =>
                                                            const AssetImage(
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
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  60)))
                                ],
                              )),
                        ),
                    itemCount:
                        authorsWorks!.length >= 5 ? 5 : authorsWorks!.length)),
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
                    AppLocalizations.of(context)!
                        .viewAllBooks(authorsWorksSize!),
                    style: TextStyle(
                        color: const Color(0xFF1B7695),
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.height / 60),
                  )),
            )
          ],
        ),
      ),
    );
  }

  Future getPageData() async {
    isConnected = ref.read(connectivityProvider).isConnected;
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
