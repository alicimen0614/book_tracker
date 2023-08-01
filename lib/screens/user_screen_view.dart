import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/widgets/animated_button.dart';
import 'package:book_tracker/widgets/bottom_navigation_bar_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_view.dart';

class UserScreenView extends ConsumerStatefulWidget {
  UserScreenView({super.key, required this.user});

  User? user;

  @override
  ConsumerState<UserScreenView> createState() => _UserScreenViewState();
}

class _UserScreenViewState extends ConsumerState<UserScreenView> {
  late bool isUserLoggedIn;
  @override
  void initState() {
    widget.user != null ? isUserLoggedIn = true : isUserLoggedIn = false;
    super.initState();
  }

  @override
  User? getCurrentUser(WidgetRef ref) {
    return ref.read(authProvider).currentUser;
  }

  Stream<User?> authState(WidgetRef ref) {
    return ref.watch(authProvider).authState;
  }

  Widget getAppBarLeading(WidgetRef ref) {
    if (ref.watch(authProvider).currentUser == null) {
      return const Icon(
        Icons.account_circle_sharp,
        size: 40,
      );
    } else {
      if (getCurrentUser(ref)!.photoURL != null) {
        return ClipOval(
          child: CachedNetworkImage(
            fit: BoxFit.cover,
            imageUrl: getCurrentUser(ref)!.photoURL as String,
            placeholder: (context, url) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: const [CircularProgressIndicator()]),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        );
      } else {
        return const Icon(
          Icons.account_circle_sharp,
          size: 40,
        );
      }
    }
  }

  Widget getAppBarTitle(WidgetRef ref) {
    if (getCurrentUser(ref) == null) {
      return const Text("Ziyaretçi");
    } else {
      if (getCurrentUser(ref)!.displayName == null) {
        return const Text("Ziyaretçi");
      } else {
        return Text(getCurrentUser(ref)!.displayName!);
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    print("yenilendi");
    print("$isUserLoggedIn -1");

    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
                title: getAppBarTitle(ref),
                leading: Padding(
                  padding: const EdgeInsets.all(3),
                  child: getAppBarLeading(ref),
                ),
                leadingWidth: 50,
                actions: [
                  isUserLoggedIn == true
                      ? IconButton(
                          onPressed: () async {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text("BookTracker"),
                                  content: const Text(
                                      "Çıkış yapmak istediğinizden emin misiniz?"),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Vazgeç")),
                                    TextButton(
                                        onPressed: () {
                                          print("$isUserLoggedIn -2");

                                          ref
                                              .read(authProvider)
                                              .signOut()
                                              .whenComplete(() {
                                            setState(() {
                                              isUserLoggedIn = false;
                                            });
                                          });
                                          Navigator.pop(context);
                                          print("$isUserLoggedIn -3");
                                        },
                                        child: const Text("Çıkış yap"))
                                  ],
                                );
                              },
                            );
                          },
                          icon: const Icon(
                            Icons.exit_to_app_sharp,
                            size: 25,
                          ))
                      : const SizedBox.shrink()
                ],
                backgroundColor: const Color.fromRGBO(195, 129, 84, 1)),
            body: Center(
              child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      isUserLoggedIn == false
                          ? AnimatedButton(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AuthView(
                                          formStatusData: FormStatus.signIn),
                                    ));
                              },
                              text: "Giriş Yap",
                              widthSize: 250,
                              backgroundColor:
                                  const Color.fromRGBO(136, 74, 57, 1))
                          : const SizedBox.shrink(),
                      const SizedBox(
                        height: 5,
                      ),
                      isUserLoggedIn == false
                          ? AnimatedButton(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AuthView(
                                          formStatusData: FormStatus.register),
                                    ));
                              },
                              text: "Üye Ol",
                              widthSize: 250,
                              backgroundColor:
                                  const Color.fromRGBO(204, 149, 68, 1))
                          : const SizedBox.shrink()
                    ],
                  )),
            )));
  }
}
