import 'package:book_tracker/databases/firestore_database.dart';
import 'package:book_tracker/models/quote_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuoteState {
  final Map<String, Quote> trendingQuotes;
  final Map<String, Quote> currentUsersQuotes;
  final Map<String, Quote> recentQuotes;
  final bool isTrendingLoading;
  final bool isRecentLoading;
  final bool isUsersQuotesLoading;

  QuoteState(
      {required this.trendingQuotes,
      required this.recentQuotes,
      this.isTrendingLoading = true,
      this.isRecentLoading = true,
      required this.currentUsersQuotes,
      this.isUsersQuotesLoading = true});

  QuoteState copyWith(
      {Map<String, Quote>? trendingQuotes,
      Map<String, Quote>? recentQuotes,
      Map<String, Quote>? currentUsersQuotes,
      bool? isRecentLoading,
      bool? isTrendingLoading,
      bool? isUsersQuotesLoading}) {
    return QuoteState(
        trendingQuotes: trendingQuotes ??
            this
                .trendingQuotes, // Eğer quotes verilmemişse mevcut quotes'u kullan
        isRecentLoading: isRecentLoading ??
            this
                .isRecentLoading, // Eğer isLoading verilmemişse mevcut isLoading'i kullan
        isTrendingLoading: isTrendingLoading ?? this.isTrendingLoading,
        recentQuotes: recentQuotes ?? this.recentQuotes,
        currentUsersQuotes: currentUsersQuotes ?? this.currentUsersQuotes,
        isUsersQuotesLoading:
            isUsersQuotesLoading ?? this.isUsersQuotesLoading);
  }
}

// StateNotifier ile Quote listesini yöneten sınıf
class QuotesNotifier extends StateNotifier<QuoteState> {
  QuotesNotifier()
      : super(QuoteState(
            recentQuotes: {},
            trendingQuotes: {},
            isTrendingLoading: true,
            isRecentLoading: true,
            currentUsersQuotes: {},
            isUsersQuotesLoading: true));

  // Firebase'den quote verilerini çekme fonksiyonu
  Future<void> fetchTrendingQuotes() async {
    try {
      state = state.copyWith(isTrendingLoading: true);
      final querySnapshot = await FirebaseFirestore.instance
          .collection('quotes')
          .orderBy("likeCount", descending: true)
          .get(); // 'quotes' koleksiyonunu alıyoruz

      // Quote modeline dönüştürüp state'i güncelliyoruz
      Map<String, Quote> trendingQuotes = {};
      querySnapshot.docs.forEach((doc) {
        trendingQuotes.addAll({(doc.id): Quote.fromJson(doc.data())});
      });

      state = state.copyWith(
          trendingQuotes: trendingQuotes,
          isTrendingLoading: false); // State'i güncelle
    } catch (e) {
      state = state.copyWith(isTrendingLoading: false);
    }
  }

  Future<void> clearQuotes() async {
    state = state.copyWith(recentQuotes: {}, trendingQuotes: {});
  }

  Future<void> fetchRecentQuotes() async {
    try {
      state = state.copyWith(isRecentLoading: true);
      final querySnapshot = await FirebaseFirestore.instance
          .collection('quotes')
          .orderBy("date", descending: true)
          .get(); // 'quotes' koleksiyonunu alıyoruz

      // Quote modeline dönüştürüp state'i güncelliyoruz
      Map<String, Quote> quotes = {};
      querySnapshot.docs.forEach((doc) {
        quotes.addAll({(doc.id): Quote.fromJson(doc.data())});
      });

      state = state.copyWith(
          recentQuotes: quotes, isRecentLoading: false); // State'i güncelle
    } catch (e) {
      // Hata durumunu yönet
      state = state.copyWith(isRecentLoading: false);
    }
  }

  Future<void> fetchCurrentUsersQuotes() async {
    state = state.copyWith(isUsersQuotesLoading: true);
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('quotes')
          .where("userId", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .orderBy("date", descending: true)
          .get(); // 'quotes' koleksiyonunu alıyoruz

      // Quote modeline dönüştürüp state'i güncelliyoruz
      Map<String, Quote> currentUsersQuotes = {};
      querySnapshot.docs.forEach((doc) {
        currentUsersQuotes.addAll({(doc.id): Quote.fromJson(doc.data())});
      });

      state = state.copyWith(
          currentUsersQuotes: currentUsersQuotes,
          isUsersQuotesLoading: false); // State'i güncelle
    } catch (e) {
      // Hata durumunu yönet
    }
  }

