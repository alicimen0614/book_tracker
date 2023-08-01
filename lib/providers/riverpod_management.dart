import 'package:book_tracker/services/auth_service.dart';
import 'package:book_tracker/services/books_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _firebaseAuth = FirebaseAuth.instance;

final authProvider = StateProvider((ref) => AuthService());

final booksProvider = StateProvider((ref) => BooksService());
