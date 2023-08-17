import 'package:book_tracker/widgets/bottom_navigation_bar_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Tracker',
      theme: ThemeData(
          scrollbarTheme: ScrollbarThemeData(
            thumbColor: MaterialStateProperty.all(Colors.white),
            minThumbLength: 100,
          ),
          primarySwatch: Colors.teal,
          scaffoldBackgroundColor: const Color.fromRGBO(224, 192, 151, 1),
          primaryColor: const Color.fromRGBO(249, 224, 187, 1),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.white)),
      home: BottomNavigationBarController(),
    );
  }
}
