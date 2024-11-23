import 'dart:async';
import 'package:book_tracker/databases/firestore_database.dart';
import 'package:book_tracker/providers/connectivity_provider.dart';
import 'package:book_tracker/providers/quotes_provider.dart';
import 'package:book_tracker/screens/auth_screen/auth_view.dart';
import 'package:book_tracker/screens/home_screen/home_screen_shimmer/quote_widget_shimmer.dart';
import 'package:book_tracker/screens/library_screen/books_list_view.dart';
import 'package:book_tracker/widgets/books_list_error.dart';
import 'package:book_tracker/widgets/no_items_found_indicator_builder.dart';
import 'package:book_tracker/widgets/quote_widget.dart';
import 'package:book_tracker/widgets/custom_alert_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class QuotesScreen extends ConsumerStatefulWidget {
  const QuotesScreen({super.key});

  @override
  ConsumerState<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends ConsumerState<QuotesScreen> {
  Map<String, Timer?> debounceTimers = {}; // Her post için bir zamanlayıcı
  Map<String, bool> pendingLikeStatus = {}; // Son beğeni durumu (beğeni/yok)

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        body: NestedScrollView(
            floatHeaderSlivers: true,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  leading: IconButton(
                    tooltip: AppLocalizations.of(context)!.addQuote,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_sharp,
                      size: 30,
                    ),
                  ),
                  actions: [
                    if (FirebaseAuth.instance.currentUser != null)
                      IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const BooksListView(isNotes: false)));
                          },
                          icon: const Icon(
                            Icons.add,
                            size: 30,
                          ))
                  ],
                  expandedHeight: 150,
                  pinned: true,
                  floating: true,
                  title: Text(AppLocalizations.of(context)!.quotes),
                  bottom: TabBar(
                    tabAlignment: TabAlignment.fill,
                    unselectedLabelColor: Colors.white60,
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelStyle: const TextStyle(
                      fontSize: 15,
                      fontFamily: "Nunito Sans",
                      fontWeight: FontWeight.bold,
                    ),
                    tabs: [
                      Tab(
                          text: AppLocalizations.of(context)!.trendings,
                          icon: const Icon(Icons.trending_up_rounded)),
                      Tab(
                          text: AppLocalizations.of(context)!.newest,
                          icon: const Icon(Icons.access_time_rounded))
                    ],
                    indicatorWeight: 5,
                  ),
                ),
              ];
            },
            body: TabBarView(children: [
              quotesBuilder(true),
              quotesBuilder(false),
            ])),
      ),
    );
  }

  RefreshIndicator quotesBuilder(bool isTrendingQuotes) {
    PagingController<DocumentSnapshot?, QuoteEntry> currentPagingController =
        isTrendingQuotes
            ? ref.read(quotesProvider.notifier).trendingPagingController
            : ref.read(quotesProvider.notifier).recentPagingController;
    return RefreshIndicator(
        onRefresh: () async {
          ref.read(quotesProvider.notifier).recentPagingController.refresh();
          return ref
              .read(quotesProvider.notifier)
              .trendingPagingController
              .refresh();
        },
        child: PagedListView.separated(
          pagingController: currentPagingController,
          padding: const EdgeInsets.symmetric(vertical: 10),
          separatorBuilder: (context, index) => Divider(
            color: Colors.grey.shade400,
            endIndent: 10,
            indent: 10,
            height: 20,
          ),
          builderDelegate: PagedChildBuilderDelegate(
            noItemsFoundIndicatorBuilder: (context) {
              return noItemsFoundIndicatorBuilder(
                  MediaQuery.of(context).size.width, context);
            },
            firstPageErrorIndicatorBuilder: (context) {
              if (!ref.read(connectivityProvider).isConnected) {
                return booksListError(
                  true,
                  context,
                  () {
                    currentPagingController.retryLastFailedRequest();
                  },
                );
              } else {
                return booksListError(false, context, () {
                  currentPagingController.retryLastFailedRequest();
                });
              }
            },
            firstPageProgressIndicatorBuilder: (context) {
              return Column(
                children: List.generate(
                  5,
                  (index) => Column(
                    children: [
                      quoteWidgetShimmer(context),
                      if (index != 4)
                        Divider(
                          color: Colors.grey.shade400,
                          endIndent: 10,
                          indent: 10,
                          height: 20,
                        ),
                    ],
                  ),
                ),
              );
            },
            itemBuilder: (context, QuoteEntry quoteEntry, index) {
              return QuoteWidget(
                  onDoubleTap: () {
                    likePost(quoteEntry, index, isTrendingQuotes);
                  },
                  quote: quoteEntry.quote,
                  quoteId: quoteEntry.id,
                  isTrendingQuotes: isTrendingQuotes,
                  onPressedLikeButton: () {
                    likePost(quoteEntry, index, isTrendingQuotes);
                  });
            },
          ),
        ));
  }

  ListView quotesShimmerBuilder() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 10),
      separatorBuilder: (context, index) => Divider(
        color: Colors.grey.shade400,
        endIndent: 10,
        indent: 10,
        height: 20,
      ),
      itemCount: 5,
      itemBuilder: (context, index) {
        return quoteWidgetShimmer(context);
      },
    );
  }

  void likePost(QuoteEntry quoteEntry, int index, bool isTrendingQuotes) {
    if (FirebaseAuth.instance.currentUser != null) {
      // UI'yi anında güncelle
      updateUILikeStatus(quoteEntry.id, index, isTrendingQuotes);

      // Son beğeni durumu kaydet
      pendingLikeStatus[quoteEntry.id] = pendingLikeStatus[quoteEntry.id] =
          quoteEntry.quote.likes!
              .contains(FirebaseAuth.instance.currentUser!.uid);

      // Eğer zaten bir zamanlayıcı varsa onu iptal et
      debounceTimers[quoteEntry.id]?.cancel();

      // Yeni bir zamanlayıcı başlat (örneğin 3 saniye sonra Firebase'e gönder)
      debounceTimers[quoteEntry.id] = Timer(const Duration(seconds: 3), () {
        FirestoreDatabase().commitLikeToFirebase(
            quoteEntry.id, pendingLikeStatus[quoteEntry.id], context);

        debounceTimers.remove(quoteEntry.id);
        pendingLikeStatus.remove(quoteEntry.id);
      });
    } else {
      showSignUpDialog();
    }
  }

  void updateUILikeStatus(String quoteId, index, bool isTrendingQuotes) {
    ref
        .read(quotesProvider.notifier)
        .updateLikedQuote(quoteId, isTrendingQuotes);
  }

  void showSignUpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return CustomAlertDialog(
          title: "VastReads",
          description: AppLocalizations.of(context)!.loginToLikePost,
          secondButtonOnPressed: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const AuthView(formStatusData: FormStatus.register),
                ));
          },
          secondButtonText: AppLocalizations.of(context)!.signUp,
          thirdButtonOnPressed: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const AuthView(formStatusData: FormStatus.signIn),
                )).then(
              (value) {
                setState(() {});
              },
            );
          },
          thirdButtonText: AppLocalizations.of(context)!.signIn,
          firstButtonOnPressed: () {
            Navigator.pop(context);
          },
          firstButtonText: AppLocalizations.of(context)!.close,
        );
      },
    );
  }
}
