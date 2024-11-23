import 'package:book_tracker/databases/firestore_database.dart';
import 'package:book_tracker/models/quote_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class QuoteEntry {
  final String id;
  final Quote quote;

  QuoteEntry({required this.id, required this.quote});

  QuoteEntry copyWith({String? id, Quote? quote}) {
    return QuoteEntry(id: id ?? this.id, quote: quote ?? this.quote);
  }
}

// StateNotifier ile Quote listesini yöneten sınıf
class QuotesNotifier extends ChangeNotifier {
  final PagingController<DocumentSnapshot?, QuoteEntry>
      trendingPagingController = PagingController(firstPageKey: null);

  final PagingController<DocumentSnapshot?, QuoteEntry> recentPagingController =
      PagingController(firstPageKey: null);

  final PagingController<DocumentSnapshot?, QuoteEntry>
      currentUsersPagingController = PagingController(firstPageKey: null);

  QuotesNotifier() {
    trendingPagingController.addPageRequestListener((pageKey) {
      fetchTrendingQuotes(pageKey);
    });

    recentPagingController.addPageRequestListener((pageKey) {
      fetchRecentQuotes(pageKey);
    });

    currentUsersPagingController.addPageRequestListener((pageKey) {
      fetchCurrentUsersQuotes(pageKey);
    });
  }

  // Firebase'den quote verilerini çekme fonksiyonu
  Future<void> fetchTrendingQuotes(
      DocumentSnapshot? lastDocumentSnapshot) async {
    try {
      final query = FirebaseFirestore.instance
          .collection("quotes")
          .orderBy("likeCount", descending: true)
          .limit(10);

      QuerySnapshot<Map<String, dynamic>> snapshot;
      if (lastDocumentSnapshot == null) {
        // İlk sayfa
        snapshot = await query.get();
      } else {
        // Sonraki sayfalar
        snapshot = await query.startAfterDocument(lastDocumentSnapshot).get();
      }
      Map<String, Quote> recentQuotes = {};
      snapshot.docs.forEach((doc) {
        recentQuotes.addAll({(doc.id): Quote.fromJson(doc.data())});
      });

      final mapEntries = recentQuotes.entries
          .map((entry) => QuoteEntry(id: entry.key, quote: entry.value))
          .toList();
      final isLastPage = recentQuotes.length < 10;
      if (isLastPage) {
        print("trending lastpage loaded: ${recentQuotes.length}");
        trendingPagingController.appendLastPage(mapEntries);
      } else {
        print("trending newpage loaded: ${recentQuotes.length}");

        final nextKey = snapshot.docs.last;
        trendingPagingController.appendPage(mapEntries, nextKey);
      }
    } catch (e) {
      print(e);
    }
  }

  /*  Future<void> clearQuotes() async {
    state = state.copyWith(recentQuotes: {}, trendingQuotes: {});
  } */

