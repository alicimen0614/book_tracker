import 'package:book_tracker/models/bookswork_editions_model.dart';
import 'package:book_tracker/providers/riverpod_management.dart';
import 'package:book_tracker/screens/user_screen/alert_for_data_source.dart';
import 'package:book_tracker/services/internet_connection_service.dart';
import 'package:book_tracker/widgets/internet_connection_error_dialog.dart';
import 'package:book_tracker/widgets/progress_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth_screen/auth_view.dart';

class UserScreenView extends ConsumerStatefulWidget {
  const UserScreenView({super.key});

  @override
  ConsumerState<UserScreenView> createState() => _UserScreenViewState();
}

class _UserScreenViewState extends ConsumerState<UserScreenView> {
  String contactMail = "cimensoft@gmail.com";
  List<BookWorkEditionsModelEntries>? listOfBooksFromSql = [];
  List<BookWorkEditionsModelEntries>? listOfBooksFromFirebase = [];
  bool isConnected = false;

  late bool isUserLoggedIn =
      ref.read(authProvider).currentUser != null ? true : false;

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
        return Icon(
          Icons.account_circle_sharp,
          size: size,
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
    print("yenilendi");
    print("$isUserLoggedIn -1");

    return Scaffold(
        body: Center(
      child: Column(
        children: [
          Container(
            height: 280,
            width: double.infinity,
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
                  Spacer(),
                  Expanded(flex: 2, child: getUserProfileImage(ref, 140)),
                  Expanded(flex: 1, child: getUserName(ref)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(children: [
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                tileColor: Colors.white,
                title: Text("Kitapları yedekle veya senkronize et"),
                onTap: () async {
                  isConnected = await checkForInternetConnection();
                  if (ref.read(authProvider).currentUser == null) {
                    ScaffoldMessenger.of(context).clearSnackBars;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text(
                          'Kitaplarınızı yedeklemek için giriş yapmalısınız.'),
                      action: SnackBarAction(label: 'Tamam', onPressed: () {}),
                      behavior: SnackBarBehavior.floating,
                    ));
                  } else if (isConnected == false) {
                    internetConnectionErrorDialog(context, false);
                  } else {
                    await getBooks();
                    //returning a bool data from progressdialog if there is a change made or not.
                    bool? didChangeMade = await showDialog(
                        barrierDismissible: true,
                        context: context,
                        builder: (BuildContext context) {
                          return ProgressDialog(
                              listOfBooksFromFirestore:
                                  listOfBooksFromFirebase!,
                              listOfBooksFromSql: listOfBooksFromSql!);
                        });
                    if (didChangeMade == false) {
                      ScaffoldMessenger.of(context).clearSnackBars;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text('Şu anda güncelsiniz!'),
                        action:
                            SnackBarAction(label: 'Tamam', onPressed: () {}),
                        behavior: SnackBarBehavior.floating,
                      ));
                    }
                  }
                },
              ),
              Divider(
                endIndent: 10,
                indent: 10,
              ),
              ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  tileColor: Colors.white,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Bize ulaşın"),
                      Text(
                        "cimensoft@gmail.com",
                        style: TextStyle(fontSize: 12),
                      )
                    ],
                  ),
                  onLongPress: () {
                    Clipboard.setData(ClipboardData(text: contactMail))
                        .then((value) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: Duration(seconds: 2),
                        content: const Text('E-posta adresi kopyalandı.'),
                        action:
                            SnackBarAction(label: 'Tamam', onPressed: () {}),
                        behavior: SnackBarBehavior.floating,
                      ));
                    });
                  }),
              Divider(
                endIndent: 10,
                indent: 10,
              ),
              ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  onTap: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AlertForDataSource()));
                  },
                  title: Text("Uygulama veri kaynağı ve sorumluluk bildirimi"),
                  tileColor: Colors.white),
              if (isUserLoggedIn == false)
                Divider(
                  endIndent: 10,
                  indent: 10,
                ),
              isUserLoggedIn == false
                  ? ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AuthView(formStatusData: FormStatus.signIn),
                            ));
                      },
                      title: Text("Giriş Yap"),
                      tileColor: Colors.white)
                  : SizedBox.shrink(),
              if (isUserLoggedIn == false)
                Divider(
                  endIndent: 10,
                  indent: 10,
                ),
              isUserLoggedIn == false
                  ? ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AuthView(formStatusData: FormStatus.register),
                            ));
                      },
                      title: Text("Üye Ol"),
                      tileColor: Colors.white)
                  : const SizedBox.shrink(),
              if (isUserLoggedIn == true)
                Divider(
                  endIndent: 10,
                  indent: 10,
                ),
              isUserLoggedIn == true
                  ? ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      onTap: () async {
                        await alertDialogBuilder(context);
                      },
                      title: Text("Çıkış Yap"),
                      tileColor: Colors.white)
                  : const SizedBox.shrink()
            ]),
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

  Future<void> getBooks() async {
    isConnected = await checkForInternetConnection();
    if (isConnected == true && ref.read(authProvider).currentUser != null) {
      var data = await ref.read(firestoreProvider).getBooks(
          "usersBooks", ref.read(authProvider).currentUser!.uid, context);
      if (data != null) {
        listOfBooksFromFirebase = data.docs
            .map(
              (e) => BookWorkEditionsModelEntries.fromJson(e.data()),
            )
            .toList();
      }
    }
    listOfBooksFromSql = await ref.read(sqlProvider).getBookShelf(context);
  }
}
