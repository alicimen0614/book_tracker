import 'package:book_tracker/const.dart';
import 'package:book_tracker/l10n/app_localizations.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/models/quote_model.dart';
import 'package:book_tracker/widgets/error_snack_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';



class FirestoreDatabase extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> getBookListFromFirestore(
      String collectionPath, String userId) {
    return _firestore
        .collection(collectionPath)
        .doc(userId)
        .collection("books")
        .snapshots();
  }

  Future<QuerySnapshot<Map<String, dynamic>>?> getBooks(
      String collectionPath, String userId) async {
    try {
      return await _firestore
          .collection(collectionPath)
          .doc(userId)
          .collection("books")
          .get();
    } catch (e) {
      return null;
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>?> getNotes(
      String collectionPath, String userId, BuildContext context) async {
    try {
      return await _firestore
          .collection(collectionPath)
          .doc(userId)
          .collection("notes")
          .get();
    } catch (e) {
      errorSnackBar(context, e.toString(),
          infoMessage: AppLocalizations.of(context)!.errorFetchingNotes);
      return null;
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> getUserInfo(
      String userId) async {
    try {
      return await _firestore.collection("usersBooks").doc(userId).get();
    } catch (e) {
      print(e);
      return null;
    }
  }

  //Deleting a data in Firebase.
  Future<void> deleteBook(BuildContext context,
      {required String referencePath,
      required String userId,
      required String bookId}) async {
    try {
      await _firestore
          .collection(referencePath)
          .doc(userId)
          .collection("books")
          .doc(bookId)
          .delete();
    } catch (e) {
      errorSnackBar(context, e.toString(),
          infoMessage: AppLocalizations.of(context)!.errorDeletingBook);
    }
  }

  Future<void> deleteNote(BuildContext context,
      {required String referencePath,
      required String userId,
      required String noteId}) async {
    try {
      await _firestore
          .collection(referencePath)
          .doc(userId)
          .collection("notes")
          .doc(noteId)
          .delete();
    } catch (e) {
      errorSnackBar(context, e.toString(),
          infoMessage: AppLocalizations.of(context)!.errorDeletingNote);
    }
  }

  Future<void> deleteNotes(BuildContext context,
      {required String referencePath,
      required String userId,
      required int bookId}) async {
    try {
      await _firestore
          .collection(referencePath)
          .doc(userId)
          .collection('notes')
          .where('bookId', isEqualTo: bookId)
          .get()
          .then((value) => value.docs.forEach((element) async {
                await _firestore
                    .collection(referencePath)
                    .doc(userId)
                    .collection('notes')
                    .doc(element.data()['id'])
                    .delete();
              }));
    } catch (e) {
      errorSnackBar(context, e.toString(),
          infoMessage: AppLocalizations.of(context)!.errorDeletingNotes);
    }
  }

  //inserting and updating a data in Firebase.

  Future<void> setBookData(
    BuildContext context, {
    required String collectionPath,
    required Map<String, dynamic> bookAsMap,
    required String userId,
  }) async {
    try {
      int uniqueBookId =
          uniqueIdCreater(BookWorkEditionsModelEntries.fromJson(bookAsMap));

      await _firestore
          .collection(collectionPath)
          .doc(userId)
          .collection("books")
          .doc(uniqueBookId.toString())
          .set(bookAsMap);
    } catch (e) {
      errorSnackBar(context, e.toString(),
          infoMessage: AppLocalizations.of(context)!.errorAddingBook);
    }
  }

  Future<void> setQuoteData(BuildContext context,
      {required Map<String, dynamic> quote, String? docId}) async {
    try {
      if (docId != null) {
        _firestore.collection("quotes").doc(docId).update(quote);
      } else {
        await _firestore.collection("quotes").doc().set(quote);
      }
    } catch (e) {
      errorSnackBar(context, e.toString(),
          infoMessage: AppLocalizations.of(context)!.errorAddingQuote);
    }
  }

  Future<List<Quote>?> getQuotes() async {
    try {
      var quotesSnapshots = await _firestore.collection("quotes").get();

      var quotesList = quotesSnapshots.docs
          .map((quotesSnapshot) => Quote.fromJson(quotesSnapshot.data()))
          .toList();

      return quotesList;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> deleteQuote(String quoteId) async {
    try {
      await _firestore.collection("quotes").doc(quoteId).delete();
    } catch (e) {
      print(e);
    }
  }

  Future<bool> commitLikeToFirebase(String quoteId, bool? isLikedOnLocal) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null || isLikedOnLocal == null) {
    return false;
  }

  final currentUserId = currentUser.uid;
  final quoteDocRef =
      FirebaseFirestore.instance.collection('quotes').doc(quoteId);

  try {
    final result = await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(quoteDocRef);

      if (!snapshot.exists) {
        return false;
      }

      List<dynamic> likes = snapshot.get('likes') as List<dynamic>;
      int likeCount = snapshot.get('likeCount') as int;

      final isLiked = likes.contains(currentUserId);

      if (isLiked && !isLikedOnLocal) {
        likes.remove(currentUserId);
        likeCount--;
      } else if (!isLiked && isLikedOnLocal) {
        likes.add(currentUserId);
        likeCount++;
      } else {
        return true; // Durum zaten aynı, işlem yapılmadan başarıyla çık
      }

      transaction.update(quoteDocRef, {
        'likes': likes,
        'likeCount': likeCount,
      });

      return true;
    });

    debugPrint("Transaction success!");
    return result;
  } catch (error) {
    debugPrint("Transaction failed: $error");
    return false;
  }
}


  Future<void> updateBookStatus(BuildContext context,
      {required String collectionPath,
      required String newBookStatus,
      required String userId,
      required int uniqueBookId}) async {
    try {
      await _firestore
          .collection(collectionPath)
          .doc(userId)
          .collection("books")
          .doc(uniqueBookId.toString())
          .update({'bookStatus': newBookStatus});
    } catch (e) {
      errorSnackBar(context, e.toString(),
          infoMessage: AppLocalizations.of(context)!.errorUpdatingBookStatus);
    }
  }

  Future<void> setNoteData(BuildContext context,
      {required String collectionPath,
      required String note,
      required String userId,
      required int uniqueBookId,
      required String noteDate,
      int? noteId}) async {
    try {
      await _firestore
          .collection(collectionPath)
          .doc(userId)
          .collection("notes")
          .doc(noteId != null
              ? noteId.toString()
              : (uniqueBookId + note.hashCode).toString())
          .set({
        'id': noteId != null
            ? noteId.toString()
            : (uniqueBookId + note.hashCode).toString(),
        'bookId': uniqueBookId,
        'note': note,
        'noteDate': noteDate
      });
    } catch (e) {
      errorSnackBar(context, e.toString(),
          infoMessage: AppLocalizations.of(context)!.errorAddingNote);
    }
  }


   Future<bool> insertReport(BuildContext context,
      {collectionPath="reportedQuotes",
      required String reason,
      required String note,
      required String reporterUserId,
      required String ownerUserId,
      required String quoteText,
      required String reporterEmail,
      required String quoteId}) async {
    try {
      await _firestore
          .collection(collectionPath)
          .doc(quoteId)
          .set({
        'reason': reason,
        'note': note,
        'reporterUserId': reporterUserId,
        'ownerUserId': ownerUserId,
        'quoteText': quoteText,
        'reporterEmail': reporterEmail,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      errorSnackBar(context, e.toString(),
          infoMessage: AppLocalizations.of(context)!.errorReportingQuote);
      return false;
    }
  }
  //update data
}

  /*  Future<Stream<QuerySnapshot<Map<String, dynamic>>>> getCustomerWorks(
      {required String collectionPath, required String id}) async {
    return await _firestore
        .collection(collectionPath)
        .doc(id)
        .get()
        .then((value) => value.data()!['works']);
  } */

