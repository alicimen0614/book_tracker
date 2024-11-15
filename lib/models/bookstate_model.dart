import 'package:book_tracker/models/bookswork_editions_model.dart';

class BookState {
  final bool isLoading;
  final bool isUserAvailable;
  final bool isConnected;
  final List<BookWorkEditionsModelEntries> listOfBooksFromFirestore;
  final List<BookWorkEditionsModelEntries> listOfBooksFromSql;
  final List<BookWorkEditionsModelEntries> listOfBooksToShow;
  final List<BookWorkEditionsModelEntries> listOfBooksCurrentlyReading;
  final List<BookWorkEditionsModelEntries> listOfBooksWantToRead;
  final List<BookWorkEditionsModelEntries> listOfBooksAlreadyRead;

  BookState(
      {this.isLoading = true,
      this.isUserAvailable = false,
      this.isConnected = false,
      this.listOfBooksFromFirestore = const [],
      this.listOfBooksFromSql = const [],
      this.listOfBooksToShow = const [],
      this.listOfBooksAlreadyRead = const [],
      this.listOfBooksWantToRead = const [],
      this.listOfBooksCurrentlyReading = const []});

  BookState copyWith(
      {bool? isLoading,
      bool? isUserAvailable,
      bool? isConnected,
      List<BookWorkEditionsModelEntries>? listOfBooksFromFirestore,
      List<BookWorkEditionsModelEntries>? listOfBooksFromSql,
      List<BookWorkEditionsModelEntries>? listOfBooksToShow,
      List<BookWorkEditionsModelEntries>? listOfBooksCurrentlyReading,
      List<BookWorkEditionsModelEntries>? listOfBooksWantToRead,
      List<BookWorkEditionsModelEntries>? listOfBooksAlreadyRead}) {
    return BookState(
      isLoading: isLoading ?? this.isLoading,
      isUserAvailable: isUserAvailable ?? this.isUserAvailable,
      isConnected: isConnected ?? this.isConnected,
      listOfBooksFromFirestore:
          listOfBooksFromFirestore ?? this.listOfBooksFromFirestore,
      listOfBooksFromSql: listOfBooksFromSql ?? this.listOfBooksFromSql,
      listOfBooksToShow: listOfBooksToShow ?? this.listOfBooksToShow,
      listOfBooksCurrentlyReading:
          listOfBooksCurrentlyReading ?? this.listOfBooksCurrentlyReading,
      listOfBooksWantToRead:
          listOfBooksWantToRead ?? this.listOfBooksWantToRead,
      listOfBooksAlreadyRead:
          listOfBooksAlreadyRead ?? this.listOfBooksAlreadyRead,
    );
  }
}
