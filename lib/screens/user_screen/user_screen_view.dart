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
import 'package:google_mobile_ads/google_mobile_ads.dart';

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
  InterstitialAd? _interstitialAd;
  bool isInterstitialAdReady = false;
  String userName = "";
  String userProfilePicture = "";
  bool isLoading = false;

  late bool isUserLoggedIn =
      ref.read(authProvider).currentUser != null ? true : false;

  User? getCurrentUser(WidgetRef ref) {
    return ref.read(authProvider).currentUser;
  }

  Widget getUserProfileImage(
    WidgetRef ref,
    double size,
  ) {
    if (ref.watch(authProvider).currentUser == null) {
      return Icon(
        Icons.account_circle_sharp,
        size: size,
        color: Colors.white,
      );
    } else {
      if (FirebaseAuth.instance.currentUser != null &&
          FirebaseAuth.instance.currentUser!.photoURL != null) {
        return ClipOval(
          child: CachedNetworkImage(
            fit: BoxFit.cover,
            imageUrl: FirebaseAuth.instance.currentUser!.photoURL!,
            placeholder: (context, url) => const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [CircularProgressIndicator()]),
            errorWidget: (context, url, error) => const Icon(Icons.circle),
          ),
        );
      } else if (getCurrentUser(ref)!.photoURL != null) {
        return ClipOval(
          child: CachedNetworkImage(
            fit: BoxFit.cover,
            imageUrl: getCurrentUser(ref)!.photoURL!,
            placeholder: (context, url) => const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [CircularProgressIndicator()]),
            errorWidget: (context, url, error) => const Icon(Icons.circle),
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
    if (isLoading = true && getCurrentUser(ref)!.displayName != null) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          getCurrentUser(ref)!.displayName!,
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.of(context).size.height / 30),
        ),
      );
    } else if (isLoading == true && getCurrentUser(ref)!.displayName == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (isLoading == false && userName != "") {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          userName,
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.of(context).size.height / 30),
        ),
      );
    } else {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          "Ziyaretçi",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.of(context).size.height / 30),
        ),
      );
    }
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(100),
                      bottomRight: Radius.circular(100)),
                  color: Theme.of(context).primaryColor),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 25, 15, 15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Spacer(),
                    Expanded(
                        flex: 2,
                        child: getUserProfileImage(
                          ref,
                          130,
                        )),
                    Expanded(
                        flex: 1,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            FirebaseAuth.instance.currentUser != null &&
                                    FirebaseAuth.instance.currentUser!
                                            .displayName !=
                                        null
                                ? FirebaseAuth
                                    .instance.currentUser!.displayName!
                                : "Ziyaretçi",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.height / 30),
                          ),
                        )),
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
                  title: const FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: Text("Kitapları yedekle veya senkronize et")),
                  onTap: () async {
                    isConnected = await checkForInternetConnection();
                    if (ref.read(authProvider).currentUser == null) {
                      ScaffoldMessenger.of(context).clearSnackBars;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text(
                            'Kitaplarınızı yedeklemek için giriş yapmalısınız.'),
                        action:
                            SnackBarAction(label: 'Tamam', onPressed: () {}),
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
                const Divider(
                  endIndent: 10,
                  indent: 10,
                  height: 20,
                ),
                ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    onTap: () async {
                      await _createInterstitialAd();
                    },
                    title: const FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Text("Reklam izleyerek destekle",
                            textAlign: TextAlign.start)),
                    tileColor: Colors.white),
                const Divider(
                  endIndent: 10,
                  indent: 10,
                  height: 20,
                ),
                ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    tileColor: Colors.white,
                    title: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "Bize ulaşın",
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "cimensoft@gmail.com",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      ],
                    ),
                    onLongPress: () {
                      Clipboard.setData(ClipboardData(text: contactMail))
                          .then((value) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: const Duration(seconds: 2),
                          content: const Text('E-posta adresi kopyalandı.'),
                          action:
                              SnackBarAction(label: 'Tamam', onPressed: () {}),
                          behavior: SnackBarBehavior.floating,
                        ));
                      });
                    }),
                const Divider(
                  endIndent: 10,
                  indent: 10,
                  height: 20,
                ),
                ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    onTap: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const AlertForDataSource()));
                    },
                    title: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Uygulama veri kaynağı ve sorumluluk bildirimi",
                      ),
                    ),
                    tileColor: Colors.white),
                if (isUserLoggedIn == false)
                  const Divider(
                    endIndent: 10,
                    indent: 10,
                    height: 20,
                  ),
                isUserLoggedIn == false
                    ? ListTile(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AuthView(
                                    formStatusData: FormStatus.signIn),
                              ));
                        },
                        title: const FittedBox(
                            alignment: Alignment.centerLeft,
                            fit: BoxFit.scaleDown,
                            child:
                                Text("Giriş Yap", textAlign: TextAlign.start)),
                        tileColor: Colors.white)
                    : const SizedBox.shrink(),
                if (isUserLoggedIn == false)
                  const Divider(
                    endIndent: 10,
                    indent: 10,
                    height: 20,
                  ),
                isUserLoggedIn == false
                    ? ListTile(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AuthView(
                                    formStatusData: FormStatus.register),
                              ));
                        },
                        title: const FittedBox(
                            alignment: Alignment.centerLeft,
                            fit: BoxFit.scaleDown,
                            child: Text("Üye Ol")),
                        tileColor: Colors.white)
                    : const SizedBox.shrink(),
                if (isUserLoggedIn == true)
                  const Divider(
                    endIndent: 10,
                    indent: 10,
                    height: 20,
                  ),
                isUserLoggedIn == true
                    ? ListTile(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        onTap: () async {
                          await alertDialogBuilder(context);
                        },
                        title: const FittedBox(
                            alignment: Alignment.centerLeft,
                            fit: BoxFit.scaleDown,
                            child: Text("Çıkış Yap")),
                        tileColor: Colors.white)
                    : const SizedBox.shrink()
              ]),
            ),
          ],
        ),
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
                  ref.read(authProvider).signOut(context).whenComplete(() {
                    setState(() {
                      isUserLoggedIn = false;
                    });
                  });
                  Navigator.pop(context);
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
            "usersBooks",
            ref.read(authProvider).currentUser!.uid,
          );
      if (data != null) {
        listOfBooksFromFirebase = data.docs
            .map(
              (e) => BookWorkEditionsModelEntries.fromJson(e.data()),
            )
            .toList();
      }
    }
    listOfBooksFromSql = await ref.read(sqlProvider).getBookShelf();
  }

  Future<void> _createInterstitialAd() async {
    print("create çalıştı");

    await InterstitialAd.load(
        adUnitId: "ca-app-pub-1939809254312142/7806936586",
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            setState(() {
              _interstitialAd = ad;
              print(ad);

              isInterstitialAdReady = true;
            });
            _showInterstitialAd();
          },
          onAdFailedToLoad: (error) {
            isInterstitialAdReady = false;
          },
        ));
    print(isInterstitialAdReady);
  }

  void _showInterstitialAd() {
    print("show çalıştı");
    print(isInterstitialAdReady);
    if (isInterstitialAdReady) {
      _interstitialAd!.show();
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) async {
          ad.dispose();
        },
        onAdFailedToShowFullScreenContent: (ad, error) async {
          ad.dispose();
        },
      );
    }
  }
}
