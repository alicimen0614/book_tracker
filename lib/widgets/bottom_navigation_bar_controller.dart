import 'package:book_tracker/providers/connectivity_provider.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/discover_screen/discover_screen_view.dart';
import '../screens/home_screen/home_screen_view.dart';
import '../screens/library_screen/library_screen_view.dart';
import '../screens/user_screen/user_screen_view.dart';

class BottomNavigationBarController extends ConsumerStatefulWidget {
  const BottomNavigationBarController({super.key, this.searchValue = ""});

  final String searchValue;

  @override
  ConsumerState<BottomNavigationBarController> createState() =>
      _BottomNavigationBarControllerState();
}

class _BottomNavigationBarControllerState
    extends ConsumerState<BottomNavigationBarController> {
  DateTime timeBackPressed = DateTime.now();
  final List<Widget> _widgetOptions = <Widget>[
    const HomeScreenView(),
    const DiscoverScreenView(),
    const LibraryScreenView(),
    const UserScreenView()
  ];
  final PageController _pageController = PageController();

  late String value = widget.searchValue;
  int indexBottomNavbar = 0;

  void onTap(int index) {
    if (indexBottomNavbar != index) {
      _pageController.jumpToPage(ref.read(indexBottomNavbarProvider));
      setState(() {
        indexBottomNavbar = index;
      });
    }
  }

  @override
  void initState() {
    ref.read(connectivityProvider.notifier).isConnected;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookStateProvider.notifier).getPageData();
    });

    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    indexBottomNavbar = ref.watch(indexBottomNavbarProvider);
    if (_pageController.hasClients) {
      if (indexBottomNavbar != _pageController.page) {
        _pageController.jumpToPage(ref.read(indexBottomNavbarProvider));
        setState(() {});
      }
    }

    return StreamBuilder<User?>(
        stream: ref.read(authProvider).authState,
        builder: (context, snapshot) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              final difference = DateTime.now().difference(timeBackPressed);
              final isExitWarning = difference >= const Duration(seconds: 2);
              timeBackPressed = DateTime.now();
              if (isExitWarning) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                    "Uygulamadan çıkmak için bir daha basın.",
                  ),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ));
                return;
              } else {
                SystemNavigator.pop();
              }
            },
            child: Scaffold(
              body: PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _pageController,
                onPageChanged: onTap,
                children: _widgetOptions,
              ),
              bottomNavigationBar: bottomNavigationBarBuilder(),
            ),
          );
        });
  }

  Widget bottomNavigationBarBuilder() {
    return NavigationBar(
      onDestinationSelected: (index) {
        ref.read(indexBottomNavbarProvider.notifier).update((state) => index);

        onTap(index);
      },
      indicatorColor: Theme.of(context).primaryColor,
      selectedIndex: indexBottomNavbar,
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
          selectedIcon: Icon(Icons.shelves),
          icon: Icon(
            Icons.shelves,
            size: 23,
          ),
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
