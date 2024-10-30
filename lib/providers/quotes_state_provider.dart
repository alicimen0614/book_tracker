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
      this.isTrendingLoading = false,
      this.isRecentLoading = false,
      required this.currentUsersQuotes,
      this.isUsersQuotesLoading = false});

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
  bool isLoading = false;
  QuotesNotifier()
      : super(QuoteState(
            recentQuotes: {},
            trendingQuotes: {},
            isTrendingLoading: false,
            isRecentLoading: false,
            currentUsersQuotes: {},
            isUsersQuotesLoading: false));

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
          currentUsersQuotes: state.currentUsersQuotes,
          isTrendingLoading: false,
          isRecentLoading: state.isRecentLoading,
          isUsersQuotesLoading: state.isUsersQuotesLoading); // State'i güncelle
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
          isRecentLoading: state.isRecentLoading,
          isUsersQuotesLoading: state.isUsersQuotesLoading,
          currentUsersQuotes: state.currentUsersQuotes); // State'i güncelle
    } catch (e) {
      // Hata durumunu yönet
      print("Error fetching quotes: $e");
    } finally {
      isLoading = false; // Yükleme tamamlandığında false yap
    }
  }

  Future<void> fetchCurrentUsersQuotes() async {
    isLoading = true;
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('quotes')
          .where("userId", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .orderBy("date", descending: true)
          .get(); // 'quotes' koleksiyonunu alıyoruz

      // Quote modeline dönüştürüp state'i güncelliyoruz
      Map<String, Quote> currentUsersQuotes = {};
      print(querySnapshot.docs.length);
      querySnapshot.docs.forEach((doc) {
        print(doc.data());
        currentUsersQuotes.addAll({(doc.id): Quote.fromJson(doc.data())});
      });
      print(currentUsersQuotes.length);

      state = QuoteState(
          trendingQuotes: state.trendingQuotes,
          recentQuotes: state.recentQuotes,
          isTrendingLoading: state.isTrendingLoading,
          isRecentLoading: state.isRecentLoading,
          isUsersQuotesLoading: false,
          currentUsersQuotes: currentUsersQuotes); // State'i güncelle
    } catch (e) {
      // Hata durumunu yönet
      print("Error fetching quotes: $e");
    } finally {
      isLoading = false; // Yükleme tamamlandığında false yap
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
}

final quotesProvider = StateNotifierProvider<QuotesNotifier, QuoteState>((ref) {
  return QuotesNotifier();
});
