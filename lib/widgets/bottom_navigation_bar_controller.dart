import 'package:flutter/material.dart';
import '../screens/discover_screen.dart';
import '../screens/home_screen.dart';
import '../screens/library_screen.dart';
import '../screens/user_screen.dart';

class BottomNavigationBarController extends StatefulWidget {
  const BottomNavigationBarController({super.key});

  @override
  State<BottomNavigationBarController> createState() =>
      _BottomNavigationBarControllerState();
}

class _BottomNavigationBarControllerState
    extends State<BottomNavigationBarController> {
  int currentIndex = 0;
  final screens = [
    const HomeScreen(),
    const DiscoverScreen(),
    const LibraryScreen(),
    const UserScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: bottomNavigationBarBuilder(),
    );
  }

  Widget bottomNavigationBarBuilder() {
    return BottomNavigationBar(
      iconSize: 30,
      fixedColor: const Color.fromRGBO(255, 194, 111, 1),
      unselectedItemColor: Colors.black54,
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (index) {
        setState(() {
          currentIndex = index;
        });
      },
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home_sharp),
          label: 'Anasayfa',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book_sharp),
          label: 'Keşfet',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_library_sharp),
          label: 'Kitaplığım',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.account_circle_sharp,
          ),
          label: 'Kullanıcı',
        ),
      ],
    );
  }
}
