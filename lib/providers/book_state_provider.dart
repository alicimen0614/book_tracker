import 'package:book_tracker/const.dart';
import 'package:book_tracker/models/bookstate_model.dart';
import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/providers/connectivity_provider.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookNotifier extends StateNotifier<BookState> {
  final Ref ref;
  BookNotifier(
    this.ref,
  ) : super(BookState());

  Future<void> getPageData() async {
    state = state.copyWith(isLoading: true);
    if (ref.read(authProvider).currentUser != null) {
      state = state.copyWith(isUserAvailable: true);
    } else {
      state = state.copyWith(isUserAvailable: false);
    }

    await getSqlBookList();
    bool isConnected = ref.read(connectivityProvider).isConnected;
    state = state.copyWith(isConnected: isConnected);

    if (state.isUserAvailable && state.isConnected) {
      await getFirestoreBookList();
    }

    await getFilteredBooks(state.listOfBooksToShow);

    state = state.copyWith(isLoading: false);
  }

  Future<void> getFirestoreBookList() async {
    var data = await ref
        .read(firestoreProvider)
        .getBooks("usersBooks", ref.read(authProvider).currentUser!.uid);

    if (data != null) {
      var listOfBooksFromFirestore = data.docs
          .map((e) => BookWorkEditionsModelEntries.fromJson(e.data()))
          .toList();

      if (listOfBooksFromFirestore.length > state.listOfBooksFromSql.length) {
        state = state.copyWith(
            listOfBooksFromFirestore: listOfBooksFromFirestore,
            listOfBooksToShow: listOfBooksFromFirestore);
      }
    }
  }

  Future<void> getSqlBookList() async {
    var data = await ref.read(sqlProvider).getBookShelf();

    List<BookWorkEditionsModelEntries>? listOfBooksFromSql = data;
    List<BookWorkEditionsModelEntries> dummyBooks = [];

    if (listOfBooksFromSql != null) {
      for (var element in listOfBooksFromSql) {
        var authorData = await ref.read(sqlProvider).getAuthors(
              uniqueIdCreater(element),
            );
        dummyBooks.add(BookWorkEditionsModelEntries(
          authorsNames: authorData,
          bookStatus: element.bookStatus,
          covers: element.covers,
          description: element.description,
          imageAsByte: element.imageAsByte,
          isbn_10: element.isbn_10,
          isbn_13: element.isbn_13,
          languages: element.languages,
          number_of_pages: element.number_of_pages,
          physical_format: element.physical_format,
          publish_date: element.publish_date,
          publishers: element.publishers,
          title: element.title,
          works: element.works,
        ));
      }

      state = state.copyWith(
          listOfBooksFromSql: listOfBooksFromSql,
          listOfBooksToShow: dummyBooks);
    }
  }

  Future<void> getFilteredBooks(
      List<BookWorkEditionsModelEntries> listOfBooksToShow) async {
    List<BookWorkEditionsModelEntries> currentlyReadingList = [];
    List<BookWorkEditionsModelEntries> alreadyReadList = [];
    List<BookWorkEditionsModelEntries> wantToReadList = [];

    for (var element in listOfBooksToShow) {
      if (element.bookStatus == "Şu an okuduklarım") {
        currentlyReadingList.add(element);
      } else if (element.bookStatus == "Okumak istediklerim") {
        wantToReadList.add(element);
      } else {
        alreadyReadList.add(element);
      }
    }
    state = state.copyWith(
        listOfBooksAlreadyRead: alreadyReadList,
        listOfBooksCurrentlyReading: currentlyReadingList,
        listOfBooksWantToRead: wantToReadList);
  }

  Future<void> clearBooks() async {
    state = BookState();
  }

  final bookStateProvider =
      StateNotifierProvider<BookNotifier, BookState>((ref) {
    return BookNotifier(ref);
  });
}
