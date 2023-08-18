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
  Future<void> deleteDocument(
      {required String referencePath, required String userId}) async {
    await _firestore.collection(referencePath).doc(userId).delete();
    print("database girdi");
  }

  //inserting and updating a data in Firebase.

  Future<void> setBookData(
      {required String collectionPath,
      required Map<String, dynamic> bookAsMap,
      required String userId,
      required String uniqueBookId}) async {
    await _firestore
        .collection(collectionPath)
        .doc(userId)
        .collection("books")
        .doc(uniqueBookId)
        .set(bookAsMap);
  }
}

  /*  Future<Stream<QuerySnapshot<Map<String, dynamic>>>> getCustomerWorks(
      {required String collectionPath, required String id}) async {
    return await _firestore
        .collection(collectionPath)
        .doc(id)
        .get()
        .then((value) => value.data()!['works']);
  } */
