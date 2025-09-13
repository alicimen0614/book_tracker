import 'package:book_tracker/widgets/bottom_navigation_bar_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        
        MaterialPageRoute(builder: (_) => const ProviderScope(child: BottomNavigationBarController()) ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9DFBA),
      body: Center(
        child: Image.asset('./lib/assets/icons/vastread.jpg',fit: BoxFit.scaleDown,height: double.infinity,width: double.infinity,),
      ),
    );
  }
}
