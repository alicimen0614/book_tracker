import 'package:book_tracker/const.dart';
import 'package:book_tracker/l10n/app_localizations.dart';
import 'package:book_tracker/main.dart';
import 'package:book_tracker/models/trendingbooks_model.dart';
import 'package:book_tracker/providers/connectivity_provider.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/discover_screen/book_info_view.dart';
import 'package:book_tracker/screens/discover_screen/categories_view.dart';
import 'package:book_tracker/screens/discover_screen/search_screen_view.dart';
import 'package:book_tracker/screens/discover_screen/shimmer_effect_builders/categories_view_shimmer.dart';
import 'package:book_tracker/screens/discover_screen/trending_books_view.dart';
import 'package:book_tracker/services/analytics_service.dart';
import 'package:book_tracker/widgets/error_snack_bar.dart';
import 'package:book_tracker/widgets/internet_connection_error_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class DiscoverScreenView extends ConsumerStatefulWidget {
  const DiscoverScreenView({super.key});

  @override
  ConsumerState<DiscoverScreenView> createState() => _DiscoverScreenViewState();
}

class _DiscoverScreenViewState extends ConsumerState<DiscoverScreenView>
    with AutomaticKeepAliveClientMixin<DiscoverScreenView>, RouteAware {
  @override
  bool get wantKeepAlive => true;
  TextEditingController searchBarController = TextEditingController();
  List<TrendingBooksWorks?>? items = [];
  bool isConnected = true;
  bool isLoading = true;
  final customCacheManager = CacheManager(
    Config("customCacheKey",
        maxNrOfCacheObjects: 25, stalePeriod: const Duration(days: 15)),
  );
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getTrendingBooks();
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPush() {
    super.didPush();
    // Log when the screen is pushed
    AnalyticsService().firebaseAnalytics.logScreenView(
          screenName: "DiscoverScreen",
        );
  }

  Future<void> getTrendingBooks() async {
    isConnected = ref.read(connectivityProvider).isConnected;

    setState(() {
      isLoading = true;
    });
    try {
      if (isConnected == true) {
        items = await ref
            .read(booksProvider)
            .getTrendingBooks("monthly", 1, context)
            .whenComplete(() {
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        });
      } else {
        items = [];
        internetConnectionErrorDialog(context, false);
      }
    } catch (e) {
      if (mounted) errorSnackBar(context, e.toString());
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
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
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            toolbarHeight: Const.screenSize.height * 0.12,
            flexibleSpace: FlexibleSpaceBar(
              background: searchBarBuilder(),
            ),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25))),
          ),
          scrollableTrendingBuilder(context),
          const CategoriesView()
        ],
      ),
    ));
  }

  Widget searchBarBuilder() {
    return Column(
      children: [
        SizedBox(
          height: Const.screenSize.height * 0.04,
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onEditingComplete: () {
                    FocusScopeNode currentFocus = FocusScope.of(context);
                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchScreenView(
                              searchValue: searchBarController.text),
                        ));
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
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchScreenView(
                                  searchValue: searchBarController.text),
                            ));
                      }),
                      icon: const Icon(
                        Icons.search,
                        size: 35,
                        color: Color(0xFF1B7695),
                      ),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  SliverToBoxAdapter scrollableTrendingBuilder(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.trendings,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.height / 40,
                    ),
                  ),
                  TextButton(
                      child: Text(
                        AppLocalizations.of(context)!.more,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.height / 60,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return const TrendingBooksView(
                              date: "Monthly",
                            );
                          },
                        ));
                      })
                ],
              ),
            ),
            if (isLoading == true && isConnected == true)
              categoriesViewShimmerEffect(),
            if (isConnected == false) trendingErrorWidget(context),
            if (isLoading == false && isConnected == true)
              trendingBooksWidget(),
            Text(
              AppLocalizations.of(context)!.categories,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.of(context).size.height / 40,
              ),
            ),
            const SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }

  Center trendingErrorWidget(BuildContext context) {
    return Center(
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text(
          AppLocalizations.of(context)!.anErrorOccurred,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.height / 50,
          ),
        ),
        Text(
          AppLocalizations.of(context)!.clickToRefresh,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.height / 50,
          ),
        ),
        IconButton(
            color: Theme.of(context).primaryColor,
            iconSize: 30,
            onPressed: () async {
              isConnected = ref.read(connectivityProvider).isConnected;
              setState(() {
                isLoading = true;
              });
              getTrendingBooks();
            },
            icon: const Icon(Icons.refresh_sharp))
      ]),
    );
  }

  SizedBox trendingBooksWidget() {
    return SizedBox(
        height: MediaQuery.of(context).size.height / 4.7,
        width: double.infinity,
        child: ListView.builder(
            physics: const ClampingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: items != null ? items?.length : 5,
            itemBuilder: (context, index) {
              return SizedBox(
                width: 120,
                child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () {
                      if (items != null) {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return BookInfoView(trendingBook: items?[index]);
                          },
                        ));
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
                      child: Column(
                        children: [
                          Expanded(
                            flex: 10,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: items?[index]?.coverI != null
                                  ? CachedNetworkImage(
                                      fit: BoxFit.fill,
                                      width: Const.screenSize.width * 0.2,
                                      imageUrl:
                                          "https://covers.openlibrary.org/b/id/${items?[index]?.coverI}-M.jpg",
                                      placeholder: (context, url) => ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Transform.scale(
                                          scale: 0.3,
                                          child: const Center(
                                              child:
                                                  CircularProgressIndicator()),
                                        ),
                                      ),
                                      cacheManager: customCacheManager,
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                              "lib/assets/images/error.png"),
                                    )
                                  : Image.asset(
                                      "lib/assets/images/error.png",
                                      width: Const.screenSize.width * 0.2,
                                    ),
                            ),
                          ),
                          const Spacer(),
                          Expanded(
                            flex: 4,
                            child: items != null
                                ? Text(
                                    items![index]!.title!,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.height /
                                                60),
                                  )
                                : const SizedBox.shrink(),
                          )
                        ],
                      ),
                    )),
              );
            }));
  }
}
