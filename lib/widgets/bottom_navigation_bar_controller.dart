import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/discover_screen_view.dart';
import '../screens/home_screen_view.dart';
import '../screens/library_screen_view.dart';
import '../screens/user_screen_view.dart';

class BottomNavigationBarController extends ConsumerStatefulWidget {
  BottomNavigationBarController(
      {super.key, this.currentIndex = 0, this.searchValue = ""});
  late int currentIndex;
  final String searchValue;

  @override
  ConsumerState<BottomNavigationBarController> createState() =>
      _BottomNavigationBarControllerState();
}

class _BottomNavigationBarControllerState
    extends ConsumerState<BottomNavigationBarController> {
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
            body: widget.currentIndex == 3
                ? UserScreenView(
                    user: snapshot.data,
                  )
                : widget.currentIndex == 1
                    ? const DiscoverScreenView()
                    : screens[widget.currentIndex],
            bottomNavigationBar: bottomNavigationBarBuilder(),
          );
        });
  }

  Widget bottomNavigationBarBuilder() {
    return BottomNavigationBar(
      iconSize: 30,
      fixedColor: const Color.fromRGBO(255, 194, 111, 1),
      unselectedItemColor: Colors.black54,
      type: BottomNavigationBarType.fixed,
      currentIndex: widget.currentIndex,
      onTap: (index) {
        setState(() {
          widget.currentIndex = index;
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
