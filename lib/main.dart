import 'package:book_tracker/const.dart';
import 'package:book_tracker/widgets/bottom_navigation_bar_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  MobileAds.instance.initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Intl.defaultLocale = 'tr';
    Const.init(context);
    return MaterialApp(
      title: 'Book Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B7695),
        ),
        scrollbarTheme: ScrollbarThemeData(
          thumbColor:
              WidgetStateProperty.all(const Color.fromRGBO(195, 129, 84, 1)),
          minThumbLength: 100,
        ),
        primarySwatch: mainAppColor,
        appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1B7695),
            centerTitle: true,
            foregroundColor: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
        progressIndicatorTheme:
            const ProgressIndicatorThemeData(color: Color(0xFF1B7695)),
        scaffoldBackgroundColor: const Color(0xFFFFEFDB),
        primaryColor: const Color(0xFF1B7695),
        bottomNavigationBarTheme:
            const BottomNavigationBarThemeData(backgroundColor: Colors.white),
        fontFamily: 'Nunito Sans',
      ),
      home: const ProviderScope(child: BottomNavigationBarController()),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
    );
  }

  final MaterialColor mainAppColor =
      const MaterialColor(0xFF1B7695, <int, Color>{
    50: Color(0xFF1B7695),
    100: Color(0xFF1B7695),
    200: Color(0xFF1B7695),
    300: Color(0xFF1B7695),
    400: Color(0xFF1B7695),
    500: Color(0xFF1B7695),
    600: Color(0xFF1B7695),
    700: Color(0xFF1B7695),
    800: Color(0xFF1B7695),
    900: Color(0xFF1B7695),
  });
}
