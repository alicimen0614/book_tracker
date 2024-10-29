import 'package:book_tracker/databases/firestore_database.dart';
import 'package:book_tracker/databases/sql_helper.dart';
import 'package:book_tracker/providers/book_state_provider.dart';
import 'package:book_tracker/services/auth_service.dart';
import 'package:book_tracker/services/books_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/bookstate_model.dart';

final authProvider = StateProvider((ref) => AuthService());

final booksProvider = StateProvider((ref) => BooksService());

final bookStateProvider = StateNotifierProvider<BookNotifier, BookState>((ref) {
  return BookNotifier(ref);
});

final firestoreProvider = StateProvider((ref) => FirestoreDatabase());

final sqlProvider = StateProvider((ref) => SqlHelper());

final indexBottomNavbarProvider = StateProvider<int>((ref) {
  return 0;
});
