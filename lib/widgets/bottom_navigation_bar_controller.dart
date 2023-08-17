import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/discover_screen/discover_screen_view.dart';
import '../screens/home_screen/home_screen_view.dart';
import '../screens/library_screen/library_screen_view.dart';
import '../screens/user_screen/user_screen_view.dart';

class BottomNavigationBarController extends ConsumerStatefulWidget {
  BottomNavigationBarController(
      {super.key, this.currentIndexParam = 0, this.searchValue = ""});
  final int currentIndexParam;
  final String searchValue;

  @override
  ConsumerState<BottomNavigationBarController> createState() =>
      _BottomNavigationBarControllerState();
}

class _BottomNavigationBarControllerState
    extends ConsumerState<BottomNavigationBarController> {
  late int currentIndex = widget.currentIndexParam;
  late String value = widget.searchValue;
  final screens = [
    const HomeScreenView(),
    const DiscoverScreenView(),
    const LibraryScreenView(),
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: ref.read(authProvider).authState,
        builder: (context, snapshot) {
          return Scaffold(
            body: currentIndex == 3
                ? UserScreenView(
                    user: snapshot.data,
                  )
                : currentIndex == 1
                    ? const DiscoverScreenView()
                    : screens[currentIndex],
            bottomNavigationBar: bottomNavigationBarBuilder(),
          );
        });
  }

  Widget bottomNavigationBarBuilder() {
    return BottomNavigationBar(
      iconSize: 30,
      fixedColor: const Color.fromRGBO(195, 129, 84, 1),
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