  Future<bool> deleteQuote(String quoteId) async {
    Map<String, Quote> currentUsersQuotes = state.currentUsersQuotes;
    Map<String, Quote> trendingQuotes = state.trendingQuotes;
    Map<String, Quote> recentQuotes = state.recentQuotes;
    try {
      if (state.recentQuotes[quoteId] != null) {
        recentQuotes.remove(quoteId);
        state = state.copyWith(recentQuotes: recentQuotes);
      }
      if (state.currentUsersQuotes[quoteId] != null) {
        currentUsersQuotes.remove(quoteId);
        state = state.copyWith(currentUsersQuotes: currentUsersQuotes);
      }
      if (state.trendingQuotes[quoteId] != null) {
        trendingQuotes.remove(quoteId);
        state = state.copyWith(trendingQuotes: trendingQuotes);
      }
      FirestoreDatabase().deleteQuote(quoteId);
      return true;
    } catch (e) {
      // Hata durumunu yönet
      return false;
    }
  }

  void updateLikedQuote(String quoteId, bool? isTrendingQuotes) {
    Map<String, Quote>? trendingQuotesList = state.trendingQuotes;
    Map<String, Quote>? recentQuotesList = state.recentQuotes;
    Map<String, Quote>? currentUsersQuotes = state.currentUsersQuotes;

    bool isQuoteExist = isTrendingQuotes != null
        ? isTrendingQuotes == true
            ? trendingQuotesList[quoteId] != null
                ? true
                : false
            : recentQuotesList[quoteId] != null
                ? true
                : false
        : currentUsersQuotes[quoteId] != null
            ? true
            : false;

    if (FirebaseAuth.instance.currentUser != null && isQuoteExist) {
      //if quote exists and is trendingquotes then do the changes on trendingquotes
      if (isTrendingQuotes == true) {
        if (!state.trendingQuotes[quoteId]!.likes!
            .contains(FirebaseAuth.instance.currentUser!.uid)) {
          trendingQuotesList[quoteId]!
              .likes
              ?.add(FirebaseAuth.instance.currentUser!.uid);
          state = state.copyWith(trendingQuotes: trendingQuotesList);
        } else {
          trendingQuotesList[quoteId]!
              .likes
              ?.remove(FirebaseAuth.instance.currentUser!.uid);
          state = state.copyWith(trendingQuotes: trendingQuotesList);
        }
      }
      //if quote exists and is not trendingquotes then its recentquotes and do the changes on recentquotes
      else if (isTrendingQuotes == false) {
        if (!state.recentQuotes[quoteId]!.likes!
            .contains(FirebaseAuth.instance.currentUser!.uid)) {
          recentQuotesList[quoteId]!
              .likes
              ?.add(FirebaseAuth.instance.currentUser!.uid);
          state = state.copyWith(recentQuotes: recentQuotesList);
        } else {
          recentQuotesList[quoteId]!
              .likes
              ?.remove(FirebaseAuth.instance.currentUser!.uid);
          state = state.copyWith(recentQuotes: recentQuotesList);
        }
      }
      //if quote exists and istrendingquotes is null then its currentusersquotes and do the changes on currentusersquotes
      else {
        if (!state.currentUsersQuotes[quoteId]!.likes!
            .contains(FirebaseAuth.instance.currentUser!.uid)) {
          currentUsersQuotes[quoteId]!
              .likes
              ?.add(FirebaseAuth.instance.currentUser!.uid);
          state = state.copyWith(currentUsersQuotes: currentUsersQuotes);
        } else {
          currentUsersQuotes[quoteId]!
              .likes
              ?.remove(FirebaseAuth.instance.currentUser!.uid);
          state = state.copyWith(currentUsersQuotes: currentUsersQuotes);
        }
      }
    }
  }

  Future<void> clearMyQuotes() async {
    try {
      state = state.copyWith(currentUsersQuotes: {});
    } catch (e) {
      // Hata durumunu yönet
    }
  }
}

final quotesProvider = StateNotifierProvider<QuotesNotifier, QuoteState>((ref) {
  return QuotesNotifier();
});
