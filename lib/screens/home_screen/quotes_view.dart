import 'dart:async';

import 'package:book_tracker/const.dart';
import 'package:book_tracker/databases/firestore_database.dart';
import 'package:book_tracker/models/quote_model.dart';
import 'package:book_tracker/providers/quotes_state_provider.dart';
import 'package:book_tracker/widgets/quote_widget.dart';
import 'package:book_tracker/widgets/sign_up_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuotesView extends ConsumerStatefulWidget {
  const QuotesView({super.key});

  @override
  ConsumerState<QuotesView> createState() => _QuotesViewState();
}

class _QuotesViewState extends ConsumerState<QuotesView> {
  Map<String, Timer?> debounceTimers = {}; // Her post için bir zamanlayıcı
  Map<String, bool> pendingLikeStatus = {}; // Son beğeni durumu (beğeni/yok)
  Map<String, Quote> quotes = {};
  bool isLoading = false;
  @override
  void initState() {
    if (ref.read(quotesProvider).currentUsersQuotes != {}) {
      ref.read(quotesProvider.notifier).fetchCurrentUsersQuotes();
      quotes = ref.read(quotesProvider).currentUsersQuotes;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Alıntılarım"),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(quotesProvider.notifier).fetchCurrentUsersQuotes();
          quotes = ref.read(quotesProvider).currentUsersQuotes;
        },
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 10),
          separatorBuilder: (context, index) => Divider(
            color: Colors.grey.shade400,
            endIndent: 10,
            indent: 10,
            height: 20,
          ),
          itemCount: quotes.length,
          itemBuilder: (context, index) {
            final quoteId = quotes.keys.toList()[index];
            int likeCount = quotes[quoteId]!.likes!.length;
            bool isUserLikedQuote = FirebaseAuth.instance.currentUser != null
                ? quotes[quoteId]!
                    .likes!
                    .contains(FirebaseAuth.instance.currentUser!.uid)
                : false;
            String text = quotes[quoteId]!.quoteText!;
            var textHeight = calculateTextHeight(
                text,
                TextStyle(
                  fontSize: MediaQuery.of(context).size.height / 55,
                ),
                Const.screenSize.width - 100);

            return isLoading == false
                ? QuoteWidget(
                    isTrendingQuotes: null,
                    quote: quotes[quoteId]!,
                    onDoubleTap: () {
                      print("doubletap");
                      likePost(quoteId, index);
                    },
                    quoteId: quoteId,
                    onPressedLikeButton: () {
                      print("doubletap");
                      likePost(quoteId, index);
                    })
                : const Align(
                    alignment: Alignment.center,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
          },
        ),
      ),
    );
  }

  void likePost(
    String quoteId,
    int index,
  ) {
    if (FirebaseAuth.instance.currentUser != null) {
      // UI'yi anında güncelle
      updateUILikeStatus(quoteId, index);

      // Son beğeni durumu kaydet
      pendingLikeStatus[quoteId] = ref
          .read(quotesProvider)
          .currentUsersQuotes[quoteId]!
          .likes!
          .contains(FirebaseAuth.instance.currentUser!.uid);

      // Eğer zaten bir zamanlayıcı varsa onu iptal et
      debounceTimers[quoteId]?.cancel();

      // Yeni bir zamanlayıcı başlat (örneğin 3 saniye sonra Firebase'e gönder)
      debounceTimers[quoteId] = Timer(const Duration(seconds: 3), () {
        FirestoreDatabase()
            .commitLikeToFirebase(quoteId, pendingLikeStatus[quoteId]);

        debounceTimers.remove(quoteId);
        pendingLikeStatus.remove(quoteId);
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
        return const SignUpDialog();
      },
    );
  }
}
