import 'package:book_tracker/models/quote_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuoteState {
  final Map<String, Quote> trendingQuotes;
  final Map<String, Quote> recentQuotes;
  final bool isTrendingLoading;
  final bool isRecentLoading;

  QuoteState(
      {required this.trendingQuotes,
      required this.recentQuotes,
      this.isTrendingLoading = false,
      this.isRecentLoading = false});

  QuoteState copyWith(
      {Map<String, Quote>? trendingQuotes,
      Map<String, Quote>? recentQuotes,
      bool? isRecentLoading,
      bool? isTrendingLoading}) {
    return QuoteState(
        trendingQuotes: trendingQuotes ??
            this
                .trendingQuotes, // Eğer quotes verilmemişse mevcut quotes'u kullan
        isRecentLoading: isRecentLoading ??
            this.isRecentLoading, // Eğer isLoading verilmemişse mevcut isLoading'i kullan
        isTrendingLoading: isTrendingLoading ?? this.isTrendingLoading,
        recentQuotes: recentQuotes ?? this.recentQuotes);
  }
}

// StateNotifier ile Quote listesini yöneten sınıf
class QuotesNotifier extends StateNotifier<QuoteState> {
  bool isLoading = false;
  QuotesNotifier()
      : super(QuoteState(
            recentQuotes: {},
            trendingQuotes: {},
            isTrendingLoading: false,
            isRecentLoading: false));

  // Firebase'den quote verilerini çekme fonksiyonu
  Future<void> fetchTrendingQuotes() async {
    isLoading = true;
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('quotes')
          .orderBy("likeCount", descending: true)
          .get(); // 'quotes' koleksiyonunu alıyoruz

      // Quote modeline dönüştürüp state'i güncelliyoruz
      Map<String, Quote> trendingQuotes = {};
      print(querySnapshot.docs.length);
      querySnapshot.docs.forEach((doc) {
        print(doc.data());
        trendingQuotes.addAll({(doc.id): Quote.fromJson(doc.data())});
      });
      print(trendingQuotes.length);

      state = QuoteState(
          trendingQuotes: trendingQuotes,
          recentQuotes: state.recentQuotes,
          isTrendingLoading: false,
          isRecentLoading: state.isRecentLoading); // State'i güncelle
    } catch (e) {
      // Hata durumunu yönet
      print("Error fetching quotes: $e");
    } finally {
      isLoading = false; // Yükleme tamamlandığında false yap
    }
  }

  Future<void> fetchRecentQuotes() async {
    isLoading = true;
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('quotes')
          .orderBy("date", descending: true)
          .get(); // 'quotes' koleksiyonunu alıyoruz

      // Quote modeline dönüştürüp state'i güncelliyoruz
      Map<String, Quote> quotes = {};
      print(querySnapshot.docs.length);
      querySnapshot.docs.forEach((doc) {
        print(doc.data());
        quotes.addAll({(doc.id): Quote.fromJson(doc.data())});
      });
      print(quotes.length);

      state = QuoteState(
          recentQuotes: quotes,
          trendingQuotes: state.trendingQuotes,
          isTrendingLoading: false,
          isRecentLoading: state.isRecentLoading); // State'i güncelle
    } catch (e) {
      // Hata durumunu yönet
      print("Error fetching quotes: $e");
    } finally {
      isLoading = false; // Yükleme tamamlandığında false yap
    }
  }

  void updateLikedQuote(String quoteId, bool isTrendingQuotes) {
    Map<String, Quote>? trendingQuotesList = state.trendingQuotes;
    Map<String, Quote>? recentQuotesList = state.recentQuotes;
    bool isQuoteExist = isTrendingQuotes
        ? trendingQuotesList[quoteId] != null
            ? true
            : false
        : recentQuotesList[quoteId] != null
            ? true
            : false;

    if (FirebaseAuth.instance.currentUser != null && isQuoteExist) {
      //if quote exists and is trendingquotes then do the changes on trendingquotes
      if (isTrendingQuotes) {
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
      else {
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
    }
  }
}

final quotesProvider = StateNotifierProvider<QuotesNotifier, QuoteState>((ref) {
  return QuotesNotifier();
});