  Future<void> fetchRecentQuotes(DocumentSnapshot? lastDocumentSnapshot) async {
    try {
      final query = FirebaseFirestore.instance
          .collection('quotes')
          .orderBy("date", descending: true)
          .limit(10);

      QuerySnapshot<Map<String, dynamic>> snapshot;
      if (lastDocumentSnapshot == null) {
        // İlk sayfa
        snapshot = await query.get();
      } else {
        // Sonraki sayfalar
        snapshot = await query.startAfterDocument(lastDocumentSnapshot).get();
      }
      Map<String, Quote> recentQuotes = {};
      snapshot.docs.forEach((doc) {
        recentQuotes.addAll({(doc.id): Quote.fromJson(doc.data())});
      });

      final mapEntries = recentQuotes.entries
          .map((entry) => QuoteEntry(id: entry.key, quote: entry.value))
          .toList();
      final isLastPage = recentQuotes.length < 10;
      if (isLastPage) {
        print("recent lastpage loaded: ${recentQuotes.length}");
        recentPagingController.appendLastPage(mapEntries);
      } else {
        print("recent newpage loaded: ${recentQuotes.length}");

        final nextKey = snapshot.docs.last;
        recentPagingController.appendPage(mapEntries, nextKey);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchCurrentUsersQuotes(
      DocumentSnapshot? lastDocumentSnapshot) async {
    try {
      final query = FirebaseFirestore.instance
          .collection('quotes')
          .where("userId", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .orderBy("date", descending: true)
          .limit(10);

      QuerySnapshot<Map<String, dynamic>> snapshot;
      if (lastDocumentSnapshot == null) {
        // İlk sayfa
        snapshot = await query.get();
      } else {
        // Sonraki sayfalar
        snapshot = await query.startAfterDocument(lastDocumentSnapshot).get();
      }
      Map<String, Quote> currentUsersQuotes = {};
      snapshot.docs.forEach((doc) {
        currentUsersQuotes.addAll({(doc.id): Quote.fromJson(doc.data())});
      });

      final mapEntries = currentUsersQuotes.entries
          .map((entry) => QuoteEntry(id: entry.key, quote: entry.value))
          .toList();
      final isLastPage = currentUsersQuotes.length < 10;
      if (isLastPage) {
        print(
            "currentUsersQuotes lastpage loaded: ${currentUsersQuotes.length}");
        currentUsersPagingController.appendLastPage(mapEntries);
      } else {
        print(
            "currentUsersQuotes newpage loaded: ${currentUsersQuotes.length}");

        final nextKey = snapshot.docs.last;
        currentUsersPagingController.appendPage(mapEntries, nextKey);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<bool> deleteQuote(String quoteId) async {
    var trendingQuotes = trendingPagingController.itemList;
    var recentQuotes = recentPagingController.itemList;
    var currentUsersQuotes = currentUsersPagingController.itemList;
    int indexOfTrending = -1;
    int indexOfRecent = -1;
    int indexOfCurrent = -1;
    if (trendingQuotes != null) {
      indexOfTrending =
          trendingQuotes.indexWhere((entry) => entry.id == quoteId);
    }
    if (recentQuotes != null) {
      indexOfRecent = recentQuotes.indexWhere((entry) => entry.id == quoteId);
    }
    if (currentUsersQuotes != null) {
      indexOfCurrent =
          currentUsersQuotes.indexWhere((entry) => entry.id == quoteId);
    }

    bool isQuoteExistOnTrending = indexOfTrending != -1;
    bool isQuoteExistOnRecent = indexOfRecent != -1;
    bool isQuoteExistOnCurrent = indexOfCurrent != -1;

    try {
      if (FirebaseAuth.instance.currentUser != null &&
          isQuoteExistOnTrending &&
          trendingQuotes != null) {
        trendingQuotes.removeAt(indexOfTrending);

        trendingPagingController.itemList = [...trendingQuotes];
      }
      if (FirebaseAuth.instance.currentUser != null &&
          isQuoteExistOnRecent &&
          recentQuotes != null) {
        recentQuotes.removeAt(indexOfRecent);
        recentPagingController.itemList = [...recentQuotes];
      }
      if (FirebaseAuth.instance.currentUser != null &&
          isQuoteExistOnCurrent &&
          currentUsersQuotes != null) {
        currentUsersQuotes.removeAt(indexOfCurrent);
        currentUsersPagingController.itemList = [...currentUsersQuotes];
      }
      FirestoreDatabase().deleteQuote(quoteId);
      return true;
    } catch (e) {
      // Hata durumunu yönet
      return false;
    }
  }

  void updateLikedQuote(String quoteId, bool? isTrendingQuotes) {
    var trendingQuotes = trendingPagingController.itemList;
    var recentQuotes = recentPagingController.itemList;
    var currentUsersQuotes = currentUsersPagingController.itemList;
    int indexOfTrending = -1;
    int indexOfRecent = -1;
    int indexOfCurrent = -1;
    if (trendingQuotes != null) {
      indexOfTrending =
          trendingQuotes.indexWhere((entry) => entry.id == quoteId);
    }
    if (recentQuotes != null) {
      indexOfRecent = recentQuotes.indexWhere((entry) => entry.id == quoteId);
    }
    if (currentUsersQuotes != null) {
      indexOfCurrent =
          currentUsersQuotes.indexWhere((entry) => entry.id == quoteId);
    }
    bool isQuoteExistOnTrending = indexOfTrending != -1;
    bool isQuoteExistOnRecent = indexOfRecent != -1;
    bool isQuoteExistOnCurrent = indexOfCurrent != -1;

    if (FirebaseAuth.instance.currentUser != null) {
      if (isQuoteExistOnTrending) {
        var likes = trendingQuotes?[indexOfTrending].quote.likes!;
        var likeCount = trendingQuotes?[indexOfTrending].quote.likeCount!;
        if (likes!.contains(FirebaseAuth.instance.currentUser!.uid)) {
          likes.remove(FirebaseAuth.instance.currentUser!.uid);
          likeCount = likeCount! - 1;
        } else {
          likes.add(FirebaseAuth.instance.currentUser!.uid);
          likeCount = likeCount! + 1;
        }
        final updatedQuote = trendingQuotes?[indexOfTrending]
            .quote
            .copyWith(likes: likes, likeCount: likeCount);

        final updatedEntry =
            trendingQuotes?[indexOfTrending].copyWith(quote: updatedQuote);

        trendingPagingController.itemList = [
          ...trendingQuotes!.sublist(0, indexOfTrending),
          updatedEntry!,
          ...trendingQuotes.sublist(indexOfTrending + 1),
        ];
      }
      if (isQuoteExistOnCurrent) {
        var likes = currentUsersQuotes?[indexOfCurrent].quote.likes!;
        var likeCount = currentUsersQuotes?[indexOfCurrent].quote.likeCount!;
        if (likes!.contains(FirebaseAuth.instance.currentUser!.uid)) {
          likes.remove(FirebaseAuth.instance.currentUser!.uid);
          likeCount = likeCount! - 1;
        } else {
          likes.add(FirebaseAuth.instance.currentUser!.uid);
          likeCount = likeCount! + 1;
        }
        final updatedQuote = currentUsersQuotes?[indexOfCurrent]
            .quote
            .copyWith(likes: likes, likeCount: likeCount);

        final updatedEntry =
            currentUsersQuotes?[indexOfCurrent].copyWith(quote: updatedQuote);

        currentUsersPagingController.itemList = [
          ...currentUsersQuotes!.sublist(0, indexOfCurrent),
          updatedEntry!,
          ...currentUsersQuotes.sublist(indexOfCurrent + 1),
        ];
      }
      if (isQuoteExistOnRecent) {
        var likes = recentQuotes?[indexOfRecent].quote.likes!;
        var likeCount = recentQuotes?[indexOfRecent].quote.likeCount!;
        if (likes!.contains(FirebaseAuth.instance.currentUser!.uid)) {
          likes.remove(FirebaseAuth.instance.currentUser!.uid);
          likeCount = likeCount! - 1;
        } else {
          likes.add(FirebaseAuth.instance.currentUser!.uid);
          likeCount = likeCount! + 1;
        }
        final updatedQuote = recentQuotes?[indexOfRecent]
            .quote
            .copyWith(likes: likes, likeCount: likeCount);

        final updatedEntry =
            recentQuotes?[indexOfRecent].copyWith(quote: updatedQuote);

        recentPagingController.itemList = [
          ...recentQuotes!.sublist(0, indexOfRecent),
          updatedEntry!,
          ...recentQuotes.sublist(indexOfRecent + 1),
        ];
      }
    }
  }
/* 
  Future<void> clearMyQuotes() async {
    try {
      state = state.copyWith(currentUsersQuotes: {});
    } catch (e) {
      // Hata durumunu yönet
    }
  } */

  @override
  void dispose() {
    trendingPagingController.dispose();
    recentPagingController.dispose();
    currentUsersPagingController.dispose();
    super.dispose();
  }
}

final quotesProvider = ChangeNotifierProvider<QuotesNotifier>((ref) {
  return QuotesNotifier();
});
