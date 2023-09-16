import 'package:book_tracker/const.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreDatabase extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> getBookListFromApi(
      String collectionPath, String userId) {
    return _firestore
        .collection(collectionPath)
        .doc(userId)
        .collection("books")
        .snapshots();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getBooks(
      String collectionPath, String userId) async {
    return await _firestore
        .collection(collectionPath)
        .doc(userId)
        .collection("books")
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getNotes(
      String collectionPath, String userId) async {
    return await _firestore
        .collection(collectionPath)
        .doc(userId)
        .collection("notes")
        .get();
  }

  Stream<List<BookWorkEditionsModelEntries>> getBookList(
      String collectionPath, String userId) {
    /// stream<QuerySnapshot> --> Stream<List<DocumentSnapshot>>

    Stream<List<DocumentSnapshot>> streamListDocument =
        getBookListFromApi(collectionPath, userId)
            .map((querySnapshot) => querySnapshot.docs);

    ///Stream<List<DocumentSnapshot>> --> Stream<List<Customer>>
    Stream<List<BookWorkEditionsModelEntries>> streamListCustomer =
        streamListDocument.map((listOfDocSnap) => listOfDocSnap
            .map((docSnap) => BookWorkEditionsModelEntries.fromJson(
                docSnap.data() as Map<String, dynamic>))
            .toList());

    return streamListCustomer;
  }

  //Deleting a data in Firebase.
  Future<void> deleteBook(
      {required String referencePath,
      required String userId,
      required String bookId}) async {
    print("book deleted");
    await _firestore
        .collection(referencePath)
        .doc(userId)
        .collection("books")
        .doc(bookId)
        .delete();
  }

  Future<void> deleteNote(
      {required String referencePath,
      required String userId,
      required String noteId}) async {
    print("note deleted");
    await _firestore
        .collection(referencePath)
        .doc(userId)
        .collection("notes")
        .doc(noteId)
        .delete();
  }

  Future<void> deleteNotes(
      {required String referencePath,
      required String userId,
      required int bookId}) async {
    print("note deleted");
    await _firestore
        .collection(referencePath)
        .doc(userId)
        .collection('notes')
        .where('bookId', isEqualTo: bookId)
        .get()
        .then((value) => value.docs.forEach((element) async {
              print(element.data());
              await _firestore
                  .collection(referencePath)
                  .doc(userId)
                  .collection('notes')
                  .doc(element.data()['id'])
                  .delete();
            }));
  }

  //inserting and updating a data in Firebase.

  Future<void> setBookData({
    required String collectionPath,
    required Map<String, dynamic> bookAsMap,
    required String userId,
  }) async {
    int uniqueBookId =
        uniqueIdCreater(BookWorkEditionsModelEntries.fromJson(bookAsMap));
    print("firebase yazdı");
    print(bookAsMap['title']);
    await _firestore
        .collection(collectionPath)
        .doc(userId)
        .collection("books")
        .doc(uniqueBookId.toString())
        .set(bookAsMap);
  }

  Future<void> setNoteData(
      {required String collectionPath,
      required String note,
      required String userId,
      required int uniqueBookId}) async {
    print("note firebase yazıldı");

    await _firestore
        .collection(collectionPath)
        .doc(userId)
        .collection("notes")
        .doc((uniqueBookId + note.hashCode).toString())
        .set({
      'id': (uniqueBookId + note.hashCode).toString(),
      'bookId': uniqueBookId,
      'note': note
    });
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

