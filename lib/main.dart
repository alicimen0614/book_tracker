import 'package:book_tracker/widgets/bottom_navigation_bar_controller.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Tracker',
      theme: ThemeData(
          scaffoldBackgroundColor: const Color.fromRGBO(249, 224, 187, 1),
          primaryColor: const Color.fromRGBO(249, 224, 187, 1),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color.fromRGBO(250, 240, 215, 1))),
      home: const BottomNavigationBarController(),
    );
  }
}
