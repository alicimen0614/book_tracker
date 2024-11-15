import 'dart:async';
import 'package:book_tracker/databases/firestore_database.dart';
import 'package:book_tracker/models/quote_model.dart';
import 'package:book_tracker/providers/connectivity_provider.dart';
import 'package:book_tracker/providers/quotes_state_provider.dart';
import 'package:book_tracker/screens/auth_screen/auth_view.dart';
import 'package:book_tracker/screens/home_screen/home_screen_shimmer/quote_widget_shimmer.dart';
import 'package:book_tracker/screens/library_screen/books_list_view.dart';
import 'package:book_tracker/widgets/books_list_error.dart';
import 'package:book_tracker/widgets/quote_widget.dart';
import 'package:book_tracker/widgets/custom_alert_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuotesScreen extends ConsumerStatefulWidget {
  const QuotesScreen({super.key});

  @override
  ConsumerState<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends ConsumerState<QuotesScreen> {
  Map<String, Timer?> debounceTimers = {}; // Her post için bir zamanlayıcı
  Map<String, bool> pendingLikeStatus = {}; // Son beğeni durumu (beğeni/yok)

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(quotesProvider).trendingQuotes.isEmpty) {
        ref.read(quotesProvider.notifier).fetchTrendingQuotes();
      }
      if (ref.read(quotesProvider).recentQuotes.isEmpty) {
        ref.read(quotesProvider.notifier).fetchRecentQuotes();
      }
    });

    super.initState();
  }

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
                    tooltip: "Yeni Alıntı Ekle",
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
                  title: const Text("Alıntılar"),
                  bottom: const TabBar(
                    tabAlignment: TabAlignment.fill,
                    unselectedLabelColor: Colors.white60,
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelStyle: TextStyle(
                      fontSize: 15,
                      fontFamily: "Nunito Sans",
                      fontWeight: FontWeight.bold,
                    ),
                    tabs: [
                      Tab(
                          text: "Trendler",
                          icon: Icon(Icons.trending_up_rounded)),
                      Tab(
                          text: "En Yeni",
                          icon: Icon(Icons.access_time_rounded))
                    ],
                    indicatorWeight: 5,
                  ),
                ),
              ];
            },
            body: TabBarView(children: [
              ref.watch(quotesProvider).trendingQuotes.isNotEmpty &&
                      ref.watch(quotesProvider).isTrendingLoading == false
                  ? quotesBuilder(true)
                  : ref.watch(quotesProvider).trendingQuotes.isEmpty &&
                          ref.watch(quotesProvider).isTrendingLoading == true
                      ? quotesShimmerBuilder(true)
                      : ref.read(connectivityProvider).isConnected == true
                          ? booksListError(false, context, () {
                              if (ref.read(connectivityProvider).isConnected ==
                                  true) {
                                ref
                                    .read(quotesProvider.notifier)
                                    .fetchRecentQuotes();
                                ref
                                    .read(quotesProvider.notifier)
                                    .fetchTrendingQuotes();
                              }
                            })
                          : booksListError(true, context, () {
                              if (ref.read(connectivityProvider).isConnected ==
                                  true) {
                                ref
                                    .read(quotesProvider.notifier)
                                    .fetchRecentQuotes();
                                ref
                                    .read(quotesProvider.notifier)
                                    .fetchTrendingQuotes();
                              }
                            }),
              ref.watch(quotesProvider).recentQuotes.isNotEmpty &&
                      ref.watch(quotesProvider).isRecentLoading == false
                  ? quotesBuilder(false)
                  : ref.watch(quotesProvider).recentQuotes.isEmpty &&
                          ref.watch(quotesProvider).isRecentLoading == true
                      ? quotesShimmerBuilder(true)
                      : ref.read(connectivityProvider).isConnected == true
                          ? booksListError(false, context, () {
                              if (ref.read(connectivityProvider).isConnected ==
                                  true) {
                                ref
                                    .read(quotesProvider.notifier)
                                    .fetchRecentQuotes();
                                ref
                                    .read(quotesProvider.notifier)
                                    .fetchTrendingQuotes();
                              }
                            })
                          : booksListError(true, context, () {
                              if (ref.read(connectivityProvider).isConnected ==
                                  true) {
                                ref
                                    .read(quotesProvider.notifier)
                                    .fetchRecentQuotes();
                                ref
                                    .read(quotesProvider.notifier)
                                    .fetchTrendingQuotes();
                              }
                            }),
            ])),
      ),
    );
  }

  RefreshIndicator quotesBuilder(bool isTrendingQuotes) {
    Map<String, Quote> readQuotesList = isTrendingQuotes
        ? ref.read(quotesProvider).trendingQuotes
        : ref.read(quotesProvider).recentQuotes;
    Map<String, Quote> watchQuotesList = isTrendingQuotes
        ? ref.watch(quotesProvider).trendingQuotes
        : ref.watch(quotesProvider).recentQuotes;
    return RefreshIndicator(
      onRefresh: () {
        ref.read(quotesProvider.notifier).clearQuotes();
        ref.read(quotesProvider.notifier).fetchTrendingQuotes();
        return ref.read(quotesProvider.notifier).fetchRecentQuotes();
      },
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 10),
        separatorBuilder: (context, index) => Divider(
          color: Colors.grey.shade400,
          endIndent: 10,
          indent: 10,
          height: 20,
        ),
        itemCount: watchQuotesList.length,
        itemBuilder: (context, index) {
          final quoteId = watchQuotesList.keys.toList()[index];
          return QuoteWidget(
              onDoubleTap: () {
                print("doubletap");
                likePost(quoteId, index, isTrendingQuotes);
              },
              quote: readQuotesList[quoteId]!,
              quoteId: quoteId,
              isTrendingQuotes: isTrendingQuotes,
              onPressedLikeButton: () {
                print("doubletap");
                likePost(quoteId, index, isTrendingQuotes);
              });
        },
      ),
    );
  }

  ListView quotesShimmerBuilder(bool isTrendingQuotes) {
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

  void likePost(String quoteId, int index, bool isTrendingQuotes) {
    if (FirebaseAuth.instance.currentUser != null) {
      // UI'yi anında güncelle
      updateUILikeStatus(quoteId, index, isTrendingQuotes);

      // Son beğeni durumu kaydet
      pendingLikeStatus[quoteId] = isTrendingQuotes
          ? ref
              .read(quotesProvider)
              .trendingQuotes[quoteId]!
              .likes!
              .contains(FirebaseAuth.instance.currentUser!.uid)
          : ref
              .read(quotesProvider)
              .recentQuotes[quoteId]!
              .likes!
              .contains(FirebaseAuth.instance.currentUser!.uid);

      // Eğer zaten bir zamanlayıcı varsa onu iptal et
      debounceTimers[quoteId]?.cancel();

      // Yeni bir zamanlayıcı başlat (örneğin 3 saniye sonra Firebase'e gönder)
      debounceTimers[quoteId] = Timer(const Duration(seconds: 3), () {
        FirestoreDatabase()
            .commitLikeToFirebase(quoteId, pendingLikeStatus[quoteId], context);

        debounceTimers.remove(quoteId);
        pendingLikeStatus.remove(quoteId);
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
          description:
              "Bir gönderiyi beğenebilmek için giriş yapmış olmalısınız.",
          secondButtonOnPressed: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const AuthView(formStatusData: FormStatus.register),
                ));
          },
          secondButtonText: "Kayıt Ol",
          thirdButtonOnPressed: () {
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const AuthView(formStatusData: FormStatus.signIn),
                ));
          },
          thirdButtonText: "Giriş Yap",
          firstButtonOnPressed: () {
            Navigator.pop(context);
          },
          firstButtonText: "Kapat",
        );
      },
    );
  }
}
