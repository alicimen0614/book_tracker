import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/widgets/animated_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth_screen/auth_view.dart';

class UserScreenView extends ConsumerStatefulWidget {
  const UserScreenView({super.key});

  @override
  ConsumerState<UserScreenView> createState() => _UserScreenViewState();
}

class _UserScreenViewState extends ConsumerState<UserScreenView>
    with AutomaticKeepAliveClientMixin<UserScreenView> {
  late bool isUserLoggedIn =
      ref.read(authProvider).currentUser != null ? true : false;
  @override
  bool get wantKeepAlive => true;

  User? getCurrentUser(WidgetRef ref) {
    return ref.read(authProvider).currentUser;
  }

  Stream<User?> authState(WidgetRef ref) {
    return ref.watch(authProvider).authState;
  }

  Widget getUserProfileImage(WidgetRef ref, double size) {
    if (ref.watch(authProvider).currentUser == null) {
      return Icon(
        Icons.account_circle_sharp,
        size: size,
        color: Colors.white,
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

  Widget getUserName(WidgetRef ref) {
    if (getCurrentUser(ref) == null) {
      return const Text(
        "Ziyaretçi",
        style: TextStyle(
            fontSize: 35, color: Colors.white, fontWeight: FontWeight.bold),
      );
    } else {
      if (getCurrentUser(ref)!.displayName == null) {
        return const Text(
          "Ziyaretçi",
          style: TextStyle(
              fontSize: 35, color: Colors.white, fontWeight: FontWeight.bold),
        );
      } else {
        return Text(
          getCurrentUser(ref)!.displayName!,
          style: TextStyle(
              fontSize: 35, color: Colors.white, fontWeight: FontWeight.bold),
        );
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    super.build(context);
    print("yenilendi");
    print("$isUserLoggedIn -1");

    return Scaffold(
        body: Center(
      child: Column(
        children: [
          Container(
            height: 330,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(100),
                    bottomRight: Radius.circular(100)),
                color: Theme.of(context).primaryColor),
            child: Padding(
              padding: EdgeInsets.fromLTRB(15, 25, 15, 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isUserLoggedIn == true)
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                          color: Colors.white,
                          onPressed: () async {
                            alertDialogBuilder(context);
                          },
                          icon: const Icon(
                            Icons.exit_to_app_sharp,
                            size: 25,
                          )),
                    ),
                  if (isUserLoggedIn == false)
                    SizedBox(
                      height: 20,
                    ),
                  if (isUserLoggedIn == false) getUserProfileImage(ref, 150),
                  if (isUserLoggedIn == false) getUserName(ref),
                  if (isUserLoggedIn == false)
                    SizedBox(
                      height: 20,
                    ),
                  if (isUserLoggedIn == false)
                    AnimatedButton(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AuthView(formStatusData: FormStatus.signIn),
                              ));
                        },
                        text: "Giriş Yap",
                        widthSize: 250,
                        backgroundColor: const Color.fromRGBO(136, 74, 57, 1))
                  else
                    Column(children: [
                      getUserProfileImage(ref, 150),
                      SizedBox(
                        height: 10,
                      ),
                      getUserName(ref)
                    ]),
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
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Future<dynamic> alertDialogBuilder(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("BookTracker"),
          content: const Text("Çıkış yapmak istediğinizden emin misiniz?"),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Vazgeç")),
            TextButton(
                onPressed: () {
                  print("$isUserLoggedIn -2");

                  ref.read(authProvider).signOut(context).whenComplete(() {
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
  }
}
