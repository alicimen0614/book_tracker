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
  List<Widget> _widgetOptions = <Widget>[
    HomeScreenView(),
    DiscoverScreenView(),
    LibraryScreenView(),
    UserScreenView()
  ];
  PageController _pageController = PageController();
  late int currentIndex;
  late String value = widget.searchValue;

  void onTap(int index) {
    if (currentIndex != index) {
      _pageController.jumpToPage(index);
      setState(() {
        currentIndex = index;
      });
    }
  }

  @override
  void initState() {
    currentIndex = widget.currentIndexParam;

    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: ref.read(authProvider).authState,
        builder: (context, snapshot) {
          return Scaffold(
            body: PageView(
              physics: NeverScrollableScrollPhysics(),
              controller: _pageController,
              onPageChanged: onTap,
              children: _widgetOptions,
            ),
            bottomNavigationBar: bottomNavigationBarBuilder(),
          );
        });
  }

  Widget bottomNavigationBarBuilder() {
    return NavigationBar(
      onDestinationSelected: (int index) {
        onTap(index);
      },
      indicatorColor: Theme.of(context).primaryColor,
      selectedIndex: currentIndex,
      destinations: const <Widget>[
        NavigationDestination(
          selectedIcon: Icon(Icons.home_outlined),
          icon: Icon(Icons.home),
          label: 'Anasayfa',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.menu_book_outlined),
          icon: Icon(Icons.menu_book_rounded),
          label: 'Keşfet',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.local_library_outlined),
          icon: Icon(Icons.local_library_sharp),
          label: 'Kitaplığım',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.account_circle_outlined),
          icon: Icon(Icons.account_circle_sharp),
          label: 'Kullanıcı',
        ),
      ],
    );
  }
}
