import 'dart:async';
import 'package:book_tracker/databases/firestore_database.dart';
import 'package:book_tracker/main.dart';
import 'package:book_tracker/providers/quotes_provider.dart';
import 'package:book_tracker/screens/auth_screen/auth_view.dart';
import 'package:book_tracker/screens/home_screen/home_screen_shimmer/quote_widget_shimmer.dart';
import 'package:book_tracker/screens/library_screen/books_list_view.dart';
import 'package:book_tracker/services/analytics_service.dart';
import 'package:book_tracker/widgets/quote_widget.dart';
import 'package:book_tracker/widgets/custom_alert_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_tracker/l10n/app_localizations.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class MyQuotesView extends ConsumerStatefulWidget {
  const MyQuotesView({super.key});

  @override
  ConsumerState<MyQuotesView> createState() => _QuotesViewState();
}

class _QuotesViewState extends ConsumerState<MyQuotesView> with RouteAware {
  Map<String, Timer?> debounceTimers = {}; // Her post için bir zamanlayıcı
  Map<String, bool> pendingLikeStatus = {}; // Son beğeni durumu (beğeni/yok)

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
          screenName: "MyQuotesScreen",
        );
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.myQuotes),
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
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            ref
                .read(quotesProvider.notifier)
                .currentUsersPagingController
                .refresh();
          },
          child: FirebaseAuth.instance.currentUser != null
              ? PagedListView.separated(
                  pagingController: ref
                      .read(quotesProvider.notifier)
                      .currentUsersPagingController,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  separatorBuilder: (context, index) => Divider(
                        color: Colors.grey.shade400,
                        endIndent: 10,
                        indent: 10,
                        height: 20,
                      ),
                  builderDelegate: PagedChildBuilderDelegate(
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
                    noItemsFoundIndicatorBuilder: (context) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              "lib/assets/images/nonotesfound.png",
                              width: MediaQuery.of(context).size.height / 1.5,
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.width / 10,
                            ),
                            Center(
                              child: Text(
                                FirebaseAuth.instance.currentUser != null
                                    ? AppLocalizations.of(context)!.noQuoteAdded
                                    : AppLocalizations.of(context)!
                                        .loginToAddQuote,
                                style: const TextStyle(fontSize: 20),
                                textAlign: TextAlign.center,
                              ),
                            )
                          ],
                        ),
                      );
                    },
                    itemBuilder: (context, QuoteEntry quoteEntry, index) {
                      return QuoteWidget(
                          isTrendingQuotes: null,
                          quote: quoteEntry.quote,
                          onDoubleTap: () {
                            likePost(quoteEntry, index);
                          },
                          quoteId: quoteEntry.id,
                          onPressedLikeButton: () {
                            likePost(quoteEntry, index);
                          });
                    },
                  ))
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "lib/assets/images/nonotesfound.png",
                        width: MediaQuery.of(context).size.height / 1.5,
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.width / 10,
                      ),
                      Center(
                        child: Text(
                          FirebaseAuth.instance.currentUser != null
                              ? AppLocalizations.of(context)!.noQuoteAdded
                              : AppLocalizations.of(context)!.loginToAddQuote,
                          style: const TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                      )
                    ],
                  ),
                ),
        ));
  }

  void likePost(
    QuoteEntry quoteEntry,
    int index,
  ) {
    if (FirebaseAuth.instance.currentUser != null) {
      // UI'yi anında güncelle
      updateUILikeStatus(quoteEntry.id, index);

      // Son beğeni durumu kaydet
      pendingLikeStatus[quoteEntry.id] = pendingLikeStatus[quoteEntry.id] =
          quoteEntry.quote.likes!
              .contains(FirebaseAuth.instance.currentUser!.uid);

      // Eğer zaten bir zamanlayıcı varsa onu iptal et
      debounceTimers[quoteEntry.id]?.cancel();

      // Yeni bir zamanlayıcı başlat (örneğin 3 saniye sonra Firebase'e gönder)
      debounceTimers[quoteEntry.id] = Timer(const Duration(seconds: 3), () {
        _commitLikeSafely(quoteEntry.id);
      });
    } else {
      showSignUpDialog();
    }
  }

  void updateUILikeStatus(String quoteId, index) {
    ref.read(quotesProvider.notifier).updateLikedQuote(quoteId, null);
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
  
   Future<void> _commitLikeSafely(String quoteId) async {
  await FirestoreDatabase().commitLikeToFirebase(
      quoteId, pendingLikeStatus[quoteId]);


  debounceTimers.remove(quoteId);
  pendingLikeStatus.remove(quoteId);
} 
}
